module atelier.etabli.media.res.scene.collision.layers;

import std.format : format;
import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.render;
import atelier.etabli.ui;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.scene.common;
import atelier.etabli.media.res.scene.editor;
import atelier.etabli.media.res.scene.selection;
import atelier.etabli.media.res.scene.settings;
import atelier.etabli.media.res.scene.collision.add;
import atelier.etabli.media.res.scene.collision.duplicate;
import atelier.etabli.media.res.scene.collision.edit;
import atelier.etabli.media.res.scene.collision.remove;
import atelier.etabli.media.res.scene.collision.toolbox;

package(atelier.etabli.media.res.scene) final class CollisionList : UIElement {
    private {
        SceneDefinition _definition;
        VBox _vbox;
        VList _layerList;
        NeutralButton _dupBtn;
        DangerButton _remBtn;
        SceneDefinition.CollisionLayer _currentLayer;

        int _tool;
        TilesSelection _selection;
        int _brushSize = 1;
        int _brushTileId;
        Tilemap _previewSelectionTM;

        Vec2i _startTile, _endTile;
        Vec2f _centerPosition = Vec2f.zero;
        Vec2f _mapPosition = Vec2f.zero;
        Vec2f _mapSize = Vec2f.zero;
        Vec2f _mapMousePosition = Vec2f.zero;
        float _zoom = 1f;
        bool _isApplyingTool;
        void delegate() _updateToolFunc;
    }

    this(SceneDefinition definition) {
        _definition = definition;

        {
            _vbox = new VBox;
            addUI(_vbox);

            _vbox.addEventListener("size", { setSize(_vbox.getSize()); });
        }

        {
            _layerList = new VList;
            _layerList.setSize(Vec2f(300f, 250f));
            _vbox.addUI(_layerList);
        }

        {
            HBox hbox = new HBox;
            hbox.setSpacing(4f);
            _vbox.addUI(hbox);

            AccentButton addBtn = new AccentButton("Ajouter");
            addBtn.addEventListener("click", &_onAddItem);
            hbox.addUI(addBtn);

            _dupBtn = new NeutralButton("Dupliquer");
            _dupBtn.addEventListener("click", &_onDuplicateItem);
            _dupBtn.isEnabled = false;
            hbox.addUI(_dupBtn);

            _remBtn = new DangerButton("Supprimer");
            _remBtn.addEventListener("click", &_onRemoveItem);
            _remBtn.isEnabled = false;
            hbox.addUI(_remBtn);
        }

        _rebuildList();

        addEventListener("globalkey", &_onKey);
    }

    void openToolbox() {
        if (!_currentLayer) {
            return;
        }
        _currentLayer.openToolbox();
        _currentLayer.toolbox.addEventListener("tool", &_onTool);
    }

    void closeToolbox() {
        if (!_currentLayer) {
            return;
        }
        _currentLayer.closeToolbox();
        _currentLayer.toolbox.removeEventListener("tool", &_onTool);
    }

    private void _onKey() {
        InputEvent.KeyButton event = getManager().input.asKeyButton();

        if (event.isPressed()) {
            switch (event.button) with (InputEvent.KeyButton.Button) {
            case f:
                _selection.flipH();
                updateSelectionPreview();
                break;
            case v:
                _selection.flipV();
                updateSelectionPreview();
                break;
            default:
                break;
            }
        }
    }

    private void _onTool() {
        if (!_currentLayer) {
            return;
        }

        _tool = _currentLayer.toolbox.getTool();
        _selection = _currentLayer.toolbox.getSelection();
        _brushSize = _currentLayer.toolbox.getBrushSize();
        if (_selection.isValid && _selection.width >= 1 && _selection.height >= 1) {
            _brushTileId = _selection.tiles[0][0];
        }

        updateSelectionPreview();
    }

    bool hasControlModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightControl);
    }

    bool hasShiftModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftShift) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightShift);
    }

    bool hasAltModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftAlt) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightAlt);
    }

    void updateView(Vec2f centerPosition, Vec2f mapPosition, float zoom) {
        _centerPosition = centerPosition;
        _mapPosition = mapPosition;
        _zoom = zoom;
        enum tileSize = 16;
        Vec2i dimensions = Vec2i(_definition.getWidth(), _definition.getHeight());
        _mapSize = (cast(Vec2f) dimensions * tileSize) * _zoom;
    }

    void startTool(Vec2f mousePos) {
        if (!_currentLayer) {
            return;
        }

        _isApplyingTool = true;

        enum tileSize = 16;
        Vec2i dimensions = Vec2i(_definition.getWidth(), _definition.getHeight());
        _mapSize = (cast(Vec2f) dimensions * tileSize) * _zoom;
        Vec2f offset = _centerPosition + _mapPosition + Vec2f(0f,
            -_definition.getLevel(_currentLayer.level) * _zoom);
        _mapMousePosition = (mousePos - (offset - _mapSize / 2f)) / _zoom;
        Vec2i tilePos = (cast(Vec2i) _mapMousePosition) / tileSize;
        _startTile = tilePos;
        _endTile = _startTile;
        _updateToolFunc = null;

        switch (_tool) {
        case 0:
            if (hasControlModifier()) {
                _onCopySelectionTool();
                _updateToolFunc = &_onCopySelectionTool;
            }
            else {
                _onPasteSelectionTool();
                _updateToolFunc = &_onPasteSelectionTool;
            }
            break;
        case 1:
            if (hasControlModifier()) {
                _onCopyBrushTool();
                _updateToolFunc = &_onCopyBrushTool;
            }
            else {
                _onPasteBrushTool();
                _updateToolFunc = &_onPasteBrushTool;
            }
            break;
        case 2:
            _onEraserTool();
            _updateToolFunc = &_onEraserTool;
            break;
        case 3:
            if (hasControlModifier()) {
                _fillTilesAt(_startTile.x, _startTile.y, -1);
            }
            else {
                _fillTilesAt(_startTile.x, _startTile.y, _brushTileId);
            }
            break;
        default:
            break;
        }
    }

    void updateTool(Vec2f mousePos) {
        if (!_currentLayer) {
            return;
        }

        enum tileSize = 16;
        Vec2i dimensions = Vec2i(_definition.getWidth(), _definition.getHeight());
        _mapSize = (cast(Vec2f) dimensions * tileSize) * _zoom;
        Vec2f offset = _centerPosition + _mapPosition + Vec2f(0f,
            -_definition.getLevel(_currentLayer.level) * _zoom);
        _mapMousePosition = (mousePos - (offset - _mapSize / 2f)) / _zoom;
        Vec2i tilePos = (cast(Vec2i) _mapMousePosition) / tileSize;
        _endTile = tilePos;

        if (_updateToolFunc) {
            _updateToolFunc();
        }
    }

    void endTool(Vec2f mousePos) {
        if (!_currentLayer) {
            return;
        }

        _isApplyingTool = false;

        enum tileSize = 16;
        Vec2i dimensions = Vec2i(_definition.getWidth(), _definition.getHeight());
        _mapSize = (cast(Vec2f) dimensions * tileSize) * _zoom;
        Vec2f offset = _centerPosition + _mapPosition + Vec2f(0f,
            -_definition.getLevel(_currentLayer.level) * _zoom);
        _mapMousePosition = (mousePos - (offset - _mapSize / 2f)) / _zoom;
        Vec2i tilePos = (cast(Vec2i) _mapMousePosition) / tileSize;
        _endTile = tilePos;
        _updateToolFunc = null;
    }

    private Vec4i getSelectionRect() {
        if (!_currentLayer)
            return Vec4i.zero;

        Vec2i startPos = _startTile.min(_endTile);
        Vec2i endPos = _startTile.max(_endTile);

        return Vec4i(startPos, endPos);
    }

    private void _onCopySelectionTool() {
        if (!_currentLayer)
            return;

        Vec4i rect = getSelectionRect();
        Vec2i startPos = rect.xy;
        Vec2i endPos = rect.zw;

        int width_ = endPos.x + 1 - startPos.x;
        int height_ = endPos.y + 1 - startPos.y;

        _selection.width = width_;
        _selection.height = height_;
        _selection.tiles = new int[][](height_, width_);

        for (int iy; iy < height_; ++iy) {
            for (int ix; ix < width_; ++ix) {
                _selection.tiles[iy][ix] = _currentLayer.tilemap.getTile(startPos.x + ix,
                    startPos.y + iy);
            }
        }
        _selection.isValid = true;

        updateSelectionPreview();
    }

    private void updateSelectionPreview() {
        if (!_currentLayer)
            return;

        _previewSelectionTM = new Tilemap(Atelier.res.get!Tileset("editor:collision"),
            _selection.width, _selection.height);
        _previewSelectionTM.setTiles(0, 0, _selection.tiles);
        _previewSelectionTM.anchor = Vec2f.zero;
    }

    private void _onPasteSelectionTool() {
        if (!_currentLayer)
            return;

        if (_selection.isValid) {
            _currentLayer.tilemap.setTiles(_endTile.x, _endTile.y, _selection.tiles);
            setDirty();
        }
    }

    private void _onCopyBrushTool() {
        if (!_currentLayer)
            return;

        _brushTileId = _currentLayer.tilemap.getTile(_endTile.x, _endTile.y);
    }

    private void _pasteBrushTool(int id) {
        if (!_currentLayer)
            return;

        int brushSize = _brushSize;
        int offset = brushSize & 0x1;
        Vec2i startTile = _endTile - ((brushSize >> 1) + offset);
        float brushSize2 = (brushSize / 2f) - (offset ? 0.5f : 0f);
        Vec2f center = (cast(Vec2f) _endTile) - (offset ? Vec2f.zero : Vec2f.half);

        for (int y; y <= brushSize + offset; ++y) {
            for (int x; x <= brushSize + offset; ++x) {
                Vec2i tile = startTile + Vec2i(x, y);
                if (tile.x < 0 || tile.y < 0 || tile.x >= _currentLayer.tilemap.columns ||
                    tile.y >= _currentLayer.tilemap.lines || (cast(Vec2f) tile)
                    .distance(center) > brushSize2)
                    continue;
                _currentLayer.tilemap.setTile(tile.x, tile.y, id);
            }
        }
        setDirty();
    }

    private void _onPasteBrushTool() {
        _pasteBrushTool(_brushTileId);
    }

    private void _onEraserTool() {
        _pasteBrushTool(-1);
    }

    private void _fillTilesAt(int x, int y, int value) {
        if (!_currentLayer)
            return;

        Tilemap tilemap = _currentLayer.tilemap;

        Vec2i[] getNeighbors(ref Vec2i tile) {
            Vec2i[] neighbors;
            if (tile.x > 0)
                neighbors ~= Vec2i(tile.x - 1, tile.y);
            if (tile.x + 1 < tilemap.columns)
                neighbors ~= Vec2i(tile.x + 1, tile.y);
            if (tile.y > 0)
                neighbors ~= Vec2i(tile.x, tile.y - 1);
            if (tile.y + 1 < tilemap.lines)
                neighbors ~= Vec2i(tile.x, tile.y + 1);
            return neighbors;
        }

        x = clamp(x, 0, tilemap.columns - 1);
        y = clamp(y, 0, tilemap.lines - 1);

        const int valueToReplace = tilemap.getTile(x, y);

        if (valueToReplace == value)
            return;

        Vec2i[] frontiers;
        frontiers ~= Vec2i(x, y);
        tilemap.setTile(x, y, value);

        while (frontiers.length) {
            Vec2i current = frontiers[0];
            frontiers = frontiers[1 .. $];

            foreach (ref neighbor; getNeighbors(current)) {
                if (tilemap.getTile(neighbor.x, neighbor.y) != valueToReplace)
                    continue;
                tilemap.setTile(neighbor.x, neighbor.y, value);
                frontiers ~= neighbor;
            }
        }
        setDirty();
    }

    void setDirty() {
        dispatchEvent("property_dirty", false);
    }

    private void _rebuildList() {
        _layerList.clearList();
        foreach (layer; _definition.getCollisionLayers()) {
            LayerElement elt = new LayerElement(this, layer);
            _layerList.addList(elt);
        }
    }

    private void _select(SceneDefinition.CollisionLayer layer) {
        closeToolbox();

        _currentLayer = layer;
        size_t i;
        foreach (item; cast(LayerElement[]) _layerList.getList()) {
            bool isSelected = item._layer == layer;
            if (isSelected) {
                _layerList.moveToElement(i);
            }
            item.updateSelection(isSelected);
            i++;
        }

        openToolbox();

        _dupBtn.isEnabled = _currentLayer !is null;
        _remBtn.isEnabled = _currentLayer !is null;
    }

    private void _onAddItem() {
        auto modal = new AddCollisionElement;
        modal.addEventListener("apply", {
            SceneDefinition.CollisionLayer layer = _definition.createCollisionLayer();
            layer.name = modal.getName();
            _rebuildList();
            _select(layer);
        });
        Atelier.ui.pushModalUI(modal);
    }

    private void _onDuplicateItem() {
        if (!_currentLayer)
            return;

        auto modal = new DuplicateCollisionElement(_currentLayer.name);
        modal.addEventListener("apply", {
            SceneDefinition.CollisionLayer layer = _definition.duplicateCollisionLayer(
                _currentLayer);
            layer.name = modal.getName();
            _rebuildList();
            _select(layer);
        });
        Atelier.ui.pushModalUI(modal);
    }

    private void _onEditItem(SceneDefinition.CollisionLayer layer) {
        auto modal = new EditCollisionElement(layer);
        modal.addEventListener("apply", {
            layer.name = modal.getName();
            layer.level = modal.getLevel();
            _rebuildList();
            _select(layer);
        });
        Atelier.ui.pushModalUI(modal);
    }

    private void _onRemoveItem() {
        if (!_currentLayer)
            return;

        auto modal = new RemoveCollisionElement(_currentLayer);
        modal.addEventListener("apply", {
            _currentLayer.remove();
            _rebuildList();
        });
        Atelier.ui.pushModalUI(modal);
    }

    private void moveUp(SceneDefinition.CollisionLayer layer) {
        layer.moveUp();
        _rebuildList();
        _select(layer);
    }

    private void moveDown(SceneDefinition.CollisionLayer layer) {
        layer.moveDown();
        _rebuildList();
        _select(layer);
    }

    Vec4f getCurrentLayerClip() const {
        if (!_currentLayer)
            return Vec4f.zero;

        Vec2i dimensions = Vec2i(_definition.getWidth(), _definition.getHeight());
        Vec2f mapSize = (cast(Vec2f) dimensions * 16f) * _zoom;
        Vec2f offset = _centerPosition + _mapPosition + Vec2f(0f,
            -_definition.getLevel(_currentLayer.level) * _zoom);
        Vec2f origin = offset - mapSize / 2f;
        return Vec4f(origin, mapSize);
    }

    void renderTool() {
        if (!_currentLayer)
            return;

        Vec2f offset = _centerPosition + _mapPosition + Vec2f(0f,
            -_definition.getLevel(_currentLayer.level) * _zoom);
        Vec2f origin = offset - _mapSize / 2f;

        switch (_tool) {
        case 0:
            if (hasControlModifier()) {
                if (_isApplyingTool) {
                    Vec4i rect = getSelectionRect();
                    Vec2i startPos = rect.xy;
                    Vec2i endPos = rect.zw;

                    Atelier.renderer.drawRect(origin + (cast(Vec2f) startPos) * 16f * _zoom,
                        cast(Vec2f)(endPos + 1 - startPos) * 16f * _zoom,
                        Atelier.theme.danger, 1f, false);
                }
            }
            else {
                if (_selection.isValid) {
                    if (_previewSelectionTM) {
                        _previewSelectionTM.size = Vec2f(_selection.width,
                            _selection.height) * 16f * _zoom;
                        _previewSelectionTM.draw(origin + (cast(Vec2f) _endTile) * 16f * _zoom);
                    }

                    Atelier.renderer.drawRect(origin + (cast(Vec2f) _endTile) * 16f * _zoom,
                        Vec2f(_selection.width, _selection.height) * 16f * _zoom, _isApplyingTool ?
                            Atelier.theme.accent : Atelier.theme.onAccent, 1f, false);
                }
            }
            break;
        default:
            Color color = _isApplyingTool ? Atelier.theme.accent : Atelier.theme.onAccent;

            if (hasControlModifier()) {
                color = Atelier.theme.danger;
            }

            Atelier.renderer.drawRect(origin + (cast(Vec2f) _endTile) * 16f * _zoom,
                Vec2f.one * 16f * _zoom, color, 1f, false);
            break;
        }
    }

    void saveView() {

    }

    void loadView() {

    }
}

