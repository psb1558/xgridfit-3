#MenuTitle: Display and copy coordinates
# -*- coding: utf-8 -*-
from Foundation import NSPoint
import subprocess
__doc__="""
Display coordinates of currently selected points in format used by Xgridfit and copy
them to the clipboard.
"""
def write_to_clipboard(output):
	process = subprocess.Popen(
		'pbcopy', env={'LANG': 'en_US.UTF-8'}, stdin=subprocess.PIPE)
	process.communicate(output.encode('utf-8'))

l = Glyphs.font.selectedLayers
currentLayer = l[0]
s = ""
for p in currentLayer.paths:
	for n in p.nodes:
		if n.selected:
			if len(s) > 0:
				s = s + " "
			s = s + "{" + str(round(n.position.x)) + ";" + str(round(n.position.y)) + "}"
if len(s) > 0:
	print(s)
	write_to_clipboard(s)
else:
	print("No points selected")
