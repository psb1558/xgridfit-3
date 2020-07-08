# xgridfit-3
A TrueType hinting language

Xgridfit is an XML-based language for hinting TrueType fonts. It has been around since circa 2006 but has never been popular; and in recent years it has been broken by its dependence on LibXML2's obsolete Python bindings. In fact, that old version suffered from a welter of dependencies: FontForge and various XML parsers and validators. It was verbose, too, and its verbosity wasn't entirely relieved by the use of auto-completing XML editors like Emacs/Nxml and oXygen. And then, autohinting with ttfautohint works extremely well for most TrueType fonts.

What I can say for Xgridfit, though, is that it was the tool I wanted back when I first wrote it, and I still like using it. It produces very compact instructions, adding relatively little to the size of a font, and it allows fine control over the programming without resorting to low-level assembly code. In fonts for modern devices, for which only vertical hinting is necessary, development can be fast (comparing well with, say, VTT, in which the graphical interface is very fast but one spends a good bit of time fine-tuning the code). And it provides several conveniences that collectively make it easy to refer to points, functions, and other objects, re-use blocks of code (including whole glyph programs), and revise the code when a glyph changes.

Version 3 throws away the elaborate command-line interface of version 2, and with it most of the program's dependencies: it now requires only Python 3, fontTools, and lxml. It introduces new shorter tags for the most commonly used commands, making Xgridfit code quicker to write. And it is licensed under the Apache license, version 2.0.

There is a tiny executable file in the examples folder; but you should generally run the file xgridfit.py, thus:

`> python3 xgridfit/Python/xgridfit.py Elstob-roman.xgf out.py`

which produces from the Xgridfit program file Elstob-roman.xgf a Python program, here named "out.py" (if you omit the name of the output file, it will be written to the console). Run this Python program to add hints to the target TrueType font.

The original documentation is [here](http://xgridfit.sourceforge.net/). Most of it is still valid, but most of the many command-line options are gone: use <default> elements in your Xgridfit program file instead. An updated element reference is in the doc folder.

For **variable fonts**, Xgridfit works well, but cannot yet add a cvar table (which may be added manually, using TTX -m). That is high up on the list of things to do.
