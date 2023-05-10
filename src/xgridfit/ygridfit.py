import yaml
from lxml import etree
import sys
import uuid
# import logging

XGF_NAMESPACE = "http://xgridfit.sourceforge.net/Xgridfit2"
XGF = "{%s}" % XGF_NAMESPACE
NSMAP = {None: XGF_NAMESPACE}

MOVETYPES = ["move", "whitedist", "blackdist", "stem", "graydist"]

DELTA_TRANSLATE = {
    4.0:    "8/2",
    3.5:    "7/2",
    3.0:    "6/2",
    2.5:    "5/2",
    2.0:    "4/2",
    1.5:    "3/2",
    1.0:    "8/8",
    0.875:  "7/8",
    0.75:   "6/8",
    0.625:  "5/8",
    0.5:    "4/8",
    0.375:  "3/8",
    0.25:   "2/8",
    0.125:  "1/8",
    -0.125: "-1/8",
    -0.25:  "-2/8",
    -0.375: "-3/8",
    -0.5:   "-4/8",
    -0.625: "-5/8",
    -0.75:  "-6/8",
    -0.875: "-7/8",
    -1.0:   "-8/8",
    -1.5:   "-3/2",
    -2.0:   "-4.2",
    -2.5:   "-5/2",
    -3.0:   "-6/2",
    -3.5:   "-7/2",
    -4.0:   "-8/2",
}

DEFAULT_TYPES = [
    "minimum-distance",
    "control-value-cut-in",
    "single-width",
    "single-width-cut-in",
    "delta-base",
    "delta-shift",
    "delta-break",
    "push-break",
    "max-twilight-points",
    "max-storage",
    "max-stack",
    "use-truetype-defaults",
    "cleartype",
    "round-state",
    "function-base",
    "compile-globals",
    "init-graphics",
    "color",
    "assume-always-y",
]

def closest_cv_delta(val):
    if val:
        l = list(DELTA_TRANSLATE.keys())
        return l[min(range(len(l)), key = lambda i: abs(l[i] - val))]
    return 


# logging.basicConfig(filename='ygridfit.log', encoding='utf-8', level=logging.DEBUG)

def build_cvt(source, xgf_doc):
    ck = source.keys()
    for c in ck:
        cvt_entry = source[c]
        cvt_element = etree.SubElement(xgf_doc, XGF + "control-value")
        cvt_element.set("name", c)
        if type(cvt_entry) is dict:
            try:
                cvt_element.set("value", str(cvt_entry['val']))
            except KeyError:
                print("Missing value for control value " + c)
                sys.exit(1)
            try:
                cvt_element.set("color", cvt_entry['col'])
            except KeyError:
                pass
        else:
            cvt_element.set("value", str(cvt_entry))

def build_cvar_from_masters(source, xgf_doc):
    # First survey cvt, gathering all var entries in a dict:
    # {master-id: {cv-id: val}}
    # Then iterate through the masters, plugging in the variant
    # CVs. Should end in exactly the same place as with
    # build_cvar.
    cvt_source = source["cvt"]
    masters_source = source["masters"]
    cvar_list = []
    k = masters_source.keys()
    # kk is an id that identifies a master internally. It associates variant
    # CVs with their masters.
    for kk in k:
        new_cvar_entry = {"regions": [], "vals": []}
        vars = masters_source[kk]["vals"]
        tag_k = vars.keys()
        for tag_kk in tag_k:
            new_cvar_entry["regions"].append({"tag": tag_kk, "val": vars[tag_kk]})
        # Search the cvt for variant CVs with kk as the "nm" key.
        # This could be way more efficient. Make a dict before embarking on this loop?
        cv_list = new_cvar_entry["vals"]
        cvt_k = cvt_source.keys()
        for cvt_kk in cvt_k:
            cvt_entry = cvt_source[cvt_kk]
            if "var" in cvt_entry:
                var = cvt_entry["var"]
                tags = var.keys()
                for tags_k in tags:
                    if tags_k == kk:
                        cv_list.append({"nm": cvt_kk, "val": var[tags_k]})
        if len(cv_list) > 0:
            cvar_list.append(new_cvar_entry)
    build_cvar(cvar_list, xgf_doc)

