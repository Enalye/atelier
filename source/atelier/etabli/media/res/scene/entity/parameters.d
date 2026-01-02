module atelier.etabli.media.res.scene.entity.parameters;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui;
import atelier.etabli.media.res.scene.common;
import atelier.etabli.media.res.scene.entity.list;
import atelier.etabli.media.res.scene.entity.toolbox;

package(atelier.etabli.media.res.scene) final class EntityParameters : UIElement {
    private {
        SceneDefinition _definition;
        EntityToolbox _toolbox;
        SceneEntityList _entityList;
        VBox _vbox;

        Vec2f _viewDestination = Vec2f.zero;
        Vec2f _centerPosition = Vec2f.zero;
        Vec2f _mapPosition = Vec2f.zero;
        Vec2f _mapSize = Vec2f.zero;
        Vec2f _startMousePosition = Vec2f.zero;
        Vec2f _endMousePosition = Vec2f.zero;
        Vec2f _deltaMousePosition = Vec2f.zero;
        bool _moveZ;

        SceneDefinition.Entity[] _selectedEntities, _tempSelectedEntities;
        UIElement _settingsWindow;

        float _zoom = 1f;
        bool _isApplyingTool;
        void delegate() _updateToolFunc;

        bool _isTool0Selecting;
    }

    this(SceneDefinition definition) {
        _definition = definition;

        _vbox = new VBox;
        _vbox.addUI(new Label("Saucisse", Atelier.theme.font));
        addUI(_vbox);

        _vbox.addEventListener("size", { setSize(_vbox.getSize()); });
        addEventListener("globalkey", &_onKey);
    }

    private void _onKey() {
        InputEvent.KeyButton event = getManager().input.asKeyButton();

        if (event.isDown()) {
            switch (event.button) with (InputEvent.KeyButton.Button) {
            case remove:
                if (_selectedEntities.length > 0) {
                    WarningModal.ask("Suppression des entités", "Voulez-vous supprimer les entités sélectionnés ?", "Supprimer", true, {
                        foreach (entity; _selectedEntities) {
                            entity.isAlive = false;
                        }
                        _selectedEntities.length = 0;
                        setDirty();
                    });
                }
                break;
            default:
                break;
            }
        }
    }

    void openToolbox() {
        if (!_toolbox) {
            _toolbox = new EntityToolbox();
            _toolbox.addEventListener("tool", {});
        }

        Atelier.ui.addUI(_toolbox);
        _toolbox.addEventListener("tool", &_onTool);
        _openSettings();
    }

    void closeToolbox() {
        if (_toolbox) {
            _toolbox.removeUI();
        }
        _toolbox.removeEventListener("tool", &_onTool);
        _unselectEntities();
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
            foreach (entity; _definition.getEntities()) {
                if (entity.isInside(_startMousePosition, _startMousePosition)) {
                    _isTool0Selecting = false;
                    break;
                }
            }

            if (_isTool0Selecting) {
                goto case 1;
            }
            else {
                _captureSelection(true);
                _moveZ = Atelier.input.hasCtrl();
            }
            break;
        case 1:
            if (!Atelier.input.hasCtrl()) {
                _unselectEntities();
            }

            _captureSelection(false);
            break;
        case 2:
            if (_selectedEntities.length == 0) {
                _captureSelection(true);
            }
            _moveZ = Atelier.input.hasCtrl();
            break;
        case 3:
            _createEntity();
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
            SceneDefinition.Entity[] hoveredList;
            foreach (entity; _definition.getEntities()) {
                entity.setHover(false);
                if (entity.checkHover(_endMousePosition))
                    hoveredList ~= entity;
            }

            SceneDefinition.Entity hoveredEntity;
            foreach (entity; hoveredList) {
                if (!hoveredEntity) {
                    hoveredEntity = entity;
                }
                else if ((hoveredEntity.entityData.position.y - hoveredEntity.entityData.position.z) < (
                        entity.entityData.position.y - entity.entityData.position.z)) {
                    hoveredEntity = entity;
                }
            }
            if (hoveredEntity) {
                hoveredEntity.setHover(true);
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
                    if (!Atelier.input.hasCtrl()) {
                        _unselectEntities();
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

        foreach (entity; _tempSelectedEntities) {
            entity.setTempSelected(false);
        }
        _tempSelectedEntities.length = 0;

        foreach (entity; _definition.getEntities()) {
            if (!entity.getTempSelected() && !entity.getSelected() &&
                entity.isInside(minCoord, maxCoord)) {
                entity.setTempSelected(true);
                _tempSelectedEntities ~= entity;
            }
        }

        if (apply) {
            foreach (entity; _tempSelectedEntities) {
                entity.setTempSelected(false);
                entity.setSelected(true);
            }
            _selectedEntities ~= _tempSelectedEntities;
            _tempSelectedEntities.length = 0;

            _openSettings();
        }
    }

    private void _moveSelection(bool apply) {
        Vec2f deltaPosition = _endMousePosition - _startMousePosition;
        Vec3f move = Vec3f.zero;

        if (_moveZ) {
            move = Vec3f(deltaPosition.x, 0f, -deltaPosition.y);
        }
        else {
            move = Vec3f(deltaPosition, 0f);
        }

        foreach (entity; _selectedEntities) {
            entity.setTempMove(move);
        }

        if (apply) {
            foreach (entity; _selectedEntities) {
                entity.applyMove();
            }
        }

        if (_settingsWindow) {
            _settingsWindow.dispatchEvent("entity_update", false);
        }
    }

    private void _createEntity() {
        if (!_toolbox.getType().length)
            return;

        SceneDefinition.Entity entity = _definition.createEntity(_toolbox.getType());
        entity.entityData.position = Vec3i(cast(Vec2i) _endMousePosition, 0);

        switch (_toolbox.getType()) {
        case "prop":
            entity.prop.rid = _toolbox.getRID();
            break;
        case "actor":
            entity.actor.rid = _toolbox.getRID();
            break;
        default:
            break;
        }

        if (!Atelier.input.hasCtrl()) {
            _unselectEntities();
        }

        entity.setSelected(true);
        _selectedEntities ~= entity;
        _openSettings();
        setDirty();
    }

    private void _unselectEntities() {
        foreach (entity; _tempSelectedEntities) {
            entity.setTempSelected(false);
        }
        _tempSelectedEntities.length = 0;

        foreach (entity; _selectedEntities) {
            entity.setSelected(false);
        }
        _selectedEntities.length = 0;
    }

    private void _openSettings() {
        _vbox.clearUI();

        if (_selectedEntities.length == 1) {
            SceneDefinition.Entity entity = _selectedEntities[0];
            _settingsWindow = entity.createSettingsWindow();
            _settingsWindow.addEventListener("property_dirty", &setDirty);
            _settingsWindow.addEventListener("entity_remove", {
                _settingsWindow = null;
                entity.isAlive = false;
                _vbox.clearUI();
                _unselectEntities();
                setDirty();
            });
            _vbox.addUI(_settingsWindow);
        }
        else {
            if (_entityList) {
                _entityList.removeUI();
            }

            if (_selectedEntities.length > 0) {
                _entityList = new SceneEntityList(_selectedEntities);
            }
            else {
                _entityList = new SceneEntityList(_definition.getEntities().array);
            }

            _entityList.addEventListener("entity_list_center", {
                SceneDefinition.Entity entity = _entityList.getSelectedEntity();
                _viewDestination = (cast(Vec3f) entity.tempPosition()).proj2D();
                dispatchEvent("property_centerView", false);
            });

            _entityList.addEventListener("entity_list_select", {
                SceneDefinition.Entity entity = _entityList.getSelectedEntity();
                _viewDestination = (cast(Vec3f) entity.tempPosition()).proj2D();

                foreach (other; _selectedEntities) {
                    other.setSelected(false);
                }
                entity.setSelected(true);
                _selectedEntities = [entity];

                _openSettings();
                dispatchEvent("property_centerView", false);
            });

            _vbox.addUI(_entityList);
        }
    }

    Vec2f getViewDestination() const {
        return _viewDestination;
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
