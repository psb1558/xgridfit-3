from fontTools import ttLib
from fontTools import subset
from fontTools.ttLib import ttFont, tables, newTable, TTFont
from fontTools.ttLib.tables.TupleVariation import TupleVariation
from fontTools.ufoLib.filenames import userNameToFileName
from fontTools.pens.hashPointPen import HashPointPen
from lxml import etree
from ast import literal_eval
try:
    from .version import __version__
except ImportError:
    from version import __version__
try:
    from .ygridfit import ygridfit_parse, ygridfit_parse_obj
except ImportError:
    from ygridfit import ygridfit_parse, ygridfit_parse_obj
from .xgfUFOWriter import xgfUFOWriter
from tempfile import SpooledTemporaryFile
import sys
import os
import argparse
import array
import re
import pkg_resources
import unicodedata

#      This file is part of xgridfit, version 3.
#      Licensed under the Apache License, Version 2.0.
#      Copyright (c) 2006-20 by Peter S. Baker

neutral_instructions = [ 'IUP', 'RDTG', 'ROFF', 'RTDG', 'RTG', 'RTHG', 'RUTG',
                         'SFVTCA', 'SFVTPV', 'SPVTCA', 'SVTCA', 'FLIPOFF',
                         'FLIPON' ]

# How many numbers popped by each instruction (-1 means a variable number)

pop_instructions = { 'ALIGNPTS': 2, 'ALIGNRP': -1, 'IP': -1,   'MDAP': 1,
                     'MIAP': 2,     'MIRP': 2,     'MDRP': 1,  'SHP': -1,  'SLOOP': 1,
                     'SRP0': 1,     'SRP1': 1,     'SRP2': 1,  'CALL': 1,  'SFVTL': 2,
                     'SPVTL': 2,    'SDPVTL': 2,   'ISECT': 5, 'MSIRP': 2, 'SCFS': 2,
                     'SCVTCI': 1,   'SFVFS': 2,    'SHC': 1,   'SHZ': 1,   'SMD': 1,
                     'SPVFS': 2,    'SROUND': 1,   'SSW': 1,   'SSWCI': 1, 'SZP0': 1,
                     'SZP1': 1,     'SZP2': 1,     'SZPS': 1,  'UTP': 1,   'WCVTF': 2,
                     'WCVTP': 2,    'WS': 2 }

byte_push_instructions = [ 'PUSHB', 'NPUSHB' ]

maxInstructions = 200

quietcount = 0

coordinateFuzz = 1

ufo_mode = False

class xgfGlyphObject:
    def __init__(self):
        self.lib = None

def get_file_path(fn):
    return pkg_resources.resource_filename(__name__, fn)

def wipe_font(fo):
    """Delete all TrueType programming in the font."""
    for g_name in fo['glyf'].glyphs:
        glyph = fo['glyf'][g_name]
        try:
            glyph.program.fromAssembly("")
        except Exception:
            pass
    try:
        del fo['prep']
    except Exception:
        pass
    try:
        del fo['fpgm']
    except Exception:
        pass
    try:
        del fo['cvt ']
    except Exception:
        pass

def wipe_font_ufo(ufo):
    pass

def install_glyph_program(nm, fo, asm):
    """ name of the glyph, the font object, the instructions in one big string."""
    try:
        global maxInstructions
        g = fo['glyf'][nm]
        g.program = tables.ttProgram.Program()
        g.program.fromAssembly(asm)
        b = len(g.program.getBytecode())
        if b > maxInstructions:
            maxInstructions = b
    except KeyError:
        print("Unable to install glyph '" + nm + "'. Make sure the glyph's")
        print("name is correct and that it exists in the font.")
        sys.exit(1)

def install_glyph_program_ufo(uw, gnm, asm, hash):
    try:
        global maxInstructions
        p = tables.ttProgram.Program()
        p.fromAssembly(asm)
        b = len(p.getBytecode())
        if b > maxInstructions:
            maxInstructions = b
        uw.install_glyph_program(gnm, hash, asm)
        #glyph = ufo[nm]
        #if not "public.truetype.instructions" in glyph.lib:
        #    glyph.lib["public.truetype.instructions"] = {}
        #glyph.lib["public.truetype.instructions"]["formatVersion"] = "1"
        #glyph.lib["public.truetype.instructions"]["assembly"] = str(asm)
    except Exception as e:
        print("error in install_glyph_program_ufo:")
        print(e.args)
        print(e)

def is_number(s):
    try:
        int(s)
        return True
    except ValueError:
        return False

def output_current_push(ilist, plist):
    """Inserts the collected PUSH instruction into the instruction stream.
    A helper for compact_instructions()."""
    push_command = "PUSHB[ ]"
    if len(plist) > 8:
        push_command = "NPUSHB[ ]"
    idx = ilist.index("pushmarker")
    ilist[idx] = push_command
    idx += 1
    plist.reverse()
    ilist[idx:idx] = plist
    return ilist

def list_to_string(ilist):
    """ Takes a list of instructions and combines them into a single string.
    This is a helper for compact_instructions()."""
    str = ""
    for s in ilist:
        if len(str) > 0:
            str += "\n"
        str += s
    return str

def compact_instructions(inst, sc):
    """ Takes a series of TT instructions with PUSH instructions
    scattered through it and consolidates the PUSHes into one PUSH
    at the top. It fails if activity on the stack looks too
    complicated; in that case it simply returns the original
    string. """
    # return inst
    input_list = inst.splitlines()
    push_store = []
    ordered_push_list = []
    push_initialized = False
    loop_counter = 1
    last_num = 'x'
    instruction_list = []
    for current_line in input_list:
        current_line = current_line.strip(" \n")
        if is_number(current_line):
            if push_initialized:
                last_num = current_line
                push_store.append(current_line)
            else:
                return inst
        else:
            this_instruction = current_line.split("[")[0]
            if this_instruction in byte_push_instructions:
                if not push_initialized:
                    push_initialized = True
                    instruction_list.append("pushmarker")
            elif this_instruction in pop_instructions:
                if this_instruction == 'SLOOP':
                    loop_counter = int(last_num)
                    ordered_push_list.append(push_store.pop())
                elif this_instruction == 'CALL':
                    ti = int(push_store[-1])
                    if ti in sc: # check if in safe_calls list
                        iloop = sc[ti]
                        while iloop > 0:
                            ordered_push_list.append(push_store.pop())
                            iloop -= 1
                    else:
                        return inst
                elif pop_instructions[this_instruction] == -1:
                    while loop_counter > 0:
                        ordered_push_list.append(push_store.pop())
                        loop_counter -= 1
                    loop_counter = 1
                else:
                    iloop = pop_instructions[this_instruction]
                    while iloop > 0:
                        ordered_push_list.append(push_store.pop())
                        iloop -= 1
                instruction_list.append(current_line)
            elif this_instruction in neutral_instructions:
                instruction_list.append(current_line)
            else:
                return inst
    if len(push_store) > 0:
        return inst
    if len(ordered_push_list) > 0:
        output_current_push(instruction_list,ordered_push_list)
    else:
        return inst
    return(list_to_string(instruction_list))

def install_cvt(fo, cvs, base):
    """If base is greater than zero, we append CVs to an existing CVT table. If
    not, we generate a new table."""
    if base > 0:
        assert base == len(fo['cvt '].values)
        for c in cvs:
            fo['cvt '].values.append(c)
    else:
        fo['cvt '] = ttFont.newTable('cvt ')
        setattr(fo['cvt '],'values',array.array('h', cvs))

