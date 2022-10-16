from PyQt6.QtWidgets import QPlainTextEdit
from PyQt6.QtCore import pyqtSignal
import yaml

class ygEditor(QPlainTextEdit):

    sig_error = pyqtSignal(object)
    sig_source_from_editor = pyqtSignal(object)

    def __init__(self, parent=None):
        super().__init__()
        self.setStyleSheet("ygEditor {font-family: Source Code Pro, monospace; }")
        self.setLineWrapMode(QPlainTextEdit.LineWrapMode.NoWrap)

    def install_source(self, text):
        self.setPlainText(text)

    def yaml_source(self):
        try:
            self.sig_source_from_editor.emit(yaml.safe_load(self.toPlainText()))
            print("Did yaml_source")
        except Exception as e:
            print("Exception in ygEditor.yaml_text_editor_contents: " + str(type(e)))
            self.sig_error.emit(["Warning", "Warning", "YAML source code is invalid."])

    def setup_error_signal(self, o):
        self.sig_error.connect(o)

    def setup_editor_signals(self, f):
        print("setup_editor_signals")
        self.sig_source_from_editor.connect(f)
