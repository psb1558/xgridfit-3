from fontTools import ttLib
from fontTools.ttLib import ttFont, tables
from fontTools.ttLib.tables.TupleVariation import TupleVariation
from lxml import etree
from ast import literal_eval
import sys
import os
import argparse
import array
import pkg_resources

#      This file is part of xgridfit, version 3.
#      Licensed under the Apache License, Version 2.0.
#      Copyright (c) 2006-20 by Peter S. Baker

neutral_instructions = [ 'IUP', 'RDTG', 'ROFF', 'RTDG', 'RTG', 'RTHG', 'RUTG',
                         'SFVTCA', 'SFVTPV', 'SPVTCA', 'SVTCA', 'FLIPOFF',
                         'FLIPON' ]

pop_instructions = { 'ALIGNPTS': 2, 'ALIGNRP': -1, 'IP': -1, 'MDAP': 1,
                     'MIAP': 2, 'MIRP': 2, 'MDRP': 1, 'SHP': -1, 'SLOOP': 1,
                     'SRP0': 1, 'SRP1': 1, 'SRP2': 1, 'CALL': 1, 'SFVTL': 2,
                     'SPVTL': 2, 'SDPVTL': 2, 'ISECT': 5, 'MSIRP': 2, 'SCFS': 2,
                     'SCVTCI': 1, 'SFVFS': 2, 'SHC': 1, 'SHZ': 1, 'SMD': 1,
                     'SPVFS': 2, 'SROUND': 1, 'SSW': 1, 'SSWCI': 1, 'SZP0': 1,
                     'SZP1': 1, 'SZP2': 1, 'SZPS': 1, 'UTP': 1, 'WCVTF': 2,
                     'WCVTP': 2, 'WS': 2 }

byte_push_instructions = [ 'PUSHB', 'NPUSHB' ]

maxInstructions = 200

def get_file_path(fn):
    return pkg_resources.resource_filename(__name__, fn)

def wipe_font(fo):
    """Delete all TrueType programming in the font."""
    for g_name in fo['glyf'].glyphs:
        glyph = fo['glyf'][g_name]
        try:
        #    del glyph.program
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
    scattered through it and consolidates them into one PUSH
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
    """If base is greater than zero, we append cvs to an existing CVT table. If
    not, we generate a new table."""
    if base > 0:
        assert base == len(fo['cvt '].values)
        for c in cvs:
            fo['cvt '].values.append(c)
    else:
        fo['cvt '] = ttFont.newTable('cvt ')
        setattr(fo['cvt '],'values',array.array('h', cvs))

def install_functions(fo, fns, base):
    """If base greater than zero, we append our own functions to those already
    in the font. If not, generate a new fpgm table."""
    if base > 0:
        oldfpgm = "\n".join(fo['fpgm'].program.getAssembly())
        newfpgm = oldfpgm + "\n" + str(fns)
        # print(newfpgm)
        # newasm = fo['fpgm'].program.getAssembly().extend(str(fns).split("\n"))
        fo['fpgm'].program.fromAssembly(newfpgm)
        # print(fo['fpgm'].program.getAssembly())
        # as a test
        fo['fpgm'].program.getBytecode()
    else:
        fo['fpgm'] = ttFont.newTable('fpgm')
        fo['fpgm'].program = tables.ttProgram.Program()
        fo['fpgm'].program.fromAssembly(str(fns))
        # as a test
        # fo['fpgm'].program.getBytecode()

def install_prep(fo, pr, keepold, replace):
    """If keepold is True, we append our own prep table to the existing one.
    It is up to the Xgridfit programmer to make sure that no conflicts arise
    (though if there's a duplication--for example, instructions being disabled
    at a different ppem in the new code than in the old, the new code will
    take precedence.)"""
    if keepold and not replace:
        oldprep = "\n".join(fo['prep'].program.getAssembly())
        newprep = oldprep + "\n" + str(pr)
        # print(newprep)
        fo['prep'].program.fromAssembly(newprep)
        # as a test
        # fo['prep'].program.getBytecode()
    else:
        fo['prep'] = ttFont.newTable('prep')
        fo['prep'].program = tables.ttProgram.Program()
        fo['prep'].program.fromAssembly(str(pr))
        # as a test
        # fo['prep'].program.getBytecode()

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

