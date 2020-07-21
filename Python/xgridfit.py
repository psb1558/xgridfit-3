from lxml import etree
from fontTools import ttLib
import sys
import os
import re
import tempfile
import argparse

#      This file is part of xgridfit, version 3.
#      Licensed under the Apache License, Version 2.0.
#      Copyright (c) 2006-20 by Peter S. Baker

# First read the command-line arguments. At minimum we need the inputfile.

argparser = argparse.ArgumentParser(description='Compile XML into TrueType instructions.')
argparser.add_argument("inputfile", help='Xgridfit (XML) file to process.')
argparser.add_argument("outputfile", nargs='?', help="Name of Python script to output")
argparser.add_argument('--novalidation', action="store_true", help="Skip validation of the input file")
argparser.add_argument('--nocompilation', action="store_true", help="Skip compilation of the input file")
args = argparser.parse_args()

inputfile  = args.inputfile
outputfile = args.outputfile
skipval    = args.novalidation
skipcomp   = args.nocompilation

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

if len(xgffile.xpath("/xg:xgridfit/xg:pre-program", namespaces=ns)):
    xslfile = "xgridfit-ft.xsl"
    xslcvarfile = "cvar-tuple-sh.xsl"
    xgfschema = "xgridfit.xsd"
elif len(xgffile.xpath("/xg:xgridfit/xg:prep", namespaces=ns)):
    xslfile = "xgridfit-ft-sh.xsl"
    xslcvarfile = "cvar-tuple-sh.xsl"
    xgfschema = "xgridfit-sh.xsd"
else:
    print("The xgridfit program must contain a pre-program (prep) element,")
    print("even if it's empty.")
    sys.exit(1)

# Grab the xsl program. This is assumed to be in ../XSL/, relative to this
# Python file.

progpath = os.path.split(os.path.dirname(__file__))[0]
xslpath = progpath + "/XSL/" + xslfile
xslprog = etree.parse(xslpath)

# Validate the xgridfit program. We're using the XML Schema rather
# than the RelaxNG here, because most of the messages seem more
# intelligible.

if skipval:
    print("Skipping validation")
else:
    xmlschemadoc = etree.parse(progpath + "/Schemas/" + xgfschema)
    xmlschema = etree.XMLSchema(xmlschemadoc)
    xmlschema.assertValid(xgffile)

# Transform the xgridfit program to generate Python output.
    
if skipcomp:
    print("Skipping compilation")
else:
    cvarstring = "'none'"
    if have_cvar:
        # cvar has its own XSLT program. Generate TupleVariation
        # list as a big string and pass it to the main program
        # as a parameter.
        xslcvarpath = progpath + "/XSL/" + xslcvarfile
        xslcvarprog = etree.parse(xslcvarpath)
        ctransform = etree.XSLT(xslcvarprog)
        cvarresult = ctransform(xgffile)
        cvarstring = etree.XSLT.strparam(str(cvarresult))
    try:
        transform = etree.XSLT(xslprog)
        result = transform(xgffile, cvartable=cvarstring)
        # result = transform(xgffile)
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
