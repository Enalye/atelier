module atelier.etabli.media.res.instrument;

import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.editor;

import atelier.etabli.ui;

final class InstrumentResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        uint _pc, _msb, _lsb;
        ParameterWindow _parameterWindow;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _name = ffd.get!string(0);

        if (ffd.hasNode("pc")) {
            _pc = ffd.getNode("pc").get!uint(0);
        }

        if (ffd.hasNode("msb")) {
            _msb = ffd.getNode("msb").get!uint(0);
        }

        if (ffd.hasNode("lsb")) {
            _lsb = ffd.getNode("lsb").get!uint(0);
        }

        _parameterWindow = new ParameterWindow(_pc, _msb, _lsb);

        _parameterWindow.addEventListener("property", {
            _pc = _parameterWindow.getPC();
            _msb = _parameterWindow.getMSB();
            _lsb = _parameterWindow.getLSB();
            setDirty();
        });
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("instrument").add(_name);
        node.addNode("pc").add(_pc);
        node.addNode("msb").add(_msb);
        node.addNode("lsb").add(_lsb);
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }
}

private final class ParameterWindow : UIElement {
    private {
        IntegerField _pcField, _msbField, _lsbField;
    }

    this(uint pc, uint msb, uint lsb) {
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

            hlayout.addUI(new Label("PC:", Atelier.theme.font));

            _pcField = new IntegerField;
            _pcField.value = pc;
            _pcField.setMinValue(1);
            _pcField.addEventListener("value", { dispatchEvent("property"); });
            hlayout.addUI(_pcField);
        }
        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("MSB:", Atelier.theme.font));

            _msbField = new IntegerField;
            _msbField.value = msb;
            _msbField.setMinValue(0);
            _msbField.addEventListener("value", { dispatchEvent("property"); });
            hlayout.addUI(_msbField);
        }
        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("LSB:", Atelier.theme.font));

            _lsbField = new IntegerField;
            _lsbField.value = lsb;
            _lsbField.setMinValue(0);
            _lsbField.addEventListener("value", { dispatchEvent("property"); });
            hlayout.addUI(_lsbField);
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });
    }

    uint getPC() const {
        return _pcField.value();
    }

    uint getMSB() const {
        return _msbField.value();
    }

    uint getLSB() const {
        return _lsbField.value();
    }
}