def install_cvt_ufo(uw, ufo_lib_tree, cvs, base):
    #cvt_dict = {}
    #if base > 0:
    #    cvt_index = base
    #    try:
    #        old_cvt_dict = ufo.lib["public.truetype.instructions"]["controlValue"]
    #    except Exception:
    #        old_cvt_dict = {}
    #else:
    #    cvt_index = 0
    #for c in cvs:
    #    cvt_dict[str(cvt_index)] = c
    #    cvt_index += 1
    #if base > 0:
    #    cvt_dict.update(old_cvt_dict)
    uw.install_cvt(ufo_lib_tree, cvs)
    #if base == 0 or not "public.truetype.instructions" in ufo.lib:
    #    ufo.lib["public.truetype.instructions"] = {}
    #ufo.lib["public.truetype.instructions"]["formatVersion"] = "1"
    #ufo.lib["public.truetype.instructions"]["controlValue"] = cvt_dict

def install_functions(fo, fns, base):
    """If base greater than zero, we append our own functions to those already
    in the font. If not, generate a new fpgm table."""
    if base > 0:
        oldfpgm = "\n".join(fo['fpgm'].program.getAssembly())
        newfpgm = oldfpgm + "\n" + str(fns)
        fo['fpgm'].program.fromAssembly(newfpgm)
        fo['fpgm'].program.getBytecode()
    else:
        fo['fpgm'] = ttFont.newTable('fpgm')
        fo['fpgm'].program = tables.ttProgram.Program()
        fo['fpgm'].program.fromAssembly(str(fns))

def install_functions_ufo(uw, ufo_lib_tree, fns, base):
    #oldfpgm = ""
    #if base > 0:
    #    try:
    #        oldfpgm = "\n".join(ufo.lib["public.truetype.instructions"]["fontProgram"])
    #    except Exception as e:
    #        print("error in install_functions_ufo:")
    #        print(e.args)
    #        print(e)
    #        pass
    #newfpgm = oldfpgm + str(fns)
    uw.install_lib_item(ufo_lib_tree, "fontProgram", fns)
    #if not "public.truetype.instructions" in ufo.lib:
    #    ufo.lib["public.truetype.instructions"] = {}
    #ufo.lib["public.truetype.instructions"]["formatVersion"] = "1"
    #ufo.lib["public.truetype.instructions"]["fontProgram"] = newfpgm


def install_prep(fo, pr, keepold, replace):
    """If keepold is True, we append our own prep table to the existing one.
    It is up to the Xgridfit programmer to make sure that no conflicts arise
    (though if there's a duplication--for example, instructions being disabled
    at a different ppem in the new code than in the old, the new code will
    take precedence.)"""
    if keepold and not replace:
        oldprep = "\n".join(fo['prep'].program.getAssembly())
        newprep = oldprep + "\n" + str(pr)
        fo['prep'].program.fromAssembly(newprep)
    else:
        fo['prep'] = ttFont.newTable('prep')
        fo['prep'].program = tables.ttProgram.Program()
        fo['prep'].program.fromAssembly(str(pr))

def install_prep_ufo(uw, ufo_lib_tree, pr, keepold, replace):
    #oldprep = ""
    #if keepold and not replace:
    #    try:
    #        oldprep = "\n".join(ufo.lib["public.truetype.instructions"]["controlValueProgram"])
    #    except Exception as e:
    #        print("error in install_prep_ufo:")
    #        print(e.args)
    #        print(e)
    #        # pass
    #newprep = oldprep + str(pr)
    uw.install_lib_item(ufo_lib_tree, "controlValueProgram", pr)
    #if not "public.truetype.instructions" in ufo.lib:
    #    ufo.lib["public.truetype.instructions"] = {}
    #ufo.lib["public.truetype.instructions"]["formatVersion"] = "1"
    #ufo.lib["public.truetype.instructions"]["controlValueProgram"] = newprep

def install_properties_ufo(uw, ufo_lib_tree, d):
    # keys can be:
    # maxFunctionDefs: int
    # maxInstructionDefs: int
    # maxStackElements: int
    # maxStorage: int
    # maxSizeOfInstructions: int
    # maxTwilightPoints: int
    # maxZones: int
    #if not "public.truetype.instructions" in ufo.lib:
    #    ufo.lib["public.truetype.instructions"] = {}
    #ufo.lib["public.truetype.instructions"]["formatVersion"] = "1"
    k = d.keys()
    for kk in k:
        uw.install_lib_item(ufo_lib_tree, kk, d[kk])
        # ufo.lib["public.truetype.instructions"][kk] = d[kk]
    

# Compare two dictionaries. It would be easier to do an equality test, but
# I can't be sure two otherwise matching dictionaries aren't in a different
# order.

def _axes_match(dict1, dict2):
    try:
        assert len(dict1) == len(dict2)
    except:
        return False
    for dd in dict1.items():
        k,v = dd[0],dd[1]
        if not (k in dict2 and v==dict2[k]):
            return False
    for dd in dict2.items():
        k,v = dd[0],dd[1]
        if not (k in dict1 and v==dict1[k]):
            return False
    return True

def install_cvar(fo, cvarstore, keepold, cvtbase):
    """If keepold is True, we append our own cvar data to the existing
    TupleVariation objects. If False, generate our own cvar table. Since
    The old cvar may not exactly match the new one, there are contingencies:
    If a tuple is missing in the old or the new cvar, pad the new one
    and issue a warning. If there is no cvar at all in the existing font (this
    can easily happen with VTT or the non-VF version of ttfautohint), pad all
    our tuples and issue a warning. In
    such cases it may be a good idea to manually edit the cvar table."""
    cvtlen = len(fo['cvt '].values)
    if keepold:
        complications = False
        needoldfontpadding = False
        try:
            oldcvarstore = fo['cvar'].variations
        except:
            if quietcount < 2:
                print("Warning: No cvar table in existing font. Making a dummy table.")
            # Create a dummy cvar table to merge the new one into.
            complications = True
            cvardummy = []
            for cvst in cvarstore:
                cvardummy.append(TupleVariation(cvst[0], [None] * cvtlen))
            fo['cvar'] = ttFont.newTable('cvar')
            fo['cvar'].variations = cvardummy
            oldcvarstore = fo['cvar'].variations
        try:
            # When you fiddle the size of the cvt, fonttools helpfully
            # extends the cvar coordinate lists to match. But test to make
            # sure it has been done (as it doesn't seem to be documented).
            assert cvtlen == len(oldcvarstore[0].coordinates)
        except:
            print("Size of cvt does not match size of cvar.")
            print("Size of cvt:  " + str(cvtlen))
            print("Size of cvar: " + str(len(oldcvarstore[0].coordinates)))
            sys.exit(1)
        oldcoordlen = len(oldcvarstore[0].coordinates)
        newcoordlen = len(cvarstore[0][1])
        new_tuple_found = [0] * len(cvarstore)
        for oldc in oldcvarstore:
            try:
                newc = None
                new_tuple_counter = 0
                for tc in cvarstore:
                    # if oldc.axes == tc[0]:
                    if _axes_match(oldc.axes, tc[0]):
                        newc = tc
                        break
                    new_tuple_counter += 1
                if newc:
                    new_tuple_found[new_tuple_counter] = 1
                    newcoordinates = newc[1]
                    i = 0
                    for val in newcoordinates:
                        if val != None and val != 0:
                            oldc.coordinates[i + cvtbase] = val
                        i += 1
                else:
                    # we've failed to find a match for one of the TupleVariations
                    # in the existing font. We don't need to do anything (the
                    # table is okay), but we'll warn.
                    complications = True
            except Exception as err:
                print(err)
                print("Here are the regions in the existing font:")
                for tup in oldcvarstore:
                    print(str(tup.axes))
                sys.exit(1)
        # If there are new TupleVariations unaccounted for:
        tt_index = 0
        for tt in new_tuple_found:
            if tt == 0:
                # In the absence of an old coordinate list, we'll pad
                # the beginning of the new list.
                newcoordlist = [None] * cvtbase
                newcoordlist.extend(cvarstore[tt_index][1])
                thistuple = TupleVariation(cvarstore[tt_index][0], newcoordlist)
                oldcvarstore.append(thistuple)
                # fo['cvar'].variations.append(thistuple)
            tt_index += 1
            complications = True
        if complications and quietcount < 2:
            print("Warning: The cvar table in the existing font and the one")
            print("in the Xgridfit program were not a perfect match. I have")
            print("done my best to combine them, but you should check over it")
            print("and make changes if necessary. Here is the new cvar table:")
            print(fo['cvar'].variations)
    else:
        ts = []
        for s in cvarstore:
            ts.append(TupleVariation(s[0], s[1]))
        fo['cvar'] = ttFont.newTable('cvar')
        fo['cvar'].variations = ts