def build_cvar(source, xgf_doc):
    cvar_element = etree.SubElement(xgf_doc, XGF + "cvar")
    for c in source:
        tuple_element = etree.SubElement(cvar_element, XGF + "tuple")
        for r in c["regions"]:
            region_element = etree.SubElement(tuple_element, XGF + "region")
            region_element.set("tag", r["tag"])
            # region_element.set("bot", str(r["bot"]))
            # region_element.set("top", str(r["top"]))
            region_element.set("peak", str(r["val"]))
        for v in c["vals"]:
            value_element = etree.SubElement(tuple_element, XGF + "cvv")
            value_element.set("name", v["nm"])
            value_element.set("value", str(v["val"]))

def point_key(p):
    lk = {"align": 0, "interpolate": 1, "shift": 2, "stem": 3, "whitedist": 3, "blackdist": 3, "graydist": 3, "move": 3}
    try:
        k = lk[p['rel']]
    except (ValueError, KeyError):
        k = 3
    return k

def is_rounded(source, dflt):
    if 'round' in source:
        if type(source['round']) is bool:
            return(source['round'])
        else:
            return True
    return dflt

def install_refs(ref, parent_el):
    ref_element = etree.SubElement(parent_el, XGF + "reference")
    if type(ref) is list:
        for p in ref:
            build_point_el(ref_element, str(p))
            # point_element = etree.SubElement(ref_element, XGF + "point")
            # point_element.set("num", str(p))
    else:
        build_point_el(ref_element, str(ref))
        # point_element = etree.SubElement(ref_element, XGF + "point")
        # point_element.set("num", str(ref))

def build_dependent_moves(source, parent_el, move_type, refpt = None):
    move_el = etree.SubElement(parent_el, XGF + move_type)
    if is_rounded(source, False):
        b = source["round"]
        if type(b) is bool:
            b = translate_bool(b)
        move_el.set("round", b)
        # move_el.set("round", "yes")
    if 'ref' in source:
        install_refs(source['ref'], move_el)
    elif refpt != None:
        install_refs([refpt], move_el)
    if type(source['ptid']) is list:
        ancestor_point = source['ptid'][0]
        for p in source['ptid']:
            build_point_el(move_el, str(p))
            # point_element = etree.SubElement(move_el, XGF + "point")
            # point_element.set("num", str(p))
    else:
        if "alt-ptid" in source:
            ancestor_point = source["alt-ptid"]
        else:
            ancestor_point = source['ptid']
        build_point_el(move_el, ancestor_point)
        # point_element = etree.SubElement(move_el, XGF + "point")
        # point_element.set("num", str(source['ptid']))
    return ancestor_point

def build_point(source, parent_el, refpt = None):
    try:
        move_type = source["rel"]
    except KeyError:
        move_type = "move"
    if move_type in MOVETYPES:
        move_element = etree.SubElement(parent_el, XGF + "move")
        color = None
        if "col" in source:
            color = source['col']
        else:
            if move_type == "whitedist":
                color = "white"
            elif move_type == "stem" or move_type == "blackdist":
                color = "black"
        if color:
            move_element.set("color", color)
        distance = None
        if 'dist' in source:
            distance = str(source['dist'])
        if 'pos' in source:
            distance = str(source['pos'])
        if distance:
            move_element.set("distance", distance)
        if 'min' in source:
            min_dist = source['min']
            if type(min_dist) is bool:
                move_element.set("min-distance", translate_bool(min_dist))
        if not is_rounded(source, True):
            move_element.set("round", "no")
        else:
            try:
                if type(source['round']) is str:
                    move_element.set("round", source['round'])
            except Exception:
                pass
        if 'ref' in source:
            install_refs(source['ref'], move_element)
        elif refpt != None:
            install_refs([refpt], move_element)
        if type(source['ptid']) is list:
            for p in source['ptid']:
                build_point_el(move_element, p)
        else:
            build_point_el(move_element, source['ptid'])
        if 'points' in source:
            source['points'].sort(key=point_key)
            for pp in source['points']:
                build_point(pp, move_element)
    else:
        if move_type == "interpolate":
            refpt = None
        # logging.info("In else clause of build_point; refpt is " + str(refpt))
        ancestor_point = build_dependent_moves(source, parent_el, move_type, refpt)
        if 'points' in source:
            # source['points'].sort(key=point_key)
            for pp in source['points']:
                # logging.info("About to recurse: " + str(pp))
                build_point(pp, parent_el, ancestor_point)

