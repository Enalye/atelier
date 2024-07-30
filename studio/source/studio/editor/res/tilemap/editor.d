/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editor.res.tilemap.editor;

import std.file;
import std.path;
import std.math : abs;
import atelier;
import farfadet;
import studio.project;
import studio.ui;
import studio.editor.res.base;
import studio.editor.res.editor;
import studio.editor.res.tilemap.toolbox;
import studio.editor.res.tilemap.parameter;
import studio.editor.res.tilemap.selection;

final class TilemapResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        string _tilesetRID;
        Vec2u _gridSize;
        Vec2f _position = Vec2f.zero;
        Tileset _tileset;
        Tilemap _tilemap;
        float _zoom = 1f;
        Vec2f _positionMouse = Vec2f.zero;
        Vec2f _deltaMouse = Vec2f.zero;
        Toolbox _toolbox;
        ParameterWindow _parameterWindow;
        int _tool;
        TilesSelection _selection;
        int _brushSize = 1;
        int _brushTileId;
        bool _isApplyingTool;
        Tilemap _previewSelectionTM;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _name = ffd.get!string(0);

        if (ffd.hasNode("tileset")) {
            _tilesetRID = ffd.getNode("tileset").get!string(0);
        }

        if (ffd.hasNode("size")) {
            _gridSize = ffd.getNode("size").get!Vec2u(0);
        }

        setTilesetRID(_tilesetRID);

        _parameterWindow = new ParameterWindow(_tilesetRID, _gridSize);

        _toolbox = new Toolbox();
        _toolbox.setTileset(getTileset());

        _parameterWindow.addEventListener("property_tilesetRID", {
            _tilesetRID = _parameterWindow.getTilesetRID();
            setTilesetRID(_tilesetRID);
            _toolbox.setTileset(getTileset());
        });

        _parameterWindow.addEventListener("property_size", {
            _gridSize = _parameterWindow.getGridSize();
        });

        addEventListener("gridSize", { _parameterWindow.setGridSize(_gridSize); });
        _toolbox.addEventListener("tool", {
            _tool = _toolbox.getTool();
            _selection = _toolbox.getSelection();
            _brushSize = _toolbox.getBrushSize();
            if (_selection.isValid && _selection.width >= 1 && _selection.height >= 1) {
                _brushTileId = _selection.tiles[0][0];
            }
            updateSelectionPreview();
        });
        addEventListener("register", { Atelier.ui.addUI(_toolbox); });
        addEventListener("unregister", { _toolbox.remove(); });
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("sprite");
        node.add(_name);
        node.addNode("tileset").add(_tilesetRID);
        node.addNode("size").add(_gridSize);
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    void setTilesetRID(string rid) {
        bool mustLoad = _tilemap is null;
        _zoom = 1f;

        if (_tilemap) {
            _tilemap.remove();
        }

        auto tilesetRes = Studio.getResource("tileset", rid);
        auto textureRes = Studio.getResource("texture",
            tilesetRes.farfadet.getNode("texture").get!string(0));
        string filePath = textureRes.farfadet.getNode("file").get!string(0);
        Texture texture = Texture.fromFile(textureRes.getPath(filePath));

        Vec4u tilesetClip;
        uint tilesetColumns, tilesetLines, tilesetMaxCount;
        if (tilesetRes.farfadet.hasNode("clip")) {
            tilesetClip = tilesetRes.farfadet.getNode("clip").get!Vec4u(0);
        }
        if (tilesetRes.farfadet.hasNode("columns")) {
            tilesetColumns = tilesetRes.farfadet.getNode("columns").get!uint(0);
        }
        if (tilesetRes.farfadet.hasNode("lines")) {
            tilesetLines = tilesetRes.farfadet.getNode("lines").get!uint(0);
        }
        tilesetMaxCount = tilesetColumns * tilesetLines;
        if (tilesetRes.farfadet.hasNode("maxCount")) {
            tilesetMaxCount = tilesetRes.farfadet.getNode("maxCount").get!uint(0);
        }

        bool isIsometric;
        if (tilesetRes.farfadet.hasNode("isIsometric")) {
            isIsometric = tilesetRes.farfadet.getNode("isIsometric", 1).get!bool(0);
        }

        uint frameTime;
        if (tilesetRes.farfadet.hasNode("frameTime")) {
            frameTime = tilesetRes.farfadet.getNode("frameTime", 1).get!uint(0);
        }

        int[] tileFrames;
        foreach (node; tilesetRes.farfadet.getNodes("tileFrame")) {
            tileFrames ~= node.get!int(0);
            tileFrames ~= node.get!int(1);
        }

        _tileset = new Tileset(texture, tilesetClip, tilesetColumns,
            tilesetLines, tilesetMaxCount);
        _tilemap = new Tilemap(_tileset, _gridSize.x, _gridSize.y);
        addImage(_tilemap);

        for (int y; y < _gridSize.y; ++y) {
            for (int x; x < _gridSize.x; ++x) {
                _tilemap.setTile(x, y, 0);
            }
        }

        if (mustLoad) {
            addEventListener("update", &_onUpdate);
            addEventListener("draw", &_onDraw);
            addEventListener("wheel", &_onWheel);
            addEventListener("mousedown", &_onMouseDown);
            addEventListener("mouseup", &_onMouseUp);
            addEventListener("mouseleave", &_onMouseLeave);
            addEventListener("clickoutside", &_onMouseLeave);
        }
    }

    private void _onUpdate() {
        _tilemap.position = getCenter() + _position;
    }

    Tileset getTileset() {
        return _tileset;
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

    private void _onMouseLeave() {
        _isApplyingTool = false;
        _positionMouse = Vec2f.zero;
        _deltaMouse = Vec2f.zero;
        removeEventListener("mousemove", &_onDrag);
        removeEventListener("mousemove", &_onCopySelectionTool);
        removeEventListener("mousemove", &_onPasteSelectionTool);
        removeEventListener("mousemove", &_onCopyBrushTool);
        removeEventListener("mousemove", &_onPasteBrushTool);
        removeEventListener("mousemove", &_onEraserTool);
    }

    private void _onMouseDown() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case right:
            addEventListener("mousemove", &_onDrag);
            break;
        case left:
            _isApplyingTool = true;
            switch (_tool) {
            case 0:
                _positionMouse = (getMousePosition() - (_tilemap.position - _tilemap.size / 2f)) / _zoom;
                if (hasControlModifier()) {
                    addEventListener("mousemove", &_onCopySelectionTool);
                    _onCopySelectionTool();
                }
                else {
                    addEventListener("mousemove", &_onPasteSelectionTool);
                    _onPasteSelectionTool();
                }
                break;
            case 1:
                _positionMouse = (getMousePosition() - (_tilemap.position - _tilemap.size / 2f)) / _zoom;
                if (hasControlModifier()) {
                    addEventListener("mousemove", &_onCopyBrushTool);
                    _onCopyBrushTool();
                }
                else {
                    addEventListener("mousemove", &_onPasteBrushTool);
                    _onPasteBrushTool();
                }
                break;
            case 2:
                _positionMouse = (getMousePosition() - (_tilemap.position - _tilemap.size / 2f)) / _zoom;
                addEventListener("mousemove", &_onEraserTool);
                _onEraserTool();
                break;
            case 3:
                _positionMouse = (getMousePosition() - (_tilemap.position - _tilemap.size / 2f)) / _zoom;
                _onFillTool();
                break;
            default:
                break;
            }
            break;
        default:
            break;
        }
    }

    private void _onMouseUp() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case right:
            removeEventListener("mousemove", &_onDrag);
            break;
        case left:
            _isApplyingTool = false;
            switch (_tool) {
            case 0:
                removeEventListener("mousemove", &_onCopySelectionTool);
                removeEventListener("mousemove", &_onPasteSelectionTool);
                _positionMouse = Vec2f.zero;
                break;
            case 1:
                removeEventListener("mousemove", &_onCopyBrushTool);
                removeEventListener("mousemove", &_onPasteBrushTool);
                _positionMouse = Vec2f.zero;
                break;
            case 2:
                removeEventListener("mousemove", &_onEraserTool);
                _positionMouse = Vec2f.zero;
                break;
            default:
                break;
            }
            break;

        default:
            break;
        }
    }

    private Vec4i getSelectionRect() {
        Vec2f endPositionMouse = (getMousePosition() - (_tilemap.position - _tilemap.size / 2f)) / _zoom;

        Vec2i pos1 = (cast(Vec2i) _positionMouse) / cast(Vec2i) _tileset.tileSize;
        Vec2i pos2 = (cast(Vec2i) endPositionMouse) / cast(Vec2i) _tileset.tileSize;

        pos1 = pos1.clamp(Vec2i.zero, Vec2i(_tilemap.columns, _tilemap.lines) - 1);
        pos2 = pos2.clamp(Vec2i.zero, Vec2i(_tilemap.columns, _tilemap.lines) - 1);

        Vec2i startPos = pos1.min(pos2);
        Vec2i endPos = pos1.max(pos2);

        return Vec4i(startPos, endPos);
    }

    private void _onCopySelectionTool() {
        Vec4i rect = getSelectionRect();
        Vec2i startPos = rect.xy;
        Vec2i endPos = rect.zw;

        int width_ = endPos.x + 1 - startPos.x;
        int height_ = endPos.y + 1 - startPos.y;

        _selection.width = width_;
        _selection.height = height_;
        _selection.tiles = new int[][](width_, height_);

        for (int iy; iy < height_; ++iy) {
            for (int ix; ix < width_; ++ix) {
                _selection.tiles[ix][iy] = _tilemap.getTile(startPos.x + ix, startPos.y + iy);
            }
        }
        _selection.isValid = true;

        updateSelectionPreview();
    }

    private void updateSelectionPreview() {
        if (_previewSelectionTM) {
            _previewSelectionTM.remove();
        }

        _previewSelectionTM = new Tilemap(_tileset, _selection.width, _selection.height);
        _previewSelectionTM.setTiles(0, 0, _selection.tiles);
        _previewSelectionTM.anchor = Vec2f.zero;
        _previewSelectionTM.isVisible = false;
        addImage(_previewSelectionTM);
    }

    private void _onPasteSelectionTool() {
        Vec2f endPositionMouse = (getMousePosition() - (_tilemap.position - _tilemap.size / 2f)) / _zoom;
        Vec2i tilePos = (cast(Vec2i) endPositionMouse) / cast(Vec2i) _tileset.tileSize;
        tilePos = tilePos.clamp(Vec2i.zero, Vec2i(_tilemap.columns, _tilemap.lines));

        if (_selection.isValid) {
            _tilemap.setTiles(tilePos.x, tilePos.y, _selection.tiles);
        }
    }

    private Vec2i getTilePos() {
        Vec2f mousePos = (getMousePosition() - (_tilemap.position - _tilemap.size / 2f)) / _zoom;
        Vec2i tilePos = (cast(Vec2i) mousePos) / cast(Vec2i) _tileset.tileSize;
        tilePos = tilePos.clamp(Vec2i.zero, Vec2i(_tilemap.columns, _tilemap.lines) - 1);
        return tilePos;
    }

    private void _onCopyBrushTool() {
        Vec2i tilePos = getTilePos();
        _brushTileId = _tilemap.getTile(tilePos.x, tilePos.y);
    }

    private void _pasteBrushTool(int id) {
        Vec2i tilePos = getTilePos();
        int offset = _brushSize & 0x1;
        Vec2i startTile = tilePos - ((_brushSize >> 1) + offset);
        float brushSize2 = (_brushSize / 2f) - (offset ? 0.5f : 0f);
        Vec2f center = (cast(Vec2f) tilePos) - (offset ? Vec2f.zero : Vec2f.half);

        for (int y; y <= _brushSize + offset; ++y) {
            for (int x; x <= _brushSize + offset; ++x) {
                Vec2i tile = startTile + Vec2i(x, y);
                if (tile.x < 0 || tile.y < 0 || tile.x >= _tilemap.columns ||
                    tile.y >= _tilemap.lines || (cast(Vec2f) tile).distance(center) > brushSize2)
                    continue;
                _tilemap.setTile(tile.x, tile.y, id);
            }
        }
    }

    private void _onPasteBrushTool() {
        _pasteBrushTool(_brushTileId);
    }

    private void _onEraserTool() {
        _pasteBrushTool(-1);
    }

    private void _onFillTool() {
        Vec2i tilePos = getTilePos();
        _fillTilesAt(tilePos.x, tilePos.y, _brushTileId);
    }

    private void _fillTilesAt(int x, int y, int value) {
        Vec2i[] getNeighbors(ref Vec2i tile) {
            Vec2i[] neighbors;
            if (tile.x > 0)
                neighbors ~= Vec2i(tile.x - 1, tile.y);
            if (tile.x + 1 < _tilemap.columns)
                neighbors ~= Vec2i(tile.x + 1, tile.y);
            if (tile.y > 0)
                neighbors ~= Vec2i(tile.x, tile.y - 1);
            if (tile.y + 1 < _tilemap.lines)
                neighbors ~= Vec2i(tile.x, tile.y + 1);
            return neighbors;
        }

        x = clamp(x, 0, _tilemap.columns - 1);
        y = clamp(y, 0, _tilemap.lines - 1);

        if (_tilemap.getTile(x, y) == value)
            return;

        const int valueToReplace = _tilemap.getTile(x, y);

        Vec2i[] frontiers;
        frontiers ~= Vec2i(x, y);
        _tilemap.setTile(x, y, value);

        while (frontiers.length) {
            Vec2i current = frontiers[0];
            frontiers = frontiers[1 .. $];

            foreach (ref neighbor; getNeighbors(current)) {
                if (_tilemap.getTile(neighbor.x, neighbor.y) != valueToReplace)
                    continue;
                _tilemap.setTile(neighbor.x, neighbor.y, value);
                frontiers ~= neighbor;
            }
        }
    }

    private void _onDrag() {
        UIManager manager = getManager();
        InputEvent.MouseMotion ev = manager.input.asMouseMotion();
        _position += ev.deltaPosition;
    }

    private void _onDraw() {
        Atelier.renderer.drawRect(_tilemap.position - _tilemap.size / 2f,
            _tilemap.size, Atelier.theme.onNeutral, 1f, false);

        if (_previewSelectionTM) {
            _previewSelectionTM.isVisible = false;
        }

        switch (_tool) {
        case 0:
            if (hasControlModifier()) {
                if (_isApplyingTool) {
                    Vec4i rect = getSelectionRect();
                    Vec2i startPos = rect.xy;
                    Vec2i endPos = rect.zw;

                    Vec2f origin = _tilemap.position - _tilemap.size / 2f;
                    Atelier.renderer.drawRect(origin + (cast(Vec2f) startPos) * _tilemap.tileSize,
                        cast(Vec2f)(endPos + 1 - startPos) * _tilemap.tileSize,
                        Atelier.theme.danger, 1f, false);
                }
            }
            else {
                if (_selection.isValid) {
                    Vec2f positionMouse = (
                        getMousePosition() - (_tilemap.position - _tilemap.size / 2f)) / _zoom;
                    Vec2i pos = (cast(Vec2i) positionMouse) / cast(Vec2i) _tileset.tileSize;

                    Vec2f origin = _tilemap.position - _tilemap.size / 2f;

                    if (_previewSelectionTM) {
                        _previewSelectionTM.isVisible = true;
                        _previewSelectionTM.size = Vec2f(_selection.width,
                            _selection.height) * _tilemap.tileSize;
                        _previewSelectionTM.position = origin + (cast(Vec2f) pos) *
                            _tilemap.tileSize;
                    }

                    Atelier.renderer.drawRect(origin + (cast(Vec2f) pos) * _tilemap.tileSize,
                        Vec2f(_selection.width, _selection.height) * _tilemap.tileSize, _isApplyingTool ?
                        Atelier.theme.accent : Atelier.theme.onAccent, 1f, false);
                }
            }
            break;
        default:
            break;
        }

        /*Vec4f clip = _zoom * cast(Vec4f) _clip;
        Atelier.renderer.drawRect(_tilemap.position - _tilemap.size / 2f + clip.xy,
            clip.zw, Atelier.theme.accent, 1f, false);*/
    }

    private void _onWheel() {
        UIManager manager = getManager();
        InputEvent.MouseWheel ev = manager.input.asMouseWheel();
        float zoomDelta = 1f + (ev.wheel.sum() * 0.25f);
        _zoom *= zoomDelta;
        _tilemap.size = _tilemap.mapSize * _zoom;
        Vec2f delta = _tilemap.position - getMousePosition();
        _tilemap.position = delta * zoomDelta + getMousePosition();
    }
}