def install_cvar(fo, cvarstore, keepold):
    """If keepold is True, we append our own cvar data to the existing
    TupleVariation objects. If False, generate our own cvar table. Since
    The old cvar may not exactly match the new one, there are contingencies:
    If a tuple is missing in the existing or the xgf cvar, pad the new one
    and issue a warning. If there is no cvar at all in the existing font (this
    can easily happen with VTT), pad all our tuples and issue a warning. In
    such cases it may be a good idea to manually edit the cvar table. This
    function seems fragile. Think about it and revisit."""
    if keepold:
        complications = False
        needoldfontpadding = False
        try:
            oldcvarstore = fo['cvar'].variations
        except:
            print("No cvar table in existing font")
            #create a dummy cvar table to put the new one on top of.
            complications = True
            oldcvardummy = []
            oldcvtlen = len(fo['cvt '].values)
            for cvst in cvarstore:
                oldcvardummy.append(TupleVariation(cvst[0], [None] * oldcvtlen))
            fo['cvar'] = ttFont.newTable('cvar')
            fo['cvar'].variations = oldcvardummy
            oldcvarstore = fo['cvar'].variations
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
                    oldc.coordinates.extend(newc[1])
                else:
                    # we've failed to find a match for one of the TupleVariations
                    # in the existing font. We'll just pad it with Nones
                    oldc.coordinates.extend([None] * newcoordlen)
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
                newcoordlist = [None] * oldcoordlen
                newcoordlist.extend(cvarstore[tt_index][1])
                thistuple = TupleVariation(cvarstore[tt_index][0], newcoordlist)
                oldcvarstore = fo['cvar'].variations.append(thistuple)
            tt_index += 1
            complications = True
        if complications:
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

def validate(f, syntax, noval):
    if noval:
        print("Skipping validation")
    else:
        schemadir = "Schemas/"
        schemafile = "xgridfit.rng"
        if syntax == "compact":
            schemafile = "xgridfit-sh.rng"
        schemapath = get_file_path(schemadir + schemafile)
        schema = etree.RelaxNG(etree.parse(schemapath))
        schema.assertValid(f)