def build_macro_function_call(source, glyph_el):
    # figure out whether we're calling a macro or a function.
    call_type = None
    if "macro" in source:
        call_type = "macro"
        call_el_name = "call-macro"
    elif "function" in source:
        call_type = "function"
        call_el_name = "call-function"
    assert call_type != None
    call_el = etree.SubElement(glyph_el, XGF + call_el_name)
    # For the "macro" or "function" item, we can have either a dict or a
    # string (if a string, it's the name of the function; if a dict, it's
    # got to have a nm key)
    if type(source[call_type]) is dict:
        keylist = source[call_type].keys()
        for k in keylist:
            if k == "nm":
                call_el.set("name", source[call_type][k])
            else:
                param_el = etree.SubElement(call_el, XGF + "with-param")
                param_el.set("name", k)
                param_el.set("value", str(source[call_type][k]))
    else:
        try:
            call_el.set("name", source[call_type])
        except TypeError:
            print("Error with name" + str(source[call_type]))
            sys.exit(1)
    # Now the point numbers. These must be key-value pairs. If we're calling a
    # macro, the value in such a pair can be a list (translated into an Xgridfit
    # set).
    keylist = source["ptid"].keys()
    ancestor_point = None
    for k in keylist:
        param_el = etree.SubElement(call_el, XGF + "with-param")
        param_el.set("name", k)
        content = source['ptid'][k]
        if type(content) is list:
            assert call_type == "macro"
            set_el = etree.SubElement(param_el, XGF + "set")
            get_ancestor_point = (len(content) == 1)
            for p in content:
                build_point_el(set_el, str(p))
                if get_ancestor_point:
                    ancestor_point = str(p)
                # point_el = etree.SubElement(set_el, XGF + "point")
                # point_el.set("num", str(p))
        else:
            param_el.set("value", str(content))
            ancestor_point = str(content)
    if 'points' in source:
        # source['points'].sort(key=point_key)
        for pp in source['points']:
            # logging.info("About to recurse: " + str(pp))
            build_point(pp, glyph_el, ancestor_point)

def build_point_el(parent_el, point_num):
    point_el = etree.SubElement(parent_el, XGF + "point")
    point_el.set("num", str(point_num))

def build_xy_block(nm, source, glyph_element, axis):
    try:
        xysection = source[axis]
        vectorset = etree.SubElement(glyph_element, XGF + "set-vectors")
        vectorset.set("axis", axis)
        # Can have several "points" blocks in an x or y block. All must
        # begin with "points" (e.g. "points_a"). Anything that
        # doesn't begin with "points" will be ignored.
        sk = xysection.keys()
        sklist = []
        for skk in sk:
            if skk.startswith("points"):
                sklist.append(skk)
        for skk in sklist:
            # xysection[skk].sort(key=point_key)
            for p in xysection[skk]:
                if "macro" in p or "function" in p:
                    build_macro_function_call(p, glyph_element)
                else:
                    build_point(p, glyph_element)
    except KeyError:
        pass
        #if axis == "y":
        #    print("Warning: no y points in glyph " + nm)

def build_glyph_program(nm, source, xgf_doc):
    glyph_element = etree.SubElement(xgf_doc, XGF + "glyph")
    glyph_element.set("ps-name", nm)
    if "props" in source:
        p = source['props']
        if "assume-y" in p:
            glyph_element.set("assume-y", translate_bool(p['assume-y']))
        if "init-graphics" in p:
            glyph_element.set("init-graphics", translate_bool(p['init-graphics']))
        if "xoffset" in p:
            glyph_element.set("xoffset", str(p['xoffset']))
        if "yoffset" in p:
            glyph_element.set("yoffset", str(p['yoffset']))
        if "compact" in p:
            glyph_element.set("compact", translate_bool(p['compact']))
    if "y" in source and "x" in source:
        glyph_element.set("assume-y", translate_bool(False))
    try:
        names = source["names"]
        nk = names.keys()
        for n in nk:
            if type(names[n]) is not list:
                constant_element = etree.SubElement(glyph_element, XGF + "constant")
                constant_element.set("name", n)
                constant_element.set("value", str(names[n]))
        for n in nk:
            if type(names[n]) is list:
                set_element = etree.SubElement(glyph_element, XGF + "set")
                set_element.set("name", n)
                for p in names[n]:
                  build_point_el(set_element, str(p))
    except KeyError as e:
        # An Exception here just means there is no "names" block for this glyph.
        # print(e)
        pass
    build_xy_block(nm, source, glyph_element, "x")
    build_xy_block(nm, source, glyph_element, "y")
    iup = etree.SubElement(glyph_element, XGF + "interpolate-untouched-points")
    if "y" in source and not "x" in source:
        iup.set("axis", "y")
    elif "x" in source and not "y" in source:
        iup.set("axis", "x")

