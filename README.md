# xgridfit-3
A TrueType hinting language

Xgridfit is an XML-based language for hinting TrueType fonts. It has been around since circa 2006 but has never been popular; and in recent years it has been broken by its dependence on LibXML2's obsolete Python bindings. In fact, that old version suffered from a welter of dependencies: FontForge and various XML parsers and validators. It was verbose, too, and its verbosity wasn't entirely relieved by the use of auto-completing XML editors like Emacs/Nxml and oXygen. Finally, the arrangement whereby the compiler generated a Python script instead of interacting directly with the font was sort of braindead.

What I can say for Xgridfit, though, is that it was the tool I wanted back when I first wrote it, and I still find it useful. It produces very compact instructions, adding relatively little to the size of a font, and it allows fine control over the programming without resorting to low-level assembly code. It plays nice with autohinters (ttfautohint and VTT), allowing you to take over where those tools produce unsatisfying results. In fonts for modern devices, for which only vertical hinting is necessary, development can be fast (comparing well with, say, VTT, in which the graphical interface is very fast but one spends a good bit of time fine-tuning the code). And it provides several conveniences that collectively make it easy to refer to points, functions, and other objects, re-use blocks of code (including whole glyph programs), and revise the code when a glyph changes.

Version 3 doesn't have nearly as many dependencies as version 2: it requires only Python3, setuptools, fontTools, and lxml. It introduces new shorter tags for the most commonly used commands, making Xgridfit code quicker to write. It also has a new, compact syntax for points and calls to functions and macros. So, for example, to move point `b` relative to point `a` and then shift points `c`, `d` and `e` relative to `b`, you wrote this in Xgridfit 2:

```
<move distance="lc-round-stem">
  <reference>
    <point num="a"/>
  </reference>
  <point num="b"/>
  <shift>
    <point num="c"/>
    <point num="d"/>
    <point num="e"/>
  </shift>
</move>
```

That syntax still works in Xgridfit 3, but this is quicker to write, and no less intelligible once you've got the hang of it:

```
<mv di="lcrs" r="a" p="b">
  <sh p="c d e"/>
</mv>
```

Because hinting is now done almost exclusively on the y axis, Xgridfit 3 has an "assume-always-y" default setting which allows optimization of some rounding operations, and also relieves you of having to tediously repeat ``<set-vectors> (<setvs>)`` and ``<interpolate-untouched-points> (<iup>)`` at the beginning and end of every glyph program. Distance-colors can now be associated with control-values, and a new default setting instructs Xgridfit to guess at the appropriate distance-color where none is given. Thus it is rarely necessary to indicate the color of individual moves.

Finally Xgridfit 3 can produce a cvar table or combine its own cvar table with an existing one; thus it can hint variable fonts.

To install, Xgridfit, it is suggested that you run a virtual environment, as you very likely do for programs like ttx and fontmake. Unzip the program files in any convenient place, change to the root directory (the one with setup.py in it) and type

```
$ pip install .
```
To run Xgridfit 3 from within the virtual environment, make sure the ``<infile>`` and ``outfile`` elements are included in your program files (with the names of the original font and the one you want to write), and then

```
$ xgridfit MyFontInstructions.xgf
```

That's all! Xgridfit will compile the instructions in your ``.xgf`` file, open the font, merge in the new instructions, and save the font under a new name.

The original documentation is [here](http://xgridfit.sourceforge.net/). It is mostly still valid, but the many command-line options are largely gone: use `<default>` elements in your Xgridfit program file instead. An updated element reference is in the doc folder.

Xgridfit 3 is licensed under the Apache license, version 2.0.
