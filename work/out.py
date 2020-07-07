from fontTools import ttLib
from fontTools.ttLib import ttFont, tables
from lxml import etree
import array

# Program generated by Xgridfit, version 3.0
# Don't edit this file unless you are very sure of what you're doing.

currentFont = ttLib.TTFont("Elstob[GRAD,opsz,wght].ttf")

maxInstructions = 200
for g_name in currentFont['glyf'].glyphs:
    glyph = currentFont['glyf'][g_name]
    if hasattr(glyph, 'program'):
        # print(glyph.program)
        glyph.program.fromAssembly("")

def install_glyph_program(nm, fo, asm):
    global maxInstructions
    g = fo['glyf'][nm]
    g.program = tables.ttProgram.Program()
    g.program.fromAssembly(asm)
    b = len(g.program.getBytecode())
    if b > maxInstructions:
        maxInstructions = b

currentFont['cvt '] = ttFont.newTable('cvt ')
setattr(currentFont['cvt '],'values',array.array('h', [0] * 21))
counter = 0
currentFont['cvt '][counter] = 891
counter += 1
currentFont['cvt '][counter] = 914
counter += 1
currentFont['cvt '][counter] = 57
counter += 1
currentFont['cvt '][counter] = 1487
counter += 1
currentFont['cvt '][counter] = 85
counter += 1
currentFont['cvt '][counter] = 39
counter += 1
currentFont['cvt '][counter] = 0
counter += 1
currentFont['cvt '][counter] = -23
counter += 1
currentFont['cvt '][counter] = 61
counter += 1
currentFont['cvt '][counter] = 1492
counter += 1
currentFont['cvt '][counter] = 51
counter += 1
currentFont['cvt '][counter] = 1128
counter += 1
currentFont['cvt '][counter] = 214
counter += 1
currentFont['cvt '][counter] = -501
counter += 1
currentFont['cvt '][counter] = -533
counter += 1
currentFont['cvt '][counter] = 1358
counter += 1
currentFont['cvt '][counter] = 1385
counter += 1
currentFont['cvt '][counter] = -27
counter += 1
currentFont['cvt '][counter] = 51
counter += 1
currentFont['cvt '][counter] = 61
counter += 1
currentFont['cvt '][counter] = 57
counter += 1

