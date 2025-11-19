module atelier.etabli.media.res.scene.light.parameters;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui;
import atelier.etabli.media.res.scene.common;
import atelier.etabli.media.res.scene.light.toolbox;

package(atelier.etabli.media.res.scene) final class LightParameters : UIElement {
    private {
        SceneDefinition _definition;
        LightToolbox _toolbox;
        VBox _vbox;

        Vec2f _centerPosition = Vec2f.zero;
        Vec2f _mapPosition = Vec2f.zero;
        Vec2f _mapSize = Vec2f.zero;
        Vec2f _startMousePosition = Vec2f.zero;
        Vec2f _endMousePosition = Vec2f.zero;
        Vec2f _deltaMousePosition = Vec2f.zero;

        SceneDefinition.Light[] _selectedLights, _tempSelectedLights;
        UIElement _settingsWindow;

        float _zoom = 1f;
        bool _isApplyingTool;
        void delegate() _updateToolFunc;

        bool _isTool0Selecting;
    }

    this(SceneDefinition definition) {
        _definition = definition;

        _vbox = new VBox;
        addUI(_vbox);

        _vbox.addEventListener("size", { setSize(_vbox.getSize()); });
    }

    void openToolbox() {
        if (!_toolbox) {
            _toolbox = new LightToolbox();
            _toolbox.addEventListener("tool", {});
        }

        Atelier.ui.addUI(_toolbox);
        _toolbox.addEventListener("tool", &_onTool);
    }

    void closeToolbox() {
        if (_toolbox) {
            _toolbox.removeUI();
        }
        _toolbox.removeEventListener("tool", &_onTool);
        _unselectLights();
    }

    private void _onTool() {
    }

    void updateView(Vec2f centerPosition, Vec2f mapPosition, float zoom) {
        _centerPosition = centerPosition;
        _mapPosition = mapPosition;
        _zoom = zoom;
        enum tileSize = 16;
        Vec2i dimensions = Vec2i(_definition.getWidth(), _definition.getHeight());
        _mapSize = (cast(Vec2f) dimensions * tileSize) * _zoom;
    }

    void setDirty() {
        dispatchEvent("property_dirty", false);
    }

    bool hasControlModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightControl);
    }

    bool hasAltModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftAlt) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightAlt);
    }

    void startTool(Vec2f mousePos) {
        _isApplyingTool = true;

        enum tileSize = 16;
        Vec2i dimensions = Vec2i(_definition.getWidth(), _definition.getHeight());
        _mapSize = (cast(Vec2f) dimensions * tileSize) * _zoom;
        Vec2f offset = _centerPosition + _mapPosition;
        _startMousePosition = (mousePos - (offset - _mapSize / 2f)) / _zoom;
        _endMousePosition = _startMousePosition;
        _deltaMousePosition = Vec2f.zero;

        switch (_toolbox.getTool()) {
        case 0:
            _isTool0Selecting = true;
            foreach (light; _definition.getLights()) {
                if (light.isInside(_startMousePosition, _startMousePosition)) {
                    _isTool0Selecting = false;
                    break;
                }
            }

            if (_isTool0Selecting) {
                goto case 1;
            }
            else {
                _captureSelection(true);
            }
            break;
        case 1:
            if (!hasControlModifier()) {
                _unselectLights();
            }

            _captureSelection(false);
            break;
        case 2:
            if (_selectedLights.length == 0) {
                _captureSelection(true);
            }
            break;
        case 3:
            _createLight();
            break;
        default:
            break;
        }
    }

    void updateTool(Vec2f mousePos) {
        enum tileSize = 16;
        Vec2i dimensions = Vec2i(_definition.getWidth(), _definition.getHeight());
        _mapSize = (cast(Vec2f) dimensions * tileSize) * _zoom;
        Vec2f offset = _centerPosition + _mapPosition;
        Vec2f endMousePosition = (mousePos - (offset - _mapSize / 2f)) / _zoom;
        _deltaMousePosition = endMousePosition - _endMousePosition;
        _endMousePosition = endMousePosition;

        if (_isApplyingTool) {
            switch (_toolbox.getTool()) {
            case 0:
                if (_isTool0Selecting) {
                    goto case 1;
                }
                else {
                    goto case 2;
                }
                break;
            case 1:
                _captureSelection(false);
                break;
            case 2:
                _moveSelection(false);
                break;
            default:
                break;
            }
        }
        else {
            SceneDefinition.Light[] hoveredList;
            foreach (light; _definition.getLights()) {
                light.setHover(false);
                if (light.checkHover(_endMousePosition))
                    hoveredList ~= light;
            }

            SceneDefinition.Light hoveredLight;
            foreach (light; hoveredList) {
                if (!hoveredLight) {
                    hoveredLight = light;
                }
                else if (hoveredLight.data.position.y < light.data.position.y) {
                    hoveredLight = light;
                }
            }
            if (hoveredLight) {
                hoveredLight.setHover(true);
            }
        }
    }

    void endTool(Vec2f mousePos) {
        if (!_isApplyingTool)
            return;
        _isApplyingTool = false;

        enum tileSize = 16;
        Vec2i dimensions = Vec2i(_definition.getWidth(), _definition.getHeight());
        _mapSize = (cast(Vec2f) dimensions * tileSize) * _zoom;
        Vec2f offset = _centerPosition + _mapPosition;
        Vec2f endMousePosition = (mousePos - (offset - _mapSize / 2f)) / _zoom;
        _deltaMousePosition = endMousePosition - _endMousePosition;
        _endMousePosition = endMousePosition;

        switch (_toolbox.getTool()) {
        case 0:
            if (_isTool0Selecting) {
                goto case 1;
            }
            else {
                if (_startMousePosition == _endMousePosition) {
                    if (!hasControlModifier()) {
                        _unselectLights();
                    }
                    _captureSelection(true);
                }
                else {
                    goto case 2;
                }
            }
            break;
        case 1:
            _captureSelection(true);
            break;
        case 2:
            _moveSelection(true);
            break;
        default:
            break;
        }
    }

    private void _captureSelection(bool apply) {
        Vec2f minCoord = _startMousePosition.min(_endMousePosition);
        Vec2f maxCoord = _startMousePosition.max(_endMousePosition);

        foreach (light; _tempSelectedLights) {
            light.setTempSelected(false);
        }
        _tempSelectedLights.length = 0;

        foreach (light; _definition.getLights()) {
            if (!light.getTempSelected() && !light.getSelected() &&
                light.isInside(minCoord, maxCoord)) {
                light.setTempSelected(true);
                _tempSelectedLights ~= light;
            }
        }

        if (apply) {
            foreach (light; _tempSelectedLights) {
                light.setTempSelected(false);
                light.setSelected(true);
            }
            _selectedLights ~= _tempSelectedLights;
            _tempSelectedLights.length = 0;

            _openSettings();
        }
    }

    private void _moveSelection(bool apply) {
        Vec2f deltaPosition = _endMousePosition - _startMousePosition;

        foreach (light; _selectedLights) {
            light.setTempMove(deltaPosition);
        }

        if (apply) {
            foreach (light; _selectedLights) {
                light.applyMove();
            }
            setDirty();
        }

        if (_settingsWindow) {
            _settingsWindow.dispatchEvent("light_update", false);
        }
    }

    private void _createLight() {
        if (!_toolbox.getType().length)
            return;

        SceneDefinition.Light light = _definition.createLight(_toolbox.getType());
        light.data.position = cast(Vec2i) _endMousePosition;

        if (!hasControlModifier()) {
            _unselectLights();
        }

        light.setSelected(true);
        _selectedLights ~= light;
        _openSettings();
        setDirty();
    }

    private void _unselectLights() {
        foreach (light; _tempSelectedLights) {
            light.setTempSelected(false);
        }
        _tempSelectedLights.length = 0;

        foreach (light; _selectedLights) {
            light.setSelected(false);
        }
        _selectedLights.length = 0;
    }

    private void _openSettings() {
        _vbox.clearUI();

        if (_selectedLights.length == 1) {
            SceneDefinition.Light light = _selectedLights[0];
            _settingsWindow = light.createSettingsWindow();
            _settingsWindow.addEventListener("property_dirty", &setDirty);
            _settingsWindow.addEventListener("light_remove", {
                _settingsWindow = null;
                light.isAlive = false;
                _vbox.clearUI();
                _unselectLights();
                setDirty();
            });
            _vbox.addUI(_settingsWindow);
        }
    }

    Vec4f getCurrentLayerClip() const {
        Vec2i dimensions = Vec2i(_definition.getWidth(), _definition.getHeight());
        Vec2f mapSize = (cast(Vec2f) dimensions * 16f) * _zoom;
        Vec2f offset = _centerPosition + _mapPosition;
        Vec2f origin = offset - mapSize / 2f;
        return Vec4f(origin, mapSize);
    }

    void renderTool() {
        Vec2f offset = _centerPosition + _mapPosition;
        Vec2f origin = offset - _mapSize / 2f;

        if (_isApplyingTool) {
            switch (_toolbox.getTool()) {
            case 0:
                if (_isTool0Selecting) {
                    goto case 1;
                }
                break;
            case 1:
                Vec2f startPos = origin + _startMousePosition * _zoom;
                Vec2f endPos = origin + _endMousePosition * _zoom;
                Atelier.renderer.drawRect(startPos, endPos - startPos,
                    Atelier.theme.danger, 1f, false);
                break;
            default:
                break;
            }
        }
    }

    void saveView() {

    }

    void loadView() {

    }
}
