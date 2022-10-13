from PyQt6.QtCore import QObject, pyqtSignal
import defcon
import yaml
from yaml import Loader, Dumper
import uuid
import sys
import copy
from defcon import Font, Glyph

hint_type_nums  = {"anchor": 0, "align": 1, "shift": 1, "interpolate": 2,
                   "stem": 3, "whitespace": 3, "blackspace": 3, "grayspace": 3,
                   "move": 3, "macro": 4, "function": 4}

class SourceFile:
    """ The yaml source read from and written to by this program.
    """
    def __init__(self, filename):
        """ The constructor reads the file into the internal structure y_doc.
        """
        self.filename = filename
        y_stream = open(filename, 'r')
        self.y_doc = yaml.safe_load(y_stream)
        y_stream.close()

    def get_source(self):
        return self.y_doc

    def save_source(self):
        f = open(self.filename, "w")
        f.write(yaml.dump(self.y_doc, sort_keys=False, Dumper=Dumper))
        f.close()



class FontFiles:
    """ Keeps references to the font to be read (ufo or ttf) and the one to be
        written.
    """
    def __init__(self, source):
        """ Source is an internal representation of a yaml file, from which
            the names of the input and output font files can be retrieved.
        """
        self.data = source["font"]

    def in_font(self):
        if "in" in self.data:
            return self.data["in"]
        return None

    def out_font(self):
        if "out" in self.data:
            return self.data["out"]
        return None

class ygFont:
    """ Keeps all the font's data, including a defcon represenation of the font,
        the "source" structure built from the yaml file, and a structure for
        each section of the yaml file. All of the font data can be accessed
        through this class.

        Call this directly to open a font for the first time. After that,
        you only have to open the yaml file.
    """
    def __init__(self, source_file):
        self.source_file = SourceFile(source_file)
        self.source      = self.source_file.get_source()
        self.font_files  = FontFiles(self.source)
        self.dc_font     = defcon.Font(self.font_files.in_font())
        self.glyphs      = ygGlyphs(self.source).data
        self.defaults    = ygDefaults(self.source)
        self.cvt         = ygcvt(self.source)
        self.cvar        = ygcvar(self.source)
        self.functions   = ygFunctions(self.source)
        self.macros      = ygMacros(self.source)
        self.glyph_list  = []
        self.clean       = True
        for g in self.dc_font:
            if g.bounds:
                u = g.unicode
                if u == None:
                    u = 65535
                self.glyph_list.append((u, g.name))
        self.glyph_list.sort(key = lambda x : x[1])
        self.glyph_list.sort(key = lambda x : x[0])
        self.glyph_index = {}
        glyph_counter = 0
        for g in self.glyph_list:
            self.glyph_index[g[1]] = glyph_counter
            glyph_counter += 1

    def get_glyph(self, gname):
        try:
            # print(self.glyphs[gname])
            return self.glyphs[gname]
        except KeyError:
            return {"y": {"points": []}}

    def get_glyph_index(self, gname):
        return self.glyph_list.index(gname)

    def save_glyph_source(self, source, gname):
        if not gname in self.glyphs:
            self.glyphs[gname] = {}
        self.glyphs[gname] = source




class ygDefaults:
    def __init__(self, source):
        self.data = source["defaults"]

    def get_default(self, *args):
        if args[0] in self.data:
            return self.data[args[0]]
        return None

    def set_default(self, **kwargs):
        for key, value in kwargs.items():
            self.data[key] = value



class ygcvt:
    def __init__(self, source):
        self.data = source["cvt"]

    def get_cvs(self, cvt, cvtype, vector):
        """ Get a list of control values filtered by type and vector.
        """
        result = {}
        keys = self.data.keys()
        for key in keys:
            entry = self.data[key]
            if type(entry) is dict:
                if "type" in entry and "vector" in entry:
                    if entry["type"] == cvtype and entry["vector"] == vector:
                        result[key] = entry["val"]
        return result

    def get_list(self, cvt, type, vector):
        """ Run get_cvs, then format for presentation in a menu
        """
        result = []
        cvt_matches = self.get_cvs(cvt, type, vector)
        for key in cvt_matches:
            s = key # + " (" + str(cvt_matches[key]["val"]) + ")"
            result.append(s)
        return result

    def get_cv(self, name):
        """ Retrieve a control value by name.
        """
        if name in self.data:
            return self.data[name]
        return None



