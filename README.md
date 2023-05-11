# xgridfit-3
A TrueType hinting language

---

Xgridfit is an language for hinting TrueType fonts. It is an XML-based language, similar to (and in fact inspired by) XSLT. It has been around since before 2006, but version 3 was reborn as a (largely) Python program with Python dependencies. Xgridfit through version 2 was verbose and awkward to use. Version 3 featured a new compact syntax, and version 3.2.10 added a YAML-based language focused on describing the positions of points relative to the origin of a glyph's grid or to other points rather than issuing commands for positioning them. This language (call it Ygridfit) is simple and easy to write, but its main purpose is to support **ygt**, a graphical hinting tool.

Documentation of the XML-based language (both full and compact syntax), is available at the [GitHub development site](https://github.com/psb1558/xgridfit-3).

There is no release for the current version (3.2.18) at GitHub. Instead, install by downloading from PyPi:
```
pip install xgridfit
```
Alternatively, download the code from GitHub, change to the project's root directory (the one with the file `pyproject.toml` in it), and type:
```
pip install .
```
Version 3.3.0  merges most of main() (command line) and the former compile_all (called from Ygt) into one routine (run()). This enables 
merge-mode for Ygt.

Version 3.2.18 logs certain errors rather than exiting (an improvement when a backend for Ygt).

Version 3.2.17 has its own code for exporting to UFO rather than relying on ufoLib2.

Version 3.2.16 adds support for deltas in the YAML notation.

Version 3.2.15 fixes a bug that made a muddle of the cvar table, and removes an obnoxious message.

Version 3.2.14 is revised to accommmodate the new organization of cvar data in ygt.

Version 3.2.13 has small changes to maintain compatibility with ygt

Version 3.2.12 changes from fontTools.ufoLib to ufoLib2 for editing UFOs.

Version 3.2.11 adds the ability to save instructions and associated data to a UFO (version 3)

Version 3.2.10 supports "min" (minimum distance) attribute for hints and emits fewer messages when run from ygt.
