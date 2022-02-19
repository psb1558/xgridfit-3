# xgridfit-3
A TrueType hinting language

---

**New in version 3.2:**

You can now identify points by either index (the usual
method) or by coordinates. Instead of writing an integer, write the point's
coordinates in braces, separated by a semicolon, e.g. `{145;-12}`. This
feature takes advantage of the way [Glyphs](https://glyphsapp.com/),
[fontmake](https://github.com/googlefonts/fontmake), and presumably other
programs keep on-curve points at the same location when generating fonts.
A small Python script for Glyphs is included, which copies the coordinates
of selected points to the clipboard in the format required by Xgridfit. This
feature is especially useful for variable fonts.

---

Xgridfit is an XML-based language for hinting TrueType fonts. It has been around since circa 2006 but has never been popular (I know of three fonts besides my own that it was used to hint); and in recent years it has been broken by its dependence on LibXML2's obsolete Python bindings. In fact, that old version suffered from a welter of dependencies: FontForge and various XML parsers and validators. It was verbose, too, and its verbosity wasn't entirely relieved by the use of auto-completing XML editors like Emacs/Nxml and oXygen. Finally, the arrangement whereby the compiler generated a Python script instead of interacting directly with the font was sort of braindead.

What I can say for Xgridfit, though, is that it was the tool I wanted back when I first wrote it, and I still find it useful. It produces very compact instructions, adding relatively little to the size of a font, and it allows fine control over the programming without resorting to low-level assembly code. It plays nice with autohinters (ttfautohint and VTT), allowing you to take over where those tools produce unsatisfying results. In fonts for modern devices, for which only vertical hinting is necessary, development can be fast (comparing well with, say, VTT, in which the graphical interface is very fast but one spends a good bit of time on repetitive tasks). And it provides several conveniences that collectively make it easy to refer to points, functions, and other objects, re-use blocks of code (including whole glyph programs), and revise the code when a glyph changes.

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

You used to call a function this way:

```
<call-function name="lc-serif">
  <with-param name="base" value="5"/>
  <with-param name="top" value="9"/>
</call-function>
```

and now you can call it this way:

```
<callf nm="lc-serif">
  base: 5, top: 9
</callf>
```

Because hinting is now done almost exclusively on the y axis, Xgridfit 3 has an "assume-always-y" default setting which allows optimization of some rounding operations, and also relieves you of having to tediously repeat ``<set-vectors> (<setvs>)`` and ``<interpolate-untouched-points> (<iup>)`` at the beginning and end of every glyph program. Distance-colors can now be associated with control-values, and a new default setting instructs Xgridfit to guess at the appropriate distance-color where none is given. Thus it is rarely necessary to indicate the color of individual moves.

Finally, Xgridfit 3 can produce a cvar table or combine its own cvar table with an existing one; in this and other ways it has been redesigned to work well with variable fonts.

To install Xgridfit, it is suggested that you run a Python3 virtual environment, as you very likely do already for programs like ttx and fontmake. Unzip the program files in any convenient place, change to the root directory (the one with setup.py in it) and type

```
$ pip install .
```
To run Xgridfit 3 from within the virtual environment, make sure the ``<inputfont>`` and ``<outputfont>`` elements are included in your program files (with the names of the original font and the one you want to write), and then

```
$ xgridfit MyFontInstructions.xgf
```

That's all! Xgridfit will compile the instructions in your ``.xgf`` file, open the font, merge in the new instructions, and save the font under a new name.

The original documentation is [here](http://xgridfit.sourceforge.net/). It is mostly still valid, but some obsolete features have been cleared away. An updated element reference is in the doc folder; for a quick summary of command-line arguments, type ``xgridfit -h``.

Xgridfit 3 is licensed under the Apache license, version 2.0.
