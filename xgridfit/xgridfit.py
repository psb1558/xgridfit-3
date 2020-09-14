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
    global maxInstructions
    g = fo['glyf'][nm]
    g.program = tables.ttProgram.Program()
    g.program.fromAssembly(asm)
    b = len(g.program.getBytecode())
    if b > maxInstructions:
        maxInstructions = b

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
        newasm = fo['fpgm'].program.getAssembly() + "\n" + fns
        fo['fpgm'].program.fromAssembly(newasm)
    else:
        fo['fpgm'] = ttFont.newTable('fpgm')
        fo['fpgm'].program = tables.ttProgram.Program()
        fo['fpgm'].program.fromAssembly(str(fns))
        # as a test
        # fo['fpgm'].program.getBytecode()

def install_prep(fo, pr, keepold):
    """If keepold is True, we append our own prep table to the existing one.
    It is up to the Xgridfit programmer to make sure that no conflicts arise
    (though if there's a duplication--for example, instructions being disabled
    at a different ppem in the new code than in the old, the new code will
    take precedence.)"""
    if keepold:
        newprep = fo['prep'].program.getAssembly() + "\n" + pr
        fo['prep'].program.fromAssembly(newprep)
    else:
        fo['prep'] = ttFont.newTable('prep')
        fo['prep'].program = tables.ttProgram.Program()
        fo['prep'].program.fromAssembly(str(pr))
        # as a test
        # fo['prep'].program.getBytecode()

def install_cvar(fo, cvstore, keepold):
    """If keepold is True, we append our own cvar data to the existing
    TupleVariation objects. If False, generate our own cvar table.
    The cvar element in the Xgridfit code must reproduce the structure of the
    cvar element in the existing font. So the number of regions must be the
    same, and in the same order."""
    if keepold:
        try:
            oldcvstore = fo['cvar'].variations
            assert len(cvstore) == len(oldcvstore)
        except:
            print("No cvar table in existing font")
            print("or count of regions in existing font does not match count")
            print("of regions in Xgridfit programming.")
            sys.exit(1)
        for oldv, newv in [(oldv,newv) for oldv in oldcvstore for newv in cvstore]:
            newaxes = newv[0]
            newcoordinates = newv[1]
            try:
                assert oldv.axes == newaxes
            except:
                print("Regions must match and be in the same order in the old")
                print("and new cvar.")
                print("existing: " + str(oldv.axes) + "new: " + newaxes)
                sys.exit(1)
            oldv.coordinates.extend(newcoordinates)
    else:
        ts = []
        for s in cvstore:
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

    argparser = argparse.ArgumentParser(description='Compile XML into TrueType instructions, embedded in a Python script.')
    argparser.add_argument("inputfile", help='Xgridfit (XML) file to process.')
    argparser.add_argument("outputfile", nargs='?', help="Name of Python script to output")
    argparser.add_argument('--novalidation', action="store_true", help="Skip validation of the input file")
    argparser.add_argument('--nocompilation', action="store_true", help="Skip compilation of the input file")
    argparser.add_argument('--expand', action="store_true", help="Convert file to expanded syntax, save, and exit")
    argparser.add_argument('--compact', action="store_true", help="Convert file to compact syntax, save, and exit")
    argparser.add_argument('--merge', action="store_true", help="Merge Xgridfit with existing instructions")
    argparser.add_argument('--quiet', action="store_true", help="No progress messages")
    args = argparser.parse_args()

    inputfile   = args.inputfile
    outputfile  = args.outputfile
    skipval     = args.novalidation
    skipcomp    = args.nocompilation
    expandonly  = args.expand
    compactonly = args.compact
    mergemode   = args.merge
    quietmode   = args.quiet

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

    inputfont = xgffile.xpath("/xgf:xgridfit/xgf:infile/text()", namespaces=ns)[0]
    thisFont = ttLib.TTFont(inputfont)
    functionBase = 0
    cvtBase      = 0
    storageBase  = 0
    maxStack     = 256
    if mergemode:
        maxInstructions = thisFont['maxp'].maxSizeOfInstructions
        storageBase = thisFont['maxp'].maxStorage
        st = thisFont['maxp'].maxStackElements
        if st > 256:
            maxStack = st
        functionBase = thisFont['maxp'].maxFunctionDefs
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

    glyph_list = str(etransform(xgffile, **{"get-glyph-list": "'yes'"}))
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

    maxFunction = etransform(xgffile, **{"function-count": "'yes'"})
    maxFunction = int(maxFunction) + functionBase

    fpgm_code = etransform(xgffile, **{"fpgm-only": "'yes'",
                           "function-base": str(functionBase),
                           "storage-base": str(storageBase),
                           "cvt-base": str(cvtBase)})
    install_functions(thisFont, fpgm_code, functionBase)

    if not quietmode:
        print("Getting prep table ...")

    prep_code = etransform(xgffile, **{"prep-only": "'yes'",
                           "function-base": str(functionBase),
                           "storage-base": str(storageBase),
                           "cvt-base": str(cvtBase)})
    install_prep(thisFont, prep_code, mergemode)

    # Now loop through the glyphs for which there is code.

    for g in glyph_list:
        if not quietmode:
            print("Processing glyph " + g)
        try:
            gt = "'" + g + "'"
            g_inst = etransform(xgffile, singleGlyphId=gt)
        except Exception as e:
            print(e)
            print("Entries in error log: " + str(len(etransform.error_log)))
            for entry in etransform.error_log:
                print('message from line %s, col %s: %s' % (entry.line, entry.column, entry.message))
        install_glyph_program(g, thisFont, compact_instructions(str(g_inst), safe_calls))

    if not quietmode:
        print("Cleaning up and writing the new font")
    thisFont['maxp'].maxSizeOfInstructions = maxInstructions + 50
    thisFont['maxp'].maxTwilightPoints = 25
    thisFont['maxp'].maxStorage = 64
    thisFont['maxp'].maxStackElements = 256
    thisFont['maxp'].maxFunctionDefs = maxFunction
    thisFont['head'].flags |= 0b0000000000001000
    outputfont = str(xgffile.xpath("/xgf:xgridfit/xgf:outfile/text()", namespaces=ns)[0])
    thisFont.save(outputfont, 1)
