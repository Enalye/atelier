module atelier.etabli.media.res.scene.parallax.toolbox;

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

import atelier.etabli.ui;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.scene.tilepicker;
import atelier.etabli.media.res.scene.selection;

package(atelier.etabli.media.res.scene) class ParallaxToolbox : Modal {
    private {
        ToolGroup _toolGroup;
        int _tool;
        TilePicker _tilePicker;
        HBox _brushSizeBox;
        Label _brushSizeLabel;
        IntegerField _brushSizeField;
    }

    this() {
        setSize(Vec2f(256f, 512f));
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
            foreach (key; ["selection", "pen", "eraser", "bucket"]) {
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

        _tilePicker = new TilePicker;
        _tilePicker.setAlign(UIAlignX.center, UIAlignY.bottom);
        _tilePicker.setPosition(Vec2f(0f, 8f));
        _tilePicker.addEventListener("value", { dispatchEvent("tool", false); });

        _brushSizeBox = new HBox;
        _brushSizeBox.setAlign(UIAlignX.center, UIAlignY.top);
        _brushSizeBox.setPosition(Vec2f(0f, 76f));

        _brushSizeLabel = new Label("Taille: ", Atelier.theme.font);
        _brushSizeBox.addUI(_brushSizeLabel);

        _brushSizeField = new IntegerField;
        _brushSizeField.setRange(1, 32);
        _brushSizeField.addEventListener("value", {
            dispatchEvent("tool", false);
        });
        _brushSizeBox.addUI(_brushSizeField);

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
            case alpha3:
                _toolGroup.value = 2;
                break;
            case alpha4:
                _toolGroup.value = 3;
                break;
            default:
                break;
            }
        }
    }

    private void _onToolChange() {
        _tilePicker.removeUI();
        _brushSizeBox.removeUI();

        switch (_toolGroup.value()) {
        case 0:
            addUI(_tilePicker);
            _tilePicker.setRectMode(true);
            break;
        case 1:
            addUI(_tilePicker);
            addUI(_brushSizeBox);
            _tilePicker.setRectMode(false);
            break;
        case 2:
            addUI(_brushSizeBox);
            _tilePicker.setRectMode(false);
            break;
        case 3:
            addUI(_tilePicker);
            _tilePicker.setRectMode(false);
            break;
        default:
            break;
        }

        dispatchEvent("tool", false);
    }

    int getTool() const {
        return _toolGroup.value();
    }

    TilesSelection getSelection() {
        return _tilePicker.selection;
    }

    int getBrushSize() {
        return _brushSizeField.value;
    }

    void setTileset(string rid) {
        _tilePicker.setTileset(rid);
    }
}