class ygcvar:
    def __init__(self, source):
        self.data = source["cvar"]



class ygCallable:
    def __init__(self, callable_type, source):
        self.data = source[callable_type]

    def complete_list(self):
        return self.data.keys()

    def get_by_name(self, name):
        return self.data[name]

    def with_n_point_params(self, n):
        callables = []
        kk = self.data.keys()
        for k in kk:
            if self.number_of_point_params(k) == n:
                callables.append(k)
        return callables

    def number_of_point_params(self, name):
        param_count = 0
        if name in self.data:
            fn = self.data[name]
            keys = fn.keys()
            for k in keys:
                if type(fn[k]) is dict and "type" in fn[k]:
                    if fn[k]["type"] == "point":
                        param_count += 1
        return param_count

    def point_params_range(self, name):
        max_count = self.number_of_point_params(name)
        min_count = 0
        if name in self.data:
            fn = self.data[name]
            keys = fn.keys()
            for k in keys:
                if type(fn[k]) is dict and "type" in fn[k] and not "val" in fn[k]:
                    if fn[k]["type"] == "point":
                        min_count += 1
        return range(min_count, max_count+1)

    def point_list(self, name):
        plist = []
        if name in self.data:
            fn = self.data[name]
            keys = fn.keys()
            for k in keys:
                try:
                    if "type" in fn[k]:
                        if fn[k]['type'] == "point":
                            plist.append(k)
                except Exception:
                    pass
        return plist

    def required_point_list(self, name):
        plist = []
        if name in self.data:
            fn = self.data[name]
            keys = fn.keys()
            for k in keys:
                try:
                    if "type" in fn[k] and not "val" in fn[k]:
                        if fn[k]['type'] == "point":
                            plist.append(k)
                except Exception:
                    pass
        return plist

    def optional_point_list(self, name):
        plist = []
        if name in self.data:
            fn = self.data[name]
            keys = fn.keys()
            for k in keys:
                try:
                    if "type" in fn[k] and "val" in fn[k]:
                        if fn[k]['type'] == "point":
                            plist.append(k)
                except Exception:
                    pass
        return plist

    def non_point_params(self, name):
        pdict = {}
        if name in self.data:
            fn = self.data[name]
            keys = fn.keys()
            for k in keys:
                if k != "code" and  (not "type" in fn[k] or fn[k]['type'] != "point"):
                    if "val" in fn[k]:
                        pdict[k] = fn[k]["val"]
                    else:
                        pdict[k] = None
        return pdict



class ygFunctions(ygCallable):
    def __init__(self, source):
        super().__init__("functions", source)



class ygMacros(ygCallable):
    def __init__(self, source):
        super().__init__("macros", source)



class ygPoint:
    def __init__(self, name, index, x, y, xoffset, yoffset, on_curve):
        self.id = uuid.uuid1()
        self.name = name
        self.index = index
        self.font_x = x
        self.font_y = y
        self.coord = "{" + str(self.font_x - xoffset) + ";" + str(self.font_y - yoffset) + "}"
        self.on_curve = on_curve
        self.id = uuid.uuid1()

    def __eq__(self, other):
        try:
            return self.id == other.id
        except AttributeError:
            return False



class ygParams:
    """ Parameters to be sent to a macro or function. There are two sets of
        these: one consisting of points, the other anything else (e.g. cvt
        indexes).

    """
    def __init__(self, hint_type, name, point_dict, other_params):
        self.hint_type = hint_type
        self.name = name
        self.point_dict = point_dict
        self.other_params = other_params



class ygSet:
    """ Xgridfit has a structure called a 'set'--just a simple list of points.
        This can be the target for a shift, align or interpolate instruction,
        and a two-member set can be reference for an interpolate.

    """
    def __init__(self, point_list):
        self.point_list = point_list
        self.id = uuid.uuid1()
        # The main point is the one the arrow is connected to.
        self._main_point = None

    def main_point(self):
        if self._main_point:
            return self._main_point
        else:
            return self.point_list[0]

    # Not currently used. Is it needed?
    def point_at_index(self, index):
        try:
            return self.point_list[index]
        except Exception:
            return self.point_list[-1]



