from PyQt6.QtWidgets import (QDialog,
                             QVBoxLayout,
                             QHBoxLayout,
                             QDialogButtonBox,
                             QComboBox,
                             QLineEdit,
                             QLabel)

class macfuncDialog(QDialog):
    def __init__(self, _hint):
        super(macfuncDialog,self).__init__(_hint.yg_hint.yg_glyph.preferences.top_window())
        self.yg_hint = _hint.yg_hint
        self.setWindowTitle("Parameters for " + str(self.yg_hint.name))
        self.yg_font = self.yg_hint.yg_glyph.yg_font
        self.yg_callable = None
        try:
            self.yg_callable = self.yg_font.functions[self.yg_hint.name]
        except Exception:
            pass
        if self.yg_callable == None:
            try:
                self.yg_callable = self.yg_font.macros[self.yg_hint.name]
            except Exception:
                pass
        self.hint_type = _hint.yg_hint.hint_type
        self.layout = QVBoxLayout()
        QBtn = QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        self.buttonBox = QDialogButtonBox(QBtn)
        self.buttonBox.accepted.connect(self.accept)
        self.buttonBox.rejected.connect(self.reject)
        if self.hint_type == "macro":
            self.params = self.yg_hint.macro
        else:
            self.params = self.yg_hint.function
        self.widgets = []
        k = self.yg_callable.keys()
        for kk in k:
            if type(self.yg_callable[kk]) is dict and "type" in self.yg_callable[kk]:
                if self.yg_callable[kk]["type"] in ["dist", "pos"]:
                    # If there's (1) a value in self.params[kk] or (2) a default
                    # val in self.yg_callable[kk], set it as text for the combo
                    # box.
                    self.widgets.append(QHBoxLayout())
                    self.widgets[-1].addWidget(QLabel(kk))
                    if kk in self.params:
                        default_value = self.params[kk]
                    elif "val" in self.yg_callable[kk]:
                        default_value = self.yg_callable[kk]["val"]
                    else:
                        default_value = None
                    self.widgets[-1].addWidget(ygCVTWidget(self.yg_hint, self.yg_callable[kk]["type"], default_value))
                elif self.yg_callable[kk]["type"] == "int":
                    self.widgets.append(QHBoxLayout())
                    self.widgets[-1].addWidget(QLabel(kk))
                    self.widgets[-1].addWidget(QLineEdit())
                    if kk in self.params:
                        default_value = self.params[kk]
                    elif "val" in self.yg_callable[kk]:
                        default_value = self.yg_callable[kk]["val"]
                    else:
                        default_value = None
                    self.widgets[-1].itemAt(1).widget().setInputMask("####")
                    if default_value:
                        self.widgets[-1].itemAt(1).widget().setText(str(default_value))
                elif self.yg_callable[kk]["type"] == "float":
                    self.widgets.append(QHBoxLayout())
                    self.widgets[-1].addWidget(QLabel(kk))
                    self.widgets[-1].addWidget(QLineEdit())
                    if kk in self.params:
                        default_value = self.params[kk]
                    elif "val" in self.yg_callable[kk]:
                        default_value = self.yg_callable[kk]["val"]
                    else:
                        default_value = None
                    self.widgets[-1].itemAt(1).widget().setInputMask("####")
                    if default_value:
                        self.widgets[-1].itemAt(1).widget().setText(str(default_value))
                else:
                    pass
        for w in self.widgets:
            self.layout.addLayout(w)
        self.layout.addWidget(self.buttonBox)
        self.setLayout(self.layout)

    def accept(self):
        result = {}
        for w in self.widgets:
            result[w.itemAt(0).widget().text()] = w.itemAt(1).widget().text()
        k = result.keys()
        if self.hint_type == "function":
            if type(self.yg_hint.function) is str:
                self.yg_hint.function = {"nm": self.yg_hint.function}
            param_list = self.yg_hint.function
        elif self.hint_type == "macro":
            if type(self.yg_hint.macro) is str:
                self.yg_hint.macro = {"nm": self.yg_hint.macro}
            param_list = self.yg_hint.macro
        else:
            super().reject()
            return
        for kk in k:
            param_list[kk] = result[kk]
        super().accept()



class ygCVTWidget(QComboBox):
    def __init__(self, hint, _type, default):
        super().__init__()
        self.addItem("None")
        # self.setInsertPolicy(QComboBox.InsertPolicy.InsertAlphabetically)
        cv_list = hint.yg_glyph.yg_font.cvt.get_list(_type, "y")
        cv_list.sort()
        for c in cv_list:
            self.addItem(c)
            if c == default:
                self.setCurrentText(default)
        if hint.cvt:
            self.setCurrentText(c)

    def text(self):
        return self.currentText()
