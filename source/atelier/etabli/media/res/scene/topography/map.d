module atelier.etabli.media.res.scene.topography.map;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui;
import atelier.etabli.media.res.scene.common;
import atelier.etabli.media.res.scene.topography.toolbox;

package(atelier.etabli.media.res.scene) final class TopographicMap : UIElement {
    private {
        SceneDefinition _definition;
        TopographyToolbox _toolbox;
        ResourceButton _terrainSelect;

        TerrainMap _terrainMap;
        TerrainMap.Brush _brush;
        int _brushSize = 1;
        int _brushLevel = 0;
        int _brushId = -1;

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

        VBox vbox = new VBox;
        addUI(vbox);

        vbox.addEventListener("size", { setSize(vbox.getSize()); });

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Terrain:", Atelier.theme.font));

            _terrainSelect = new ResourceButton(_definition.topologicMap.terrainRID,
                "terrain", ["terrain"]);
            _terrainSelect.addEventListener("value", {
                _definition.topologicMap.terrainRID = _terrainSelect.getName();
                _terrainMap = Atelier.etabli.getTerrain(_definition.topologicMap.terrainRID);

                if (_toolbox) {
                    _toolbox.setTerrainMap(_terrainMap);
                }

                _brush = _terrainMap.getBrush(_toolbox.getBrushName());
                _brushLevel = _toolbox.getBrushLevel();
                _brushSize = _toolbox.getBrushSize();

                setDirty();
            });
            hlayout.addUI(_terrainSelect);
        }

        _terrainMap = Atelier.etabli.getTerrain(_definition.topologicMap.terrainRID);
        if (_terrainMap) {
            _brush = _terrainMap.getBrush(0);
        }
    }

    void openToolbox() {
        if (!_toolbox) {
            _toolbox = new TopographyToolbox(_terrainMap);
            _toolbox.addEventListener("tool", {
                _brushSize = _toolbox.getBrushSize();
                if (_terrainMap) {
                    _brush = _terrainMap.getBrush(_toolbox.getBrushName());
                }
                else {
                    _brush = null;
                }
                _brushLevel = _toolbox.getBrushLevel();
            });
            _toolbox.addEventListener("debug", {
                _definition.topologicMap.debugMode = _toolbox.getDebugMode();
                _definition.topologicMap.debugLevel = _toolbox.getDebugLevel();
            });
        }

        Atelier.ui.addUI(_toolbox);
        _toolbox.addEventListener("tool", &_onTool);
    }

    void closeToolbox() {
        if (_toolbox) {
            _toolbox.removeUI();
        }
        _definition.topologicMap.debugMode = 0;
        _definition.topologicMap.debugLevel = 0;
        _toolbox.removeEventListener("tool", &_onTool);
    }

    private void _onTool() {
    }

    bool hasControlModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightControl);
    }

    void updateView(Vec2f centerPosition, Vec2f mapPosition, float zoom) {
        _centerPosition = centerPosition;
        _mapPosition = mapPosition;
        _zoom = zoom;
        enum tileSize = 16;
        Vec2i dimensions = Vec2i(_definition.getWidth(), _definition.getHeight());
        _mapSize = (cast(Vec2f) dimensions * tileSize) * _zoom;
    }

    private void _pasteBrushTool() {
        int brushSize = _brushSize;
        int offset = brushSize & 0x1;
        Vec2i startTile = _endTile - ((brushSize >> 1) + offset);
        float brushSize2 = (brushSize / 2f) - (offset ? 0.5f : 0f);
        Vec2f center = (cast(Vec2f) _endTile) - (offset ? Vec2f.zero : Vec2f.half);

        for (int y; y <= brushSize + offset; ++y) {
            for (int x; x <= brushSize + offset; ++x) {
                Vec2i tile = startTile + Vec2i(x, y);
                if (tile.x < 0 || tile.y < 0 || tile.x > _definition.getWidth() ||
                    tile.y > (_definition.getHeight() + max(0, _definition.getLevels() - 1)) || (
                        cast(Vec2f) tile)
                    .distance(center) > brushSize2)
                    continue;
                _setTile(tile.x, tile.y);
            }
        }
        _definition.topologicMap.updateTiles();
        setDirty();
    }

    private void _setTile(int x, int y) {
        _definition.topologicMap.setTile(x, y, _brushId, _brushLevel);
        setDirty();
    }

    bool hasAltModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftAlt) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightAlt);
    }

    void startTool(Vec2f mousePos) {
        _isApplyingTool = true;

        enum tileSize = 16;
        Vec2i dimensions = Vec2i(_definition.getWidth() + 1, _definition.getHeight() + 1);
        _mapSize = (cast(Vec2f) dimensions * tileSize) * _zoom;
        Vec2f offset = _centerPosition + _mapPosition;
        _mapMousePosition = (mousePos - (offset - _mapSize / 2f)) / _zoom;
        Vec2i tilePos = (cast(Vec2i) _mapMousePosition) / tileSize;
        _startTile = tilePos;
        _endTile = _startTile;

        if (hasAltModifier()) {
            _brushId = -1;
        }
        else {
            _brushId = _brush ? _brush.id : -1;
        }

        _pasteBrushTool();
        _updateToolFunc = &_pasteBrushTool;
    }

    void updateTool(Vec2f mousePos) {
        enum tileSize = 16;
        Vec2i dimensions = Vec2i(_definition.getWidth() + 1, _definition.getHeight() + 1);
        _mapSize = (cast(Vec2f) dimensions * tileSize) * _zoom;
        Vec2f offset = _centerPosition + _mapPosition;
        _mapMousePosition = (mousePos - (offset - _mapSize / 2f)) / _zoom;
        Vec2i tilePos = (cast(Vec2i) _mapMousePosition) / tileSize;
        _endTile = tilePos;

        if (_updateToolFunc) {
            _updateToolFunc();
        }
    }

    void endTool(Vec2f mousePos) {
        _isApplyingTool = false;

        enum tileSize = 16;
        Vec2i dimensions = Vec2i(_definition.getWidth() + 1, _definition.getHeight() + 1);
        _mapSize = (cast(Vec2f) dimensions * tileSize) * _zoom;
        Vec2f offset = _centerPosition + _mapPosition;
        _mapMousePosition = (mousePos - (offset - _mapSize / 2f)) / _zoom;
        Vec2i tilePos = (cast(Vec2i) _mapMousePosition) / tileSize;
        _endTile = tilePos;
        _updateToolFunc = null;
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
        Vec2f origin = offset + Vec2f(-8f, -8f) * _zoom - _mapSize / 2f;

        Color color = _isApplyingTool ? Atelier.theme.accent : Atelier.theme.onAccent;

        if (hasControlModifier()) {
            color = Atelier.theme.danger;
        }

        if (_definition.topologicMap.debugMode == 2 || _definition.topologicMap.debugMode == 3) {
            renderDebug(_definition.topologicMap.debugLevel);
        }

        Atelier.renderer.drawRect(origin + (cast(Vec2f) _endTile) * 16f * _zoom,
            Vec2f.one * 16f * _zoom, color, 1f, false);
    }

    void renderDebug(int levelToShow) {
        Vec2f offset = _centerPosition + _mapPosition;
        Vec2f origin = offset - _mapSize / 2f;

        for (int y; y <= (_definition.getHeight() + max(0, _definition.getLevels() - 1));
            ++y) {
            for (int x; x <= _definition.getWidth(); ++x) {
                Vec2f pos = origin + (Vec2f(-8f, -8f) + Vec2f(x, y) * 16f +
                        Vec2f(0f, -_definition.getLevel(levelToShow))) * _zoom;

                int level = _definition.topologicMap.getLevel(x, y);
                Color levelColor;

                if (level < levelToShow) {
                    levelColor = Color.blue;
                }
                else if (level == levelToShow) {
                    levelColor = Color.green;
                }
                else if (level > levelToShow) {
                    levelColor = Color.red;
                }

                import std.conv : to;

                Atelier.renderer.drawRect(pos, Vec2f.one * 16f * _zoom, levelColor, 1f, false);
                drawText(pos + Vec2f(6f, 6f) * _zoom, to!dstring(level),
                    Atelier.theme.font, levelColor);
            }
        }
    }

    void setDirty() {
        dispatchEvent("property_dirty", false);
    }

    void saveView() {

    }

    void loadView() {

    }
}