def make_coordinate_index(glist, fo):
    """ Make an index for lookup by coordinates. The key will look like:
        glyphname@123x456
     glyph list, the font object. 
    """
    coordinateIndex = {}
    bad_glyphs = []
    for gn in glist:
        try:
            currentGlyph = fo['glyf'][gn]
            if not currentGlyph.isComposite():
                c = currentGlyph.getCoordinates(fo['glyf'])
                pointIndex = 0
                for point in zip(c[0], c[2]):
                    if point[1] & 0x01 == 0x01:
                        pp = gn + "@" + str(point[0]).replace('(','').replace(')','').replace(',','x').replace(' ','')
                        coordinateIndex[pp] = pointIndex
                    pointIndex += 1
        except Exception as e:
            print("Error in glyph " + str(gn))
            print("Removing it from glyphs list")
            bad_glyphs.append(gn)
    if len(bad_glyphs) > 0:
        for gn in bad_glyphs:
            glist.remove(gn)
    return coordinateIndex, bad_glyphs

def make_reverse_coordinate_index(glist, fo):
    idx, bad = make_coordinate_index(glist, fo)[0]
    return {val: key for key, val in idx.items()}

def rewrite_point_string(original_point_string, coordinateIndex, coord_pattern, glyph_name,
                         xoffset, yoffset, crash=True):
    """ Determines whether original_point_string is a pair of coordinates for
        a point, and if so, looks up the point number in coordinateIndex. If
        not, simply returns the original value. In theory, this should leave
        simple expressions undisturbed, e.g. {125;10} + 4. """
    coord = coord_pattern.search(original_point_string)
    if coord:
        # Extract the coordinates (saving the rest); split them apart so that
        # offsets can be applied to them, then reassemble them as a key for the
        # coordinate list.
        matched_string = coord.group()
        split_string = coord_pattern.split(original_point_string)
        string_index = split_string.index(matched_string)
        raw_coord = matched_string.replace('{','').replace('}','').replace(' ','')
        coord_list = raw_coord.split(';')
        x_coord = int(coord_list[0]) + int(xoffset)
        y_coord = int(coord_list[1]) + int(yoffset)
        coord_id = glyph_name + '@' + str(x_coord) + 'x' + str(y_coord)

        # Try to look up the point number from coordinates. If that fails,
        # try to make a fuzzy match. If that fails, fall back on the val
        # attribute (if we've been evaluating the coord attribute). Failing
        # that, we crash.
        try:
            point_number = coordinateIndex[coord_id]
        except KeyError:
            point_number = coordinateFuzzyMatch(coord_id, coordinateIndex)
            try:
                int(point_number)
            except TypeError:
                if crash:
                    print("In glyph " + glyph_name + ", can't resolve coordinates " + matched_string)
                    # sys.exit(1)
                    return original_point_string, False
                else:
                    if quietcount < 2:
                        print("Can't resolve coordinate " + original_point_string + "; falling back to value")
                    # raise Exception("Can't resolve coordinate")
                    return original_point_string, False

        # Reassemble the expression.
        string_counter = 0
        substitute_string = ""
        for string_bit in split_string:
            if string_counter == string_index:
                substitute_string = substitute_string + str(point_number)
            else:
                substitute_string = substitute_string + string_bit
            string_counter += 1
        return substitute_string, True
    else:
        return original_point_string, True

def coordinateFuzzyMatch(coordID, coordinateIndex):
    # This is an extremely inefficient search, executed only if no match found
    # without it. Construct a box around the coordinate (default is 2x2), and
    # for each position in that box, construct a potential key for
    # coordinateIndex. If we find a match, we issue a warning and go on. If
    # not, return None and (probably) crash.
    splitCoordID = coordID.split('@')
    glyphID = splitCoordID[0]
    coordinates = splitCoordID[1].split('x')
    originalX = int(coordinates[0])
    originalY = int(coordinates[1])
    startX = originalX - coordinateFuzz
    endX = originalX + coordinateFuzz
    startY = originalY - coordinateFuzz
    endY = originalY + coordinateFuzz
    Xcounter = startX
    while Xcounter <= endX:
        Ycounter = startY
        while Ycounter <= endY:
            teststring = glyphID + '@' + str(Xcounter) + 'x' + str(Ycounter)
            try:
                ci = coordinateIndex[teststring]
                if quietcount < 2:
                    print("Warning: In glyph " + glyphID + ", point " + str(ci) + " found at coordinates " +
                          str(Xcounter) + "," + str(Ycounter) + " instead of " + str(originalX) + "," + str(originalY) + ".")
                return ci
            except KeyError:
                Ycounter += 1
        Xcounter += 1
    return None

def coordinates_to_points(glist, xgffile, coordinateIndex, ns):
    """ glyph list, xgf program, coordinate index, namespaces.
        surveys all the glyph programs in the file and changes coordinate
        pairs (e.g. {125;-3}) to point numbers. """
    bad_glyphs = []
    coord_pattern = re.compile(r'(\{[0-9\-]{1,4};[0-9\-]{1,4}\})')
    gPathString = "/xgf:xgridfit/xgf:glyph[@ps-name='{gnm}']"
    for gn in glist:
        good_val = True
        try:
            xoffset = xgffile.xpath(gPathString.format(gnm=gn), namespaces=ns)[0].attrib['xoffset']
        except (KeyError, IndexError):
            xoffset = "0"
        try:
            yoffset = xgffile.xpath(gPathString.format(gnm=gn), namespaces=ns)[0].attrib['yoffset']
        except (KeyError, IndexError):
            yoffset = "0"

        points = xgffile.xpath((gPathString + "/descendant::xgf:point").format(gnm=gn), namespaces=ns)
        for p in points:
            p.attrib['num'], good_val = rewrite_point_string(p.attrib['num'],
                                                             coordinateIndex,
                                                             coord_pattern,
                                                             gn,
                                                             xoffset,
                                                             yoffset)
        wparams = xgffile.xpath((gPathString + "/descendant::xgf:with-param").format(gnm=gn), namespaces=ns)
        for p in wparams:
            try:
                p.attrib['value'], good_val = rewrite_point_string(p.attrib['value'],
                                                                   coordinateIndex,
                                                                   coord_pattern,
                                                                   gn,
                                                                   xoffset,
                                                                   yoffset)
            except:
                pass

        params = xgffile.xpath((gPathString + "/descendant::xgf:param").format(gnm=gn), namespaces=ns)
        for p in params:
            p.attrib['value'], good_val = rewrite_point_string(p.attrib['value'],
                                                               coordinateIndex,
                                                               coord_pattern,
                                                               gn,
                                                               xoffset,
                                                               yoffset)

        constants = xgffile.xpath((gPathString + "/descendant::xgf:constant").format(gnm=gn), namespaces=ns)
        for c in constants:
            orig_value = c.attrib['value']
            try:
                orig_coord = c.attrib['coordinate']
                point_num, good_val = rewrite_point_string(orig_coord,
                                                           coordinateIndex,
                                                           coord_pattern,
                                                           gn,
                                                           xoffset,
                                                           yoffset,
                                                           False)
                if str(point_num) != orig_value:
                    if quietcount < 2:
                        print("Warning: In glyph '" + gn + "', changing value " + orig_value + " to " +
                              str(point_num) + " after coordinate " + orig_coord)
                    c.attrib['value'] = str(point_num)
            except:
                c.attrib['value'], good_val = rewrite_point_string(orig_value,
                                                                   coordinateIndex,
                                                                   coord_pattern,
                                                                   gn,
                                                                   xoffset,
                                                                   yoffset)
        if not good_val:
            bad_glyphs.append(gn)
    if len(bad_glyphs):
        for b in bad_glyphs:
            del glist[b]
    return bad_glyphs

