# xgridfit-3
A TrueType hinting language

Xgridfit is an XML-based language for hinting TrueType fonts. It has been around since circa 2006 but has never been popular; and in recent years it has been broken by its dependence on LibXML2's obsolete Python bindings. In fact, that old version suffered from a welter of dependencies: FontForge and various XML parsers and validators. It was verbose, too, and its verbosity wasn't entirely relieved by the use of auto-completing XML editors like Emacs/Nxml and oXygen. And then, autohinting with ttfautohint works extremely well for most TrueType fonts.

What I can say for Xgridfit, though, is that it was the tool I wanted back when I first wrote it, and I still like using it. It produces very compact instructions, adding relatively little to the size of a font, and it allows fine control over the programming without resorting to low-level assembly code. In fonts for modern devices, for which only vertical hinting is necessary, development can be fast (comparing well with, say, VTT, in which the graphical interface is very fast but one spends a good bit of time fine-tuning the code). And it provides several conveniences that collectively make it easy to refer to points, functions, and other objects, re-use blocks of code (including whole glyph programs), and revise the code when a glyph changes.

Version 3 throws away the elaborate command-line interface of version 2, and with it most of the program's dependencies: it now requires only Python3, fontTools, and lxml. It introduces new shorter tags for the most commonly used commands, making Xgridfit code quicker to write. It also has a new, compact syntax for points and calls to functions and macros. So, for example, to move point `b` relative to point `a` and then shift points `c`, `d` and `e` relative to `b`, you wrote this in Xgridfit 2:

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

That syntax still works in Xgridfit 3, but this is quicker to write, and no less intelligible, once you've got the hang of it:

```
<mv di="lcrs" r="a" p="b">
  <sh p="c d e"/>
</mv>
```

Because hinting is now done almost exclusively on the y axis, Xgridfit 3 has an "assume-always-y" default setting which allows optimization of some rounding operations, and also relieves you of having to tediously repeat ``<set-vectors> (<setvs>)`` and ``<interpolate-untouched-points> (<iup>)`` at the beginning and end of every glyph program.

Finally Xgridfit 3 can produce a cvar table, and thus can hint variable fonts.

To run Xgridfit 3, unzip the program files in any convenient place and run the program `xgridfit.py` with Python3, e.g.

```
$ python3 /Users/myaccount/fontprojects/xgridfit/Python/xgridfit.py MyFontInstructions.xgf out.py
```

To merge hints into your font, simply run the file `out.py` with Python3.

The original documentation is [here](http://xgridfit.sourceforge.net/). It is mostly still valid, but the many command-line options are largely gone: use `<default>` elements in your Xgridfit program file instead. An updated element reference is in the doc folder.

Xgridfit 3 is licensed under the Apache license, version 2.0.