def build_input_output(source, xgf_doc):
    if "in" in source:
        input_el = etree.SubElement(xgf_doc, XGF + "inputfont")
        input_el.text = source['in']
    if "out" in source:
        output_el = etree.SubElement(xgf_doc, XGF + "outputfont")
        output_el.text = source['out']

def build_defaults(source, xgf_doc):
    source_keys = source.keys()
    for d in source_keys:
        # ignore anything not recognized by Xgridfit (ygt's internal defaults)
        if d in DEFAULT_TYPES:
            default_el = etree.SubElement(xgf_doc, XGF + "default")
            default_el.set("type", d)
            v = source[d]
            if type(v) is bool:
                valstring = translate_bool(v)
            else:
                valstring = str(v)
            default_el.set("value", valstring)

def build_cvt_settings(source, cvt_source, xgf_doc):
    prep_el = etree.SubElement(xgf_doc, XGF + "pre-program")
    if "code" in source:
        newcode = source['code'].replace("\n", "")
        newxml = etree.XML(newcode)
        for n in newxml:
            prep_el.append(n)
    k = cvt_source.keys()
    # Round the CVs for which rounding has been requested.
    for kk in k:
        cvt_entry = cvt_source[kk]
        if "round" in cvt_entry and cvt_entry["round"]:
            round_el = etree.SubElement(prep_el, XGF + "round")
            round_el.set("value", kk)
    # Next the deltas. First sort first into blocks by "delta-shift" value.
    shift_blocks = {}
    for kk in k:
        cvt_entry = cvt_source[kk]
        if "deltas" in cvt_entry:
            delta_list = cvt_entry["deltas"]
            # Rem each entry in the delta_list has a size and a distance. The
            # distance encapsulates two values: dist and shift. A list of
            # deltas has to be sorted by size (resolution).
            new_delta_list = sorted(delta_list, key=lambda s: s['size'])
            for d in new_delta_list:
                val = d["distance"]
                dist = 0.0
                sh =   8
                if type(val) is str and "/" in val:
                    r = val.split("/", 1)
                    try:
                        dist = int(r[0])
                        sh   = int(r[1])
                    except Exception:
                        pass
                else:
                    try:
                        val = DELTA_TRANSLATE[closest_cv_delta(float(val))]
                        r = val.split("/", 1)
                        dist = int(r[0])
                        sh   = int(r[1])
                    except Exception as e:
                        pass
                if dist != 0 and dist >= -8 and dist <= 8:
                    if not sh in shift_blocks:
                        shift_blocks[sh] = []
                    shift_blocks[sh].append({"name": kk, "size": d["size"], "distance": dist})
    if len(shift_blocks) > 0:
        s = shift_blocks.keys()
        for ss in s:
            dshift = etree.SubElement(prep_el, XGF + "set-delta-shift")
            dshift.set("units-per-pixel", str(ss))
            cv_delta = etree.SubElement(prep_el, XGF + "control-value-delta")
            dblock = shift_blocks[ss]
            for dd in dblock:
                try:
                    dset_el = etree.SubElement(cv_delta, XGF + "delta-set")
                    dset_el.set("cv", dd["name"])
                    # Subtract the delta base. This can't be changed in ygt.
                    dset_el.set("size", str(int(dd["size"]) - 9))
                    dset_el.set("distance", str(int(dd["distance"])))
                except Exception as e:
                    pass
        dshift = etree.SubElement(prep_el, XGF + "set-delta-shift")
        dshift.set("units-per-pixel", str(8))
    # Now the "same as" entries. First sort into blocks by size, then go through
    # each block, creating "set-control-value" commands.
    size_blocks = {}
    for kk in k:
        cvt_entry = cvt_source[kk]
        # Surveying "same as" properties in CV list. First sort into blocks
        # by size.
        if "same-as" in cvt_entry:
            sa = cvt_entry["same-as"]
            if "below" in sa:
                below_key = (sa["below"]["ppem"], "<")
                if not below_key in size_blocks:
                    size_blocks[below_key] = []
                block = {}
                block["name"] = kk
                block["value"] = f"control-value({sa['below']['cv']})"
                size_blocks[below_key].append(block)
            if "above" in sa:
                above_key = (sa["above"]["ppem"], ">")
                if not above_key in size_blocks:
                    size_blocks[above_key] = []
                block = {}
                block["name"] = kk
                block["value"] = f"control-value({sa['above']['cv']})"
                size_blocks[above_key].append(block)
    s = size_blocks.keys()
    for ss in s:
        _size = ss[0]
        _op   = ss[1]
        if_el = etree.SubElement(prep_el, XGF + "if")
        if_el.set("test", "pixels-per-em " + _op + " " + str(_size))
        for b in size_blocks[ss]:
            set_cv_el = etree.SubElement(if_el, XGF + "set-control-value")
            set_cv_el.set("name", b["name"])
            set_cv_el.set("unit", "pixel")
            set_cv_el.set("value", b["value"])