package final class LayerElement : UIElement {
    private {
        CollisionList _list;
        Rectangle _rect;
        Label _label;
        bool _isSelected;
        HBox _hbox;
        IconButton _editBtn, _upBtn, _downBtn;
        SceneDefinition.CollisionLayer _layer;
    }

    this(CollisionList rlist, SceneDefinition.CollisionLayer layer) {
        _list = rlist;
        _layer = layer;
        setSize(Vec2f(284f, 32f));

        _rect = Rectangle.fill(getSize());
        _rect.anchor = Vec2f.zero;
        _rect.color = Atelier.theme.foreground;
        _rect.isVisible = false;
        addImage(_rect);

        _label = new Label(format("%s (%d)", _layer.name, _layer.level), Atelier.theme.font);
        _label.setAlign(UIAlignX.left, UIAlignY.center);
        _label.setPosition(Vec2f(64f, 0f));
        addUI(_label);

        {
            _hbox = new HBox;
            _hbox.setAlign(UIAlignX.right, UIAlignY.center);
            _hbox.setSpacing(2f);
            addUI(_hbox);

            _editBtn = new IconButton("editor:gear");
            _editBtn.addEventListener("click", { _list._onEditItem(_layer); });
            _hbox.addUI(_editBtn);

            _upBtn = new IconButton("editor:arrow-small-up");
            _upBtn.addEventListener("click", { _list.moveUp(_layer); });
            _hbox.addUI(_upBtn);

            _downBtn = new IconButton("editor:arrow-small-down");
            _downBtn.addEventListener("click", { _list.moveDown(_layer); });
            _hbox.addUI(_downBtn);

            _hbox.isVisible = false;
            _hbox.isEnabled = false;
        }

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
        addEventListener("click", &_onClick);
    }

    private void _onMouseEnter() {
        if (_isSelected) {
            _rect.color = Atelier.theme.accent;
            _label.textColor = Atelier.theme.onAccent;
        }
        else {
            _rect.color = Atelier.theme.foreground;
            _label.textColor = Atelier.theme.onNeutral;
        }
        _rect.isVisible = true;
        _hbox.isVisible = true;
        _hbox.isEnabled = true;
    }

    private void _onMouseLeave() {
        if (_isSelected) {
            _rect.color = Atelier.theme.accent;
            _label.textColor = Atelier.theme.onAccent;
        }
        else {
            _rect.color = Atelier.theme.foreground;
            _label.textColor = Atelier.theme.onNeutral;
        }
        _rect.isVisible = _isSelected;
        _hbox.isVisible = false;
        _hbox.isEnabled = false;
    }

    private void _onClick() {
        _list._select(_layer);
    }

    protected void updateSelection(bool select_) {
        if (_isSelected == select_)
            return;

        _isSelected = select_;

        if (isHovered) {
            _onMouseEnter();
        }
        else {
            _onMouseLeave();
        }
    }
}
