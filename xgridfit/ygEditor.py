from PyQt6.QtCore import (pyqtSignal, Qt)
from PyQt6.QtWidgets import (QWidget,
                             QDialog,
                             QGridLayout,
                             QVBoxLayout,
                             QPlainTextEdit,
                             QDialogButtonBox)
import yaml
from yaml import Dumper
import copy
import ygPreferences

# From https://stackoverflow.com/questions/8640959/
# how-can-i-control-what-scalar-form-pyyaml-uses-for-my-data
def str_presenter(dumper, data):
  if len(data.splitlines()) > 1:  # check for multiline string
    return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')
  return dumper.represent_scalar('tag:yaml.org,2002:str', data)

yaml.add_representer(str, str_presenter)

# to use with safe_dump:
yaml.representer.SafeRepresenter.add_representer(str, str_presenter)

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
            self.setPlainText("[]\n")

class editorDialog(QDialog):
    def __init__(self, preferences, sourceable, top_structure="dict"):
        super().__init__()
        self.setAttribute(Qt.WidgetAttribute.WA_DeleteOnClose)
        self.preferences = preferences
        self.sourceable = sourceable
        print(self.sourceable)
        if top_structure == "dict":
            self._empty_string = "{}\n"
        else:
            self._empty_string = "[]\n"
        self.setMinimumSize(500, 500)
        self.layout = QVBoxLayout()
        self.setLayout(self.layout)
        self.edit_pane = QPlainTextEdit()
        self.edit_pane.setStyleSheet("QPlainTextEdit {font-family: Source Code Pro, monospace; }")
        self.install_yaml(copy.copy(self.sourceable.source()))
        self.layout.addWidget(self.edit_pane)
        QBtn = QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        self.buttonBox = QDialogButtonBox(QBtn)
        self.buttonBox.accepted.connect(self.accept)
        self.buttonBox.rejected.connect(self.reject)
        self.layout.addWidget(self.buttonBox)

    def install_text(self, text):
        self.edit_pane.setPlainText(text)

    def install_yaml(self, y):
        try:
            t = yaml.dump(y, sort_keys=False, Dumper=Dumper)
        except Exception as e:
            print(e)
            t = self._empty_string
        self.install_text(t)

    def yaml_source(self):
        try:
            return(yaml.safe_load(self.edit_pane.toPlainText()))
        except Exception as e:
            self.preferences.top_window().show_error_message(["Warning", "Warning", "YAML source code is invalid."])

    def text_changed(self):
        if len(self.edit_pane.toPlainText()) == 0:
            self.setPlainText(self._empty_string)

    def reject(self):
        self.done(QDialog.DialogCode.Rejected)

    def accept(self):
        c = self.yaml_source()
        if c != None:
            self.sourceable.save(c)
        else:
            self.reject()
            return
        self.done(QDialog.DialogCode.Accepted)
        # super().accept()
