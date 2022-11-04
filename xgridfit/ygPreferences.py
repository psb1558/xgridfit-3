import yaml
from yaml import Loader, Dumper
import sys

class ygPreferences(dict):
    def __init__(self, *args, **kwargs):
        super(ygPreferences, self).__init__(*args, **kwargs)
        self["top_window"] = None
        self["show_off_curve_points"] = True
        self["show_point_numbers"] = False
        self["current_glyph"] = {}
        self["current_vector"] = "y"
        self["save_points_as"] = "indices"
        self["current_font"] = None
        self["show_metrics"] = True

    def top_window(self):
        return self["top_window"]

    def show_off_curve_points(self):
        return self["show_off_curve_points"]

    def set_show_off_curve_points(self, b):
        self["show_off_curve_points"] = b

    def show_point_numbers(self):
        return self["show_point_numbers"]

    def set_show_point_numbers(self, b):
        self["show_point_numbers"] = b

    def current_glyph(self, fontfile):
        try:
            return self["current_glyph"][fontfile]
        except Exception:
            return "A"

    def set_current_glyph(self, fontfile, gname):
        self["current_glyph"][fontfile] = gname

    def current_font(self):
        return self["current_font"]

    def set_current_font(self, f):
        self["current_font"] = f

    def points_as(self):
        return self["save_points_as"]

    def set_points_as(self, val):
        if val in ["indices", "coordinates"]:
            self["points_as"] = val

    def save_config(self):
        w = self["top_window"]
        del self["top_window"]
        f = open("yg_config.yaml", "w")
        f.write(yaml.dump(self, sort_keys=False, Dumper=Dumper))
        f.close()
        self["top_window"] = w

def open_config(top_window):
    try:
        pstream = open("yg_config.yaml", 'r')
        pref_dict = yaml.safe_load(y_stream)
        y_stream.close()
        p = ygPreferences()
        k = pref_dict.keys()
        for kk in k:
            p[kk] = pref_dict[kk]
        p["top_window"] = top_window
        return p
    except Exception:
        p = ygPreferences()
        p["top_window"] = top_window
        return p