class ygHintNode:
    """ A wrapper for ygHint, with stuff for storing in a tree, and managing
        the tree.

    """

    hint_index = {}

    def __init__(self):
        self.data = None
        self.children = []

    def del_child(self, root, hint):
        owner = self._find_owner(hint)
        owner.children.remove(self)
        del ygHintNode.hint_index[hint.id]
        # If the deleted node had children, reconnect them as best we can.
        for c in self.children:
            root.add_child(root, c.data)

    def _find_owner(self, hint):
        found_hint = None
        for c in self.children:
            if c.data == hint:
                return(c)
            else:
                for cc in c.children:
                    return cc._find_owner(hint)
        return None

    def add_child(self, root, hint):
        # Wrap the hint in a node object and record it in the hint index.
        if type(hint) is ygHintNode:
            new_node = hint
        else:
            new_node = ygHintNode()
            new_node.data = hint
            ygHintNode.hint_index[new_node.data.id] = new_node

        # Find a place in the tree for the new hint.
        # If the new hint has a ref, see if there's a hint with a matching
        # target.
        if new_node.data.ref != None:
            found_nodes = self.search_tree(self, new_node.data.ref)
            if len(found_nodes) > 0:
                found_nodes[0].children.append(new_node)
                tgt = new_node.data.get_target()
                # Some top-level hints may be eligible for attachment as
                # children of the newly created node. We're going to have to
                # do more here, though, since some top-level hints may have
                # automatically added anchor hints.
                top_level_hints = []
                for c in self.children:
                    if c.data.get_target() == tgt:
                        top_level_hints.append(c)
                for t in top_level_hints:
                    if len(t.children) > 0:
                        new_node.children.extend(t.children)
                        self.children.remove(t)
            else:
                self.children.append(new_node)
        else:
            self.children.append(new_node)

    def search_tree(self, node, pt):
        """ Search for a target point (pt) in a tree (node).

        """
        result = []
        search_target = None
        searching_for = None
        if node.data:
            search_target = node.data.yg_glyph.resolve_point_identifier(node.data.get_target())
            searching_for = node.data.yg_glyph.resolve_point_identifier(pt)
        if search_target != None and searching_for != None and search_target == searching_for:
            result.append(node)
        for c in node.children:
            result.extend(self.search_tree(c, pt))
        return result

    def print_hint_tree(self, node, indent=""):
        """ Rough-and-ready print of the tree (for debugging).

        """
        if node.data:
            print(indent + str(node.data))
        else:
            print("root")
        for c in node.children:
            self.print_hint_tree(c, indent + " ")



class yamlTree:
    """ For building a tree of lists and dicts that the yaml package can
        dump to a yaml sequence.

        Parameters:
        yg_tree (ygHintNode): the node at the top of a glyph's hint hierarchy.
        vector (str): the current vector, "x" or "y".

    """
    def __init__(self, yg_tree, vector):
        self.yg_tree = yg_tree
        self.tree = {"points": []}
        self.build_yaml_tree(yg_tree, self.tree["points"])

    def build_yaml_tree(self, yg_tree, attach):
        yaml_hint = None
        if hasattr(yg_tree, "data") and yg_tree.data != None:
            yaml_hint = yamlNode(yg_tree.data).yaml_node
            attach.append(yaml_hint)
        if hasattr(yg_tree, "children") and len(yg_tree.children) > 0:
            for c in yg_tree.children:
                at = attach
                if yaml_hint != None:
                    at = yaml_hint["points"]
                self.build_yaml_tree(c, at)
        else:
            if yaml_hint != None:
                del yaml_hint["points"]