currentFont['fpgm'] = ttFont.newTable('fpgm')
currentFont['fpgm'].program = tables.ttProgram.Program()
currentFont['fpgm'].program.fromAssembly('PUSHB[ ]\n\
0\n\
FDEF[ ]\n\
PUSHB[ ]\n\
0\n\
0\n\
RS[ ]\n\
EQ[ ]\n\
PUSHB[ ]\n\
5\n\
SWAP[ ]\n\
JROF[ ]\n\
RTG[ ]\n\
PUSHB[ ]\n\
77\n\
JMPR[ ]\n\
PUSHB[ ]\n\
1\n\
0\n\
RS[ ]\n\
EQ[ ]\n\
PUSHB[ ]\n\
5\n\
SWAP[ ]\n\
JROF[ ]\n\
RTHG[ ]\n\
PUSHB[ ]\n\
64\n\
JMPR[ ]\n\
PUSHB[ ]\n\
2\n\
0\n\
RS[ ]\n\
EQ[ ]\n\
PUSHB[ ]\n\
5\n\
SWAP[ ]\n\
JROF[ ]\n\
RTDG[ ]\n\
PUSHB[ ]\n\
51\n\
JMPR[ ]\n\
PUSHB[ ]\n\
3\n\
0\n\
RS[ ]\n\
EQ[ ]\n\
PUSHB[ ]\n\
5\n\
SWAP[ ]\n\
JROF[ ]\n\
RDTG[ ]\n\
PUSHB[ ]\n\
38\n\
JMPR[ ]\n\
PUSHB[ ]\n\
4\n\
0\n\
RS[ ]\n\
EQ[ ]\n\
PUSHB[ ]\n\
5\n\
SWAP[ ]\n\
JROF[ ]\n\
RUTG[ ]\n\
PUSHB[ ]\n\
25\n\
JMPR[ ]\n\
PUSHB[ ]\n\
5\n\
0\n\
RS[ ]\n\
EQ[ ]\n\
PUSHB[ ]\n\
5\n\
SWAP[ ]\n\
JROF[ ]\n\
ROFF[ ]\n\
PUSHB[ ]\n\
12\n\
JMPR[ ]\n\
PUSHB[ ]\n\
6\n\
0\n\
RS[ ]\n\
EQ[ ]\n\
IF[ ]\n\
PUSHB[ ]\n\
1\n\
RS[ ]\n\
SROUND[ ]\n\
EIF[ ]\n\
ENDF[ ]\n\
PUSHB[ ]\n\
1\n\
FDEF[ ]\n\
NPUSHB[ ]\n\
0\n\
2\n\
1\n\
3\n\
5\n\
6\n\
7\n\
8\n\
10\n\
12\n\
9\n\
11\n\
13\n\
14\n\
15\n\
16\n\
RS[ ]\n\
WS[ ]\n\
RS[ ]\n\
WS[ ]\n\
RS[ ]\n\
WS[ ]\n\
RS[ ]\n\
WS[ ]\n\
RS[ ]\n\
WS[ ]\n\
RS[ ]\n\
WS[ ]\n\
RS[ ]\n\
WS[ ]\n\
RS[ ]\n\
WS[ ]\n\
ENDF[ ]\n\
PUSHB[ ]\n\
2\n\
FDEF[ ]\n\
PUSHB[ ]\n\
23\n\
SWAP[ ]\n\
WS[ ]\n\
PUSHB[ ]\n\
22\n\
SWAP[ ]\n\
WS[ ]\n\
PUSHB[ ]\n\
21\n\
SWAP[ ]\n\
WS[ ]\n\
PUSHB[ ]\n\
20\n\
SWAP[ ]\n\
WS[ ]\n\
PUSHB[ ]\n\
4\n\
0\n\
WS[ ]\n\
PUSHB[ ]\n\
20\n\
RS[ ]\n\
PUSHB[ ]\n\
21\n\
RS[ ]\n\
GT[ ]\n\
IF[ ]\n\
PUSHB[ ]\n\
20\n\
RS[ ]\n\
PUSHB[ ]\n\
21\n\
RS[ ]\n\
PUSHB[ ]\n\
20\n\
SWAP[ ]\n\
WS[ ]\n\
PUSHB[ ]\n\
21\n\
SWAP[ ]\n\
WS[ ]\n\
EIF[ ]\n\
PUSHB[ ]\n\
20\n\
RS[ ]\n\
DUP[ ]\n\
DUP[ ]\n\
PUSHB[ ]\n\
22\n\
RS[ ]\n\
NEQ[ ]\n\
SWAP[ ]\n\
PUSHB[ ]\n\
23\n\
RS[ ]\n\
NEQ[ ]\n\
AND[ ]\n\
IF[ ]\n\
DUP[ ]\n\
PUSHB[ ]\n\
4\n\
RS[ ]\n\
PUSHB[ ]\n\
1\n\
ADD[ ]\n\
PUSHB[ ]\n\
4\n\
SWAP[ ]\n\
WS[ ]\n\
EIF[ ]\n\
PUSHB[ ]\n\
1\n\
ADD[ ]\n\
DUP[ ]\n\
PUSHB[ ]\n\
21\n\
RS[ ]\n\
GT[ ]\n\
PUSHW[ ]\n\
-37\n\
SWAP[ ]\n\
JROF[ ]\n\
POP[ ]\n\
ENDF[ ]\n\
PUSHB[ ]\n\
3\n\
FDEF[ ]\n\
PUSHB[ ]\n\
20\n\
SWAP[ ]\n\
WS[ ]\n\
PUSHB[ ]\n\
21\n\
SWAP[ ]\n\
WS[ ]\n\
PUSHB[ ]\n\
20\n\
RS[ ]\n\
PUSHB[ ]\n\
21\n\
RS[ ]\n\
GT[ ]\n\
IF[ ]\n\
PUSHB[ ]\n\
21\n\
RS[ ]\n\
PUSHB[ ]\n\
20\n\
RS[ ]\n\
ELSE[ ]\n\
PUSHB[ ]\n\
20\n\
RS[ ]\n\
PUSHB[ ]\n\
21\n\
RS[ ]\n\
EIF[ ]\n\
ENDF[ ]\n\
PUSHB[ ]\n\
4\n\
FDEF[ ]\n\
DEPTH[ ]\n\
PUSHB[ ]\n\
17\n\
SWAP[ ]\n\
WS[ ]\n\
DEPTH[ ]\n\
PUSHB[ ]\n\
17\n\
RS[ ]\n\
SUB[ ]\n\
PUSHB[ ]\n\
1\n\
ADD[ ]\n\
CINDEX[ ]\n\
DEPTH[ ]\n\
PUSHB[ ]\n\
17\n\
RS[ ]\n\
SUB[ ]\n\
PUSHB[ ]\n\
7\n\
ADD[ ]\n\
CINDEX[ ]\n\
MIAP[1]\n\
DEPTH[ ]\n\
PUSHB[ ]\n\
17\n\
RS[ ]\n\
SUB[ ]\n\
PUSHB[ ]\n\
3\n\
ADD[ ]\n\
CINDEX[ ]\n\
DEPTH[ ]\n\
PUSHB[ ]\n\
17\n\
RS[ ]\n\
SUB[ ]\n\
PUSHB[ ]\n\
5\n\
ADD[ ]\n\
CINDEX[ ]\n\
DEPTH[ ]\n\
PUSHB[ ]\n\
17\n\
RS[ ]\n\
SUB[ ]\n\
PUSHB[ ]\n\
6\n\
ADD[ ]\n\
CINDEX[ ]\n\
PUSHB[ ]\n\
3\n\
SLOOP[ ]\n\
SHP[1]\n\
DEPTH[ ]\n\
PUSHB[ ]\n\
17\n\
RS[ ]\n\
SUB[ ]\n\
PUSHB[ ]\n\
2\n\
ADD[ ]\n\
CINDEX[ ]\n\
PUSHB[ ]\n\
18\n\
MIRP[01101]\n\
DEPTH[ ]\n\
PUSHB[ ]\n\
17\n\
RS[ ]\n\
SUB[ ]\n\
PUSHB[ ]\n\
4\n\
ADD[ ]\n\
CINDEX[ ]\n\
SHP[0]\n\
POP[ ]\n\
POP[ ]\n\
POP[ ]\n\
POP[ ]\n\
POP[ ]\n\
POP[ ]\n\
POP[ ]\n\
ENDF[ ]\n\
PUSHB[ ]\n\
5\n\
FDEF[ ]\n\
DEPTH[ ]\n\
PUSHB[ ]\n\
17\n\
SWAP[ ]\n\
WS[ ]\n\
DEPTH[ ]\n\
PUSHB[ ]\n\
17\n\
RS[ ]\n\
SUB[ ]\n\
PUSHB[ ]\n\
1\n\
ADD[ ]\n\
CINDEX[ ]\n\
PUSHB[ ]\n\
3\n\
MIAP[1]\n\
DEPTH[ ]\n\
PUSHB[ ]\n\
17\n\
RS[ ]\n\
SUB[ ]\n\
PUSHB[ ]\n\
1\n\
ADD[ ]\n\
CINDEX[ ]\n\
PUSHB[ ]\n\
1\n\
SUB[ ]\n\
DEPTH[ ]\n\
PUSHB[ ]\n\
17\n\
RS[ ]\n\
SUB[ ]\n\
PUSHB[ ]\n\
1\n\
ADD[ ]\n\
CINDEX[ ]\n\
PUSHB[ ]\n\
2\n\
SUB[ ]\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
SHP[1]\n\
POP[ ]\n\
ENDF[ ]\n\
PUSHB[ ]\n\
6\n\
FDEF[ ]\n\
DEPTH[ ]\n\
PUSHB[ ]\n\
17\n\
SWAP[ ]\n\
WS[ ]\n\
DEPTH[ ]\n\
PUSHB[ ]\n\
17\n\
RS[ ]\n\
SUB[ ]\n\
PUSHB[ ]\n\
1\n\
ADD[ ]\n\
CINDEX[ ]\n\
PUSHB[ ]\n\
1\n\
MIAP[1]\n\
DEPTH[ ]\n\
PUSHB[ ]\n\
17\n\
RS[ ]\n\
SUB[ ]\n\
PUSHB[ ]\n\
1\n\
ADD[ ]\n\
CINDEX[ ]\n\
PUSHB[ ]\n\
1\n\
SUB[ ]\n\
DEPTH[ ]\n\
PUSHB[ ]\n\
17\n\
RS[ ]\n\
SUB[ ]\n\
PUSHB[ ]\n\
1\n\
ADD[ ]\n\
CINDEX[ ]\n\
PUSHB[ ]\n\
2\n\
SUB[ ]\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
SHP[1]\n\
POP[ ]\n\
ENDF[ ]')
b = len(currentFont['fpgm'].program.getBytecode())
if b > maxInstructions:
    maxInstructions = b
currentFont['prep'] = ttFont.newTable('prep')
currentFont['prep'].program = tables.ttProgram.Program()
currentFont['prep'].program.fromAssembly('PUSHB[ ]\n\
2\n\
0\n\
3\n\
1\n\
0\n\
0\n\
1\n\
0\n\
WS[ ]\n\
WS[ ]\n\
RS[ ]\n\
WS[ ]\n\
RS[ ]\n\
WS[ ]\n\
PUSHB[ ]\n\
6\n\
64\n\
5\n\
64\n\
WS[ ]\n\
WS[ ]\n\
PUSHB[ ]\n\
8\n\
68\n\
7\n\
68\n\
WS[ ]\n\
WS[ ]\n\
PUSHB[ ]\n\
12\n\
0\n\
10\n\
0\n\
WS[ ]\n\
WS[ ]\n\
PUSHB[ ]\n\
11\n\
0\n\
9\n\
0\n\
WS[ ]\n\
WS[ ]\n\
PUSHB[ ]\n\
14\n\
9\n\
13\n\
9\n\
WS[ ]\n\
WS[ ]\n\
PUSHB[ ]\n\
16\n\
3\n\
15\n\
3\n\
WS[ ]\n\
WS[ ]\n\
SVTCA[0]\n\
SVTCA[0]')
b = len(currentFont['prep'].program.getBytecode())
if b > maxInstructions:
    maxInstructions = b

install_glyph_program("a", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
41\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
0\n\
SHP[1]\n\
PUSHB[ ]\n\
55\n\
MDRP[01101]\n\
PUSHB[ ]\n\
24\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
11\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
24\n\
SRP1[ ]\n\
PUSHB[ ]\n\
41\n\
SRP2[ ]\n\
PUSHB[ ]\n\
48\n\
IP[ ]\n\
PUSHB[ ]\n\
48\n\
SRP1[ ]\n\
PUSHB[ ]\n\
49\n\
SHP[1]\n\
IUP[0]")

install_glyph_program("b", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
9\n\
PUSHB[ ]\n\
5\n\
CALL[ ]\n\
PUSHB[ ]\n\
32\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
26\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
40\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
18\n\
2\n\
MIRP[01100]\n\
IUP[0]")

install_glyph_program("c", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
8\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
24\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
32\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("d", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
23\n\
PUSHB[ ]\n\
5\n\
CALL[ ]\n\
PUSHB[ ]\n\
14\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
47\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
5\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
0\n\
SHP[1]\n\
PUSHB[ ]\n\
40\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("e", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
26\n\
MDRP[01101]\n\
PUSHB[ ]\n\
8\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
18\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
8\n\
SRP1[ ]\n\
PUSHB[ ]\n\
0\n\
SRP2[ ]\n\
PUSHB[ ]\n\
12\n\
IP[ ]\n\
PUSHB[ ]\n\
12\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
12\n\
SRP0[ ]\n\
PUSHB[ ]\n\
15\n\
8\n\
MIRP[11100]\n\
IUP[0]")

install_glyph_program("f", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
36\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
0\n\
SHP[1]\n\
PUSHB[ ]\n\
37\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
10\n\
9\n\
MIAP[1]\n\
PUSHB[ ]\n\
26\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
36\n\
SRP1[ ]\n\
PUSHB[ ]\n\
10\n\
SRP2[ ]\n\
PUSHB[ ]\n\
32\n\
IP[ ]\n\
PUSHB[ ]\n\
32\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
32\n\
SRP0[ ]\n\
PUSHB[ ]\n\
33\n\
MDRP[11100]\n\
PUSHB[ ]\n\
1\n\
ALIGNRP[ ]\n\
IUP[0]")

install_glyph_program("longs", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
33\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
0\n\
SHP[1]\n\
PUSHB[ ]\n\
34\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
10\n\
9\n\
MIAP[1]\n\
PUSHB[ ]\n\
26\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
33\n\
SRP1[ ]\n\
PUSHB[ ]\n\
10\n\
SRP2[ ]\n\
PUSHB[ ]\n\
1\n\
IP[ ]\n\
PUSHB[ ]\n\
1\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
IUP[0]")

install_glyph_program("f.alt", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
37\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
0\n\
SHP[1]\n\
PUSHB[ ]\n\
38\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
11\n\
9\n\
MIAP[1]\n\
PUSHB[ ]\n\
26\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
37\n\
SRP1[ ]\n\
PUSHB[ ]\n\
11\n\
SRP2[ ]\n\
PUSHB[ ]\n\
33\n\
IP[ ]\n\
PUSHB[ ]\n\
33\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
33\n\
SRP0[ ]\n\
PUSHB[ ]\n\
34\n\
MDRP[11100]\n\
PUSHB[ ]\n\
1\n\
ALIGNRP[ ]\n\
IUP[0]")

install_glyph_program("g", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
51\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
65\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
51\n\
SRP1[ ]\n\
PUSHB[ ]\n\
75\n\
90\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
0\n\
14\n\
MIAP[1]\n\
PUSHB[ ]\n\
14\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
51\n\
SRP1[ ]\n\
PUSHB[ ]\n\
0\n\
SRP2[ ]\n\
PUSHB[ ]\n\
20\n\
43\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
IP[ ]\n\
PUSHB[ ]\n\
20\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
43\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
43\n\
SRP0[ ]\n\
PUSHB[ ]\n\
59\n\
2\n\
MIRP[11101]\n\
PUSHB[ ]\n\
29\n\
IP[ ]\n\
PUSHB[ ]\n\
29\n\
SRP2[ ]\n\
PUSHB[ ]\n\
28\n\
SHP[0]\n\
PUSHB[ ]\n\
20\n\
SRP0[ ]\n\
PUSHB[ ]\n\
36\n\
MDRP[11101]\n\
PUSHB[ ]\n\
7\n\
IP[ ]\n\
IUP[0]")

install_glyph_program("h", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
5\n\
PUSHB[ ]\n\
5\n\
CALL[ ]\n\
PUSHB[ ]\n\
35\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
28\n\
MDRP[01101]\n\
PUSHB[ ]\n\
11\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
12\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
12\n\
SRP1[ ]\n\
PUSHB[ ]\n\
17\n\
SHP[1]\n\
PUSHB[ ]\n\
11\n\
SRP1[ ]\n\
PUSHB[ ]\n\
0\n\
16\n\
21\n\
PUSHB[ ]\n\
3\n\
SLOOP[ ]\n\
SHP[1]\n\
IUP[0]")

install_glyph_program("dotlessi", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
8\n\
PUSHB[ ]\n\
6\n\
CALL[ ]\n\
PUSHB[ ]\n\
0\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
1\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
1\n\
SRP1[ ]\n\
PUSHB[ ]\n\
2\n\
14\n\
15\n\
PUSHB[ ]\n\
3\n\
SLOOP[ ]\n\
SHP[1]\n\
IUP[0]")

install_glyph_program("uni0237", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
21\n\
PUSHB[ ]\n\
6\n\
CALL[ ]\n\
PUSHB[ ]\n\
0\n\
14\n\
MIAP[1]\n\
PUSHB[ ]\n\
12\n\
MDRP[01100]\n\
PUSHB[ ]\n\
6\n\
MDRP[01100]\n\
IUP[0]")

install_glyph_program("dotaccent", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
11\n\
MIAP[1]\n\
PUSHB[ ]\n\
6\n\
12\n\
MIRP[01100]\n\
IUP[0]")

install_glyph_program("macron", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
2\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("macron.case", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
2\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("hyphen", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
2\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("hyphen.cap", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
2\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("endash", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
2\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("emdash", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
2\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("underscore", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
2\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("uni0305", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
2\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("uni0305.high", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
2\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("uni0305.med", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
2\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("uni0335", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
2\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("uni0335.sc", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
2\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("uni0335.wide", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
2\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("uni2010", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
2\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("uni2011", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
2\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("uni2015", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
2\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("plus", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
2\n\
MDAP[1]\n\
PUSHB[ ]\n\
5\n\
SHP[1]\n\
PUSHB[ ]\n\
3\n\
MDRP[01101]\n\
PUSHB[ ]\n\
2\n\
SHP[0]\n\
IUP[0]")

install_glyph_program("k", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
5\n\
PUSHB[ ]\n\
5\n\
CALL[ ]\n\
PUSHB[ ]\n\
27\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
28\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
27\n\
SRP1[ ]\n\
PUSHB[ ]\n\
32\n\
0\n\
11\n\
PUSHB[ ]\n\
3\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
28\n\
SRP1[ ]\n\
PUSHB[ ]\n\
33\n\
SHP[1]\n\
PUSHB[ ]\n\
39\n\
0\n\
MIAP[1]\n\
PUSHB[ ]\n\
22\n\
SHP[1]\n\
PUSHB[ ]\n\
38\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
39\n\
SRP1[ ]\n\
PUSHB[ ]\n\
27\n\
SRP2[ ]\n\
PUSHB[ ]\n\
16\n\
24\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
IP[ ]\n\
PUSHB[ ]\n\
16\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
24\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
16\n\
SRP0[ ]\n\
PUSHB[ ]\n\
17\n\
MDRP[11100]\n\
IUP[0]")

install_glyph_program("l", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
11\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
12\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
11\n\
SRP1[ ]\n\
PUSHB[ ]\n\
12\n\
SHP[1]\n\
PUSHB[ ]\n\
5\n\
PUSHB[ ]\n\
5\n\
CALL[ ]\n\
IUP[0]")

install_glyph_program("m", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
5\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
4\n\
3\n\
38\n\
58\n\
PUSHB[ ]\n\
4\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
38\n\
SRP0[ ]\n\
PUSHB[ ]\n\
31\n\
MDRP[11100]\n\
PUSHB[ ]\n\
51\n\
SHP[0]\n\
PUSHB[ ]\n\
11\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
12\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
11\n\
SRP1[ ]\n\
PUSHB[ ]\n\
16\n\
21\n\
0\n\
26\n\
44\n\
PUSHB[ ]\n\
5\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
12\n\
SRP1[ ]\n\
PUSHB[ ]\n\
17\n\
22\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
SHP[1]\n\
IUP[0]")

install_glyph_program("n", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
37\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
36\n\
35\n\
14\n\
PUSHB[ ]\n\
3\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
14\n\
SRP0[ ]\n\
PUSHB[ ]\n\
7\n\
MDRP[11100]\n\
PUSHB[ ]\n\
22\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
23\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
22\n\
SRP1[ ]\n\
PUSHB[ ]\n\
27\n\
32\n\
0\n\
PUSHB[ ]\n\
3\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
23\n\
SRP1[ ]\n\
PUSHB[ ]\n\
28\n\
SHP[1]\n\
IUP[0]")

install_glyph_program("o", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
8\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
24\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
16\n\
2\n\
MIRP[01101]\n\
IUP[0]")

install_glyph_program("p", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
5\n\
PUSHB[ ]\n\
6\n\
CALL[ ]\n\
PUSHB[ ]\n\
5\n\
SRP1[ ]\n\
PUSHB[ ]\n\
35\n\
SHP[1]\n\
PUSHB[ ]\n\
35\n\
SRP0[ ]\n\
PUSHB[ ]\n\
27\n\
2\n\
MIRP[11101]\n\
PUSHB[ ]\n\
11\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
19\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
43\n\
13\n\
MIAP[1]\n\
PUSHB[ ]\n\
44\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
0\n\
SHP[0]\n\
IUP[0]")

install_glyph_program("q", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
13\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
33\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
13\n\
SRP1[ ]\n\
PUSHB[ ]\n\
17\n\
SHP[1]\n\
PUSHB[ ]\n\
5\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
24\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
41\n\
13\n\
MIAP[1]\n\
PUSHB[ ]\n\
42\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
41\n\
SRP1[ ]\n\
PUSHB[ ]\n\
0\n\
SHP[1]\n\
IUP[0]")

install_glyph_program("r", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
37\n\
PUSHB[ ]\n\
6\n\
CALL[ ]\n\
PUSHB[ ]\n\
37\n\
SRP1[ ]\n\
PUSHB[ ]\n\
8\n\
SHP[1]\n\
PUSHB[ ]\n\
8\n\
SRP0[ ]\n\
PUSHB[ ]\n\
23\n\
MDRP[11100]\n\
PUSHB[ ]\n\
23\n\
SHP[0]\n\
PUSHB[ ]\n\
27\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
28\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
27\n\
SRP1[ ]\n\
PUSHB[ ]\n\
32\n\
SHP[1]\n\
IUP[0]")

install_glyph_program("s", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
24\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
40\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
10\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
24\n\
SRP1[ ]\n\
PUSHB[ ]\n\
0\n\
SRP2[ ]\n\
PUSHB[ ]\n\
48\n\
IP[ ]\n\
PUSHB[ ]\n\
48\n\
SRP1[ ]\n\
PUSHB[ ]\n\
16\n\
SHP[1]\n\
IUP[0]")

install_glyph_program("t", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
14\n\
MDAP[1]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
27\n\
MDRP[01101]\n\
PUSHB[ ]\n\
14\n\
SRP1[ ]\n\
PUSHB[ ]\n\
0\n\
SRP2[ ]\n\
PUSHB[ ]\n\
16\n\
IP[ ]\n\
PUSHB[ ]\n\
16\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
16\n\
SRP0[ ]\n\
PUSHB[ ]\n\
19\n\
MDRP[11101]\n\
PUSHB[ ]\n\
8\n\
SHP[0]\n\
IUP[0]")

install_glyph_program("u", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
7\n\
0\n\
MIAP[1]\n\
PUSHB[ ]\n\
27\n\
SHP[1]\n\
PUSHB[ ]\n\
6\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
26\n\
SHP[0]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
22\n\
SHP[1]\n\
PUSHB[ ]\n\
15\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("v", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
10\n\
0\n\
MIAP[1]\n\
PUSHB[ ]\n\
15\n\
SHP[1]\n\
PUSHB[ ]\n\
9\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
14\n\
SHP[0]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
4\n\
3\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
SHP[1]\n\
IUP[0]")

install_glyph_program("w", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
18\n\
0\n\
MIAP[1]\n\
PUSHB[ ]\n\
23\n\
28\n\
1\n\
9\n\
5\n\
14\n\
PUSHB[ ]\n\
6\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
17\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
22\n\
27\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
SHP[0]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
4\n\
3\n\
8\n\
12\n\
11\n\
PUSHB[ ]\n\
5\n\
SLOOP[ ]\n\
SHP[1]\n\
IUP[0]")

install_glyph_program("x", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
20\n\
0\n\
MIAP[1]\n\
PUSHB[ ]\n\
25\n\
5\n\
2\n\
PUSHB[ ]\n\
3\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
19\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
24\n\
SHP[0]\n\
PUSHB[ ]\n\
8\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
13\n\
0\n\
7\n\
PUSHB[ ]\n\
3\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
9\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
14\n\
SHP[0]\n\
IUP[0]")

install_glyph_program("y", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
21\n\
0\n\
MIAP[1]\n\
PUSHB[ ]\n\
26\n\
16\n\
10\n\
PUSHB[ ]\n\
3\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
20\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
25\n\
SHP[0]\n\
PUSHB[ ]\n\
0\n\
13\n\
MIAP[1]\n\
PUSHB[ ]\n\
6\n\
MDRP[01100]\n\
PUSHB[ ]\n\
21\n\
SRP1[ ]\n\
PUSHB[ ]\n\
0\n\
SRP2[ ]\n\
PUSHB[ ]\n\
15\n\
IP[ ]\n\
IUP[0]")

install_glyph_program("z", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
20\n\
0\n\
MIAP[1]\n\
PUSHB[ ]\n\
17\n\
6\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
8\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
3\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
0\n\
23\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
25\n\
10\n\
MIRP[01101]\n\
IUP[0]")

install_glyph_program("ae", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
49\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
56\n\
SHP[1]\n\
PUSHB[ ]\n\
35\n\
MDRP[01101]\n\
PUSHB[ ]\n\
10\n\
SHP[0]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
25\n\
SHP[1]\n\
PUSHB[ ]\n\
68\n\
MDRP[01101]\n\
PUSHB[ ]\n\
18\n\
SHP[0]\n\
PUSHB[ ]\n\
49\n\
SRP1[ ]\n\
PUSHB[ ]\n\
0\n\
SRP2[ ]\n\
PUSHB[ ]\n\
61\n\
IP[ ]\n\
PUSHB[ ]\n\
61\n\
SRP1[ ]\n\
PUSHB[ ]\n\
6\n\
SHP[1]\n\
IUP[0]")

install_glyph_program("thorn", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
5\n\
PUSHB[ ]\n\
5\n\
CALL[ ]\n\
PUSHB[ ]\n\
11\n\
13\n\
MIAP[1]\n\
PUSHB[ ]\n\
12\n\
10\n\
MIRP[01101]\n\
PUSHB[ ]\n\
11\n\
SRP1[ ]\n\
PUSHB[ ]\n\
0\n\
SHP[1]\n\
PUSHB[ ]\n\
40\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
32\n\
MDRP[01101]\n\
PUSHB[ ]\n\
16\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
24\n\
2\n\
MIRP[01101]\n\
IUP[0]")

install_glyph_program("eth", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
8\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
35\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
25\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
16\n\
MDAP[1]\n\
PUSHB[ ]\n\
16\n\
SRP1[ ]\n\
PUSHB[ ]\n\
8\n\
SRP2[ ]\n\
PUSHB[ ]\n\
44\n\
45\n\
46\n\
47\n\
PUSHB[ ]\n\
4\n\
SLOOP[ ]\n\
IP[ ]\n\
IUP[0]")

install_glyph_program("oslash", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
8\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
24\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
16\n\
2\n\
MIRP[01101]\n\
IUP[0]\n\
PUSHB[ ]\n\
8\n\
SRP1[ ]\n\
PUSHB[ ]\n\
34\n\
SHP[1]\n\
PUSHB[ ]\n\
0\n\
SRP1[ ]\n\
PUSHB[ ]\n\
32\n\
SHP[1]\n\
IUP[0]")

install_glyph_program("thorn.loclENG", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
8\n\
PUSHB[ ]\n\
5\n\
CALL[ ]\n\
PUSHB[ ]\n\
0\n\
14\n\
MIAP[1]\n\
PUSHB[ ]\n\
30\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
23\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
15\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
16\n\
2\n\
MIRP[01101]\n\
IUP[0]")

install_glyph_program("uni01BF", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
31\n\
PUSHB[ ]\n\
6\n\
CALL[ ]\n\
PUSHB[ ]\n\
23\n\
14\n\
MIAP[1]\n\
PUSHB[ ]\n\
15\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
8\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
1\n\
2\n\
MIRP[01101]\n\
IUP[0]")

install_glyph_program("eth.loclENG", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
8\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
35\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
26\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
13\n\
MDAP[1]\n\
PUSHB[ ]\n\
13\n\
SRP1[ ]\n\
PUSHB[ ]\n\
8\n\
SRP2[ ]\n\
PUSHB[ ]\n\
43\n\
47\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
IP[ ]\n\
PUSHB[ ]\n\
43\n\
SRP1[ ]\n\
PUSHB[ ]\n\
52\n\
SHP[1]\n\
PUSHB[ ]\n\
47\n\
SRP1[ ]\n\
PUSHB[ ]\n\
48\n\
SHP[1]\n\
IUP[0]")

install_glyph_program("eth.loclENG.alt", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
8\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
35\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
25\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
13\n\
MDAP[1]\n\
PUSHB[ ]\n\
13\n\
SRP1[ ]\n\
PUSHB[ ]\n\
8\n\
SRP2[ ]\n\
PUSHB[ ]\n\
45\n\
49\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
IP[ ]\n\
PUSHB[ ]\n\
45\n\
SRP1[ ]\n\
PUSHB[ ]\n\
54\n\
SHP[1]\n\
PUSHB[ ]\n\
49\n\
SRP1[ ]\n\
PUSHB[ ]\n\
50\n\
SHP[1]\n\
IUP[0]")

install_glyph_program("uniA77A.alt", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
8\n\
1\n\
MIAP[1]\n\
PUSHB[ ]\n\
35\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
26\n\
2\n\
MIRP[01101]\n\
PUSHB[ ]\n\
13\n\
MDAP[1]\n\
IUP[0]")

install_glyph_program("A", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
11\n\
16\n\
MIAP[1]\n\
PUSHB[ ]\n\
18\n\
SHP[1]\n\
PUSHB[ ]\n\
6\n\
0\n\
17\n\
26\n\
25\n\
31\n\
30\n\
PUSHB[ ]\n\
4\n\
CALL[ ]\n\
PUSHB[ ]\n\
11\n\
SRP1[ ]\n\
PUSHB[ ]\n\
30\n\
SRP2[ ]\n\
PUSHB[ ]\n\
21\n\
IP[ ]\n\
PUSHB[ ]\n\
21\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
21\n\
SRP0[ ]\n\
PUSHB[ ]\n\
22\n\
19\n\
MIRP[11101]\n\
IUP[0]")

install_glyph_program("B", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
17\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
18\n\
18\n\
MIRP[01100]\n\
PUSHB[ ]\n\
35\n\
15\n\
MIAP[1]\n\
PUSHB[ ]\n\
34\n\
18\n\
MIRP[01100]\n\
PUSHB[ ]\n\
35\n\
SRP1[ ]\n\
PUSHB[ ]\n\
17\n\
SRP2[ ]\n\
PUSHB[ ]\n\
37\n\
IP[ ]\n\
PUSHB[ ]\n\
37\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
37\n\
SRP0[ ]\n\
PUSHB[ ]\n\
37\n\
18\n\
MIRP[11101]\n\
IUP[0]")

install_glyph_program("C", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
10\n\
16\n\
MIAP[1]\n\
PUSHB[ ]\n\
15\n\
SHP[1]\n\
PUSHB[ ]\n\
22\n\
20\n\
MIRP[01101]\n\
PUSHB[ ]\n\
0\n\
17\n\
MIAP[1]\n\
PUSHB[ ]\n\
38\n\
SHP[1]\n\
PUSHB[ ]\n\
31\n\
20\n\
MIRP[01101]\n\
IUP[0]")

install_glyph_program("D", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
28\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
29\n\
18\n\
MIRP[01100]\n\
PUSHB[ ]\n\
26\n\
15\n\
MIAP[1]\n\
PUSHB[ ]\n\
25\n\
18\n\
MIRP[01100]\n\
IUP[0]")

install_glyph_program("E", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
34\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
0\n\
13\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
35\n\
18\n\
MIRP[01100]\n\
PUSHB[ ]\n\
5\n\
SHP[0]\n\
PUSHB[ ]\n\
32\n\
15\n\
MIAP[1]\n\
PUSHB[ ]\n\
1\n\
19\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
31\n\
18\n\
MIRP[01100]\n\
PUSHB[ ]\n\
18\n\
SHP[0]\n\
PUSHB[ ]\n\
32\n\
SRP1[ ]\n\
PUSHB[ ]\n\
34\n\
SRP2[ ]\n\
PUSHB[ ]\n\
22\n\
IP[ ]\n\
PUSHB[ ]\n\
22\n\
MDAP[1]\n\
PUSHB[ ]\n\
27\n\
SHP[1]\n\
PUSHB[ ]\n\
23\n\
19\n\
MIRP[11101]\n\
PUSHB[ ]\n\
27\n\
SHP[0]\n\
IUP[0]")

install_glyph_program("F", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
28\n\
15\n\
MIAP[1]\n\
PUSHB[ ]\n\
1\n\
10\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
27\n\
18\n\
MIRP[01100]\n\
PUSHB[ ]\n\
9\n\
SHP[0]\n\
PUSHB[ ]\n\
13\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
14\n\
18\n\
MIRP[01101]\n\
PUSHB[ ]\n\
13\n\
SRP1[ ]\n\
PUSHB[ ]\n\
0\n\
SHP[1]\n\
PUSHB[ ]\n\
28\n\
SRP1[ ]\n\
PUSHB[ ]\n\
13\n\
SRP2[ ]\n\
PUSHB[ ]\n\
18\n\
IP[ ]\n\
PUSHB[ ]\n\
18\n\
MDAP[1]\n\
PUSHB[ ]\n\
23\n\
SHP[1]\n\
PUSHB[ ]\n\
19\n\
19\n\
MIRP[11101]\n\
PUSHB[ ]\n\
23\n\
SHP[0]\n\
IUP[0]")

install_glyph_program("G", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
9\n\
16\n\
MIAP[1]\n\
PUSHB[ ]\n\
21\n\
20\n\
MIRP[01101]\n\
PUSHB[ ]\n\
9\n\
SRP1[ ]\n\
PUSHB[ ]\n\
15\n\
SHP[1]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
29\n\
20\n\
MIRP[01101]\n\
PUSHB[ ]\n\
9\n\
SRP1[ ]\n\
PUSHB[ ]\n\
0\n\
SRP2[ ]\n\
PUSHB[ ]\n\
38\n\
IP[ ]\n\
PUSHB[ ]\n\
38\n\
MDAP[1]\n\
PUSHB[ ]\n\
37\n\
18\n\
MIRP[01101]\n\
PUSHB[ ]\n\
35\n\
42\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
SHP[0]\n\
IUP[0]")

install_glyph_program("H", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
15\n\
5\n\
1\n\
28\n\
29\n\
23\n\
24\n\
PUSHB[ ]\n\
4\n\
CALL[ ]\n\
PUSHB[ ]\n\
6\n\
4\n\
0\n\
18\n\
17\n\
13\n\
12\n\
PUSHB[ ]\n\
4\n\
CALL[ ]\n\
PUSHB[ ]\n\
12\n\
SRP1[ ]\n\
PUSHB[ ]\n\
24\n\
SRP2[ ]\n\
PUSHB[ ]\n\
8\n\
IP[ ]\n\
PUSHB[ ]\n\
8\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
8\n\
SRP0[ ]\n\
PUSHB[ ]\n\
9\n\
19\n\
MIRP[11101]\n\
IUP[0]")

install_glyph_program("uni0126", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
15\n\
5\n\
1\n\
28\n\
29\n\
23\n\
24\n\
PUSHB[ ]\n\
4\n\
CALL[ ]\n\
PUSHB[ ]\n\
6\n\
4\n\
0\n\
18\n\
17\n\
13\n\
12\n\
PUSHB[ ]\n\
4\n\
CALL[ ]\n\
PUSHB[ ]\n\
12\n\
SRP1[ ]\n\
PUSHB[ ]\n\
24\n\
SRP2[ ]\n\
PUSHB[ ]\n\
8\n\
IP[ ]\n\
PUSHB[ ]\n\
8\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
8\n\
SRP0[ ]\n\
PUSHB[ ]\n\
9\n\
19\n\
MIRP[11101]\n\
IUP[0]\n\
PUSHB[ ]\n\
30\n\
SRP1[ ]\n\
PUSHB[ ]\n\
12\n\
SRP2[ ]\n\
PUSHB[ ]\n\
32\n\
IP[ ]\n\
PUSHB[ ]\n\
32\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
32\n\
SRP0[ ]\n\
PUSHB[ ]\n\
33\n\
19\n\
MIRP[11101]\n\
IUP[0]")

install_glyph_program("I", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
9\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
0\n\
SHP[1]\n\
PUSHB[ ]\n\
10\n\
18\n\
MIRP[01101]\n\
PUSHB[ ]\n\
6\n\
15\n\
MIAP[1]\n\
PUSHB[ ]\n\
1\n\
SHP[1]\n\
PUSHB[ ]\n\
5\n\
18\n\
MIRP[01101]\n\
IUP[0]")

install_glyph_program("J", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
26\n\
15\n\
MIAP[1]\n\
PUSHB[ ]\n\
17\n\
SHP[1]\n\
PUSHB[ ]\n\
25\n\
18\n\
MIRP[01101]\n\
PUSHB[ ]\n\
0\n\
MDAP[1]\n\
PUSHB[ ]\n\
11\n\
SHP[1]\n\
PUSHB[ ]\n\
6\n\
MDRP[01101]\n\
IUP[0]")

install_glyph_program("K", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
15\n\
17\n\
1\n\
41\n\
42\n\
36\n\
37\n\
PUSHB[ ]\n\
4\n\
CALL[ ]\n\
PUSHB[ ]\n\
30\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
0\n\
29\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
31\n\
18\n\
MIRP[01101]\n\
PUSHB[ ]\n\
28\n\
SHP[0]\n\
PUSHB[ ]\n\
37\n\
SRP1[ ]\n\
PUSHB[ ]\n\
30\n\
SRP2[ ]\n\
PUSHB[ ]\n\
11\n\
IP[ ]\n\
PUSHB[ ]\n\
11\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
11\n\
SRP0[ ]\n\
PUSHB[ ]\n\
12\n\
19\n\
MIRP[11101]\n\
PUSHB[ ]\n\
19\n\
SHP[0]\n\
IUP[0]")

install_glyph_program("L", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
15\n\
15\n\
MIAP[1]\n\
PUSHB[ ]\n\
1\n\
SHP[1]\n\
PUSHB[ ]\n\
14\n\
18\n\
MIRP[01101]\n\
PUSHB[ ]\n\
18\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
4\n\
0\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
19\n\
18\n\
MIRP[01101]\n\
PUSHB[ ]\n\
5\n\
SHP[0]\n\
IUP[0]")

install_glyph_program("M", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
6\n\
0\n\
22\n\
32\n\
31\n\
27\n\
26\n\
PUSHB[ ]\n\
4\n\
CALL[ ]\n\
PUSHB[ ]\n\
9\n\
15\n\
MIAP[1]\n\
PUSHB[ ]\n\
23\n\
38\n\
20\n\
1\n\
4\n\
14\n\
PUSHB[ ]\n\
6\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
8\n\
18\n\
MIRP[01101]\n\
PUSHB[ ]\n\
39\n\
SHP[0]\n\
IUP[0]")

install_glyph_program("N", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
27\n\
15\n\
MIAP[1]\n\
PUSHB[ ]\n\
13\n\
6\n\
17\n\
PUSHB[ ]\n\
3\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
26\n\
18\n\
MIRP[01100]\n\
PUSHB[ ]\n\
5\n\
SHP[0]\n\
PUSHB[ ]\n\
20\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
16\n\
0\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
21\n\
18\n\
MIRP[01100]\n\
PUSHB[ ]\n\
12\n\
SHP[0]\n\
IUP[0]")

install_glyph_program("O", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
10\n\
16\n\
MIAP[1]\n\
PUSHB[ ]\n\
30\n\
20\n\
MIRP[01100]\n\
PUSHB[ ]\n\
0\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
20\n\
20\n\
MIRP[01100]\n\
IUP[0]")

install_glyph_program("P", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
31\n\
15\n\
MIAP[1]\n\
PUSHB[ ]\n\
1\n\
SHP[1]\n\
PUSHB[ ]\n\
30\n\
18\n\
MIRP[01100]\n\
PUSHB[ ]\n\
24\n\
SHP[0]\n\
PUSHB[ ]\n\
33\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
0\n\
SHP[1]\n\
PUSHB[ ]\n\
34\n\
18\n\
MIRP[01100]\n\
PUSHB[ ]\n\
31\n\
SRP1[ ]\n\
PUSHB[ ]\n\
33\n\
SRP2[ ]\n\
PUSHB[ ]\n\
10\n\
IP[ ]\n\
PUSHB[ ]\n\
10\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
10\n\
SRP0[ ]\n\
PUSHB[ ]\n\
16\n\
20\n\
MIRP[11101]\n\
IUP[0]")

install_glyph_program("Q", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
11\n\
16\n\
MIAP[1]\n\
PUSHB[ ]\n\
37\n\
20\n\
MIRP[01100]\n\
PUSHB[ ]\n\
21\n\
7\n\
MIAP[1]\n\
PUSHB[ ]\n\
0\n\
SHP[1]\n\
PUSHB[ ]\n\
0\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
27\n\
20\n\
MIRP[01100]\n\
PUSHB[ ]\n\
46\n\
SHP[0]\n\
IUP[0]")

install_glyph_program("R", currentFont, "PUSHB[ ]\n\
1\n\
CALL[ ]\n\
SVTCA[0]\n\
PUSHB[ ]\n\
47\n\
15\n\
MIAP[1]\n\
PUSHB[ ]\n\
23\n\
SHP[1]\n\
PUSHB[ ]\n\
46\n\
18\n\
MIRP[01100]\n\
PUSHB[ ]\n\
20\n\
SHP[0]\n\
PUSHB[ ]\n\
40\n\
6\n\
MIAP[1]\n\
PUSHB[ ]\n\
22\n\
39\n\
PUSHB[ ]\n\
2\n\
SLOOP[ ]\n\
SHP[1]\n\
PUSHB[ ]\n\
41\n\
18\n\
MIRP[01100]\n\
PUSHB[ ]\n\
38\n\
SHP[0]\n\
PUSHB[ ]\n\
47\n\
SRP1[ ]\n\
PUSHB[ ]\n\
40\n\
SRP2[ ]\n\
PUSHB[ ]\n\
6\n\
IP[ ]\n\
PUSHB[ ]\n\
6\n\
DUP[ ]\n\
GC[0]\n\
ROUND[00]\n\
SCFS[ ]\n\
PUSHB[ ]\n\
6\n\
SRP0[ ]\n\
PUSHB[ ]\n\
11\n\
20\n\
MIRP[11101]\n\
PUSHB[ ]\n\
31\n\
IP[ ]\n\
IUP[0]")
currentFont['maxp'].maxSizeOfInstructions =  maxInstructions + 50
currentFont['maxp'].maxTwilightPoints = 25
currentFont['maxp'].maxStorage = 70
currentFont['maxp'].maxStackElements = 256
currentFont['maxp'].maxFunctionDefs = 7
currentFont.save("Elstob[GRAD,opsz,wght]-hinted.ttf", 1)

