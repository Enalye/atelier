module atelier.etabli.media.res.material;

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

final class MaterialResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        MaterialData _data;
        ParameterWindow _parameterWindow;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _name = ffd.get!string(0);

        _data.load(ffd);

        _parameterWindow = new ParameterWindow(_data);

        _parameterWindow.addEventListener("property", {
            _data = _parameterWindow.getData();
            setDirty();
        });
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("material").add(_name);
        _data.save(node);
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }
}

private final class ParameterWindow : UIElement {
    private {
        NumberField _frictionField;
        MaterialData _data;
    }

    this(MaterialData data) {
        _data = data;

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

            hlayout.addUI(new Label("Emplacement:", Atelier.theme.font));

            IntegerField slotField = new IntegerField;
            slotField.value = _data.slot;
            slotField.setMinValue(0);
            slotField.addEventListener("value", {
                _data.slot = slotField.value;
                dispatchEvent("property", false);
            });
            hlayout.addUI(slotField);
        }
        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Friction:", Atelier.theme.font));

            NumberField frictionField = new NumberField;
            frictionField.value = _data.friction;
            frictionField.setMinValue(0);
            frictionField.addEventListener("value", {
                _data.friction = frictionField.value;
                dispatchEvent("property", false);
            });
            hlayout.addUI(frictionField);
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });
    }

    MaterialData getData() const {
        return _data;
    }
}
