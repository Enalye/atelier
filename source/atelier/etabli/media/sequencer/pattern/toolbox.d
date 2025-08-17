module atelier.etabli.media.sequencer.pattern.toolbox;

import atelier;

package class PatternSequencerToolbox : Modal {
    private {
        TabGroup _modeGroup;
        ToolGroup _toolGroup;
        int _tool;
        string _mode;
    }

    this() {
        setSize(Vec2f(264f, 125f));
        setAlign(UIAlignX.left, UIAlignY.top);
        setPosition(Vec2f(258f, 75f));

        {
            Label title = new Label("Outils", Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 8f));
            addUI(title);
        }

        {
            _modeGroup = new TabGroup;
            _modeGroup.setAlign(UIAlignX.center, UIAlignY.top);
            _modeGroup.setPosition(Vec2f(0f, 32f));
            _modeGroup.setWidth(getWidth() - 2f);
            _modeGroup.addTab("Note", "note");
            _modeGroup.addTab("Effet", "effect");
            _modeGroup.selectTab("note");
            addUI(_modeGroup);
        }

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.center, UIAlignY.top);
            hbox.setPosition(Vec2f(0f, 80f));
            hbox.setSpacing(4f);
            addUI(hbox);

            _toolGroup = new ToolGroup;
            foreach (key; [
                    "selection", "move", "pen", "resize", "eraser", "settings",
                    "preview"
                ]) {
                ToolButton btn = new ToolButton(_toolGroup,
                    "editor:" ~ key ~ "-button", key == "selection");
                btn.setSize(Vec2f(32f, 32f));
                hbox.addUI(btn);
            }
        }

        addEventListener("update", {
            if (_toolGroup.value != _tool) {
                _tool = _toolGroup.value;
                dispatchEvent("tool", false);
            }
            else if (_modeGroup.value != _mode) {
                _mode = _modeGroup.value;
                dispatchEvent("tool", false);
            }
        });

        addEventListener("globalkey", &_onKey);
    }

    private void _onKey() {
        InputEvent.KeyButton event = getManager().input.asKeyButton();

        if (event.isPressed()) {
            switch (event.button) with (InputEvent.KeyButton.Button) {
            case tab:
                _modeGroup.selectTab(_modeGroup.value == "note" ? "effect" : "note");
                break;
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
            case alpha5:
                _toolGroup.value = 4;
                break;
            case alpha6:
                _toolGroup.value = 5;
                break;
            case alpha7:
                _toolGroup.value = 6;
                break;
            default:
                break;
            }
        }
    }

    int getTool() const {
        return _toolGroup.value();
    }

    bool getMode() const {
        return _modeGroup.value() == "effect";
    }
}
