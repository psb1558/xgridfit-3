import sys
import ygModel
import ygHintEditor
from PyQt6.QtWidgets import (QApplication, QGraphicsScene, QGraphicsView, QMainWindow, QHBoxLayout, QSplitter, QWidget, QPlainTextEdit)
from PyQt6.QtGui import QPainter, QPainterPath, QPen, QBrush, QColor, QPolygonF, QAction, QFont
from defcon import Font, Glyph, registerRepresentationFactory

class ygEditor(QPlainTextEdit):
    def __init__(self, parent=None):
        super().__init__()
        # print("Doing init for the editor pane")
        self.setStyleSheet("ygEditor {font-family: Source Code Pro, monospace; }")
        self.setLineWrapMode(QPlainTextEdit.LineWrapMode.NoWrap)
        print(self.lineWrapMode())

    def install_source(self, text):
        self.setPlainText(text)



class MainWindow(QMainWindow):
    def __init__(self, parent=None):
        super(MainWindow,self).__init__(parent=parent)
        self.setWindowTitle("YG")
        self.qs = QSplitter(self)
        self.glyph_pane = None
        self.source_editor = None

        self.central_widget = self.qs

        self.setCentralWidget(self.central_widget)

    def add_editor(self, editor):
        self.source_editor = editor
        self.qs.addWidget(self.source_editor)

    def add_glyph_pane(self, g):
        # Must be a MyView(QGraphicsView) object.
        self.glyph_pane = g
        self.qs.addWidget(self.glyph_pane)



def QTFactory(glyph):
    """ For defcon's drawing of glyph outlines
    """
    from fontTools.pens.qtPen import QtPen
    pen = QtPen(glyph.getParent(), QPainterPath())
    glyph.draw(pen)
    return pen.path

if __name__ == "__main__":
    registerRepresentationFactory(Glyph, "NSQTPath", QTFactory)

    # print(dir(QPlainTextEdit))

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
    modelGlyph = ygModel.ygGlyph(yg_font, "A")
    modelGlyph.set_yaml_editor(yg_editor)
    viewer = ygHintEditor.ygGlyphViewer(modelGlyph)
    view = ygHintEditor.MyView(viewer, yg_font)
    top_window.add_glyph_pane(view)
    top_window.show()
    sys.exit(app.exec())
