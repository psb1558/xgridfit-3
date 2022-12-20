# xgridfit-3
A TrueType hinting language

---

Xgridfit is an language for hinting TrueType fonts. It is an XML-based language, similar to (and in fact inspired by) XSLT. It has been around since before 2006, but version 3 was reborn as a (largely) Python program with Python dependencies. Xgridfit through version 2 was verbose and awkward to use. Version 3 featured a new compact syntax, and the current version (3.2.5) adds a YAML-based language focused on describing the positions of points relative to the origin of a glyph's grid or to other points rather than issuing commands for positioning them. This language (call it Ygridfit) is simple and easy to write, but its main purpose is to support **ygt**, a graphical hinting tool.

Documentation of the XML-based language (both full and compact syntax), is available at the [GitHub development site](https://github.com/psb1558/xgridfit-3).

There is no release for the current version (3.2.5) at GitHub. Instead, install by downloading from PyPi:
```
pip install xgridfit
```
Alternatively, download the code from this site, change to the project's root directory (the one with the file `pyproject.toml` in it), and type:
```
pip install .
```
