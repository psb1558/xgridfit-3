from lxml import etree
from fontTools.ufoLib.filenames import userNameToFileName
from pathlib import Path
from typing import Optional

TT_TYPES = {
    "formatVersion":           "string",
    "controlValue":            "dict",
    "controlValueProgram":     "string",
    "fontProgram":             "string",
    "maxFunctionDefs":         "integer",
    "maxInstructionDefs":      "integer",
    "maxStackElements":        "integer",
    "maxStorage":              "integer",
    "maxSizeOfInstructions":   "integer",
    "maxTwilightPoints":       "integer",
    "maxZones":                "integer"
}

LIB_PLIST_TEMPLATE = """<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>public.truetype.instructions</key>
    <dict>
      <key>formatVersion</key>
      <string>1</string>
    </dict>
  </dict>
</plist>"""


class xgfUFOWriter:

    def __init__(self, ufo: str) -> None:
        u = Path(ufo)
        if u.is_dir():
            self.ufo = ufo
            self.valid = True
        else:
            self.valid = False

    def add_truetype_key(self, parent) -> list:
        k = etree.SubElement(parent, "key")
        k.text = "public.truetype.instructions"
        di = etree.SubElement(parent, "dict")
        fv_k = etree.SubElement(di, "key")
        fv_k.text = "formatVersion"
        fv_s = etree.SubElement(di, "string")
        fv_s.text = "1"
        return [k]

    def install_glyph_program(self, glyph: str, hash: str, prog: str) -> None:
        """ Done and tested.
            For details of how the hash must be constructed, see
            https://github.com/googlefonts/ufo2ft/blob/main/Lib/ufo2ft/instructionCompiler.py
            lines 57-67
        """
        filename = userNameToFileName(glyph) + ".glif"
        path = Path(self.ufo + "/glyphs/" + filename)
        tree = etree.parse(str(path))
        g = tree.xpath('/glyph')[0]
        # First check for key "public.truetype.instructions", then, if it
        # doesn't exist, build as much of the path to it as needed.
        k = tree.xpath('/glyph/lib/dict/key[text()="public.truetype.instructions"]')
        if not len(k):
            l = tree.xpath('/glyph/lib')
            if not len(l):
                l = [etree.SubElement(g, "lib")]
            d = tree.xpath("/glyph/lib/dict")
            if not len(d):
                d = [etree.SubElement(l[0], "dict")]
            k = self.add_truetype_key(d[0])
        di = k[0].getnext()
        if di.tag != "dict":
            print("Error: no dict following key 'public.truetype.instructions'.")
            return
        di_kids = list(di)
        # Empty out the instructions dict
        for di_kid in di_kids:
            di.remove(di_kid)
        t = etree.SubElement(di, "key")
        t.text = "formatVersion"
        t = etree.SubElement(di, "string")
        t.text = "1"
        t = etree.SubElement(di, "key")
        t.text = "id"
        t = etree.SubElement(di, "string")
        t.text = hash
        t = etree.SubElement(di, "key")
        t.text = "assembly"
        t = etree.SubElement(di, "string")
        t.text = prog
        output_string = etree.tostring(tree).decode()
        of = open(str(path), "w")
        of.write(output_string)
        of.close()

    def open_lib(self):
        """ If lib.plist exists, read and return the doc. If it doesn't, create a minimal doc
            using LIB_PLIST_TEMPLATE.
        """
        path = Path(self.ufo + "/lib.plist")
        err = False
        if path.is_file():
            try:
                tree = etree.parse(str(path))
            except Exception:
                err = True
        else:
            err = True
        if err:
            tree = etree.fromstring(bytes(LIB_PLIST_TEMPLATE, 'utf-8'))
        return tree
    
    def save_lib(self, tree):
        path = Path(self.ufo + "/lib.plist")
        of = open(str(path), "w")
        of.write(etree.tostring(tree).decode())
        of.close()

    def lib_tree(self, tree) -> tuple:
        """ Opens lib.plist and returns:
            1) The <key>public.truetype.instructions</key> element
            2) The <dict> element associated with (1). If it is None,
               the operation can't go on.
        """
        pdict = tree.xpath("/plist/dict")[0]
        if not len(pdict):
            print("Ill-formed lib.plist: it has no dict element")
            return None, None
        k = tree.xpath("/plist/dict/key[text()='public.truetype.instructions']")
        if not len(k):
            # k = [etree.SubElement(pdict, "key")]
            # k[0].text = "public.truetype.instructions"
            # di = etree.SubElement(pdict, "dict")
            k = self.add_truetype_key(pdict)
            di = k[0].getnext()
        else:
            di = k[0].getnext()
            if di == None:
                msg = "Ill-formed lib.plist: <key>public.truetype.instructions</key>"
                msg += " must be followed by a <dict> element."
                print(msg)
                return k[0], None
        return k[0], di

    def install_lib_item(self, tree, kk: str, d: str | int) -> None:
        # Where k is the key and d is the data. First openLib, then install this item
        # (guarding against dupication). This is only for string and integer types in
        # lib.plist.
        k, di = self.lib_tree(tree)
        if di == None:
            print("Ill formed lib.plist: no <dict> element")
            return
        di_kids = list(di)
        di_kid = None
        for dd in di_kids:
            if dd.tag == "key" and dd.text == kk:
                di_kid = dd
                break
        if di_kid != None:
            val = di_kid.getnext()
            if val == None or val.tag != TT_TYPES[kk]:
                print("Ill-formed lib.plist: no data for " + di_kid.tag)
                return
            # print("d : " + str(d))
            val.text = str(d)
        else:
            ke = etree.SubElement(di, "key")
            ke.text = kk
            val = etree.SubElement(di, TT_TYPES[kk])
            val.text = str(d)

    def mk_cv_dict(self, container, c):
        cc = list(container)
        for ccc in cc:
            container.remove(ccc)
        for i, cv in enumerate(c):
            k = etree.SubElement(container, "key")
            k.text = str(i)
            k = etree.SubElement(container, "integer")
            k.text = str(cv)

    def install_cvt(self, tree, c: list) -> None:
        # k       <key>public.truetype.instructions</key>
        # di        <dict>
        #             <key>formatVersion</key>
        #             <string>1</string>
        # di_kid      <key>controlValue</key>
        # val         <dict>
        # i             <key>i</key>
        # c[i]          <integer>c[i]</integer>
        #             </dict>
        #           </dict>
        k, di = self.lib_tree(tree)
        if di == None:
            msg = "Ill formed lib.plist: <key>public.truetype.instructions</key>"
            msg += "must be followed by a <dict> element."
            print(msg)
            return
        di_kids = list(di)
        di_kid = None
        for dd in di_kids:
            if dd.tag == "key" and dd.text == "controlValue":
                di_kid = dd
                break
        if di_kid != None:
            val = di_kid.getnext()
            if val == None or val.tag != "dict":
                msg = "Ill-formed lib.plist: <key>controlValue</key> must be"
                msg += " followed by a <dict> element."
                print(msg)
                return
            self.mk_cv_dict(val, c)
        else:
            di_kid = etree.SubElement(di, "key")
            di_kid.text = "controlValue"
            val = etree.SubElement(di, "dict")
            self.mk_cv_dict(val, c)

#uw = ufoWriter("/Users/peterbaker/work/GitHub/ygt/example/ElstobD-Regular.ufo")
# uw.install_glyph_program("C", "glyph program 2")
# uw.install_cvt([4, 3, 2, 1, 0])
#uw.install_lib_item("maxFunctionDefs", 5)
