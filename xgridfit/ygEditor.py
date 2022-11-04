from PyQt6.QtWidgets import QPlainTextEdit
from PyQt6.QtCore import (pyqtSignal, Qt)
import yaml
import ygPreferences

class ygEditor(QPlainTextEdit):

    sig_source_from_editor = pyqtSignal(object)

    def __init__(self, preferences, parent=None):
        super().__init__()
        self.setAttribute(Qt.WidgetAttribute.WA_AcceptTouchEvents, False)
        self.setStyleSheet("ygEditor {font-family: Source Code Pro, monospace; }")
        self.setLineWrapMode(QPlainTextEdit.LineWrapMode.NoWrap)
        self.preferences = preferences
        self.textChanged.connect(self.text_changed)

    def install_source(self, text):
        self.setPlainText(text)

    def yaml_source(self):
        try:
            self.sig_source_from_editor.emit(yaml.safe_load(self.toPlainText()))
        except Exception as e:
            self.preferences.top_window().show_error_message(["Warning", "Warning", "YAML source code is invalid."])

    def setup_editor_signals(self, f):
        self.sig_source_from_editor.connect(f)

    def disconnect_editor_signals(self, f):
        self.sig_source_from_editor.disconnect(f)

    def text_changed(self):
        if len(self.toPlainText()) == 0:
            self.setPlainText("points: []\n")