def main():

    global maxInstructions

    # First read the command-line arguments. At minimum we need the inputfile.

    argparser = argparse.ArgumentParser(description='Compile XML into TrueType instructions and add them to a font.')
    argparser.add_argument('-e', '--expand', action="store_true", help="Convert file to expanded syntax, save, and exit")
    argparser.add_argument('-c', '--compact', action="store_true", help="Convert file to compact syntax, save, and exit")
    argparser.add_argument('-n', '--novalidation', action="store_true", help="Skip validation of the input file")
    argparser.add_argument('--nocompilation', action="store_true", help="Skip compilation of the input file")
    argparser.add_argument('-m', '--merge', action="store_true", help="Merge Xgridfit with existing instructions")
    argparser.add_argument('-r', '--replaceprep', action="store_true", help="Whether to replace the existing prep table or append the new one (use with --merge)")
    argparser.add_argument('--initgraphics', choices=['yes', 'no'],
                           help="Whether to initialize graphics-tracking variables at the beginning of glyph program")
    argparser.add_argument('-a', '--assume_y', choices=['yes', 'no'],
                           help="Whether compiler should assume that your hints are all vertical")
    argparser.add_argument('-q', '--quiet', action="store_true", help="No progress messages")
    argparser.add_argument('-g', '--glyphlist', help="List of glyphs to compile")
    argparser.add_argument('-i', '--inputfont', action='store', type=str, help="The font file to add instructions to")
    argparser.add_argument('-o', '--outputfont', action='store', type=str, help="The font file to write")
    argparser.add_argument("inputfile", help='Xgridfit (XML) file to process.')
    argparser.add_argument("outputfile", nargs='?', help="Filename for options (e.g. --expand) that produce text output")
    args = argparser.parse_args()

    inputfile    = args.inputfile
    outputfile   = args.outputfile
    inputfont    = args.inputfont
    outputfont   = args.outputfont
    skipval      = args.novalidation
    skipcomp     = args.nocompilation
    expandonly   = args.expand
    compactonly  = args.compact
    mergemode    = args.merge
    quietmode    = args.quiet
    initgraphics = args.initgraphics
    assume_y     = args.assume_y
    glyphlist    = args.glyphlist
    replaceprep  = args.replaceprep

    if not quietmode:
        print("Opening the Xgridfit file ...")

    xgffile = etree.parse(inputfile)

    # We'll need namespaces

    ns = {"xgf": "http://xgridfit.sourceforge.net/Xgridfit2",
          "xi": "http://www.w3.org/2001/XInclude",
          "xsl": "http://www.w3.org/1999/XSL/Transform"}

    # Do xinclude if this is a multipart file

    if len(xgffile.xpath("/xgf:xgridfit/xi:include", namespaces=ns)):
        xgffile.xinclude()

    # Next determine whether we are using long tagnames or short. Best way
    # is to find out which tag is used for the required <pre-program> (<prep>)
    # element. If we don't find it, print an error message and exit. Here's
    # where we validate too; and if we're only expanding or compacting a file,
    # do that and exit before we go to the trouble of opening the font.
    if not quietmode:
        print("Validating ...")

    if len(xgffile.xpath("/xgf:xgridfit/xgf:prep", namespaces=ns)):
        # first validate
        validate(xgffile, "compact", skipval)
        # as we can't use the compact syntax, always expand
        if not quietmode:
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
        validate(xgffile, "normal", skipval)
        if compactonly:
            xslfile = get_file_path("XSL/compact.xsl")
            etransform = etree.XSLT(etree.parse(xslfile))
            xgffile = etransform(xgffile)
            tstr = str(xgffile)
            tstr = tstr.replace('xgf:','')
            tstr = tstr.replace('xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"','')
            tstr = tstr.replace(' >','>')
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

    if skipcomp:
        print("Skipping compilation")
        sys.exit(0)

    # Now open the font. If we're in merge-mode, we need to know some things
    # about the current state of it; otherwise we just wipe it.

    if not quietmode:
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
    cvtBase      = 0     # Offset to account for cvs in existing font
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

    # Get a list of the glyphs in the file

    if glyphlist:
        glyph_list = glyphlist
    else:
        glyph_list = str(etransform(xgffile, **{"get-glyph-list": "'yes'"}))
    print(type(glyph_list[1]))
    glyph_list = list(glyph_list.split(" "))

    # Back to the xgf file. We're also going to need a list of stack-safe
    # functions in this font.

    if not quietmode:
        print("Getting list of safe function calls ...")

    safe_calls = etransform(xgffile, **{"stack-safe-list": "'yes'"})
    safe_calls = literal_eval(str(safe_calls))

    # Get cvt

    if not quietmode:
        print("Getting control-value table ...")

    cvt_list = str(etransform(xgffile, **{"get-cvt-list": "'yes'"}))
    cvt_list = literal_eval("[" + cvt_list + "]")
    install_cvt(thisFont, cvt_list, cvtBase)

    # Test whether we have a cvar element (i.e. this is a variable font)

    cvar_count = len(xgffile.xpath("/xgf:xgridfit/xgf:cvar", namespaces=ns))
    if cvar_count > 0:
        if not quietmode:
            print("Getting cvar table ...")
        tuple_store = literal_eval(str(etransform(xgffile, **{"get-cvar": "'yes'"})))
        install_cvar(thisFont, tuple_store, mergemode)

    if not quietmode:
        print("Getting fpgm table ...")

    predef_functions = int(xslfile.xpath("/xsl:stylesheet/xsl:variable[@name='predefined-functions']",
                                         namespaces=ns)[0].attrib['select'])
    maxFunction = etransform(xgffile, **{"function-count": "'yes'"})
    maxFunction = int(maxFunction) + predef_functions + functionBase

    fpgm_code = etransform(xgffile, **{"fpgm-only": "'yes'"})
    install_functions(thisFont, fpgm_code, functionBase)

    if not quietmode:
        print("Getting prep table ...")

    prep_code = etransform(xgffile, **{"prep-only": "'yes'"})
    install_prep(thisFont, prep_code, mergemode, replaceprep)

    # Now loop through the glyphs for which there is code.

    for g in glyph_list:
        if not quietmode:
            print("Processing glyph " + g)
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
            # print("Entries in error log: " + str(len(etransform.error_log)))
            for entry in etransform.error_log:
                print('message from line %s, col %s: %s' % (entry.line, entry.column, entry.message))
        install_glyph_program(g, thisFont, compact_instructions(str(g_inst), safe_calls))

    if not quietmode:
        print("Cleaning up and writing the new font")
    thisFont['maxp'].maxSizeOfInstructions = maxInstructions + 50
    thisFont['maxp'].maxTwilightPoints = twilightBase + 25
    thisFont['maxp'].maxStorage = storageBase + 64
    thisFont['maxp'].maxStackElements = maxStack
    thisFont['maxp'].maxFunctionDefs = maxFunction
    thisFont['head'].flags |= 0b0000000000001000
    if not outputfont:
        outputfont = str(xgffile.xpath("/xgf:xgridfit/xgf:outputfont/text()",
                                       namespaces=ns)[0])
    if not outputfont:
        print("Need the filename of a font to write. Use the --outputfont")
        print("command-line argument or the <outputfont> element in your")
        print("Xgridfit file.")
        sys.exit(1)
    thisFont.save(outputfont, 1)