def translate_bool(b):
    if b:
        return "yes"
    return "no"

def build_functions(source, xgf_doc):
    fk = source.keys()
    for f in fk:
        function_el = etree.SubElement(xgf_doc, XGF + "function")
        function_el.set("name", f)
        ffk = source[f].keys()
        for ff in ffk:
            if ff == "stack-safe":
                function_el.set("stack-safe", translate_bool(source[f][ff]))
            elif ff == "primitive":
                function_el.set("primitive", translate_bool(source[f][ff]))
            elif ff == "code":
                newcode = source[f]['code'].replace("\n", '')
                newxml = etree.XML(newcode)
                for n in newxml:
                    function_el.append(n)
            else:
                param_el = etree.SubElement(function_el, XGF + "param")
                param_el.set("name", ff)
                this_item = source[f][ff]
                if type(this_item) is dict:
                    if "val" in this_item and this_item['val'] != None:
                        param_el.set("value", str(this_item['val']))
                else:
                    if this_item != None:
                        param_el.set("value", str(this_item))

def build_macros(source, xgf_doc):
    fk = source.keys()
    for f in fk:
        macro_el = etree.SubElement(xgf_doc, XGF + "macro")
        macro_el.set("name", f)
        ffk = source[f].keys()
        for ff in ffk:
            if ff == "code":
                newcode = source[f]['code'].replace("\n", '')
                newxml = etree.XML(newcode)
                for n in newxml:
                    macro_el.append(n)
            else:
                param_el = etree.SubElement(macro_el, XGF + "param")
                param_el.set("name", ff)
                this_item = source[f][ff]
                if type(this_item) is dict:
                    if "val" in this_item and this_item['val'] != None:
                        param_el.set("value", str(this_item['val']))
                else:
                    if this_item != None:
                        param_el.set("value", str(this_item))

def ygridfit_parse(yamlfile):

    y_stream = open(yamlfile, 'r')
    y_doc = yaml.safe_load(y_stream)
    return ygridfit_parse_obj(y_doc)

def ygridfit_parse_obj(y_doc, single_glyph=None, glyph_list=None):
    y_keys = y_doc.keys()

    xgf_doc = etree.Element(XGF + "xgridfit", nsmap=NSMAP)

    for k in y_keys:
        if k == "font":
            build_input_output(y_doc[k], xgf_doc)
        elif k == "defaults":
            build_defaults(y_doc[k], xgf_doc)
        elif k == "prep":
            build_cvt_settings(y_doc[k], y_doc["cvt"], xgf_doc)
        elif k == "cvt":
            build_cvt(y_doc[k], xgf_doc)
        elif k == "masters":
            try:
                build_cvar_from_masters(y_doc, xgf_doc)
            except Exception as e:
                pass
        elif k == "cvar":
            if not "masters" in y_doc:
                build_cvar(y_doc[k], xgf_doc)
        elif k == "functions":
            build_functions(y_doc[k], xgf_doc)
        elif k == "macros":
            build_macros(y_doc[k], xgf_doc)
        elif k == "glyphs":
            if not single_glyph and not glyph_list:
                g_keys = y_doc[k].keys()
            elif glyph_list and not single_glyph:
                g_keys = glyph_list
            else:
                g_keys = [single_glyph]
            for g in g_keys:
                try:
                    build_glyph_program(g, y_doc[k][g], xgf_doc)
                except KeyError:
                    build_glyph_program(g, {}, xgf_doc)
                except Exception as e:
                    print("Exception in build_glyph_program:")
                    print(type(e))
                    print(e)
    return xgf_doc
