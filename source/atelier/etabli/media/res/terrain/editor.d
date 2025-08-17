module atelier.etabli.media.res.terrain.editor;

import std.conv : to;
import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier;

import atelier.etabli.ui;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.editor;
import atelier.etabli.media.res.terrain.toolbox;
import atelier.etabli.media.res.terrain.parameter;

final class TerrainResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;

        Vec2f _mapPosition = Vec2f.zero;
        float _zoom = 1f;
        Vec2f _mapSize = Vec2f.zero;
        Vec2f _nominalMapSize = Vec2f.zero;
        Vec2f _positionMouse = Vec2f.zero;
        ParameterWindow _parameterWindow;
        Toolbox _toolbox;
        int _colliderTileId, _brushTileId;
        uint _material;
        bool _isApplyingTool;

        string _name;
        uint _columns, _lines;
        string _tilesetRID;
        Tileset _tileset;
        Tilemap _tilemap, _collTilemap, _matTilemap;
        Rectangle _rectangle;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _tilemap = new Tilemap(0, 0);
        _collTilemap = new Tilemap(Atelier.res.get!Tileset("editor:collision"), 0, 0);
        _matTilemap = new Tilemap(0, 0);

        _collTilemap.defaultTile = -1;
        _matTilemap.defaultTile = 0;

        _collTilemap.alpha = .5f;
        _matTilemap.alpha = .5f;

        _rectangle = Rectangle.fill(Vec2f(16f, 16f));
        _rectangle.anchor = Vec2f.zero;
        _rectangle.color = Atelier.theme.accent;
        _rectangle.alpha = .5f;

        _name = _ffd.get!string(0);

        if (_ffd.hasNode("size")) {
            Farfadet sizeNode = _ffd.getNode("size");
            _columns = sizeNode.get!uint(0);
            _lines = sizeNode.get!uint(1);
        }

        if (_ffd.hasNode("tileset")) {
            _setTilesetRID(_ffd.getNode("tileset").get!string(0));
        }

        if (_ffd.hasNode("collision")) {
            _collTilemap.setTiles(0, 0, _ffd.getNode("collision").get!(int[][])(0));
        }

        if (_ffd.hasNode("material")) {
            _matTilemap.setTiles(0, 0, _ffd.getNode("material").get!(int[][])(0));
        }

        _parameterWindow = new ParameterWindow(_tilesetRID, _tileset ?
                _tileset.columns : 0, _tileset ? _tileset.lines : 0);
        _parameterWindow.load(_ffd);

        _toolbox = new Toolbox;

        _toolbox.addEventListener("tool", {
            _colliderTileId = _toolbox.getColliderId();
            _brushTileId = _toolbox.getBrushId();
            _material = _toolbox.getMaterial();
        });

        addEventListener("update", &_onUpdate);
        addEventListener("draw", &_onDraw);
        addEventListener("wheel", &_onWheel);
        addEventListener("mousedown", &_onMouseDown);
        addEventListener("mouseup", &_onMouseUp);
        addEventListener("mouseleave", {
            _isApplyingTool = false;
            removeEventListener("mousemove", &_onDrag);
            removeEventListener("mousemove", &_onCopyMaterialTool);
            removeEventListener("mousemove", &_onPasteMaterialTool);
            removeEventListener("mousemove", &_onCopyCollisionTool);
            removeEventListener("mousemove", &_onPasteCollisionTool);
            removeEventListener("mousemove", &_onEraseCollisionTool);
            removeEventListener("mousemove", &_onCopyBrushTool);
            removeEventListener("mousemove", &_onPasteBrushTool);
            removeEventListener("mousemove", &_onEraseBrushTool);
        });

        _parameterWindow.addEventListener("property_tilesetRID", {
            _setTilesetRID(_parameterWindow.getTilesetRID());
        });

        addEventListener("register", { Atelier.ui.addUI(_toolbox); });
        addEventListener("unregister", { _toolbox.removeUI(); });
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("terrain").add(_name);
        node.addNode("tileset").add(_tilesetRID);
        node.addNode("size").add(_columns).add(_lines);
        node.addNode("collision").add(_collTilemap.getTiles());
        node.addNode("material").add(_matTilemap.getTiles());
        _parameterWindow.save(node);
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    private void _setTilesetRID(string rid) {
        _tilesetRID = rid;
        _tileset = Atelier.etabli.getTileset(rid);
        if (!_tileset)
            return;

        _tilemap.setTileset(_tileset);

        _columns = _tileset.columns;
        _lines = _tileset.lines;

        _tilemap.setDimensions(_columns, _lines);
        _collTilemap.setDimensions(_columns, _lines);
        _matTilemap.setDimensions(_columns << 1, _lines << 1);

        int id;
        __tilesetLoop: for (int y; y < _tileset.lines; ++y) {
            for (int x; x < _tileset.columns; ++x) {
                _tilemap.setTile(x, y, id);
                id++;
                if (id > _tileset.maxCount)
                    break __tilesetLoop;
            }
        }

        if (_parameterWindow) {
            _parameterWindow.setDimensions(_tileset.columns, _tileset.lines);
        }

        _nominalMapSize = Vec2f(_tileset.columns, _tileset.lines) * 16f;
        _mapSize = _nominalMapSize;
        _mapPosition = Vec2f.zero;
        _zoom = 1f;
    }

    bool hasControlModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightControl);
    }

    bool hasAltModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftAlt) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightAlt);
    }

    private void _onUpdate() {
        _tilemap.position = getCenter() + _mapPosition;
        _tilemap.size = _mapSize;

        _collTilemap.position = getCenter() + _mapPosition;
        _collTilemap.size = _mapSize;

        _matTilemap.position = getCenter() + _mapPosition;
        _matTilemap.size = _mapSize;

        Tilemap tilemap = _parameterWindow.getBrushTilemap();
        if (tilemap) {
            tilemap.position = getCenter() + _mapPosition;
            tilemap.size = _mapSize;
        }
    }

    private void _onMouseDown() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case right:
            addEventListener("mousemove", &_onDrag);
            break;
        case left:
            _isApplyingTool = true;
            switch (_toolbox.getTool()) {
            case 0:
                _positionMouse = (getMousePosition() - (_tilemap.position - _tilemap.size / 2f)) / _zoom;
                if (hasControlModifier()) {
                    addEventListener("mousemove", &_onCopyMaterialTool);
                    _onCopyMaterialTool();
                }
                else {
                    addEventListener("mousemove", &_onPasteMaterialTool);
                    _onPasteMaterialTool();
                }
                break;
            case 1:
                _positionMouse = (getMousePosition() - (_tilemap.position - _tilemap.size / 2f)) / _zoom;
                if (hasControlModifier() && hasAltModifier()) {
                    _colliderTileId = -1;
                }
                else if (hasControlModifier()) {
                    addEventListener("mousemove", &_onCopyCollisionTool);
                    _onCopyCollisionTool();
                }
                else if (hasAltModifier()) {
                    addEventListener("mousemove", &_onEraseCollisionTool);
                    _onEraseCollisionTool();
                }
                else {
                    addEventListener("mousemove", &_onPasteCollisionTool);
                    _onPasteCollisionTool();
                }
                break;
            case 2:
                _positionMouse = (getMousePosition() - (_tilemap.position - _tilemap.size / 2f)) / _zoom;
                if (hasControlModifier() && hasAltModifier()) {
                    _brushTileId = -1;
                }
                else if (hasControlModifier()) {
                    addEventListener("mousemove", &_onCopyBrushTool);
                    _onCopyBrushTool();
                }
                else if (hasAltModifier()) {
                    addEventListener("mousemove", &_onEraseBrushTool);
                    _onEraseBrushTool();
                }
                else {
                    addEventListener("mousemove", &_onPasteBrushTool);
                    _onPasteBrushTool();
                }
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
            switch (_toolbox.getTool()) {
            case 0:
                removeEventListener("mousemove", &_onCopyMaterialTool);
                removeEventListener("mousemove", &_onPasteMaterialTool);
                _positionMouse = Vec2f.zero;
                break;
            case 1:
                removeEventListener("mousemove", &_onCopyCollisionTool);
                removeEventListener("mousemove", &_onPasteCollisionTool);
                removeEventListener("mousemove", &_onEraseCollisionTool);
                _positionMouse = Vec2f.zero;
                break;
            case 2:
                removeEventListener("mousemove", &_onCopyBrushTool);
                removeEventListener("mousemove", &_onPasteBrushTool);
                removeEventListener("mousemove", &_onEraseBrushTool);
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

    private void _onDrag() {
        UIManager manager = getManager();
        InputEvent.MouseMotion ev = manager.input.asMouseMotion();
        _mapPosition += ev.deltaPosition;
    }

    private void _onWheel() {
        UIManager manager = getManager();
        InputEvent.MouseWheel ev = manager.input.asMouseWheel();
        float zoomDelta = 1f + (ev.wheel.sum() * 0.25f);
        _zoom *= zoomDelta;

        if (_mapSize.x == 0 || _mapSize.y == 0)
            return;

        Vec2f mouseOffset = getMousePosition() - getCenter();
        Vec2f delta = (mouseOffset - _mapPosition) / _mapSize;
        _mapSize = _nominalMapSize * _zoom;
        Vec2f delta2 = (mouseOffset - _mapPosition) / _mapSize;

        _mapPosition += (delta2 - delta) * _mapSize;
    }

    private void _onDraw() {
        if (!_tileset)
            return;

        _tilemap.draw();

        switch (_toolbox.getTool()) {
        case 1:
            _collTilemap.draw();
            break;
        case 2:
            Tilemap tilemap = _parameterWindow.getBrushTilemap();
            if (tilemap)
                tilemap.draw();
            break;
        default:
            break;
        }

        Vec2f origin = _tilemap.position - _tilemap.size / 2f;
        uint frame;

        switch (_toolbox.getTool()) {
        case 0:
            _rectangle.size = Vec2f.one * 8f * _zoom;

            for (uint y; y < (_tileset.lines << 1); ++y) {
                for (uint x; x < (_tileset.columns << 1); ++x) {
                    Vec4f clip = Vec4f(x, y, 1f, 1f) * 8f * _zoom;

                    int material = _matTilemap.getTile(x, y);
                    if (material == _material) {
                        _rectangle.draw(origin + clip.xy);
                        drawText(origin + Vec2f(2f, 8f - 2f) + clip.xy,
                            to!dstring(material), Atelier.theme.font, Atelier.theme.onAccent);
                    }
                    else {
                        drawText(origin + Vec2f(2f, 8f - 2f) + clip.xy,
                            to!dstring(material), Atelier.theme.font, Atelier.theme.onNeutral);
                    }

                    Atelier.renderer.drawRect(origin + clip.xy, clip.zw,
                        Atelier.theme.neutral, 1f, false);

                    frame++;
                }
            }
            break;
        default:
            _rectangle.size = Vec2f.one * 16f * _zoom;

            for (uint y; y < _tileset.lines; ++y) {
                for (uint x; x < _tileset.columns; ++x) {
                    Vec4f clip = Vec4f(x, y, 1f, 1f) * 16f * _zoom;

                    Atelier.renderer.drawRect(origin + clip.xy, clip.zw,
                        Atelier.theme.neutral, 1f, false);

                    frame++;
                }
            }
            break;
        }
    }

    private Vec2i getTilePos() {
        Vec2f mousePos = (getMousePosition() - (_tilemap.position - _tilemap.size / 2f)) / _zoom;
        Vec2i tilePos = (cast(Vec2i) mousePos) / cast(Vec2i) _tileset.tileSize;
        return tilePos;
    }

    private Vec2i getSubTilePos() {
        Vec2f mousePos = (getMousePosition() - (_tilemap.position - _tilemap.size / 2f)) / _zoom;
        Vec2i tilePos = (2 * cast(Vec2i) mousePos) / cast(Vec2i) _tileset.tileSize;
        return tilePos;
    }

    private void _onCopyMaterialTool() {
        Vec2i tilePos = getSubTilePos();
        _material = _matTilemap.getTile(tilePos.x, tilePos.y);
    }

    private void _onPasteMaterialTool() {
        Vec2i tilePos = getSubTilePos();
        _matTilemap.setTile(tilePos.x, tilePos.y, _material);
        setDirty();
    }

    private void _onCopyCollisionTool() {
        Vec2i tilePos = getTilePos();
        _colliderTileId = _collTilemap.getTile(tilePos.x, tilePos.y);
    }

    private void _onPasteCollisionTool() {
        Vec2i tilePos = getTilePos();
        _collTilemap.setTile(tilePos.x, tilePos.y, _colliderTileId);
        setDirty();
    }

    private void _onEraseCollisionTool() {
        Vec2i tilePos = getTilePos();
        _collTilemap.setTile(tilePos.x, tilePos.y, -1);
        setDirty();
    }

    private void _onCopyBrushTool() {
        Tilemap tilemap = _parameterWindow.getBrushTilemap();
        if (!tilemap)
            return;
        Vec2i tilePos = getTilePos();
        _brushTileId = tilemap.getTile(tilePos.x, tilePos.y);
    }

    private void _onPasteBrushTool() {
        Tilemap tilemap = _parameterWindow.getBrushTilemap();
        if (!tilemap)
            return;
        Vec2i tilePos = getTilePos();
        tilemap.setTile(tilePos.x, tilePos.y, _brushTileId);
        setDirty();
    }

    private void _onEraseBrushTool() {
        Tilemap tilemap = _parameterWindow.getBrushTilemap();
        if (!tilemap)
            return;
        Vec2i tilePos = getTilePos();
        tilemap.setTile(tilePos.x, tilePos.y, -1);
        setDirty();
    }
}
