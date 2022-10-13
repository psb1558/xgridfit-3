import sys
import ygModel
import ygHintEditor
from PyQt6.QtCore import Qt
from PyQt6.QtWidgets import (QApplication, QGraphicsScene, QGraphicsView, QMainWindow, QHBoxLayout, QSplitter, QWidget, QPlainTextEdit)
from PyQt6.QtGui import QPainter, QPainterPath, QPen, QBrush, QColor, QPolygonF, QAction, QFont, QKeySequence
from defcon import Font, Glyph, registerRepresentationFactory

class ygEditor(QPlainTextEdit):
    def __init__(self, parent=None):
        super().__init__()
        # print("Doing init for the editor pane")
        self.setStyleSheet("ygEditor {font-family: Source Code Pro, monospace; }")
        self.setLineWrapMode(QPlainTextEdit.LineWrapMode.NoWrap)
        # print(self.lineWrapMode())

    def install_source(self, text):
        self.setPlainText(text)



class MainWindow(QMainWindow):
    def __init__(self, parent=None):
        super(MainWindow,self).__init__(parent=parent)
        self.setWindowTitle("YG")
        self.qs = QSplitter(self)
        self.glyph_pane = None
        self.yg_font = None
        self.source_editor = None

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

        self.black_action = self.hint_menu.addAction("Black Distance")
        self.black_action.setShortcut(QKeySequence(Qt.Key.Key_B))
        # self.black_action.setShortcut(QKeySequence("Ctrl+b"))

        self.white_action = self.hint_menu.addAction("White Distance")
        self.white_action.setShortcut(QKeySequence(Qt.Key.Key_W))

        self.gray_action = self.hint_menu.addAction("Gray Distance")
        self.gray_action.setShortcut(QKeySequence(Qt.Key.Key_G))

        self.anchor_action = self.hint_menu.addAction("Anchor")
        self.anchor_action.setShortcut(QKeySequence(Qt.Key.Key_A))

        self.shift_action = self.hint_menu.addAction("Shift")
        self.shift_action.setShortcut(QKeySequence(Qt.Key.Key_S))

        self.align_action = self.hint_menu.addAction("Align")
        self.align_action.setShortcut(QKeySequence(Qt.Key.Key_L))

        self.interpolate_action = self.hint_menu.addAction("Interpolate")
        self.interpolate_action.setShortcut(QKeySequence(Qt.Key.Key_I))

        self.hint_menu.addSeparator()

        make_set_action = self.hint_menu.addAction("Make Set")

        self.hint_menu.aboutToShow.connect(self.hint_menu_about_to_show)

        self.central_widget = self.qs
        self.setCentralWidget(self.central_widget)

    def hint_menu_about_to_show(self):
        print("Got the signal")
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
        try:
            self.next_glyph_action.triggered.disconnect(self.glyph_pane.next_glyph)
        except Exception:
            pass
        try:
            self.previous_glyph_action.triggered.disconnect(self.glyph_pane.previous_glyph)
        except Exception:
            pass

    def setup_file_connections(self):
        self.save_action.triggered.connect(self.save_yaml_file)

    def setup_hint_connections(self):
        self.black_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.white_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.gray_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.anchor_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.interpolate_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.shift_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)
        self.align_action.triggered.connect(self.glyph_pane.viewer.make_hint_from_selection)

    def setup_zoom_connections(self):
        self.zoom_in_action.triggered.connect(self.glyph_pane.zoom, type=Qt.ConnectionType.SingleShotConnection)
        self.zoom_out_action.triggered.connect(self.glyph_pane.zoom, type=Qt.ConnectionType.SingleShotConnection)
        self.original_size_action.triggered.connect(self.glyph_pane.zoom, type=Qt.ConnectionType.SingleShotConnection)

    def setup_nav_connections(self):
        self.next_glyph_action.triggered.connect(self.glyph_pane.next_glyph, type=Qt.ConnectionType.SingleShotConnection)
        self.previous_glyph_action.triggered.connect(self.glyph_pane.previous_glyph, type=Qt.ConnectionType.SingleShotConnection)

    def setup_connections(self):
        print(self.glyph_pane.viewer.yg_glyph.gname)
        self.setup_file_connections()
        self.setup_hint_connections()
        self.setup_nav_connections()
        self.setup_zoom_connections()

    def add_editor(self, editor):
        self.source_editor = editor
        self.qs.addWidget(self.source_editor)

    def add_glyph_pane(self, g):
        # Must be a MyView(QGraphicsView) object.
        self.glyph_pane = g
        self.qs.addWidget(self.glyph_pane)
        self.setup_connections()

    def save_yaml_file(self):
        self.glyph_pane.viewer.yg_glyph.save_source()
        self.yg_font.source_file.save_source()




def QTFactory(glyph):
    """ For defcon's drawing of glyph outlines
    """
    from fontTools.pens.qtPen import QtPen
    pen = QtPen(glyph.getParent(), QPainterPath())
    glyph.draw(pen)
    return pen.path

if __name__ == "__main__":
    registerRepresentationFactory(Glyph, "NSQTPath", QTFactory)

    print(dir(Qt.ConnectionType))

    # 1. create the QApplication
    # 2. create the main window
    # 3. create the yaml editor pane and add it to the main window
    # 4. open the yaml file (which should contain font information)
    # 5. create a ygGlyph object for the default character
    # 6. create a ygGlypnViewer (QGraphicsScene, graphical wrapper for a ygGlyph)
    # 7. create a MyView (QGraphicsView) and add it to the main window
    # 8. show the window
    # 9. start the app

    app = QApplication([])
    top_window = MainWindow()
    yg_editor = ygEditor()
    top_window.add_editor(yg_editor)
    yg_font = ygModel.ygFont("Junicode-roman.yaml")
    top_window.yg_font = yg_font
    modelGlyph = ygModel.ygGlyph(yg_font, "w")
    modelGlyph.set_yaml_editor(yg_editor)
    viewer = ygHintEditor.ygGlyphViewer(modelGlyph)
    view = ygHintEditor.MyView(viewer, yg_font)
    top_window.add_glyph_pane(view)
    # top_window.setup_connections()
    top_window.show()
    sys.exit(app.exec())
