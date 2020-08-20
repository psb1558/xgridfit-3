from lxml import etree
from fontTools import ttLib
import sys
import os
import argparse

#      This file is part of xgridfit, version 3.
#      Licensed under the Apache License, Version 2.0.
#      Copyright (c) 2006-20 by Peter S. Baker

# First read the command-line arguments. At minimum we need the inputfile.

argparser = argparse.ArgumentParser(description='Compile XML into TrueType instructions, embedded in a Python script.')
argparser.add_argument("inputfile", help='Xgridfit (XML) file to process.')
argparser.add_argument("outputfile", nargs='?', help="Name of Python script to output")
argparser.add_argument('--novalidation', action="store_true", help="Skip validation of the input file")
argparser.add_argument('--nocompilation', action="store_true", help="Skip compilation of the input file")
argparser.add_argument('--expand', action="store_true", help="Convert file to expanded syntax, save, and exit")
argparser.add_argument('--compact', action="store_true", help="Convert file to compact syntax, save, and exit")
args = argparser.parse_args()

inputfile   = args.inputfile
outputfile  = args.outputfile
skipval     = args.novalidation
skipcomp    = args.nocompilation
expandonly  = args.expand
compactonly = args.compact

# Look for all program files relative to this python file:
# xsl files in ../XSL/, schemas in ../Schemas.

progpath = os.path.split(os.path.dirname(__file__))[0]

def validate(f, syntax, noval):
    schemafile = "xgridfit.rng"
    if syntax == "compact":
        schemafile = "xgridfit-sh.rng"
    if noval:
        print("Skipping validation")
    else:
        schema = etree.RelaxNG(etree.parse(progpath + "/Schemas/" + schemafile))
        schema.assertValid(f)

# Get the xgridfit file.

xgffile = etree.parse(inputfile)

# We'll need namespaces

ns = {"xg": "http://xgridfit.sourceforge.net/Xgridfit2",
          "xi": "http://www.w3.org/2001/XInclude"}

# Do xinclude if this is a multipart file

if len(xgffile.xpath("/xg:xgridfit/xi:include", namespaces=ns)):
    xgffile.xinclude()

# Test whether we have a cvar element

have_cvar = (len(xgffile.xpath("/xg:xgridfit/xg:cvar", namespaces=ns)) > 0)

# Next determine whether we are using long tagnames or short. Best way
# is to find out which tag is used for the required <pre-program> (<prep>)
# element. If we don't find it, print an error message and exit.

if len(xgffile.xpath("/xg:xgridfit/xg:prep", namespaces=ns)):
    # first validate
    validate(xgffile, "compact", skipval)
    # as we can't use the compact syntax, always expand
    etransform = etree.XSLT(etree.parse(progpath + "/XSL/expand.xsl"))
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
elif len(xgffile.xpath("/xg:xgridfit/xg:pre-program", namespaces=ns)):
    validate(xgffile, "normal", skipval)
    if compactonly:
        etransform = etree.XSLT(etree.parse(progpath + "/XSL/compact.xsl"))
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

# Now compile.

if skipcomp:
    print("# Skipping compilation")
else:
    cvarstring = "'none'"
    if have_cvar:
        # cvar has its own XSLT program. Generate TupleVariation
        # list as a big string and pass it to the main program
        # as a parameter.
        ctransform = etree.XSLT(etree.parse(progpath + "/XSL/cvar-tuple-sh.xsl"))
        cvarresult = ctransform(xgffile)
        cvarstring = etree.XSLT.strparam(str(cvarresult))
    try:
        # Do the transformation of xgridfit file to Python program
        # and store in string "result."
        transform = etree.XSLT(etree.parse(progpath + "/XSL/xgridfit-ft.xsl"))
        result = transform(xgffile, cvartable=cvarstring)
    except:
        for entry in transform.error_log:
            print('message from line %s, col %s: %s' % (
                entry.line, entry.column, entry.message))
            print('domain: %s (%d)' % (entry.domain_name, entry.domain))
            print('type: %s (%d)' % (entry.type_name, entry.type))
            print('level: %s (%d)' % (entry.level_name, entry.level))
            print('filename: %s' % entry.filename)
        sys.exit(1)
    if outputfile:
        of = open(outputfile, "w")
        of.write(str(result))
        of.close()
    else:
        print(result)
