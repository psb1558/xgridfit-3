from PyQt6.QtWidgets import QPlainTextEdit
from PyQt6.QtCore import pyqtSignal
import yaml
import ygPreferences

class ygEditor(QPlainTextEdit):

    sig_source_from_editor = pyqtSignal(object)

    def __init__(self, preferences, parent=None):
        super().__init__()
        self.setStyleSheet("ygEditor {font-family: Source Code Pro, monospace; }")
        self.setLineWrapMode(QPlainTextEdit.LineWrapMode.NoWrap)
        self.preferences = preferences

    def install_source(self, text):
        print("Running ygEditor.install_source")
        self.setPlainText(text)

    def yaml_source(self):
        try:
            self.sig_source_from_editor.emit(yaml.safe_load(self.toPlainText()))
        except Exception as e:
            print("Exception in ygEditor.yaml_text_editor_contents: " + str(type(e)))
            self.preferences.top_window().show_error_message(["Warning", "Warning", "YAML source code is invalid."])
            # self.sig_error.emit(["Warning", "Warning", "YAML source code is invalid."])

    def setup_editor_signals(self, f):
        self.sig_source_from_editor.connect(f)

    def disconnect_editor_signals(self, f):
        self.sig_source_from_editor.disconnect(f)
