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

def fixupShort(s):
    s = re.sub(r'<callm\b', '<call-macro', s)
    s = re.sub(r'<\/callm\b', '</call-macro', s)
    s = re.sub(r'<callf\b', '<call-function', s)
    s = re.sub(r'<\/callf\b', '</call-function', s)
    s = re.sub(r'<callg\b', '<call-glyph', s)
    s = re.sub(r'<\/callg\b', '</call-glyph', s)
    s = re.sub(r'<callp\b', '<call-param', s)
    s = re.sub(r'<\/callp\b', '</call-param', s)
    s = re.sub(r'<pmset\b', '<param-set', s)
    s = re.sub(r'<\/pmset\b', '</param-set', s)
    s = re.sub(r'<cv\b\b', '<control-value', s)
    s = re.sub(r'<\/cv\b\b', '</control-value', s)
    s = re.sub(r'<fn\b', '<function', s)
    s = re.sub(r'<\/fn\b', '</function', s)
    s = re.sub(r'<mo\b', '<macro', s)
    s = re.sub(r'<\/mo\b', '</macro', s)
    s = re.sub(r'<gl\b', '<glyph', s)
    s = re.sub(r'<\/gl\b', '</glyph', s)
    s = re.sub(r'<pt\b', '<point', s)
    s = re.sub(r'<\/pt\b', '</point', s)
    s = re.sub(r'<pm\b', '<param', s)
    s = re.sub(r'<\/pm\b', '</param', s)
    s = re.sub(r'<var\b', '<variable', s)
    s = re.sub(r'<\/var\b', '</variable', s)
    s = re.sub(r'<wpm\b', '<with-param', s)
    s = re.sub(r'<\/wpm\b', '</with-param', s)
    s = re.sub(r'<setvs\b', '<set-vectors', s)
    s = re.sub(r'<\/setvs\b', '</set-vectors', s)
    s = re.sub(r'<wcv\b', '<with-control-value', s)
    s = re.sub(r'<\/wcv\b', '</with-control-value', s)
    s = re.sub(r'<ref\b', '<reference', s)
    s = re.sub(r'<\/ref\b', '</reference', s)
    s = re.sub(r'<al\b', '<align', s)
    s = re.sub(r'<\/al\b', '</align', s)
    s = re.sub(r'<sh\b', '<shift', s)
    s = re.sub(r'<\/sh\b', '</shift', s)
    s = re.sub(r'<ip\b', '<interpolate', s)
    s = re.sub(r'<\/ip\b', '</interpolate', s)
    s = re.sub(r'<cn\b', '<constant', s)
    s = re.sub(r'<\/cn\b', '</constant', s)
    s = re.sub(r'<wvs\b', '<with-vectors', s)
    s = re.sub(r'<\/wvs\b', '</with-vectors', s)
    s = re.sub(r'<setcv\b', '<set-control-value', s)
    s = re.sub(r'<\/setcv\b', '</set-control-value', s)
    s = re.sub(r'<iup\b', '<interpolate-untouched-points', s)
    s = re.sub(r'<\/iup\b', '</interpolate-untouched-points', s)
    s = re.sub(r'<prep\b', '<pre-program', s)
    s = re.sub(r'<\/prep\b', '</pre-program', s)
    s = re.sub(r'<mv\b', '<move', s)
    s = re.sub(r'<\/mv\b', '</move', s)
    s = re.sub(r'\bn=', 'num=', s)
    s = re.sub(r'\bnm=', 'name=', s)
    s = re.sub(r'\bval=', 'value=', s)
    s = re.sub(r'\bdi=', 'distance=', s)
    s = re.sub(r'\bpnm=', 'ps-name=', s)
    return(s)

# Steps (but isn't this awkward?):
# Read a file into a string and convert from short to long forms
# Write the result to a temporary file
# Read and parse the temporary file to get an etree
# Transform the etree.

progpath = os.path.split(os.path.dirname(__file__))[0]
xslfile = progpath + "/XSL/xgridfit-ft.xsl"
f = open(inputfile)
fstr = f.read().replace("\n", " ")
f.close()
tf = tempfile.TemporaryFile()
tf.write(bytearray(fixupShort(fstr), 'utf-8'))
xgfprog = etree.parse(xslfile)
tf.seek(0)
xgffile = etree.parse(tf)
tf.close()
if skipval:
    print("Skipping validation")
else:
    # XML Schema (it seems to give more intelligible error messages
    # than the relaxNG validator):
    xmlschemadoc = etree.parse(progpath + "/Schemas/xgridfit.xsd")
    xmlschema = etree.XMLSchema(xmlschemadoc)
    xmlschema.assertValid(xgffile)
    # RelaxNG:
    # relaxngdoc = etree.parse(progpath + "/Schemas/xgridfit.rng")
    # relaxng = etree.RelaxNG(relaxngdoc)
    # relaxng.assertValid(xgffile)
    # end of validation
if skipcomp:
    print("Skipping compilation")
else:
    transform = etree.XSLT(xgfprog)
    result = transform(xgffile)
    if outputfile:
        of = open(outputfile, "w")
        of.write(str(result))
        of.close()
    else:
        print(result)