class yamlNode:
    """ A node in the yaml tree.

        Parameter:
        hint (ygHint): A hint to make this node from.

    """
    def __init__(self, hint):
        self.yaml_node = {"ptid": None,
                          "ref": None,
                          "macro": None,
                          "function": None,
                          "pos": None,
                          "rel": None,
                          "round": None,
                          "extra": {},
                          "points": []}
        self.other_params = None
        self.name = None

        # Every node has to have a ptid: a target point or structure.
        self.yaml_node["ptid"] = self.ptstruct_to_yaml(hint.target)
        if hint.ref != None:
            self.yaml_node["ref"] = self.ptstruct_to_yaml(hint.ref)
        else:
            del self.yaml_node["ref"]
        if ("ref-is-implicit" in hint.extra) and hint.extra["ref-is-implicit"]:
            if "ref" in self.yaml_node:
                del self.yaml_node["ref"]
                del hint.extra["ref-is-implicit"]
        if hint.hint_type in ["anchor", "macro", "function"]:
            del self.yaml_node["rel"]
        else:
            self.yaml_node["rel"] = hint.hint_type
        if hint.hint_type in ["macro", "function"]:
            if 'rel' in self.yaml_node:
                del self.yaml_node['rel']
            if hint.hint_type == "macro":
                if self.other_params != None and len(self.other_params) > 0:
                    self.yaml_node["macro"] = self.other_params
                    if hint.name != None:
                        self.yaml_node["macro"]["nm"] = hint.name
                else:
                    if hint.name != None:
                        self.yaml_node["macro"] = hint.name
                del self.yaml_node["function"]
            else:
                if self.other_params != None and len(self.other_params) > 0:
                    self.yaml_node["function"] = self.other_params
                    if hint.name != None:
                        self.yaml_node["function"]["nm"] = hint.name
                else:
                    if hint.name != None:
                        self.yaml_node["function"] = hint.name
                del self.yaml_node["macro"]
        if "macro" in self.yaml_node and self.yaml_node["macro"] == None:
            del self.yaml_node["macro"]
        if "function" in self.yaml_node and self.yaml_node["function"] == None:
            del self.yaml_node["function"]
        if hasattr(hint, "cvt") and hint.cvt != None:
            self.yaml_node["pos"] = hint.cvt
        else:
            del self.yaml_node["pos"]
        if hint.round_is_default():
            if "round" in self.yaml_node:
                del self.yaml_node["round"]
        else:
            self.yaml_node["round"] = hint.round
        if len(hint.extra) > 0:
            kk = hint.extra.keys()
            for k in kk:
                self.yaml_node["extra"][k] = hint.extra[k]
                if k == "target" or k == "ref":
                    self.yaml_node["extra"][k] = self.yaml_node["extra"][k].index
        else:
            del self.yaml_node["extra"]

    def ptstruct_to_yaml(self, obj):
        new_obj = None
        if type(obj) is ygSet:
            new_obj = []
            src = obj.point_list
            for p in src:
                new_obj.append(self.ptstruct_to_yaml(p))
        elif type(obj) is dict:
            new_obj = {}
            kk = obj.keys()
            for k in kk:
                new_obj[k] = self.ptstruct_to_yaml(obj[k])
        elif type(obj) is ygParams:
            # side effects. Strikes me as bad form, but
            self.other_params = obj.other_params
            self.name = obj.name
            new_obj = self.ptstruct_to_yaml(obj.point_dict)
        elif type(obj) is list:
            new_obj = []
            for p in obj:
                new_obj.append(self.ptstruct_to_yaml(p))
        elif type(obj) is ygPoint:
            # new_obj = obj.coord
            new_obj = obj.index
        elif type(obj) is int:
            new_obj = obj
        return new_obj



