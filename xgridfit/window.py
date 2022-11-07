import sys
import os
import copy
import ygModel
import freetype
from ygPreview import ygPreview
import ygEditor
import ygHintEditor
import ygPreferences
from xgridfit import compile_one, compile_all
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
    QSizePolicy,
    QGraphicsView
)
from PyQt6.QtGui import (
    QPainter,
    QAction,
    QKeySequence,
    QIcon,
    QPixmap,
    QActionGroup
)

class MainWindow(QMainWindow):
    def __init__(self, app, parent=None):
        super(MainWindow,self).__init__(parent=parent)
        self.cvt_editor = None
        self.cvar_editor = None
        self.function_editor = None
        self.macro_editor = None
        self.default_editor = None

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
        self.save_as_action.setEnabled(False)

        self.save_font_action = self.file_menu.addAction("Export Font...")
        self.save_font_action.setShortcut(QKeySequence("Ctrl+e"))
        # self.save_font_action.setEnabled(False)

        self.quit_action = self.file_menu.addAction("Quit")
        self.quit_action.setShortcut(QKeySequence.StandardKey.Quit)

        self.edit_menu = self.menu.addMenu("&Edit")

        self.cut_action = self.edit_menu.addAction("Cut")
        self.cut_action.setShortcut(QKeySequence.StandardKey.Cut)
        self.cut_action.setEnabled(False)

        self.copy_action = self.edit_menu.addAction("Copy")
        self.copy_action.setShortcut(QKeySequence.StandardKey.Copy)
        self.copy_action.setEnabled(False)

        self.paste_action = self.edit_menu.addAction("Paste")
        self.paste_action.setShortcut(QKeySequence.StandardKey.Paste)
        self.paste_action.setEnabled(False)

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

        cursor_action_group = QActionGroup(self.toolbar)
        cursor_action_group.setExclusive(True)

        self.cursor_action = self.toolbar.addAction("Cursor (Edit hints)")
        cursor_icon = QIcon()
        cursor_icon.addPixmap(QPixmap("./cursor-icon-on.png"), state=QIcon.State.On)
        cursor_icon.addPixmap(QPixmap("./cursor-icon-off.png"), state=QIcon.State.Off)
        self.cursor_action.setIcon(cursor_icon)
        self.cursor_action.setCheckable(True)
        # self.cursor_action.setChecked(True)

        self.hand_action = self.toolbar.addAction("Hand (Pan the canvas)")
        hand_icon = QIcon()
        hand_icon.addPixmap(QPixmap("./hand-icon-on.png"), state=QIcon.State.On)
        hand_icon.addPixmap(QPixmap("./hand-icon-off.png"), state=QIcon.State.Off)
        self.hand_action.setIcon(hand_icon)
        self.hand_action.setCheckable(True)
        # self.hand_action.setChecked(False)

        cursor_action_group.addAction(self.cursor_action)
        cursor_action_group.addAction(self.hand_action)
        self.cursor_action.setChecked(True)

        self.black_action = self.toolbar.addAction("Black Distance (B)")
        self.black_action.setIcon(QIcon(QPixmap("./black_distance.png")))
        self.black_action.setShortcut(QKeySequence(Qt.Key.Key_B))
        self.black_action.setEnabled(False)

        self.toolbar.insertSeparator(self.black_action)

        self.white_action = self.toolbar.addAction("White Distance (W)")
        self.white_action.setIcon(QIcon(QPixmap("./white_distance.png")))
        self.white_action.setShortcut(QKeySequence(Qt.Key.Key_W))
        self.white_action.setEnabled(False)

        self.gray_action = self.toolbar.addAction("Gray Distance (G)")
        self.gray_action.setIcon(QIcon(QPixmap("./gray_distance.png")))
        self.gray_action.setShortcut(QKeySequence(Qt.Key.Key_G))
        self.gray_action.setEnabled(False)

        self.shift_action = self.toolbar.addAction("Shift (S)")
        self.shift_action.setIcon(QIcon(QPixmap("./shift.png")))
        self.shift_action.setShortcut(QKeySequence(Qt.Key.Key_S))
        self.shift_action.setEnabled(False)

        self.align_action = self.toolbar.addAction("Align (L)")
        self.align_action.setIcon(QIcon(QPixmap("./align.png")))
        self.align_action.setShortcut(QKeySequence(Qt.Key.Key_L))
        self.align_action.setEnabled(False)

        self.interpolate_action = self.toolbar.addAction("Interpolate (I)")
        self.interpolate_action.setIcon(QIcon(QPixmap("./interpolate.png")))
        self.interpolate_action.setShortcut(QKeySequence(Qt.Key.Key_I))
        self.interpolate_action.setEnabled(False)

        self.anchor_action = self.toolbar.addAction("Anchor (A)")
        self.anchor_action.setIcon(QIcon(QPixmap("./anchor.png")))
        self.anchor_action.setShortcut(QKeySequence(Qt.Key.Key_A))
        self.anchor_action.setEnabled(False)

        self.make_set_action = self.toolbar.addAction("Make Set (K)")
        self.make_set_action.setIcon(QIcon(QPixmap("./make_set.png")))
        self.make_set_action.setShortcut(QKeySequence(Qt.Key.Key_K))
        self.make_set_action.setEnabled(False)

        self.code_menu = self.menu.addMenu("&Code")

        self.compile_action = self.code_menu.addAction("Compile")
        self.compile_action.setShortcut(QKeySequence("Ctrl+r"))

        self.edit_cvt_action = self.code_menu.addAction("Edit cvt...")

        self.edit_prep_action = self.code_menu.addAction("Edit prep...")

        self.edit_cvar_action = self.code_menu.addAction("Edit cvar...")

        self.edit_functions_action = self.code_menu.addAction("Edit Functions...")

        self.edit_macros_action = self.code_menu.addAction("Edit Macros...")

        self.edit_defaults_action = self.code_menu.addAction("Edit Defaults...")

        # self.code_menu.aboutToShow.connect(self.code_menu_about_to_show)

        self.central_widget = self.qs
        self.setCentralWidget(self.central_widget)

        self.setup_file_connections()

        self.setup_edit_connections()

    def set_mouse_panning(self, panning_on):
        if self.glyph_pane:
            if panning_on:
                self.glyph_pane.setDragMode(QGraphicsView.DragMode.ScrollHandDrag)
                # self.glyph_pane.setCursor(Qt.CursorShape.OpenHandCursor)
            #else:
            #    self.glyph_pane.setDragMode(QGraphicsView.DragMode.NoDrag)

    def set_mouse_editing(self, editing_on):
        if self.glyph_pane:
            if editing_on:
                self.glyph_pane.setDragMode(QGraphicsView.DragMode.NoDrag)
                # self.glyph_pane.setCursor(Qt.CursorShape.ArrowCursor)
            # else:
            #    self.glyph_pane.setDragMode(QGraphicsView.DragMode.ScrollHandDrag)

    def preview_current_glyph(self):
        self.glyph_pane.viewer.yg_glyph.save_source()
        source = self.yg_font.source
        font = self.yg_font.font_files.in_font()
        glyph = self.glyph_pane.viewer.yg_glyph.gname
        glyph_index = self.yg_font.name_to_index[glyph]
        # tmp_font = compile_one(self.yg_font.ft_font, source, glyph)
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

    # def code_menu_about_to_show(self):
    #    if len(self.glyph_pane.viewer.selectedObjects(True)) != 1:
    #        self.anchor_action.setEnabled(False)
    #    else:
    #        self.anchor_action.setEnabled(True)
    #    if len(self.glyph_pane.viewer.selectedObjects(True)) != 2:
    #        self.black_action.setEnabled(False)
    #        self.white_action.setEnabled(False)
    #        self.gray_action.setEnabled(False)
    #        self.shift_action.setEnabled(False)
    #        self.align_action.setEnabled(False)
    #    else:
    #        self.black_action.setEnabled(True)
    #        self.white_action.setEnabled(True)
    #        self.gray_action.setEnabled(True)
    #        self.shift_action.setEnabled(True)
    #        self.align_action.setEnabled(True)
    #    if len(self.glyph_pane.viewer.selectedObjects(True)) != 3:
    #        self.interpolate_action.setEnabled(False)
    #    else:
    #        self.interpolate_action.setEnabled(True)

    def setup_editor_connections(self):
        self.compile_action.triggered.connect(self.source_editor.yaml_source)

    def setup_file_connections(self):
        self.save_action.triggered.connect(self.save_yaml_file)
        self.quit_action.triggered.connect(self.quit, type=Qt.ConnectionType.QueuedConnection)
        self.open_action.triggered.connect(self.open_file)
        self.save_font_action.triggered.connect(self.export_font)

    def setup_hint_connections(self):
        self.black_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.white_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.gray_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.anchor_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.interpolate_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.shift_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.align_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.make_set_action.triggered.connect(self.glyph_pane.viewer.make_set)

    def setup_edit_connections(self):
        self.edit_cvt_action.triggered.connect(self.edit_cvt)
        self.edit_prep_action.triggered.connect(self.edit_prep)
        self.edit_cvar_action.triggered.connect(self.edit_cvar)
        self.edit_functions_action.triggered.connect(self.edit_functions)
        self.edit_macros_action.triggered.connect(self.edit_macros)
        self.edit_defaults_action.triggered.connect(self.edit_defaults)

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
        self.save_current_glyph_action.triggered.connect(self.preview_current_glyph)
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

    def setup_cursor_connections(self):
        self.hand_action.toggled.connect(self.set_mouse_panning)
        self.cursor_action.toggled.connect(self.set_mouse_editing)

    def disconnect_cursor(self):
        self.hand_action.toggled.connect(self.set_mouse_panning)
        self.cursor_action.toggled.connect(self.set_mouse_editing)


    def setup_glyph_pane_connections(self):
        # These get destroyed whenever we move from one glyph to another, and so the connections
        # have to be reestablished every time. Check carefully to make sure we can't ever have
        # duplicate connections!
        self.setup_hint_connections()
        self.setup_nav_connections()
        self.setup_zoom_connections()
        self.source_editor.setup_editor_signals(self.glyph_pane.viewer.yg_glyph.save_editor_source)
        self.setup_cursor_connections()

    def disconnect_glyph_pane(self):
        self.disconnect_nav()
        self.disconnect_zoom()
        # self.disconnect_hint()
        self.source_editor.disconnect_editor_signals(self.glyph_pane.viewer.yg_glyph.save_editor_source)
        self.disconnect_cursor()

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
        if not self.yg_font.clean():
            self.glyph_pane.viewer.yg_glyph.save_source()
            self.yg_font.source_file.save_source()
            self.yg_font.set_clean()

    def export_font(self):
        self.glyph_pane.viewer.yg_glyph.save_source()
        source = self.yg_font.source
        new_file_name = self.yg_font.font_files.out_font()
        in_file_name = self.yg_font.font_files.in_font()
        if new_file_name == None or in_file_name == None:
            return
        compile_all(in_file_name, source, new_file_name)


    def open_file(self): # ***
        f = QFileDialog.getOpenFileName(self, "Open TrueType font or YAML file",
                                               "/Users/peterbaker/work/GitHub/Junicode-New/source/xgf",
                                               "Files (*.ttf *.yaml)")
        filename = f[0]
        self.black_action.setEnabled(True)
        self.white_action.setEnabled(True)
        self.gray_action.setEnabled(True)
        self.shift_action.setEnabled(True)
        self.align_action.setEnabled(True)
        self.interpolate_action.setEnabled(True)
        self.anchor_action.setEnabled(True)
        self.make_set_action.setEnabled(True)

        if filename and len(filename) > 0:
            self.preferences.add_recent(filename)
            split_fn = os.path.splitext(filename)
            fn_base = split_fn[0]
            extension = split_fn[1]
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
            if ("current_glyph" in top_window.preferences and
                self.yg_font.full_name() in top_window.preferences["current_glyph"]):
                initGlyph = top_window.preferences["current_glyph"][self.yg_font.full_name()]
            else:
                initGlyph = "A"
            modelGlyph = ygModel.ygGlyph(top_window.preferences, self.yg_font, initGlyph)
            modelGlyph.set_yaml_editor(self.source_editor)
            viewer = ygHintEditor.ygGlyphViewer(self.preferences, modelGlyph)
            view = ygHintEditor.MyView(self.preferences, viewer, self.yg_font)
            self.add_glyph_pane(view)
            view.centerOn(view.viewer.glyphwidget.center_x, view.sceneRect().center().y())
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
        msg.exec()

    def edit_cvt(self):
        self.cvt_editor = ygEditor.editorDialog(self.preferences,
                                                self.yg_font.cvt)
        self.cvt_editor.show()
        # self.cvt_editor.raise()
        self.cvt_editor.activateWindow()

    def edit_prep(self):
        self.cvt_editor = ygEditor.editorDialog(self.preferences,
                                                self.yg_font.prep)
        self.cvt_editor.show()
        # self.cvt_editor.raise()
        self.cvt_editor.activateWindow()

    def edit_cvar(self):
        self.cvar_editor = ygEditor.editorDialog(self.preferences,
                                                 self.yg_font.cvar,
                                                 top_structure="list")
        self.cvar_editor.show()
        # self.cvar_editor.raise()
        self.cvar_editor.activateWindow()

    def edit_functions(self):
        self.function_editor = ygEditor.editorDialog(self.preferences,
                                                     self.yg_font.functions_func)
        self.function_editor.show()
        # self.function_editor.raise()
        self.function_editor.activateWindow()

    def edit_macros(self):
        self.macro_editor = ygEditor.editorDialog(self.preferences,
                                                  self.yg_font.macros_func)
        self.macro_editor.show()
        # self.macro_editor.raise()
        self.macro_editor.activateWindow()

    def edit_defaults(self):
        self.default_editor = ygEditor.editorDialog(self.preferences,
                                                    self.yg_font.defaults)
        self.default_editor.show()
        # self.default_editor.raise()
        self.default_editor.activateWindow()

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
        if self.yg_font.clean():
            self.preferences.save_config()
            self.app.quit()
        else:
            msg_box = QMessageBox()
            msg_box.setText("The YAML source has been modified.")
            msg_box.setInformativeText("Do you want to save it?")
            msg_box.setStandardButtons(QMessageBox.StandardButton.Discard |
                                       QMessageBox.StandardButton.Cancel |
                                       QMessageBox.StandardButton.Save)
            msg_box.setDefaultButton(QMessageBox.StandardButton.Save)
            ret = msg_box.exec()
            if ret == QMessageBox.StandardButton.Cancel:
                return
            if ret == QMessageBox.StandardButton.Save:
                self.save_yaml_file()
            self.preferences.save_config()
            self.app.quit()


if __name__ == "__main__":

    print(dir(Qt))

    app = QApplication([])
    top_window = MainWindow(app)
    top_window.preferences = ygPreferences.open_config(top_window)
    print(top_window.preferences)
    qg = top_window.screen().availableGeometry()
    x = qg.x() + 20
    y = qg.y() + 20
    width = qg.width() * 0.66
    height = qg.height() * 0.75
    top_window.setGeometry(int(x), int(y), int(width), int(height))
    top_window.show()
    sys.exit(app.exec())
