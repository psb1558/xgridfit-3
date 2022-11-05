import sys
import os
import copy
import ygModel
import freetype
from ygPreview import ygPreview
import ygEditor
import ygHintEditor
import ygPreferences
from xgridfit import compile_one
from PyQt6.QtCore import Qt, QSize
from PyQt6.QtWidgets import (
    QWidget,
    QApplication,
    QMainWindow,
    QSplitter,
    QMessageBox,
    QInputDialog,
    QLineEdit,
    QFileDialog, QDialogButtonBox, QComboBox, QDialog, QScrollArea,
    QSizePolicy
)
from PyQt6.QtGui import (
    QPainter,
    QAction,
    QKeySequence,
    QIcon,
    QPixmap
)

class MainWindow(QMainWindow):
    def __init__(self, app, parent=None):
        super(MainWindow,self).__init__(parent=parent)
        self.setAttribute(Qt.WidgetAttribute.WA_AcceptTouchEvents, False)
        self.setWindowTitle("YG")
        self.toolbar = self.addToolBar("Tools")
        self.toolbar.setIconSize(QSize(32,32))
        spacer = QWidget()
        spacer.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding)
        self.toolbar.addWidget(spacer)
        self.qs = QSplitter(self)
        self.glyph_pane = None
        self.yg_font = None
        self.source_editor = None
        self.preview_scroller = None
        self.yg_preview = None
        self.app = app
        self.preferences = ygPreferences.ygPreferences()

        self.menu = self.menuBar()

        self.file_menu = self.menu.addMenu("&File")

        self.open_action = self.file_menu.addAction("Open")
        self.open_action.setShortcut(QKeySequence.StandardKey.Open)

        self.close_action = self.file_menu.addAction("Close")
        self.close_action.setShortcut(QKeySequence.StandardKey.Close)

        self.save_action = self.file_menu.addAction("Save")
        self.save_action.setShortcut(QKeySequence.StandardKey.Save)

        self.save_as_action = self.file_menu.addAction("Save As...")
        self.save_as_action.setShortcut(QKeySequence.StandardKey.SaveAs)

        self.save_font_action = self.file_menu.addAction("Save Font...")
        self.save_font_action.setShortcut(QKeySequence("Ctrl+e"))

        self.quit_action = self.file_menu.addAction("Quit")
        self.quit_action.setShortcut(QKeySequence.StandardKey.Quit)

        self.edit_menu = self.menu.addMenu("&Edit")

        self.cut_action = self.edit_menu.addAction("Cut")
        self.cut_action.setShortcut(QKeySequence.StandardKey.Cut)

        self.copy_action = self.edit_menu.addAction("Copy")
        self.copy_action.setShortcut(QKeySequence.StandardKey.Copy)

        self.paste_action = self.edit_menu.addAction("Paste")
        self.paste_action.setShortcut(QKeySequence.StandardKey.Paste)

        self.goto_action = self.edit_menu.addAction("Go to...")
        self.goto_action.setShortcut(QKeySequence("Ctrl+G"))

        self.preview_menu = self.menu.addMenu("&Preview")

        self.save_current_glyph_action = self.preview_menu.addAction("Update Preview")
        self.save_current_glyph_action.setShortcut(QKeySequence("Ctrl+u"))

        self.pv_bigger_one_action = self.preview_menu.addAction("Grow by One")
        self.pv_bigger_one_action.setShortcut(QKeySequence.StandardKey.MoveToPreviousLine)

        self.pv_bigger_ten_action = self.preview_menu.addAction("Grow by Ten")
        self.pv_bigger_ten_action.setShortcut(QKeySequence.StandardKey.MoveToStartOfBlock)

        self.pv_smaller_one_action = self.preview_menu.addAction("Shrink by One")
        self.pv_smaller_one_action.setShortcut(QKeySequence.StandardKey.MoveToNextLine)

        self.pv_smaller_ten_action = self.preview_menu.addAction("Shrink by Ten")
        self.pv_smaller_ten_action.setShortcut(QKeySequence.StandardKey.MoveToEndOfBlock)

        self.preview_menu.addSeparator()

        self.pv_set_size_action = self.preview_menu.addAction("Points per Em...")
        self.pv_set_size_action.setShortcut(QKeySequence("Ctrl+p"))

        # self.pv_toggle_hinting_action = QAction("Show hinting", checkable=True)
        # self.preview_menu.addAction(self.pv_toggle_hinting_action)

        # self.preview_menu.aboutToShow.connect(self.preview_menu_about_to_show)

        self.view_menu = self.menu.addMenu("&View")

        self.zoom_in_action = self.view_menu.addAction("Zoom In")
        self.zoom_in_action.setShortcut(QKeySequence.StandardKey.ZoomIn)

        self.zoom_out_action = self.view_menu.addAction("Zoom Out")
        self.zoom_out_action.setShortcut(QKeySequence.StandardKey.ZoomOut)

        self.original_size_action = self.view_menu.addAction("Original Size")
        self.original_size_action.setShortcut(QKeySequence("Ctrl+0"))

        self.view_menu.addSeparator()

        self.next_glyph_action = self.view_menu.addAction("Next Glyph")
        self.next_glyph_action.setShortcut(QKeySequence.StandardKey.MoveToNextChar)

        self.previous_glyph_action = self.view_menu.addAction("Previous Glyph")
        self.previous_glyph_action.setShortcut(QKeySequence.StandardKey.MoveToPreviousChar)

        self.hint_menu = self.menu.addMenu("&Hints")

        self.black_action = self.toolbar.addAction("Black Distance (B)")
        self.black_action.setIcon(QIcon(QPixmap("./black_distance.png")))
        self.black_action.setShortcut(QKeySequence(Qt.Key.Key_B))

        # self.black_action.setShortcut(QKeySequence("Ctrl+b"))

        self.white_action = self.toolbar.addAction("White Distance (W)")
        self.white_action.setIcon(QIcon(QPixmap("./white_distance.png")))
        self.white_action.setShortcut(QKeySequence(Qt.Key.Key_W))

        self.gray_action = self.toolbar.addAction("Gray Distance (G)")
        self.gray_action.setIcon(QIcon(QPixmap("./gray_distance.png")))
        self.gray_action.setShortcut(QKeySequence(Qt.Key.Key_G))

        self.shift_action = self.toolbar.addAction("Shift (S)")
        self.shift_action.setIcon(QIcon(QPixmap("./shift.png")))
        self.shift_action.setShortcut(QKeySequence(Qt.Key.Key_S))

        self.align_action = self.toolbar.addAction("Align (L)")
        self.align_action.setIcon(QIcon(QPixmap("./align.png")))
        self.align_action.setShortcut(QKeySequence(Qt.Key.Key_L))

        self.interpolate_action = self.toolbar.addAction("Interpolate (I)")
        self.interpolate_action.setIcon(QIcon(QPixmap("./interpolate.png")))
        self.interpolate_action.setShortcut(QKeySequence(Qt.Key.Key_I))

        self.anchor_action = self.toolbar.addAction("Anchor (A)")
        self.anchor_action.setIcon(QIcon(QPixmap("./anchor.png")))
        self.anchor_action.setShortcut(QKeySequence(Qt.Key.Key_A))

        self.make_set_action = self.toolbar.addAction("Make Set (K)")
        self.make_set_action.setIcon(QIcon(QPixmap("./make_set.png")))
        self.make_set_action.setShortcut(QKeySequence(Qt.Key.Key_K))

        # self.hint_menu.addSeparator()

        # self.make_set_action = self.hint_menu.addAction("Make Set")

        self.compile_action = self.hint_menu.addAction("Compile")
        self.compile_action.setShortcut(QKeySequence("Ctrl+r"))

        self.hint_menu.aboutToShow.connect(self.hint_menu_about_to_show)

        self.central_widget = self.qs
        self.setCentralWidget(self.central_widget)

        self.setup_file_connections()

    def compile_current_glyph(self):
        self.glyph_pane.viewer.yg_glyph.save_source()
        source = self.yg_font.source
        font = self.yg_font.font_files.in_font()
        # glyph = self.preferences["current_glyph"] ***
        glyph = self.glyph_pane.viewer.yg_glyph.gname
        glyph_index = self.yg_font.name_to_index[glyph]
        tmp_font = compile_one(font, source, glyph)
        self.yg_preview.fetch_glyph(tmp_font, glyph_index)
        self.yg_preview.update()

    # def preview_menu_about_to_show(self):
    #    if self.yg_preview.face == None or self.yg_preview.glyph_index == 0:
    #        self.pv_toggle_hinting_action.setEnabled(False)
    #        return
    #    else:
    #        self.pv_toggle_hinting_action.setEnabled(True)
    #    if self.yg_preview.hinting == "on":
    #        self.preview_menu.setChecked(True)
    #    else:
    #        self.preview_menu.setChecked(False)

    def hint_menu_about_to_show(self):
        if len(self.glyph_pane.viewer.selectedObjects(True)) != 1:
            self.anchor_action.setEnabled(False)
        else:
            self.anchor_action.setEnabled(True)
        if len(self.glyph_pane.viewer.selectedObjects(True)) != 2:
            self.black_action.setEnabled(False)
            self.white_action.setEnabled(False)
            self.gray_action.setEnabled(False)
            self.shift_action.setEnabled(False)
            self.align_action.setEnabled(False)
        else:
            self.black_action.setEnabled(True)
            self.white_action.setEnabled(True)
            self.gray_action.setEnabled(True)
            self.shift_action.setEnabled(True)
            self.align_action.setEnabled(True)
        if len(self.glyph_pane.viewer.selectedObjects(True)) != 3:
            self.interpolate_action.setEnabled(False)
        else:
            self.interpolate_action.setEnabled(True)

    def disconnect_all(self):
        try:
            self.black_action.triggered.disconnect(self.glyph_pane.viewer.make_hint_from_selection)
        except Exception:
            pass
        try:
            self.white_action.triggered.disconnect(self.glyph_pane.viewer.make_hint_from_selection)
        except Exception:
            pass
        try:
            self.gray_action.triggered.disconnect(self.glyph_pane.viewer.make_hint_from_selection)
        except Exception:
            pass
        try:
            self.anchor_action.triggered.disconnect(self.glyph_pane.viewer.make_hint_from_selection)
        except Exception:
            pass
        try:
            self.interpolate_action.triggered.disconnect(self.glyph_pane.viewer.make_hint_from_selection)
        except Exception:
            pass
        try:
            self.shift_action.triggered.disconnect(self.glyph_pane.viewer.make_hint_from_selection)
        except Exception:
            pass
        try:
            self.align_action.triggered.disconnect(self.glyph_pane.viewer.make_hint_from_selection)
        except Exception:
            pass
        try:
            self.zoom_in_action.triggered.disconnect(self.glyph_pane.zoom)
        except Exception:
            pass
        try:
            self.zoom_out_action.triggered.disconnect(self.glyph_pane.zoom)
        except Exception:
            pass
        try:
            self.original_size_action.triggered.disconnect(self.glyph_pane.zoom)
        except Exception:
            pass

    def setup_editor_connections(self):
        self.compile_action.triggered.connect(self.source_editor.yaml_source)

    def setup_file_connections(self):
        self.save_action.triggered.connect(self.save_yaml_file)
        self.quit_action.triggered.connect(self.quit, type=Qt.ConnectionType.QueuedConnection)
        self.open_action.triggered.connect(self.open_file)

    def setup_hint_connections(self):
        self.black_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.white_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.gray_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.anchor_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.interpolate_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.shift_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.align_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.make_set_action.triggered.connect(self.glyph_pane.viewer.make_set)

    def disconnect_hint(self):
        try:
            self.black_action.triggered.disconnect(self.glyph_pane.viewer.make_hint_from_selection)
        except Exception:
            pass
        try:
            self.white_action.triggered.disconnect(self.glyph_pane.viewer.make_hint_from_selection)
        except Exception:
            pass
        try:
            self.gray_action.triggered.disconnect(self.glyph_pane.viewer.make_hint_from_selection)
        except Exception:
            pass
        try:
            self.anchor_action.triggered.disconnect(self.glyph_pane.viewer.make_hint_from_selection)
        except Exception:
            pass
        try:
            self.interpolate_action.triggered.disconnect(self.glyph_pane.viewer.make_hint_from_selection)
        except Exception:
            pass
        try:
            self.shift_action.triggered.disconnect(self.glyph_pane.viewer.make_hint_from_selection)
        except Exception:
            pass
        try:
            self.align_action.triggered.disconnect(self.glyph_pane.viewer.make_hint_from_selection)
        except Exception:
            pass

    def setup_preview_connections(self):
        self.pv_bigger_one_action.triggered.connect(self.yg_preview.bigger_one)
        self.pv_bigger_ten_action.triggered.connect(self.yg_preview.bigger_ten)
        self.pv_smaller_one_action.triggered.connect(self.yg_preview.smaller_one)
        self.pv_smaller_ten_action.triggered.connect(self.yg_preview.smaller_ten)
        self.pv_set_size_action.triggered.connect(self.show_ppem_dialog)
        # self.pv_toggle_hinting_action.triggered.connect(self.yg_preview.toggle_hinting)

    def setup_zoom_connections(self):
        self.zoom_in_action.triggered.connect(self.glyph_pane.zoom, type=Qt.ConnectionType.SingleShotConnection)
        self.zoom_out_action.triggered.connect(self.glyph_pane.zoom, type=Qt.ConnectionType.SingleShotConnection)
        self.original_size_action.triggered.connect(self.glyph_pane.zoom, type=Qt.ConnectionType.SingleShotConnection)
        self.save_current_glyph_action.triggered.connect(self.compile_current_glyph)

    def disconnect_zoom(self):
        try:
            self.next_glyph_action.triggered.disconnect(self.glyph_pane.next_glyph)
        except Exception:
            pass
        try:
            self.previous_glyph_action.triggered.disconnect(self.glyph_pane.previous_glyph)
        except Exception:
            pass
        try:
            self.goto_action.triggered.disconnect(self.show_goto_dialog)
        except Exception:
            pass
        try:
            self.save_current_glyph_action.triggered.disconnect(self.compile_current_glyph)
        except Exception:
            pass

    def setup_nav_connections(self):
        self.next_glyph_action.triggered.connect(self.glyph_pane.next_glyph, type=Qt.ConnectionType.SingleShotConnection)
        self.previous_glyph_action.triggered.connect(self.glyph_pane.previous_glyph, type=Qt.ConnectionType.SingleShotConnection)
        self.goto_action.triggered.connect(self.show_goto_dialog)
        self.glyph_pane.setup_goto_signal(self.show_goto_dialog)

    def disconnect_nav(self):
        try:
            self.next_glyph_action.triggered.disconnect(self.glyph_pane.next_glyph)
        except Exception:
            pass
        try:
            self.previous_glyph_action.triggered.disconnect(self.glyph_pane.previous_glyph)
        except Exception:
            pass
        try:
            self.goto_action.triggered.disconnect(self.show_goto_dialog)
        except Exception:
            pass


    def setup_glyph_pane_connections(self):
        # These get destroyed whenever we move from one glyph to another, and so the connections
        # have to be reestablished every time. Check carefully to make sure we can't ever have
        # duplicate connections!
        self.setup_hint_connections()
        self.setup_nav_connections()
        self.setup_zoom_connections()
        self.source_editor.setup_editor_signals(self.glyph_pane.viewer.yg_glyph.save_editor_source)

    def disconnect_glyph_pane(self):
        self.disconnect_nav()
        self.disconnect_zoom()
        self.disconnect_hint()
        self.source_editor.disconnect_editor_signals(self.glyph_pane.viewer.yg_glyph.save_editor_source)

    def setup_connections(self):
        # This can safely be run when the program has just started, but not
        # later.
        self.setup_glyph_pane_connections()
        self.setup_file_connections()
        self.setup_hint_connections()
        self.setup_nav_connections()
        self.setup_zoom_connections()
        self.setup_preview_connections()

    def add_preview(self, previewer):
        self.yg_preview = previewer
        self.preview_scroller = QScrollArea()
        self.preview_scroller.setWidget(self.yg_preview)
        self.qs.addWidget(self.preview_scroller)
        self.setup_preview_connections()

    def add_editor(self, editor):
        self.source_editor = editor
        self.qs.addWidget(self.source_editor)

    def add_glyph_pane(self, g):
        # Must be a MyView(QGraphicsView) object.
        self.glyph_pane = g
        self.qs.addWidget(self.glyph_pane)
        self.setup_glyph_pane_connections()

    def save_yaml_file(self):
        self.glyph_pane.viewer.yg_glyph.save_source()
        self.yg_font.source_file.save_source()

    def open_file(self): # ***
        f = QFileDialog.getOpenFileName(self, "Open TrueType font or YAML file",
                                               "/Users/peterbaker/work/GitHub/Junicode-New/source/xgf",
                                               "Files (*.ttf *.yaml)")
        filename = f[0]

        if filename and len(filename) > 0:
            # print(filename)
            split_fn = os.path.splitext(filename)
            fn_base = split_fn[0]
            # print("base: " + str(fn_base))
            extension = split_fn[1]
            # print("ext: " + str(extension))
            yaml_source = None
            if extension == ".ttf":
                yaml_filename = fn_base + ".yaml"
                yaml_source = {}
                yaml_source["font"] = {}
                yaml_source["font"]["in"] = copy.copy(filename)
                yaml_source["font"]["out"] = fn_base + "-hinted" + extension
                yaml_source["defaults"] = {}
                yaml_source["cvt"] = {}
                yaml_source["prep"] = {}
                prep_code = """<code xmlns=\"http://xgridfit.sourceforge.net/Xgridfit2\">
                    <push>4 511</push>
                    <command nm="SCANCTRL"/>
                    <command nm="SCANTYPE"/>
                  </code>"""
                yaml_source["prep"] = {"code": prep_code}
                yaml_source["functions"] = {}
                yaml_source["macros"] = {}
                yaml_source["glyphs"] = {}
                filename = yaml_filename

            # print("filename: " + str(filename))

            # Wrong. We should use familyname + stylename to index here.
            top_window.preferences["current_font"] = filename

            self.yg_preview = ygPreview()
            self.add_preview(self.yg_preview)
            self.source_editor = ygEditor.ygEditor(top_window.preferences)
            self.add_editor(self.source_editor)
            if yaml_source != None:
                self.yg_font = ygModel.ygFont(yaml_source, yaml_filename=filename)
            else:
                self.yg_font = ygModel.ygFont(filename)
            # This is not working.
            if "current_glyph" in top_window.preferences and filename in top_window.preferences["current_glyph"]:
                initGlyph = top_window.preferences["current_glyph"][filename]
            else:
                initGlyph = "A"
            modelGlyph = ygModel.ygGlyph(top_window.preferences, self.yg_font, initGlyph)
            modelGlyph.set_yaml_editor(self.source_editor)
            viewer = ygHintEditor.ygGlyphViewer(self.preferences, modelGlyph)
            view = ygHintEditor.MyView(self.preferences, viewer, self.yg_font)
            self.add_glyph_pane(view)
            self.set_background()
            self.set_window_title()
            self.setup_editor_connections()
        # self.show()

    def set_background(self):
        self.glyph_pane.set_background()

    def set_window_title(self):
        base = "YG"
        if self.yg_font:
            base += " -- " + str(self.yg_font.family_name()) + "-" + str(self.yg_font.style_name())
        if self.glyph_pane:
            base += " -- " + self.glyph_pane.viewer.yg_glyph.gname
        self.setWindowTitle(base)

    def show_error_message(self, msg_list):
        msg = QMessageBox(self)
        if msg_list[0] == "Warning":
            msg.setIcon(QMessageBox.Icon.Warning)
        msg.setWindowTitle(msg_list[1])
        msg.setText(msg_list[2])
        msg.show()

    def show_goto_dialog(self):
        text, ok = QInputDialog().getText(self, "Go to glyph", "Glyph name:",
                                          QLineEdit.EchoMode.Normal)
        if ok and text:
            self.glyph_pane.go_to_glyph(text)

    def show_ppem_dialog(self):
        text, ok = QInputDialog().getText(self, "Set Points per Em", "Points per em:",
                                          QLineEdit.EchoMode.Normal)
        if ok and text:
            self.yg_preview.set_size(text)

    def quit(self):
        self.preferences.save_config()
        self.app.quit()



if __name__ == "__main__":

    # print(dir(QSizePolicy.Policy))

    app = QApplication([])
    top_window = MainWindow(app)
    qg = top_window.screen().availableGeometry()
    x = qg.x() + 20
    y = qg.y() + 20
    width = qg.width() * 0.66
    height = qg.height() * 0.75
    top_window.setGeometry(int(x), int(y), int(width), int(height))
    top_window.preferences = ygPreferences.open_config(top_window)
    top_window.show()
    sys.exit(app.exec())