class ygGlyph(QObject):
    """ Keeps all the data for one glyph and provides an interface for
        changing it.

        Parameters:

        yg_font (ygFont): The font object, providing access to the defcon
        representation and the whole of the hinting source.

        gname (str): The name of this glyph.

    """

    sig_hints_changed = pyqtSignal(object)
    sig_glyph_source_ready = pyqtSignal(object)
    viewer_ready = False

    def __init__(self, yg_font, gname):
        """ Requires a ygFont object and the name of the glyph. This will also
            parse the glyph's x and y hints into a tree structure.
        """
        super().__init__()
        self.yaml_editor = None
        ygHintNode.hint_index = {}
        self.yg_font = yg_font
        self.gsource = yg_font.get_glyph(gname)
        self.gname = gname
        self.names = None
        self.props = None
        self.y_block = None
        self.x_block = None
        self.clean = True
        if "names" in self.gsource:
            self.names = copy.copy(self.gsource["names"])
        if "props" in self.gsource:
            self.props = copy.copy(self.gsource["props"])
        # Keep a copy of the source for this glyph separate from the main
        # body of code. Mark it as dirty only when we make substantive changes.
        if "y" in self.gsource:
            self.y_block = copy.copy(self.gsource["y"])
        if "x" in self.gsource:
            self.x_block = copy.copy(self.gsource["x"])
        try:
            self.defcon_glyph = yg_font.dc_font[gname]
        except KeyError:
            # ***Figure out something to do here that's not a crash.
            raise Exception("Tried to load nonexistent glyph " + gname)
        self.xoffset = 0
        self.yoffset = 0
        if self.props:
            if "xoffset" in self.props:
                self.xoffset = self.props["xoffset"]
            if "yoffset" in self.props:
                self.yoffset = self.props["yoffset"]
        # Going to run several indexes for this glyph's points. This is because
        # Xgridfit is permissive about naming, so we need several ways to look
        # up points. (Check later to make sure all these are being used.)
        # Get the defcon-style glyph.
        self.point_list = self._make_point_list()
        self.point_id_dict = {}
        for p in self.point_list:
            self.point_id_dict[p.id] = p
        self.point_coord_dict = {}
        for p in self.point_list:
            self.point_coord_dict[p.coord] = p
        # Copy the hint tree from the yaml source, flatten it into a list, and
        # build a new tree. This gives us a chance to insert implicit hints
        # and handle functions and macros properly. (on the to do list) The
        # default axis will be y. If there is no code yet, supply a stub.
        if not self.y_block:
            self.y_block = {"points": []}
        # Fix up the source and build a tree of ygHhint objects.
        k = self.y_block.keys()
        for kk in k:
            # This procedure is clunky and (no doubt) inefficient. I need to
            # work on doing it more simply, in one pass.
            self.yaml_add_parents(self.y_block[kk])
            self.yaml_supply_refs(self.y_block[kk])
            self.yaml_strip_parent_nodes(self.y_block[kk])
        self.current_block = self.y_block
        self.current_vector = "y"
        # This provides a flat list of ygHint objects.
        flat_list = self._flatten_hint_list_from_source(self.y_block)
        # Then rebuild it in to a tree of ygHintNode objects.
        self.hint_tree = self._build_hint_tree(flat_list)

        # This is the QGraphicsScene wrapper for this glyph object. But
        # do we need a reference here in the __init__? It's only used once,
        # in setting up a signal, and there are other ways to do that.
        self.glyph_viewer = None

        self.sig_hints_changed.connect(self.hints_changed)

    def save_source(self):
        """ Converts the working hint tree for this glyph to a yaml tree and
            calls ygFont.save_glyph_source to save it to the in-memory yaml
            source.

        """
        if not self.clean:
            s = {}
            if self.y_block:
                s['y'] = yamlTree(self.hint_tree, self.y_block).tree
            if self.x_block:
                s['x'] = yamlTree(self.hint_tree, self.x_block).tree
            self.yg_font.save_glyph_source(s, self.gname)
        # Also save the other things (cvt, etc.) if dirty.

    def set_yaml_editor(self, ed):
        self.sig_glyph_source_ready.connect(ed.install_source)
        self.send_yaml()

    def send_yaml(self):
        new_yaml = yamlTree(self.hint_tree, "y").tree
        self.sig_glyph_source_ready.emit(yaml.dump(new_yaml, sort_keys=False, Dumper=Dumper))

    def hint_changed(self, h):
        """ Called by signal from ygHint

        """
        self.clean = False
        self._rebuild_hint_tree()

    def hints_changed(self, hint_tree):
        """ Called by signal. *** Is this the best way to do this? Calling
            ygGlyphView directly? Figure out something else (compare
            sig_glyph_source_ready, for which we didn't have to import
            anything).

        """
        self.clean = False
        from ygHintEditor import ygGlyphViewer
        if self.glyph_viewer:
            self.glyph_viewer.install_hints(hint_tree)

    def _rebuild_hint_tree(self):
        """ Flatten the current tree and then rebuild it. Doing it this way
            limits the number of procedures we need for manipulating the tree.

        """
        flat_list = self._flatten_hint_list_from_tree(self.hint_tree)
        ygHintNode.hint_index = {}
        self.hint_tree = self._build_hint_tree(flat_list)

    def _build_hint_tree(self, flist):
        """ Assemble a tree from a flattened list of hint nodes and send a
            signal that it is ready.

        """
        root = ygHintNode()
        for hint in flist:
            root.add_child(root, hint)
        self.sig_hints_changed.emit(root)
        if hasattr(self, "hint_tree"):
            new_yaml = yamlTree(self.hint_tree, "y").tree
            self.gsource["y"] = yamlTree(self.hint_tree, "y")
            new_source = self.yg_font.get_glyph(self.gname)
            new_source["y"] = yamlTree(self.hint_tree, "y").tree
            self.sig_glyph_source_ready.emit(yaml.dump(new_source, sort_keys=False, Dumper=Dumper))
        return root

    def _flatten_hint_list_from_tree(self, node):
        result = []
        if node.data:
            result.append(node.data)
        for c in node.children:
            result.extend(self._flatten_hint_list_from_tree(c))
        return result

    def _flatten_hint_list_from_source(self, source):
        flist = []
        point_block_keys = source.keys()
        for k in point_block_keys:
            self._mk_hint_list(source[k], flist, parent=None)
        return flist

    def _mk_hint_list(self, source, flist, parent=None):
        """ 'source' is a yaml "points" block. A helper for
            _flatten_hint_list_from_source.

        """
        for pt in source:
            # Not your standard kwargs, but an ordinary dict passed as an arg.
            # kwargs = {"target": self.resolve_point_identifier(pt['ptid'])}
            target = self.resolve_point_identifier(pt['ptid'])
            if "ref" in pt:
                ref = self.resolve_point_identifier(pt["ref"])
            else:
                ref = None
            kwargs = {}
            if "pos" in pt:
                kwargs['cvt'] = pt['pos']
            if "dist" in pt:
                kwargs['cvt'] = pt['dist']
            if "rel" in pt:
                kwargs['rel'] = pt['rel']
            if "macro" in pt:
                kwargs['macro'] = pt['macro']
                if type(pt['macro']) is str:
                    kwargs['name'] = pt['macro']
                elif type(pt['macro']) is dict:
                    kwargs['name'] = pt['macro']['nm']
            if "function" in pt:
                kwargs['function'] = pt['function']
                if type(pt['function']) is str:
                    kwargs['name'] = pt['function']
                elif type(pt['function']) is dict:
                    kwargs['name'] = pt['function']['nm']
            if "round" in pt:
                kwargs['round'] = pt['round']
            if "parent" in pt:
                kwargs['parent'] = True
            if "extra" in pt:
                kwargs['extra'] = pt['extra']
            else:
                kwargs['extra'] = {}
            yg_hint = ygHint(self, target, ref, kwargs)
            flist.append(yg_hint)
            if "points" in pt:
                self._mk_hint_list(pt['points'], flist, parent=pt)

    def yaml_add_parents(self, node):
        """ Walk through the yaml source for one 'points' block, adding 'parent'
            items to each point dict so that we can easily climb the tree if we
            have to.

            We do this (and also supply refs) when we copy a "y" or "x" block
            from the main source file so we don't have to do it elsewhere.

        """
        for pt in node:
            if "points" in pt:
                for ppt in pt["points"]:
                    ppt["parent"] = pt
                self.yaml_add_parents(pt['points'])

    def yaml_strip_parent_nodes(self, node):
        for pt in node:
            if "parent" in pt:
                del pt["parent"]
            if "points" in pt:
                self.yaml_strip_parent_nodes(pt["points"])

    def yaml_supply_refs(self, node):
        """ After "parent" properties have been added, walk the tree supplying
            implicit references. If we can't find a reference, print a message
            but don't crash (yet). ***Figure out a way to handle a failure
            here gracefully.

        """
        if type(node) is list:
            for n in node:
                if not "extra" in n:
                    n['extra'] = {}
                if "rel" in n:
                    hint_type_num = hint_type_nums[n['rel']]
                    if "parent" in n:
                        if hint_type_num in [1, 2, 3]:
                            pp = n['parent']['ptid']
                            if type(pp) is list:
                                n['ref'] = pp[0]
                            else:
                                n['ref'] = pp
                            n['extra']['ref-is-implicit'] = True
                            if hint_type_num == 2:
                                n['ref'] = [n['ref']]
                                if "parent" in n['parent']:
                                    ppp = n['parent']['parent']['ptid']
                                    if type(ppp) is list:
                                        n['ref'].append(ppp[0])
                                    else:
                                        n['ref'].append(ppp)
                                    n['extra']['ref-is-implicit'] = True
                                else:
                                    print("Can't supply a reference for " + n['rel'] + ".")
                                    if "ref" in n:
                                        del n['ref']
                        else:
                            print("Can't supply a reference for " + n['rel'] + ".")
                            if "ref" in n:
                                del n['ref']
                if "points" in n:
                    self.yaml_supply_refs(n['points'])

    def _is_pt_obj(self, o):
        """ Whether an object is a 'point object' (a point or a container for
            points), which can appear in a ptid or ref field.

        """
        return type(o) is ygPoint or type(o) is ygSet or type(o) is ygParams

    def resolve_point_identifier(self, ptid, depth=0):
        """ Get the ygPoint object identified by ptid. ***Failures are very
            possible here, since there may be nonsense in a source file or in
            the editor. Figure out how to handle failures gracefully.

            Parameters:
            ptid (int, str): An identifier for a point. Xgridfit allows them
            to be in any of three styles: int (the raw index of the point),
            coordinates (in the format "{100;100}"), or name (from the
            glyph's "names" section). The identifier may point to a single
            point, a list of points, or a dict (holding named parameters for
            a macro or function).

            depth (int): How deeply nested we are. We give up if we get to 20.

            Returns:
            ygPoint, ygSet, ygParams: Depending whether the input was a point,
            a list of points, or a dict of parameters for a macro or function
            call.

        """
        result = ptid
        if self._is_pt_obj(ptid):
            return result
        if type(ptid) is list:
            new_list = []
            for p in ptid:
                new_list.append(self.resolve_point_identifier(p, depth=depth+1))
            return ygSet(new_list)
        elif type(ptid) is dict:
            new_dict = {}
            key_list = ptid.keys()
            for key in key_list:
                p = self.resolve_point_identifier(ptid[key], depth=depth+1)
                if isinstance(p, ygPoint):
                    p.name = key
                new_dict[key] = p
            return ygParams(None, None, new_dict, None)
        elif type(ptid) is int:
            result = self.point_list[ptid]
            if self._is_pt_obj(result):
                return result
        elif ptid in self.point_coord_dict:
            result = self.point_coord_dict[ptid]
            if self._is_pt_obj(result):
                return result
        elif self.names != None and ptid in self.names:
            result = self.names[ptid]
            if self._is_pt_obj(result):
                return result
        if result == None:
            raise Exception("obj " + str(ptid) + " resolved to None")
        if depth > 20:
            raise Exception("Failed to resolve point identifier " + str(ptid) + " (" + str(result) + ")")
        result = self.resolve_point_identifier(result, depth=depth+1)
        if self._is_pt_obj(result):
            return result

    def _make_point_list(self):
        """ Make a list of the points in a defcon glyph structure.

            Returns:
            A list of ygPoint objects.

        """
        pt_list = []
        point_index = 0
        for contour in self.defcon_glyph:
            for point in contour:
                is_on_curve = point.segmentType in ["qcurve", "line"]
                pt = ygPoint(None, point_index, point.x, point.y, self.xoffset, self.yoffset, is_on_curve)
                point_index += 1
                pt_list.append(pt)
        return(pt_list)

    def print_hint_tree(self, node, indent=""):
        if node.data:
            print(indent + str(node.data) + " " + str(node.data.target) + " " + str(node.data.ref))
        else:
            print("root")
        for c in node.children:
            self.print_hint_tree(c, indent + " ")



