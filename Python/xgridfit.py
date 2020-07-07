from lxml import etree
from fontTools import ttLib
import sys
import re
import tempfile
import os


#      This file is part of xgridfit, version 3.
#      Licensed under the Apache License, Version 2.0.
#      Copyright (c) 2006-20 by Peter S. Baker


inputfile = sys.argv[1]

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

xslfile = os.path.split(os.path.dirname(__file__))[0] + "/XSL/xgridfit-ft.xsl"
f = open(inputfile)
fstr = f.read().replace("\n", " ")
f.close()
tf = tempfile.TemporaryFile()
tf.write(bytearray(fixupShort(fstr), 'utf-8'))
xgfprog = etree.parse(xslfile)
tf.seek(0)
xgffile = etree.parse(tf)
tf.close()
transform = etree.XSLT(xgfprog)
result = transform(xgffile)
print(result)