def validate(f, syntax, noval):
    if noval and quietcount < 1:
        print("Skipping validation")
    else:
        schemadir = "Schemas/"
        schemafile = "xgridfit.rng"
        if syntax == "compact":
            schemafile = "xgridfit-sh.rng"
        schemapath = get_file_path(schemadir + schemafile)
        schema = etree.RelaxNG(etree.parse(schemapath))
        schema.assertValid(f)

def compile_list(font: ttFont, yaml: dict, gname: str) -> tuple:
    """
        Compile code either for a single glyph or a list of glyphs. This will
        generate a hinted font (as a SpooledTemporaryFile) with *only* those glyphs
        in it. It returns this open file, plus a name:gid dict and a list of
        glyphs that failed to compile.
    """
    # No output to console.
    failed_glyph_list = []
    global quietcount
    quietcount = 3
    if type(gname) is list:
        xgffile = ygridfit_parse_obj(yaml, glyph_list=gname)
    else:
        xgffile = ygridfit_parse_obj(yaml, single_glyph=gname)
    ns = {"xgf": "http://xgridfit.sourceforge.net/Xgridfit2",
          "xi": "http://www.w3.org/2001/XInclude",
          "xsl": "http://www.w3.org/1999/XSL/Transform"}
    thisFont = font
    wipe_font(thisFont)
    xslfile = etree.parse(get_file_path("XSL/xgridfit-ft.xsl"))
    etransform = etree.XSLT(xslfile)
    if type(gname) is str:
        glyph_list = [gname]
    else:
        glyph_list = gname
    coordinateIndex, bad = make_coordinate_index(glyph_list, thisFont)
    if len(bad):
        failed_glyph_list.extend(bad)
    bad = coordinates_to_points(glyph_list, xgffile, coordinateIndex, ns)
    if len(bad):
        failed_glyph_list.extend(bad)
    safe_calls = etransform(xgffile, **{"stack-safe-list": "'yes'"})
    safe_calls = literal_eval(str(safe_calls))
    cvt_list = str(etransform(xgffile, **{"get-cvt-list": "'yes'"}))
    cvt_list = literal_eval("[" + cvt_list + "]")
    install_cvt(thisFont, cvt_list, 0)
    cvar_count = len(xgffile.xpath("/xgf:xgridfit/xgf:cvar", namespaces=ns))
    if cvar_count > 0:
        tuple_store = literal_eval(str(etransform(xgffile, **{"get-cvar": "'yes'"})))
        install_cvar(thisFont, tuple_store, False, 0)
    predef_functions = int(xslfile.xpath("/xsl:stylesheet/xsl:variable[@name='predefined-functions']",
                                         namespaces=ns)[0].attrib['select'])
    maxFunction = etransform(xgffile, **{"function-count": "'yes'"})
    maxFunction = int(maxFunction) + predef_functions
    thisFont['maxp'].maxSizeOfInstructions = maxInstructions + 50
    thisFont['maxp'].maxTwilightPoints = 25
    thisFont['maxp'].maxStorage = 64
    thisFont['maxp'].maxStackElements = 256
    thisFont['maxp'].maxFunctionDefs = maxFunction
    thisFont['head'].flags |= 0b0000000000001000
    fpgm_code = etransform(xgffile, **{"fpgm-only": "'yes'"})
    install_functions(thisFont, fpgm_code, 0)
    prep_code = etransform(xgffile, **{"prep-only": "'yes'"})
    install_prep(thisFont, prep_code, False, True)
    for g in glyph_list:
        try:
            gt = "'" + g + "'"
            glyph_args = {'singleGlyphId': gt}
            #if initgraphics:
            #    glyph_args['init_graphics'] = "'" + initgraphics + "'"
            g_inst = etransform(xgffile, **glyph_args)
            # g_inst_final = compact_instructions(str(g_inst), safe_calls)
            # install_glyph_program(g, thisFont, g_inst_final)
            # g_inst_final = str(g_inst)
            # install_glyph_program(g, thisFont, g_inst_final)
            install_glyph_program(g, thisFont, str(g_inst))
        except Exception as e:
            print(e)
            for entry in etransform.error_log:
                if quietcount < 3:
                    print('message from line %s, col %s: %s' % (entry.line, entry.column, entry.message))
            failed_glyph_list.append(g)
    try:
        # Grab the font, subset it with just the one glyph we're
        # previewing, and write it to a spooled temporary file.
        tf = SpooledTemporaryFile(max_size=1000000, mode='b')
        options = subset.Options(glyph_names=True)
        options.layout_features = ["*"]
        subsetter = subset.Subsetter(options)
        subsetter.populate(glyphs=glyph_list)
        subsetter.subset(thisFont)
        glyph_id = {}
        for g in glyph_list:
            glyph_id[g] = thisFont.getGlyphID(g)
        # temp diagnostic:
        # thisFont.save("temp_font.ttf", 1)
        thisFont.save(tf, 1)
        tf.seek(0)
    except Exception as e:
        print(e)
    # Return: a handle to the temp file, the index of the target glyph, a list of
    # glyphs for which complilation failed
    return tf, glyph_id, failed_glyph_list