class ygGlyphs:
    """ The "glyphs" section of a yaml file.

    """
    def __init__(self, source):
        self.data = source["glyphs"]

    def get_glyph(self, gname):
        if gname in self.data:
            return self.data[gname]
        else:
            return {}



class ygHint(QObject):

    hint_changed_signal = pyqtSignal(object)

    # target is required; ref must be present here, but can be None.
    def __init__(self, glyph, target, ref, other_args={}):
        super().__init__()
        self.id = uuid.uuid1()
        self.yg_glyph = glyph
        self.parent = None
        self.implicit = False
        self.cvt = None
        self.name = None
        self.extra = {}
        self.round = False

        self.target = target
        self.ref = ref

        # Get hint type and other info
        if "rel" in other_args:
            self.hint_type = other_args["rel"]
        elif "macro" in other_args:
            self.hint_type = "macro"
            self.macro = other_args["macro"]
        elif "function" in other_args:
            self.hint_type  = "function"
            self.function = other_args["function"]
        else:
            self.hint_type = "anchor"
        if "name" in other_args:
            self.name = other_args["name"]
        if "cvt" in other_args:
            self.cvt = other_args["cvt"]
        #if "pos" in other_args:
        #    self.cvt = other_args["pos"]
        #if "dist" in other_args:
        #    self.cvt = other_args["dist"]
        if "extra" in other_args:
            kk = other_args["extra"].keys()
            for k in kk:
                self.extra[k] = other_args['extra'][k]
        if "round" in other_args:
            self.round = other_args["round"]
        else:
            self.round = hint_type_nums[self.hint_type] in [0, 3]

        self.hint_changed_signal.connect(self.yg_glyph.hint_changed)

    def get_target(self):
        if "target" in self.extra:
            return self.yg_glyph.resolve_point_identifier(self.extra["target"])
        elif type(self.target) is ygSet:
            return self.target.main_point()
        else:
            return self.target

    def set_extra_target(self, pt):
        """ In a function or macro call object. When set, they can behave in a
            tree like other hints.

        """
        if self.hint_type in ["macro", "function"]:
            self.extra["target"] = pt
        if not pt and "target" in self.extra:
            del self.extra["target"]
        self.hint_changed_signal.emit(self)

    def set_extra_ref(self, pt):
        """ In a function or macro call object. When set, they can behave in a
            tree like other hints.

        """
        if self.hint_type in ["macro", "function"]:
            self.extra["ref"] = pt
        if not pt and ("ref" in self.extra):
            del self.extra["ref"]
        self.hint_changed_signal.emit(self)

    def can_be_reversed(self):
        no_func = not hasattr(self, "function") or self.function == None
        no_macro = not hasattr(self, "macro") or self.macro == None
        return self.ref != None and no_func and no_macro

    def reverse_hint(self, h):
        if self.can_be_reversed():
            h.ref, h.target = h.target, h.ref
            self.hint_changed_signal.emit(h)

    def swap_macfunc_points(self, new_name, old_name):
        if type(self.target) is dict:
            try:
                self.target[new_name], self.target[old_name] = self.target[old_name], self.target[new_name]
            except Exception:
                self.target[new_name] = self.target[old_name]
                del self.target[old_name]
        elif type(self.target) is ygParams:
            try:
                self.target.point_dict[new_name], self.target.point_dict[old_name] = self.target.point_dict[old_name], self.target.point_dict[new_name]
            except Exception:
                self.target.point_dict[new_name] = self.target.point_dict[old_name]
                del self.target.point_dict[old_name]
        self.hint_changed_signal.emit(self)

    def change_hint_color(self, new_color):
        self.hint_type = new_color
        self.hint_changed_signal.emit(self)

    def round_hint(self):
        self.round = not self.round
        self.hint_changed_signal.emit(self)

    def round_is_default(self):
        dflt = hint_type_nums[self.hint_type] in [0, 3]
        return self.round == dflt

    def change_cv(self, new_cv):
        if self.hint_type in ["anchor", "stem", "whitespace", "blackspace", "grayspace"]:
            self.cvt = new_cv
            self.hint_changed_signal.emit(self)

    def hint_has_changed(self, h):
        self.hint_changed_signal.emit(h)

    def add_hint(self, hint):
        """ Add a hint to the hint tree.

        """
        self.yg_glyph.hint_tree.add_child(self.yg_glyph.hint_tree, hint)
        # See if I can get away with hint_changed_signal
        self.hint_changed_signal.emit(hint)

    def delete_hints(self, hint_list):
        """ Delete a hint from the hint tree.

        """
        flat_list = self.yg_glyph._flatten_hint_list_from_tree(self.yg_glyph.hint_tree)
        for h in hint_list:
            try:
                flat_list.remove(h)
            except ValueError:
                print("Didn't find hint in list: " + str(h) + " " + str(type(h)))
        self.yg_glyph.hint_tree = self.yg_glyph._build_hint_tree(flat_list)
        self.hint_changed_signal.emit(h)

    def print(*args, **kwargs):
        __builtin__.print("Hint target " + str(self.target) + "; ref: " + str(self.ref))
        return __builtin__.print(*args, **kwargs)

    def __str__(self):
        result = "Hint target: "
        result += str(self.target)
        result += "; ref: "
        result += str(self.ref)
        if hasattr(self, "parent"):
            result += "; parent: "
            result += str(self.parent)
        return result

    def __eq__(self, other):
        try:
            return self.id == other.id
        except:
            return False



class ygPointSorter:
    def __init__(self, vector):
        self.vector = vector

    def _ptcoords(self, p):
        if self.vector == "y":
            return p.font_y
        else:
            return p.font_x

    def sort(self, pt_list):
        pt_list.sort(key=self._ptcoords)
