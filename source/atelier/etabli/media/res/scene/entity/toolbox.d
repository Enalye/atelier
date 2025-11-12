module atelier.etabli.media.res.scene.entity.toolbox;

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

package(atelier.etabli.media.res.scene) class EntityToolbox : Modal {
    private {
        ToolGroup _toolGroup;
        int _tool;
        SelectButton _typeBtn;
        ResourceButton _ridBtn;
    }

    this() {
        setSize(Vec2f(256f, 140f));
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
            foreach (key; ["selectmove", "selection", "move", "pen"]) {
                ToolButton btn = new ToolButton(_toolGroup,
                    "editor:" ~ key ~ "-button", key == "selectmove");
                btn.setSize(Vec2f(32f, 32f));
                hbox.addUI(btn);
            }
        }

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.center, UIAlignY.top);
        vbox.setChildAlign(UIAlignX.left);
        vbox.setPosition(Vec2f(0f, 80f));
        vbox.setSpacing(4f);
        addUI(vbox);

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(getWidth() - 16f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Type:", Atelier.theme.font));

            _typeBtn = new SelectButton([
                "prop", "actor", "trigger", "teleporter", "note"
            ], "prop");
            _typeBtn.addEventListener("value", &_onType);
            hlayout.addUI(_typeBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(getWidth() - 16f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("RID:", Atelier.theme.font));

            _ridBtn = new ResourceButton("", _typeBtn.value, [_typeBtn.value]);
            hlayout.addUI(_ridBtn);
        }

        addEventListener("update", {
            if (_toolGroup.value != _tool) {
                _tool = _toolGroup.value;
                dispatchEvent("tool", false);
            }
        });

        addEventListener("globalkey", &_onKey);
    }

    private void _onType() {
        switch (_typeBtn.value) {
        case "prop":
        case "actor":
            _ridBtn.setTypes([_typeBtn.value]);
            _ridBtn.setValue(_typeBtn.value, "");
            _ridBtn.isEnabled = true;
            break;
        default:
            _ridBtn.isEnabled = false;
            break;
        }
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

    int getTool() const {
        return _toolGroup.value();
    }

    string getType() const {
        return _typeBtn.value();
    }

    string getRID() const {
        return _ridBtn.isEnabled ? _ridBtn.getName() : "";
    }
}