def compile_all(font: ttFont, yaml: dict, new_file_name: str) -> list:
    global ufo_mode
    failed_glyph_list = []
    xgffile = ygridfit_parse_obj(yaml)
    ns = {"xgf": "http://xgridfit.sourceforge.net/Xgridfit2",
          "xi": "http://www.w3.org/2001/XInclude",
          "xsl": "http://www.w3.org/1999/XSL/Transform"}
    split_fn = os.path.splitext(new_file_name)
    extension = split_fn[1]
    ufo_mode = (extension == ".ufo")
    thisFont = font
    functionBase = 0     # Offset to account for functions in existing font
    cvtBase      = 0     # Offset to account for CVs in existing font
    storageBase  = 0     # Offset to account for storage in existing font
    maxStack     = 256   # Our (generous) default stack size
    twilightBase = 0     # Offset to account for twilight space in existing font
    wipe_font(thisFont)
    xslfile = etree.parse(get_file_path("XSL/xgridfit-ft.xsl"))
    etransform = etree.XSLT(xslfile)
    glyph_list = str(etransform(xgffile, **{"get-glyph-list": "'yes'"}))
    glyph_list = list(glyph_list.split(" "))
    coordinateIndex, bad = make_coordinate_index(glyph_list, thisFont)
    if len(bad) > 0:
        failed_glyph_list.extend(bad)
    bad = coordinates_to_points(glyph_list, xgffile, coordinateIndex, ns)
    if len(bad) > 0:
        failed_glyph_list.extend(bad)
    safe_calls = etransform(xgffile, **{"stack-safe-list": "'yes'"})
    safe_calls = literal_eval(str(safe_calls))
    cvt_list = str(etransform(xgffile, **{"get-cvt-list": "'yes'"}))
    cvt_list = literal_eval("[" + cvt_list + "]")
    uw = None
    if ufo_mode:
        uw = xgfUFOWriter(new_file_name)
    ufo_lib_tree = None
    if ufo_mode:
        ufo_lib_tree = uw.open_lib()
        uw.install_cvt(ufo_lib_tree, cvt_list)
        # install_cvt_ufo(uw, ufo_lib_tree, cvt_list, cvtBase)
    else:
        install_cvt(thisFont, cvt_list, cvtBase)

    cvar_count = len(xgffile.xpath("/xgf:xgridfit/xgf:cvar", namespaces=ns))
    if cvar_count > 0 and not ufo_mode:
        tuple_store = literal_eval(str(etransform(xgffile, **{"get-cvar": "'yes'"})))
        install_cvar(thisFont, tuple_store, False, cvtBase)
    predef_functions = int(xslfile.xpath("/xsl:stylesheet/xsl:variable[@name='predefined-functions']",
                                         namespaces=ns)[0].attrib['select'])
    maxFunction = etransform(xgffile, **{"function-count": "'yes'"})
    maxFunction = int(maxFunction) + predef_functions + functionBase
    fpgm_code = etransform(xgffile, **{"fpgm-only": "'yes'"})
    if ufo_mode:
        install_functions_ufo(uw, ufo_lib_tree, fpgm_code, functionBase)
    else:
        install_functions(thisFont, fpgm_code, functionBase)
    prep_code = etransform(xgffile, **{"prep-only": "'yes'"})
    if ufo_mode:
        install_prep_ufo(uw, ufo_lib_tree, prep_code, False, True)
    else:
        install_prep(thisFont, prep_code, False, True)
    for g in glyph_list:
        try:
            gt = "'" + g + "'"
            glyph_args = {'singleGlyphId': gt}
            #if initgraphics:
            #    glyph_args['init_graphics'] = "'" + initgraphics + "'"
            g_inst = etransform(xgffile, **glyph_args)
            g_inst_final = compact_instructions(str(g_inst), safe_calls)
            if ufo_mode:
                ttglyph = thisFont['glyf'][g]
                ttwidth = thisFont["hmtx"][g][0]
                hash_pen = HashPointPen(ttwidth, thisFont.getGlyphSet())
                ttglyph.drawPoints(hash_pen, thisFont["glyf"])
                install_glyph_program_ufo(uw, g, g_inst_final, hash_pen.hash)
            else:
                install_glyph_program(g, thisFont, g_inst_final)
        except Exception as e:
            print("error in compile_all:")
            print(e.args)
            print(e)
            for entry in etransform.error_log:
                if quietcount < 3:
                    print('message from line %s, col %s: %s' % (entry.line, entry.column, entry.message))
            # sys.exit(1)
            failed_glyph_list.append(g)
    try:
        if ufo_mode:
            d = {"maxSizeOfInstructions": maxInstructions + 50,
                 "maxTwilightPoints": twilightBase + 25,
                 "maxStorage": 64,
                 "maxStackElements": maxStack,
                 "maxFunctionDefs": maxFunction}
            install_properties_ufo(uw, ufo_lib_tree, d)
            uw.save_lib(ufo_lib_tree)
        else:
            thisFont['maxp'].maxSizeOfInstructions = maxInstructions + 50
            thisFont['maxp'].maxTwilightPoints = twilightBase + 25
            thisFont['maxp'].maxStorage = storageBase + 64
            thisFont['maxp'].maxStackElements = maxStack
            thisFont['maxp'].maxFunctionDefs = maxFunction
            thisFont['head'].flags |= 0b0000000000001000
            with thisFont as f:
                f.save(new_file_name, 1)
    except Exception as e:
        print("Error while installing maxp and head settings:")
        print(e.args)
        print(e)
    return failed_glyph_list


