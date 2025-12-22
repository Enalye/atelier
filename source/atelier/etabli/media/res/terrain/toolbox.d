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
        IntegerField _brushMapCountField;
        IntegerField _currentBrushMapField;
        IntegerField _mainBrushField, _brushField;
        MultiTilePicker _cliffTilePicker;
        IntegerField _srcField, _dstField;
        NeutralButton _replaceBtn;
        VBox _brushBox, _altBrushBox;
        int _srcBrush, _dstBrush;
        Label _countLabel;

        int _brushID = -1;
        int _brushMapCount;
        int _currentBrushMap;
    }

    this(int brushMapCount, int currentBrushMap) {
        _brushMapCount = brushMapCount;
        _currentBrushMap = currentBrushMap;

        setSize(Vec2f(300f, 350f));
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
            foreach (i, key; ["material", "material", "brush"]) {
                ToolButton btn = new ToolButton(_toolGroup,
                    "editor:" ~ key ~ "-button", i == 0);
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
        _cliffTilePicker.setMaxTile(TerrainMap.CliffsSize + 1);
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

                _mainBrushField = new IntegerField();
                _mainBrushField.setRange(-1, 255);
                _mainBrushField.value = _brushID;
                _mainBrushField.addEventListener("value", {
                    _brushID = _mainBrushField.value;
                    dispatchEvent("tool", false);
                });
                hlayout.addUI(_mainBrushField);
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

                _replaceBtn = new NeutralButton("Remplacer");
                _replaceBtn.addEventListener("click", {
                    _srcBrush = srcField.value();
                    _dstBrush = dstField.value();
                    dispatchEvent("tool_replaceBrush", false);
                });
                _brushBox.addUI(_replaceBtn);
            }
        }

        {
            _altBrushBox = new VBox;
            _altBrushBox.setAlign(UIAlignX.center, UIAlignY.bottom);
            _altBrushBox.setPosition(Vec2f(0f, 8f));
            _altBrushBox.setSpacing(16f);

            {
                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(200, 0f));
                _altBrushBox.addUI(hlayout);

                hlayout.addUI(new Label("Calques:", Atelier.theme.font));

                DangerButton remBtn = new DangerButton("-");
                AccentButton addBtn = new AccentButton("+");
                _countLabel = new Label(to!string(brushMapCount), Atelier.theme.font);

                remBtn.isEnabled = _brushMapCount > 0;
                remBtn.addEventListener("click", {
                    if (_brushMapCount <= 0) {
                        return;
                    }
                    _brushMapCount--;
                    remBtn.isEnabled = _brushMapCount > 0;
                    _countLabel.text = to!string(_brushMapCount);
                    if (_currentBrushMap >= _brushMapCount) {
                        _currentBrushMap = _brushMapCount - 1;

                        if (_brushMapCount == 0) {
                            _currentBrushMapField.isEnabled = false;
                            _currentBrushMapField.setRange(-1, -1);
                            _srcField.isEnabled = false;
                            _dstField.isEnabled = false;
                            _replaceBtn.isEnabled = false;
                        }
                        else {
                            _currentBrushMapField.isEnabled = true;
                            _currentBrushMapField.setRange(0, _brushMapCount - 1);
                            _srcField.isEnabled = true;
                            _dstField.isEnabled = true;
                            _replaceBtn.isEnabled = true;
                        }
                        _currentBrushMapField.value = _currentBrushMap;
                    }
                    dispatchEvent("tool_removeBrushMap");
                });

                addBtn.isEnabled = _brushMapCount < 16;
                addBtn.addEventListener("click", {
                    if (_brushMapCount >= 16) {
                        return;
                    }
                    _brushMapCount++;
                    addBtn.isEnabled = _brushMapCount < 16;
                    _countLabel.text = to!string(_brushMapCount);
                    _currentBrushMapField.setRange(0, _brushMapCount - 1);

                    if (_currentBrushMap < 0) {
                        _currentBrushMap = 0;
                        _currentBrushMapField.isEnabled = true;
                        _srcField.isEnabled = true;
                        _dstField.isEnabled = true;
                        _replaceBtn.isEnabled = true;

                        _currentBrushMapField.value = _currentBrushMap;
                    }
                    dispatchEvent("tool_addBrushMap");
                });

                hlayout.addUI(remBtn);
                hlayout.addUI(_countLabel);
                hlayout.addUI(addBtn);
            }
            {
                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(200, 0f));
                _altBrushBox.addUI(hlayout);

                hlayout.addUI(new Label("Calque actuel:", Atelier.theme.font));

                _currentBrushMapField = new IntegerField();
                if (_brushMapCount <= 0) {
                    _currentBrushMapField.setRange(-1, -1);
                    _currentBrushMapField.isEnabled = false;
                }
                else {
                    _currentBrushMapField.isEnabled = true;
                    _currentBrushMapField.setRange(0, _brushMapCount - 1);
                }
                _currentBrushMapField.addEventListener("value", {
                    _currentBrushMap = _currentBrushMapField.value;
                    dispatchEvent("tool_currentBrushMap");
                });
                hlayout.addUI(_currentBrushMapField);
            }

            {
                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(200, 0f));
                _altBrushBox.addUI(hlayout);

                hlayout.addUI(new Label("Pinceau:", Atelier.theme.font));

                _brushField = new IntegerField();
                _brushField.setRange(-1, 255);
                _brushField.value = _brushID;
                _brushField.addEventListener("value", {
                    _brushID = _brushField.value();
                    dispatchEvent("tool", false);
                });
                hlayout.addUI(_brushField);
            }
            {
                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(200, 0f));
                _altBrushBox.addUI(hlayout);

                hlayout.addUI(new Label("Remplacer:", Atelier.theme.font));

                _srcField = new IntegerField();
                _srcField.setRange(-1, 255);
                hlayout.addUI(_srcField);

                hlayout = new HLayout;
                hlayout.setPadding(Vec2f(200, 0f));
                _altBrushBox.addUI(hlayout);

                hlayout.addUI(new Label("Par:", Atelier.theme.font));

                _dstField = new IntegerField();
                _dstField.setRange(-1, 255);
                hlayout.addUI(_dstField);

                _replaceBtn = new NeutralButton("Remplacer");
                _replaceBtn.addEventListener("click", {
                    _srcBrush = _srcField.value();
                    _dstBrush = _dstField.value();
                    dispatchEvent("tool_replaceBrush", false);
                });
                _altBrushBox.addUI(_replaceBtn);
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
            case alpha3:
                _toolGroup.value = 2;
                break;
            default:
                break;
            }
        }
    }

    private void _onToolChange() {
        _brushBox.removeUI();
        _altBrushBox.removeUI();
        _cliffTilePicker.removeUI();

        switch (_toolGroup.value()) {
        case 0:
            addUI(_brushBox);
            break;
        case 1:
            addUI(_altBrushBox);
            break;
        case 2:
            addUI(_cliffTilePicker);
            break;
        default:
            break;
        }

        dispatchEvent("tool", false);
    }

    int getBrushMapID() const {
        return _currentBrushMap;
    }

    int getTool() const {
        return _toolGroup.value();
    }

    TilesSelection!int getSelection() {
        return _cliffTilePicker.selection;
    }

    int getBrushId() const {
        return _brushID;
    }

    void setBrushId(int id) {
        _brushID = id;
        _mainBrushField.value = _brushID;
        _brushField.value = _brushID;
    }

    Vec2i getBrushReplaceIds() const {
        return Vec2i(_srcBrush, _dstBrush);
    }

    Tileset getTileset() {
        return _cliffTilePicker.getTileset();
    }
}
