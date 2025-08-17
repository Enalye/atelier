module atelier.etabli.media.res.truetype;

import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.media.res.base;
import atelier.etabli.media.res.editor;

import atelier.etabli.ui;

final class TrueTypeResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        string _filePath;
        int _fontSize, _fontOutline;
        string _testText1 = "Voix ambiguë d'un cœur qui,";
        string _testText2 = "au zéphyr,";
        string _testText3 = "préfère les jattes de kiwis.";
        TrueTypeFont _font;
        VBox _labelBox;
        Label _label1, _label2, _label3;
        ParameterWindow _parameterWindow;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _name = ffd.get!string(0);

        if (ffd.hasNode("file")) {
            _filePath = ffd.getNode("file").get!string(0);
        }

        if (ffd.hasNode("size")) {
            _fontSize = ffd.getNode("size").get!int(0);
        }

        if (ffd.hasNode("outline")) {
            _fontOutline = ffd.getNode("outline").get!int(0);
        }

        _parameterWindow = new ParameterWindow(path(), _filePath, _fontSize,
            _fontOutline, _testText1, _testText2, _testText3);
        _filePath = _parameterWindow.getFile();
        updateFont();

        _parameterWindow.addEventListener("property_file", {
            _filePath = _parameterWindow.getFile();
            updateFont();
            setDirty();
        });

        _parameterWindow.addEventListener("property_size", {
            _fontSize = _parameterWindow.getFontSize();
            updateFont();
            setDirty();
        });

        _parameterWindow.addEventListener("property_outline", {
            _fontOutline = _parameterWindow.getFontOutline();
            updateFont();
            setDirty();
        });

        _parameterWindow.addEventListener("property_text", {
            _testText1 = _parameterWindow.getTestText1();
            _testText2 = _parameterWindow.getTestText2();
            _testText3 = _parameterWindow.getTestText3();
            if (_label1) {
                _label1.text = _testText1;
            }
            if (_label2) {
                _label2.text = _testText2;
            }
            if (_label3) {
                _label3.text = _testText3;
            }
        });
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("truetype");
        node.add(_name);
        node.addNode("file").add(_filePath);
        node.addNode("size").add(_fontSize);
        node.addNode("outline").add(_fontOutline);
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    void updateFont() {
        if (!_filePath.length)
            return;

        string filePath = buildNormalizedPath(dirName(path()), _filePath);

        if (!exists(filePath) || _fontSize <= 0)
            return;

        _font = TrueTypeFont.fromFile(filePath, _fontSize, _fontOutline);

        if (!_labelBox) {
            _labelBox = new VBox;
            _labelBox.setAlign(UIAlignX.center, UIAlignY.center);
            addUI(_labelBox);
        }

        if (!_label1) {
            _label1 = new Label(_testText1, _font);
            _label1.outlineColor = Color.black;
            _label1.textColor = Color.white;
            _labelBox.addUI(_label1);
        }
        else {
            _label1.font = _font;
        }
        if (!_label2) {
            _label2 = new Label(_testText2, _font);
            _label2.outlineColor = Color.black;
            _label2.textColor = Color.white;
            _labelBox.addUI(_label2);
        }
        else {
            _label2.font = _font;
        }
        if (!_label3) {
            _label3 = new Label(_testText3, _font);
            _label3.outlineColor = Color.black;
            _label3.textColor = Color.white;
            _labelBox.addUI(_label3);
        }
        else {
            _label3.font = _font;
        }
    }
}

private final class ParameterWindow : UIElement {
    private {
        SelectButton _fileSelect;
        IntegerField _fontSizeField, _fontOutlineField;
        TextField _testField1, _testField2, _testField3;
    }

    this(string resPath, string filePath, int fontSize, int fontOutline,
        string testText1, string testText2, string testText3) {
        string p = buildNormalizedPath(relativePath(resPath, Atelier.etabli.getMediaDir()));
        auto split = pathSplitter(p);
        if (!split.empty) {
            p = split.front;
        }

        string dir = dirName(resPath);
        auto entries = dirEntries(buildNormalizedPath(Atelier.etabli.getMediaDir(), p), SpanMode
                .depth);
        string[] files;
        foreach (entry; entries) {
            if (!entry.isDir) {
                switch (extension(entry)) {
                case ".ttf":
                    files ~= relativePath(entry, dir);
                    break;
                default:
                    break;
                }
            }
        }

        VList vlist = new VList;
        vlist.setPosition(Vec2f(8f, 8f));
        vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        vlist.setAlign(UIAlignX.left, UIAlignY.top);
        vlist.setColor(Atelier.theme.surface);
        vlist.setSpacing(8f);
        vlist.setChildAlign(UIAlignX.left);
        addUI(vlist);

        {
            LabelSeparator sep = new LabelSeparator("Propriétés", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Fichier:", Atelier.theme.font));

            _fileSelect = new SelectButton(files, filePath);
            _fileSelect.setWidth(200f);
            _fileSelect.addEventListener("value", {
                dispatchEvent("property_file", false);
            });
            hlayout.addUI(_fileSelect);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Taille:", Atelier.theme.font));

            _fontSizeField = new IntegerField;
            _fontSizeField.value = fontSize;
            _fontSizeField.setMinValue(1);
            _fontSizeField.addEventListener("value", {
                dispatchEvent("property_size");
            });
            hlayout.addUI(_fontSizeField);
        }
        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Bordure:", Atelier.theme.font));

            _fontOutlineField = new IntegerField;
            _fontOutlineField.value = fontOutline;
            _fontOutlineField.setMinValue(0);
            _fontOutlineField.addEventListener("value", {
                dispatchEvent("property_outline");
            });
            hlayout.addUI(_fontOutlineField);
        }

        {
            LabelSeparator sep = new LabelSeparator("Prévisualisation", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            _testField1 = new TextField;
            _testField1.setWidth(284f);
            _testField1.value = testText1;
            _testField1.addEventListener("value", {
                dispatchEvent("property_text");
            });
            vlist.addList(_testField1);
        }

        {
            _testField2 = new TextField;
            _testField2.setWidth(284f);
            _testField2.value = testText2;
            _testField2.addEventListener("value", {
                dispatchEvent("property_text");
            });
            vlist.addList(_testField2);
        }

        {
            _testField3 = new TextField;
            _testField3.setWidth(284f);
            _testField3.value = testText3;
            _testField3.addEventListener("value", {
                dispatchEvent("property_text");
            });
            vlist.addList(_testField3);
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });
    }

    string getFile() const {
        return _fileSelect.value();
    }

    int getFontSize() const {
        return _fontSizeField.value();
    }

    int getFontOutline() const {
        return _fontOutlineField.value();
    }

    string getTestText1() const {
        return _testField1.value();
    }

    string getTestText2() const {
        return _testField2.value();
    }

    string getTestText3() const {
        return _testField3.value();
    }
}