def run(
        inputfile,
        quiet = -1,
        outputfile = None,
        inputfont = None,
        outputfont = None,
        skipval = False,
        skipcomp = False,
        expandonly = False,
        compactonly = False,
        yconvonly = False,
        mergemode = False,
        initgraphics = "yes",
        assume_y = "no",
        glyphlist = None,
        replaceprep = False,
        saveprograms = False,
        nocompact = False,
        cfuzz = 1,
        source: str = "xgf",
        font: ttFont = None,
        yaml: dict = None,
    ):

    # Return a tuple: (error_msg: str, failed glyphs: list)

    global maxInstructions, quietcount, ufo_mode, coordinateFuzz

    if quiet >= 0:
        quietcount = quiet

    if quietcount < 1:
        print("Opening the Xgridfit file ...")

    failed_glyph_list = []

    if cfuzz > 1:
        coordinateFuzz = cfuzz

    source_ext = os.path.splitext(inputfile)[1]
    if source_ext == ".yaml":
        if quietcount < 1:
            print("Converting yaml source to Xgridfit")
        xgffile = ygridfit_parse(inputfile)
    else:
        xgffile = etree.parse(inputfile)

    # We'll need namespaces

    ns = {"xgf": "http://xgridfit.sourceforge.net/Xgridfit2",
          "xi": "http://www.w3.org/2001/XInclude",
          "xsl": "http://www.w3.org/1999/XSL/Transform"}
    
    split_fn = os.path.splitext(outputfont)
    extension = split_fn[1]
    ufo_mode = (extension == ".ufo")

    # Next determine whether we are using long tagnames or short. Best way
    # is to find out which tag is used for the required <pre-program> (<prep>)
    # element. If we don't find it, print an error message and exit. Here's
    # where we validate too; and if we're only expanding or compacting a file,
    # do that and exit before we go to the trouble of opening the font.
    if quietcount < 1:
        print("Validating ...")

    # This block validates XGF code, expands compact to normal pre-compilation,
    # checks for the presence of a prep program, and saves transformed code if
    # necessary, including converted ygt code. None of this is necessary if
    # source if ygt.
    if source == "xgf":
        if len(xgffile.xpath("/xgf:xgridfit/xgf:prep", namespaces=ns)):
            # first validate
            validate(xgffile, "compact", skipval)
            # as we can't use the compact syntax, always expand
            if quietcount < 1:
                print("Expanding compact to normal syntax ...")
            xslfile = get_file_path("XSL/expand.xsl")
            etransform = etree.XSLT(etree.parse(xslfile))
            xgffile = etransform(xgffile)
            if expandonly:
                tstr = str(xgffile)
                tstr = tstr.replace('xgf:','')
                tstr = tstr.replace('xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"','')
                if outputfile:
                    of = open(outputfile, "w")
                    of.write(tstr)
                    of.close()
                else:
                    print(tstr)
                sys.exit(0)
        elif len(xgffile.xpath("/xgf:xgridfit/xgf:pre-program", namespaces=ns)):
            # validate(xgffile, "normal", skipval)
            if compactonly or yconvonly:
                if compactonly:
                    xslfile = get_file_path("XSL/compact.xsl")
                    etransform = etree.XSLT(etree.parse(xslfile))
                    xgffile = etransform(xgffile)
                    tstr = str(xgffile)
                    tstr = tstr.replace('xgf:','')
                    tstr = tstr.replace('xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"','')
                    tstr = tstr.replace(' >','>')
                if yconvonly:
                    tstr = str(etree.tostring(xgffile).decode())
                    # tstr = str(xgffile)
                if outputfile:
                    of = open(outputfile, "w")
                    of.write(tstr)
                    of.close()
                else:
                    print(tstr)
                sys.exit(0)
        else:
            print("The xgridfit program must contain a pre-program (prep) element,")
            print("even if it's empty.")
            sys.exit(1)

    # Don't do this if called from ygt.
    if source == "ygt" and skipcomp and quietcount < 1:
        print("Skipping compilation")
        sys.exit(0)

    # Now open the font. If in xgf mode, we open a file. If ygt, we operate
    # on the fontTools font passed to us in the font parameter.

    if source == "xgf":
        if quietcount < 1:
            print("Opening and evaluating the font ...")
        if not inputfont:
            inputfont = xgffile.xpath("/xgf:xgridfit/xgf:inputfont/text()", namespaces=ns)[0]
        if not inputfont:
            err = "No font to read"
            return (err, failed_glyph_list)
        thisFont = ttLib.TTFont(inputfont)
    else:
        thisFont = font

    # If we're in merge-mode, we need to know some things about the current state
    # of it; otherwise we just wipe it.

    functionBase = 0     # Offset to account for functions in existing font
    cvtBase      = 0     # Offset to account for CVs in existing font
    storageBase  = 0     # Offset to account for storage in existing font
    maxStack     = 256   # Our (generous) default stack size
    twilightBase = 0     # Offset to account for twilight space in existing font
    if mergemode:
        maxInstructions = max(maxInstructions, thisFont['maxp'].maxSizeOfInstructions)
        storageBase = thisFont['maxp'].maxStorage
        maxStack = max(maxStack, thisFont['maxp'].maxStackElements)
        functionBase = thisFont['maxp'].maxFunctionDefs
        twilightBase = thisFont['maxp'].maxTwilightPoints
        try:
            cvtBase = len(getattr(thisFont['cvt '], 'values'))
        except:
            cvtBase = 0
    else:
        wipe_font(thisFont)

    # Get the xsl file, change some defaults (only relevant in merge-mode),
    # and get a transform object

    xslfile = etree.parse(get_file_path("XSL/xgridfit-ft.xsl"))
    if mergemode:
        xslfile.xpath("/xsl:stylesheet/xsl:param[@name='function-base']",
                      namespaces=ns)[0].attrib['select'] = str(functionBase)
        xslfile.xpath("/xsl:stylesheet/xsl:param[@name='cvt-base']",
                      namespaces=ns)[0].attrib['select'] = str(cvtBase)
        xslfile.xpath("/xsl:stylesheet/xsl:param[@name='storage-base']",
                      namespaces=ns)[0].attrib['select'] = str(storageBase)
    etransform = etree.XSLT(xslfile)

    # Get a list of the glyphs to compile

    if quietcount < 1:
        print("Getting glyph list ...")

    if glyphlist:
        # a list passed in as a command-line argument. If called from ygt,
        # we won't have this.
        glyph_list = glyphlist
    else:
        # all the glyph programs in the file
        glyph_list = str(etransform(xgffile, **{"get-glyph-list": "'yes'"}))
    glyph_list = list(glyph_list.split(" "))
    no_compact_list = str(etransform(xgffile, **{"get-no-compact-list": "'yes'"}))
    if no_compact_list == None:
        no_compact_list = []
    else:
        no_compact_list = list(no_compact_list.split(" "))

    # Now that we have a glyph list, we can make the coordinate index
    # and substitute point numbers for coordinates.

    coordinateIndex, bad = make_coordinate_index(glyph_list, thisFont)
    if len(bad):
        failed_glyph_list.extend(bad)
    bad = coordinates_to_points(glyph_list, xgffile, coordinateIndex, ns)
    if len(bad):
        failed_glyph_list.extend(bad)

    # Back to the xgf file. We're also going to need a list of stack-safe
    # functions in this font.

    if quietcount < 1:
        print("Getting list of safe function calls ...")

    safe_calls = etransform(xgffile, **{"stack-safe-list": "'yes'"})
    safe_calls = literal_eval(str(safe_calls))

    # If this is ufo_mode, open the ufo with xgfUFOWriter.
    uw = None
    if ufo_mode:
        uw = xgfUFOWriter(outputfont)

    # Get cvt

    if quietcount < 1:
        print("Building control-value table ...")

    cvt_list = str(etransform(xgffile, **{"get-cvt-list": "'yes'"}))
    cvt_list = literal_eval("[" + cvt_list + "]")
    ufo_lib_tree = None
    if ufo_mode:
        ufo_lib_tree = uw.open_lib()
        uw.install_cvt(ufo_lib_tree, cvt_list)
    else:
        install_cvt(thisFont, cvt_list, cvtBase)

    # Test whether we have a cvar element (i.e. this is a variable font)

    cvar_count = len(xgffile.xpath("/xgf:xgridfit/xgf:cvar", namespaces=ns))
    if cvar_count > 0 and not ufo_mode:
        if quietcount < 1:
            print("Building cvar table ...")
        tuple_store = literal_eval(str(etransform(xgffile, **{"get-cvar": "'yes'"})))
        install_cvar(thisFont, tuple_store, mergemode, cvtBase)

    if quietcount < 1:
        print("Building fpgm table ...")

    predef_functions = int(xslfile.xpath("/xsl:stylesheet/xsl:variable[@name='predefined-functions']",
                                         namespaces=ns)[0].attrib['select'])
    maxFunction = etransform(xgffile, **{"function-count": "'yes'"})
    maxFunction = int(maxFunction) + predef_functions + functionBase

    fpgm_code = etransform(xgffile, **{"fpgm-only": "'yes'"})
    if ufo_mode:
        install_functions_ufo(uw, ufo_lib_tree, fpgm_code, functionBase)
    else:
        install_functions(thisFont, fpgm_code, functionBase)

    if saveprograms:
        instf = open("fpgm.instructions", "w")
        instf.write(str(fpgm_code))
        instf.close

    if quietcount < 1:
        print("Building prep table ...")

    prep_code = etransform(xgffile, **{"prep-only": "'yes'"})
    if ufo_mode:
        install_prep_ufo(uw, ufo_lib_tree, prep_code, False, True)
    else:
        install_prep(thisFont, prep_code, mergemode, replaceprep)

    if saveprograms:
        instf = open("prep.instructions", "w")
        instf.write(str(prep_code))
        instf.close

    # Now loop through the glyphs for which there is code.

    cycler = 0
    for g in glyph_list:
        if quietcount < 1:
            print("Processing glyph " + g)
        elif quietcount < 2 and cycler == 4:
            print(".", end=" ", flush=True)
        cycler += 1
        if cycler == 5:
            cycler = 0
        try:
            gt = "'" + g + "'"
            glyph_args = {'singleGlyphId': gt}
            if initgraphics:
                glyph_args['init_graphics'] = "'" + initgraphics + "'"
            if assume_y:
                glyph_args['assume-always-y'] = "'" + assume_y + "'"
            g_inst = etransform(xgffile, **glyph_args)
        except Exception as e:
            print(e)
            for entry in etransform.error_log:
                if quietcount < 3:
                    print('message from line %s, col %s: %s' % (entry.line, entry.column, entry.message))
            # sys.exit(1)
            failed_glyph_list.append(g)
            continue
        # Two lines added for (possible) debugging
        for entry in etransform.error_log:
            if quietcount < 3:
                print('message from line %s, col %s: %s' % (entry.line, entry.column, entry.message))
        if nocompact or g in no_compact_list:
            g_inst_final = str(g_inst)
        else:
            g_inst_final = compact_instructions(str(g_inst), safe_calls)
        if ufo_mode:
            ttglyph = thisFont['glyf'][g]
            ttwidth = thisFont["hmtx"][g][0]
            hash_pen = HashPointPen(ttwidth, thisFont.getGlyphSet())
            ttglyph.drawPoints(hash_pen, thisFont["glyf"])
            install_glyph_program_ufo(uw, g, g_inst_final, hash_pen.hash)
        else:
            install_glyph_program(g, thisFont, g_inst_final)
        if saveprograms:
            gfn = userNameToFileName(g) + ".instructions"
            gfnfile = open(gfn, "w")
            if nocompact or g in no_compact_list:
                gfnfile.write(g_inst_final)
            else:
                gfnfile.write("Uncompacted:\n\n")
                gfnfile.write(str(g_inst))
                gfnfile.write("\n\nCompacted:\n\n")
                gfnfile.write(g_inst_final)
            gfnfile.close
    if quietcount == 1:
        print("")

    if quietcount < 1:
        print("Hinted " + str(len(glyph_list)) + " glyphs.")
        print("Cleaning up and writing the new font")
    if len(failed_glyph_list) and source == "xgf":
        print("There were problems with these glyphs:")
        for f in failed_glyph_list:
            print(f, end = " ")
            print()
    try:
        if ufo_mode:
            d = {"maxSizeOfInstructions": maxInstructions + 50,
                 "maxTwilightPoints": twilightBase + 25,
                 "maxStorage": 64,
                 "maxStackElements": maxStack,
                 "maxFunctionDefs": maxFunction}
            install_properties_ufo(uw, ufo_lib_tree, d)
            uw.save_lib(ufo_lib_tree)
        else:
            thisFont['maxp'].maxSizeOfInstructions = maxInstructions + 50
            thisFont['maxp'].maxTwilightPoints = twilightBase + 25
            thisFont['maxp'].maxStorage = storageBase + 64
            thisFont['maxp'].maxStackElements = maxStack
            thisFont['maxp'].maxFunctionDefs = maxFunction
            thisFont['head'].flags |= 0b0000000000001000
    except Exception as e:
        print("Error while installing maxp and head settings:")
        print(e.args)
        print(e)
    if skipcomp:
        if quietcount < 1:
            print("As --nocompilation flag is set, exiting without writing font file.")
        sys.exit(0)
    if not outputfont:
        outputfont = str(xgffile.xpath("/xgf:xgridfit/xgf:outputfont/text()",
                                       namespaces=ns)[0])
    if not outputfont:
        print("Need the filename of a font to write. Use the --outputfont")
        print("command-line argument or the <outputfont> element in your")
        print("Xgridfit file.")
        sys.exit(1)
    if not ufo_mode:
        with thisFont as f:
            f.save(outputfont, 1)
        # thisFont.save(outputfont, 1)


