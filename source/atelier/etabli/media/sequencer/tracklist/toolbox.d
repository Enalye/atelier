module atelier.etabli.media.sequencer.tracklist.toolbox;

import atelier;
import atelier.etabli.media.sequencer.tracklist.editor;

package class TracklistSequencerToolbox : Modal {
    private {
        TabGroup _modeGroup;
        ToolGroup _toolGroup;
        SelectButton _patternSelect;

        int _tool;
        string _mode;
        TracklistSequencerEditor _editor;
    }

    this(TracklistSequencerEditor editor) {
        _editor = editor;
        setSize(Vec2f(225f, 157f));
        setAlign(UIAlignX.left, UIAlignY.top);
        setPosition(Vec2f(258f, 75f));

        {
            Label title = new Label("Outils", Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 8f));
            addUI(title);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setAlign(UIAlignX.center, UIAlignY.top);
            hlayout.setPosition(Vec2f(0f, 32f));
            hlayout.setPadding(Vec2f(200f, 0f));
            addUI(hlayout);

            hlayout.addUI(new Label("Motif:", Atelier.theme.font));

            _patternSelect = new SelectButton(_editor.getPatternList(), "");
            hlayout.addUI(_patternSelect);
        }

        {
            _modeGroup = new TabGroup;
            _modeGroup.setAlign(UIAlignX.center, UIAlignY.top);
            _modeGroup.setPosition(Vec2f(0f, 64f));
            _modeGroup.setWidth(getWidth() - 2f);
            _modeGroup.addTab("Motif", "pattern");
            _modeGroup.addTab("Tempo", "tempo");
            _modeGroup.selectTab("pattern");
            addUI(_modeGroup);
        }

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.center, UIAlignY.top);
            hbox.setPosition(Vec2f(0f, 112f));
            hbox.setSpacing(4f);
            addUI(hbox);

            _toolGroup = new ToolGroup;
            foreach (key; [
                    "selection", "move", "pen", "resize", "eraser", "settings"
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
                _modeGroup.selectTab(_modeGroup.value == "pattern" ? "tempo" : "pattern");
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
            default:
                break;
            }
        }
    }

    int getTool() const {
        return _toolGroup.value();
    }

    bool getMode() const {
        return _modeGroup.value() == "tempo";
    }

    string getPatternName() {
        return _patternSelect.value();
    }
}
