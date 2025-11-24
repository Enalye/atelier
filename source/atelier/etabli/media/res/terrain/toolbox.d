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

import atelier.etabli.ui;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.terrain.tilepicker;
import atelier.etabli.media.res.terrain.selection;

package(atelier.etabli.media.res.terrain) class Toolbox : Modal {
    private {
        ToolGroup _toolGroup;
        int _tool;
        TilePicker _collTilePicker, _brushTilePicker;
        SelectButton _materialSelect;
        HBox _materialBox;
    }

    this() {
        setSize(Vec2f(256f, 200f));
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
            foreach (key; ["material", "pen", "brush"]) {
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

        _collTilePicker = new TilePicker;
        _collTilePicker.setAlign(UIAlignX.center, UIAlignY.bottom);
        _collTilePicker.setPosition(Vec2f(0f, 8f));
        _collTilePicker.addEventListener("value", {
            dispatchEvent("tool", false);
        });
        _collTilePicker.setTileset("editor:collision");

        _brushTilePicker = new TilePicker;
        _brushTilePicker.setAlign(UIAlignX.center, UIAlignY.bottom);
        _brushTilePicker.setPosition(Vec2f(0f, 8f));
        _brushTilePicker.addEventListener("value", {
            dispatchEvent("tool", false);
        });
        _brushTilePicker.setTileset("editor:autotile");

        {
            _materialBox = new HBox;
            _materialBox.setSpacing(16f);

            _materialBox.addUI(new Label("Matériau:", Atelier.theme.font));

            string[] materialList;
            foreach (i, mat; Atelier.world.getMaterials()) {
                materialList ~= to!string(i) ~ " - " ~ mat.name;
            }
            _materialSelect = new SelectButton(materialList, "");
            _materialSelect.addEventListener("value", {
                dispatchEvent("tool", false);
            });
            _materialBox.addUI(_materialSelect);
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
            case alpha3:
                _toolGroup.value = 2;
                break;
            default:
                break;
            }
        }
    }

    private void _onToolChange() {
        _collTilePicker.removeUI();
        _materialBox.removeUI();
        _brushTilePicker.removeUI();

        switch (_toolGroup.value()) {
        case 0:
            addUI(_materialBox);
            break;
        case 1:
            addUI(_collTilePicker);
            break;
        case 2:
            addUI(_brushTilePicker);
            break;
        default:
            break;
        }

        dispatchEvent("tool", false);
    }

    int getTool() const {
        return _toolGroup.value();
    }

    int getColliderId() const {
        return _collTilePicker.getTileId();
    }

    int getMaterial() const {
        return _materialSelect.ivalue();
    }

    int getBrushId() const {
        return _brushTilePicker.getTileId();
    }
}