def main():

    global maxInstructions, quietcount

    # First read the command-line arguments. At minimum we need the inputfile.

    argparser = argparse.ArgumentParser(prog='xgridfit',
                                        description='Compile XML into TrueType instructions and add them to a font.')
    argparser.add_argument('-v', '--version', action='version', version='Xgridfit ' + __version__)
    argparser.add_argument('-e', '--expand', action="store_true",
                           help="Convert file to expanded syntax, save, and exit")
    argparser.add_argument('-c', '--compact', action="store_true",
                           help="Convert file to compact syntax, save, and exit")
    argparser.add_argument('-y', '--yaml2xgf', action="store_true",
                           help="Convert yaml file to expanded syntax, save, and exit")
    argparser.add_argument('-n', '--novalidation', action="store_true",
                           help="Skip validation of the Xgridfit program")
    argparser.add_argument('--nocompilation', action="store_true",
                           help="Skip compilation of the Xgridfit program")
    argparser.add_argument('--nocompact', action="store_true",
                           help="Do not compact glyph programs (can help with debugging)")
    argparser.add_argument('-m', '--merge', action="store_true",
                           help="Merge Xgridfit with existing instructions")
    argparser.add_argument('-r', '--replaceprep', action="store_true",
                           help="Whether to replace the existing prep table or append the new one (use with --merge)")
    argparser.add_argument('--initgraphics', choices=['yes', 'no'],
                           help="Whether to initialize graphics-tracking variables at the beginning of glyph program")
    argparser.add_argument('-a', '--assume_y', choices=['yes', 'no'],
                           help="Whether compiler should assume that your hints are all vertical")
    argparser.add_argument('-q', '--quiet', action="count", default=0,
                           help="No progress messages (-qq to suppress warnings too)")
    argparser.add_argument('-g', '--glyphlist', help="List of glyphs to compile")
    argparser.add_argument('-i', '--inputfont', action='store', type=str,
                           help="The font file to add instructions to")
    argparser.add_argument('-o', '--outputfont', action='store', type=str,
                           help="The font file to write")
    argparser.add_argument('-s', '--saveprograms', action="store_true",
                           help="Save generated instructions to text files")
    argparser.add_argument('-f', '--coordinatefuzz', type=int, default=1,
                           help="Error tolerance for points identified by coordinates (default is 1)")
    argparser.add_argument("inputfile", help='Xgridfit (XML) file to process.')
    argparser.add_argument("outputfile", nargs='?',
                           help="Filename for options (e.g. --expand) that produce text output")
    args = argparser.parse_args()

    inputfile    = args.inputfile
    outputfile   = args.outputfile
    inputfont    = args.inputfont
    outputfont   = args.outputfont
    skipval      = args.novalidation
    skipcomp     = args.nocompilation
    expandonly   = args.expand
    compactonly  = args.compact
    yconvonly    = args.yaml2xgf
    mergemode    = args.merge
    quietcount   = args.quiet
    initgraphics = args.initgraphics
    assume_y     = args.assume_y
    glyphlist    = args.glyphlist
    replaceprep  = args.replaceprep
    saveprograms = args.saveprograms
    nocompact    = args.nocompact
    cfuzz        = args.coordinatefuzz

    if quietcount < 1:
        print("Opening the Xgridfit file ...")

    if cfuzz > 1:
        coordinateFuzz = cfuzz

    source_ext = os.path.splitext(inputfile)[1]
    if source_ext == ".yaml":
        if quietcount < 1:
            print("Converting yaml source to Xgridfit")
        xgffile = ygridfit_parse(inputfile)
        # print(xgffile)
    else:
        xgffile = etree.parse(inputfile)

    # We'll need namespaces

    ns = {"xgf": "http://xgridfit.sourceforge.net/Xgridfit2",
          "xi": "http://www.w3.org/2001/XInclude",
          "xsl": "http://www.w3.org/1999/XSL/Transform"}

    # Do xinclude if this is a multipart file

    #if len(xgffile.xpath("/xgf:xgridfit/xi:include", namespaces=ns)):
    #    xgffile.xinclude()

    # Next determine whether we are using long tagnames or short. Best way
    # is to find out which tag is used for the required <pre-program> (<prep>)
    # element. If we don't find it, print an error message and exit. Here's
    # where we validate too; and if we're only expanding or compacting a file,
    # do that and exit before we go to the trouble of opening the font.
    if quietcount < 1:
        print("Validating ...")

    if len(xgffile.xpath("/xgf:xgridfit/xgf:prep", namespaces=ns)):
        # first validate
        validate(xgffile, "compact", skipval)
        # as we can't use the compact syntax, always expand
        if quietcount < 1:
            print("Expanding compact to normal syntax ...")
        xslfile = get_file_path("XSL/expand.xsl")
        etransform = etree.XSLT(etree.parse(xslfile))
        xgffile = etransform(xgffile)
        if expandonly:
            tstr = str(xgffile)
            tstr = tstr.replace('xgf:','')
            tstr = tstr.replace('xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"','')
            if outputfile:
                of = open(outputfile, "w")
                of.write(tstr)
                of.close()
            else:
                print(tstr)
            sys.exit(0)
    elif len(xgffile.xpath("/xgf:xgridfit/xgf:pre-program", namespaces=ns)):
        # validate(xgffile, "normal", skipval)
        if compactonly or yconvonly:
            if compactonly:
                xslfile = get_file_path("XSL/compact.xsl")
                etransform = etree.XSLT(etree.parse(xslfile))
                xgffile = etransform(xgffile)
                tstr = str(xgffile)
                tstr = tstr.replace('xgf:','')
                tstr = tstr.replace('xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"','')
                tstr = tstr.replace(' >','>')
            if yconvonly:
                tstr = str(etree.tostring(xgffile).decode())
                # tstr = str(xgffile)
            if outputfile:
                of = open(outputfile, "w")
                of.write(tstr)
                of.close()
            else:
                print(tstr)
            sys.exit(0)
    else:
        print("The xgridfit program must contain a pre-program (prep) element,")
        print("even if it's empty.")
        sys.exit(1)

    if skipcomp and quietcount < 1:
        print("Skipping compilation")
        sys.exit(0)

    # Now open the font. If we're in merge-mode, we need to know some things
    # about the current state of it; otherwise we just wipe it.

    if quietcount < 1:
        print("Opening and evaluating the font ...")
    if not inputfont:
        inputfont = xgffile.xpath("/xgf:xgridfit/xgf:inputfont/text()", namespaces=ns)[0]
    if not inputfont:
        print("Need the filename of a font to read. Use the --inputfont")
        print("command-line argument or the <inputfont> element in your")
        print("Xgridfit file.")
        sys.exit(1)
    thisFont = ttLib.TTFont(inputfont)
    functionBase = 0     # Offset to account for functions in existing font
    cvtBase      = 0     # Offset to account for CVs in existing font
    storageBase  = 0     # Offset to account for storage in existing font
    maxStack     = 256   # Our (generous) default stack size
    twilightBase = 0     # Offset to account for twilight space in existing font
    if mergemode:
        maxInstructions = max(maxInstructions, thisFont['maxp'].maxSizeOfInstructions)
        storageBase = thisFont['maxp'].maxStorage
        maxStack = max(maxStack, thisFont['maxp'].maxStackElements)
        functionBase = thisFont['maxp'].maxFunctionDefs
        twilightBase = thisFont['maxp'].maxTwilightPoints
        try:
            cvtBase = len(getattr(thisFont['cvt '], 'values'))
        except:
            cvtBase = 0
    else:
        wipe_font(thisFont)

    # Get the xsl file, change some defaults (only relevant in merge-mode),
    # and get a transform object

    xslfile = etree.parse(get_file_path("XSL/xgridfit-ft.xsl"))
    if mergemode:
        xslfile.xpath("/xsl:stylesheet/xsl:param[@name='function-base']",
                      namespaces=ns)[0].attrib['select'] = str(functionBase)
        xslfile.xpath("/xsl:stylesheet/xsl:param[@name='cvt-base']",
                      namespaces=ns)[0].attrib['select'] = str(cvtBase)
        xslfile.xpath("/xsl:stylesheet/xsl:param[@name='storage-base']",
                      namespaces=ns)[0].attrib['select'] = str(storageBase)
    etransform = etree.XSLT(xslfile)

    # Get a list of the glyphs to compile

    if quietcount < 1:
        print("Getting glyph list ...")

    if glyphlist:
        # a list passed in as a command-line argument
        glyph_list = glyphlist
    else:
        # all the glyph programs in the file
        glyph_list = str(etransform(xgffile, **{"get-glyph-list": "'yes'"}))
    glyph_list = list(glyph_list.split(" "))
    no_compact_list = str(etransform(xgffile, **{"get-no-compact-list": "'yes'"}))
    if no_compact_list == None:
        no_compact_list = []
    else:
        no_compact_list = list(no_compact_list.split(" "))

    # Now that we have a glyph list, we can make the coordinate index
    # and substitute point numbers for coordinates.

    failed_glyph_list = []

    coordinateIndex, bad = make_coordinate_index(glyph_list, thisFont)
    if len(bad):
        failed_glyph_list.extend(bad)
    bad = coordinates_to_points(glyph_list, xgffile, coordinateIndex, ns)
    if len(bad):
        failed_glyph_list.extend(bad)

    # Back to the xgf file. We're also going to need a list of stack-safe
    # functions in this font.

    if quietcount < 1:
        print("Getting list of safe function calls ...")

    safe_calls = etransform(xgffile, **{"stack-safe-list": "'yes'"})
    safe_calls = literal_eval(str(safe_calls))

    # Get cvt

    if quietcount < 1:
        print("Building control-value table ...")

    cvt_list = str(etransform(xgffile, **{"get-cvt-list": "'yes'"}))
    cvt_list = literal_eval("[" + cvt_list + "]")
    install_cvt(thisFont, cvt_list, cvtBase)

    # Test whether we have a cvar element (i.e. this is a variable font)

    cvar_count = len(xgffile.xpath("/xgf:xgridfit/xgf:cvar", namespaces=ns))
    if cvar_count > 0:
        if quietcount < 1:
            print("Building cvar table ...")
        tuple_store = literal_eval(str(etransform(xgffile, **{"get-cvar": "'yes'"})))
        install_cvar(thisFont, tuple_store, mergemode, cvtBase)

    if quietcount < 1:
        print("Building fpgm table ...")

    predef_functions = int(xslfile.xpath("/xsl:stylesheet/xsl:variable[@name='predefined-functions']",
                                         namespaces=ns)[0].attrib['select'])
    maxFunction = etransform(xgffile, **{"function-count": "'yes'"})
    maxFunction = int(maxFunction) + predef_functions + functionBase

    fpgm_code = etransform(xgffile, **{"fpgm-only": "'yes'"})
    install_functions(thisFont, fpgm_code, functionBase)
    if saveprograms:
        instf = open("fpgm.instructions", "w")
        instf.write(str(fpgm_code))
        instf.close

    if quietcount < 1:
        print("Building prep table ...")

    prep_code = etransform(xgffile, **{"prep-only": "'yes'"})
    install_prep(thisFont, prep_code, mergemode, replaceprep)
    if saveprograms:
        instf = open("prep.instructions", "w")
        instf.write(str(prep_code))
        instf.close

    # Now loop through the glyphs for which there is code.

    cycler = 0
    for g in glyph_list:
        if quietcount < 1:
            print("Processing glyph " + g)
        elif quietcount < 2 and cycler == 4:
            print(".", end=" ", flush=True)
        cycler += 1
        if cycler == 5:
            cycler = 0
        try:
            gt = "'" + g + "'"
            glyph_args = {'singleGlyphId': gt}
            if initgraphics:
                glyph_args['init_graphics'] = "'" + initgraphics + "'"
            if assume_y:
                glyph_args['assume-always-y'] = "'" + assume_y + "'"
            g_inst = etransform(xgffile, **glyph_args)
        except Exception as e:
            print(e)
            for entry in etransform.error_log:
                if quietcount < 3:
                    print('message from line %s, col %s: %s' % (entry.line, entry.column, entry.message))
            # sys.exit(1)
            failed_glyph_list.append(g)
            continue
        # Two lines added for (possible) debugging
        for entry in etransform.error_log:
            if quietcount < 3:
                print('message from line %s, col %s: %s' % (entry.line, entry.column, entry.message))
        if nocompact or g in no_compact_list:
            g_inst_final = str(g_inst)
        else:
            g_inst_final = compact_instructions(str(g_inst), safe_calls)
        install_glyph_program(g, thisFont, g_inst_final)
        if saveprograms:
            gfn = userNameToFileName(g) + ".instructions"
            gfnfile = open(gfn, "w")
            if nocompact or g in no_compact_list:
                gfnfile.write(g_inst_final)
            else:
                gfnfile.write("Uncompacted:\n\n")
                gfnfile.write(str(g_inst))
                gfnfile.write("\n\nCompacted:\n\n")
                gfnfile.write(g_inst_final)
            gfnfile.close
    print("")

    if quietcount < 1:
        print("Hinted " + str(len(glyph_list)) + " glyphs.")
        print("Cleaning up and writing the new font")
    if len(failed_glyph_list):
        print("There were problems with these glyphs:")
        for f in failed_glyph_list:
            print(f, end = " ")
            print()
    thisFont['maxp'].maxSizeOfInstructions = maxInstructions + 50
    thisFont['maxp'].maxTwilightPoints = twilightBase + 25
    thisFont['maxp'].maxStorage = storageBase + 64
    thisFont['maxp'].maxStackElements = maxStack
    thisFont['maxp'].maxFunctionDefs = maxFunction
    thisFont['head'].flags |= 0b0000000000001000
    if skipcomp:
        if quietcount < 1:
            print("As --nocompilation flag is set, exiting without writing font file.")
        sys.exit(0)
    if not outputfont:
        outputfont = str(xgffile.xpath("/xgf:xgridfit/xgf:outputfont/text()",
                                       namespaces=ns)[0])
    if not outputfont:
        print("Need the filename of a font to write. Use the --outputfont")
        print("command-line argument or the <outputfont> element in your")
        print("Xgridfit file.")
        sys.exit(1)
    thisFont.save(outputfont, 1)
