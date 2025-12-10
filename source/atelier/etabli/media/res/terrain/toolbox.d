module atelier.etabli.media.res.terrain.toolbox;

import std.conv : to;
import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.render;

import atelier.etabli.common;
import atelier.etabli.ui;
import atelier.etabli.media.res.base;

package(atelier.etabli.media.res.terrain) class Toolbox : Modal {
    private {
        ToolGroup _toolGroup;
        int _tool;
        IntegerField _brushField;
        MultiTilePicker _cliffTilePicker;
        VBox _brushBox;
        int _srcBrush, _dstBrush;
    }

    this() {
        setSize(Vec2f(256f, 250f));
        setAlign(UIAlignX.left, UIAlignY.top);
        setPosition(Vec2f(258f, 75f));

        {
            Label title = new Label("Outils", Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 8f));
            addUI(title);
        }

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.center, UIAlignY.top);
            hbox.setPosition(Vec2f(0f, 32f));
            hbox.setSpacing(4f);
            addUI(hbox);

            _toolGroup = new ToolGroup;
            foreach (key; ["material", "brush"]) {
                ToolButton btn = new ToolButton(_toolGroup,
                    "editor:" ~ key ~ "-button", key == "selection");
                btn.setSize(Vec2f(32f, 32f));
                hbox.addUI(btn);
            }
        }

        addEventListener("update", {
            if (_toolGroup.value != _tool) {
                _tool = _toolGroup.value;
                _onToolChange();
            }
        });

        addEventListener("globalkey", &_onKey);

        _cliffTilePicker = new MultiTilePicker(128f);
        _cliffTilePicker.setAlign(UIAlignX.center, UIAlignY.bottom);
        _cliffTilePicker.setPosition(Vec2f(0f, 8f));
        _cliffTilePicker.addEventListener("value", {
            dispatchEvent("tool", false);
        });
        _cliffTilePicker.setTileset("editor:autotile");
        _cliffTilePicker.setRectMode(true);

        {
            _brushBox = new VBox;
            _brushBox.setAlign(UIAlignX.center, UIAlignY.bottom);
            _brushBox.setPosition(Vec2f(0f, 8f));
            _brushBox.setSpacing(16f);

            {
                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(200, 0f));
                _brushBox.addUI(hlayout);

                hlayout.addUI(new Label("Pinceau:", Atelier.theme.font));

                _brushField = new IntegerField();
                _brushField.setRange(-1, 255);
                _brushField.addEventListener("value", {
                    dispatchEvent("tool", false);
                });
                hlayout.addUI(_brushField);
            }
            {
                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(200, 0f));
                _brushBox.addUI(hlayout);

                hlayout.addUI(new Label("Remplacer:", Atelier.theme.font));

                IntegerField srcField = new IntegerField();
                srcField.setRange(-1, 255);
                hlayout.addUI(srcField);

                hlayout = new HLayout;
                hlayout.setPadding(Vec2f(200, 0f));
                _brushBox.addUI(hlayout);

                hlayout.addUI(new Label("Par:", Atelier.theme.font));

                IntegerField dstField = new IntegerField();
                dstField.setRange(-1, 255);
                hlayout.addUI(dstField);

                NeutralButton replaceBtn = new NeutralButton("Remplacer");
                replaceBtn.addEventListener("click", {
                    _srcBrush = srcField.value();
                    _dstBrush = dstField.value();
                    dispatchEvent("tool_replaceBrush", false);
                });
                _brushBox.addUI(replaceBtn);
            }
        }

        _onToolChange();
    }

    private void _onKey() {
        InputEvent.KeyButton event = getManager().input.asKeyButton();

        if (event.isPressed()) {
            switch (event.button) with (InputEvent.KeyButton.Button) {
            case alpha1:
                _toolGroup.value = 0;
                break;
            case alpha2:
                _toolGroup.value = 1;
                break;
            default:
                break;
            }
        }
    }

    private void _onToolChange() {
        _brushBox.removeUI();
        _cliffTilePicker.removeUI();

        switch (_toolGroup.value()) {
        case 0:
            addUI(_brushBox);
            break;
        case 1:
            addUI(_cliffTilePicker);
            break;
        default:
            break;
        }

        dispatchEvent("tool", false);
    }

    int getTool() const {
        return _toolGroup.value();
    }

    TilesSelection!int getSelection() {
        return _cliffTilePicker.selection;
    }

    int getBrushId() const {
        return _brushField.value();
    }

    void setBrushId(int id) {
        _brushField.value = id;
    }

    Vec2i getBrushReplaceIds() const {
        return Vec2i(_srcBrush, _dstBrush);
    }

    Tileset getTileset() {
        return _cliffTilePicker.getTileset();
    }
}
