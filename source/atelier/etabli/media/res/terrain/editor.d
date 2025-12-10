module atelier.etabli.media.res.terrain.editor;

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
        int _cliffId, _brushTileId;
        int _brushId = -1;
        bool _isApplyingTool;

        Vec2i _startTile, _endTile;
        TilesSelection!int _selection;
        Tilemap _previewSelectionTM;

        string _name;
        uint _columns, _lines;
        string _tilesetRID;
        Tileset _tileset;
        Tilemap _tilemap, _brushTilemap, _cliffTilemap;
        Rectangle _rectangle;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _tilemap = new Tilemap(0, 0);
        _cliffTilemap = new Tilemap(Atelier.res.get!Tileset("editor:autotile"), 0, 0);
        _brushTilemap = new Tilemap(0, 0);

        _cliffTilemap.defaultTile = -1;
        _brushTilemap.defaultTile = -1;

        _cliffTilemap.alpha = .5f;
        _brushTilemap.alpha = .5f;

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

        if (_ffd.hasNode("cliffmap")) {
            _cliffTilemap.setTiles(0, 0, _ffd.getNode("cliffmap").get!(int[][])(0));
        }

        if (_ffd.hasNode("brushmap")) {
            _brushTilemap.setTiles(0, 0, _ffd.getNode("brushmap").get!(int[][])(0));
        }

        _parameterWindow = new ParameterWindow(_tilesetRID, _tileset ?
                _tileset.columns : 0, _tileset ? _tileset.lines : 0);
        _parameterWindow.load(_ffd);

        _toolbox = new Toolbox();

        _toolbox.addEventListener("tool", {
            //_cliffId = _toolbox.getCliffId();
            _brushId = _toolbox.getBrushId();

            _selection = _toolbox.getSelection();
            if (_selection.isValid && _selection.width >= 1 && _selection.height >= 1) {
                _cliffId = _selection.tiles[0][0];
            }

            updateSelectionPreview();
        });

        _toolbox.addEventListener("tool_replaceBrush", {
            Vec2i brushReplaceIds = _toolbox.getBrushReplaceIds();
            int len = cast(int)(_brushTilemap.lines * _brushTilemap.columns);
            for (int i; i < len; ++i) {
                if (_brushTilemap.getRawTile(i) == brushReplaceIds.x) {
                    _brushTilemap.setRawTile(i, brushReplaceIds.y);
                }
            }
        });

        addEventListener("update", &_onUpdate);
        addEventListener("draw", &_onDraw);
        addEventListener("wheel", &_onWheel);
        addEventListener("mousedown", &_onMouseDown);
        addEventListener("mouseup", &_onMouseUp);
        addEventListener("mouseleave", {
            _isApplyingTool = false;
            removeEventListener("mousemove", &_onDrag);
            removeEventListener("mousemove", &_onCopyBrushTool);
            removeEventListener("mousemove", &_onPasteBrushTool);
            removeEventListener("mousemove", &_onEraseBrushTool);
            removeEventListener("mousemove", &_onCopyCliffTool);
            removeEventListener("mousemove", &_onPasteCliffTool);
            removeEventListener("mousemove", &_onEraseCliffTool);
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
        node.addNode("cliffmap").add(_cliffTilemap.getTiles());
        node.addNode("brushmap").add(_brushTilemap.getTiles());
        _parameterWindow.save(node);
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    private void updateSelectionPreview() {
        _previewSelectionTM = new Tilemap(_toolbox.getTileset(),
            _selection.width, _selection.height);
        _previewSelectionTM.setTiles(0, 0, _selection.tiles);
        _previewSelectionTM.anchor = Vec2f.zero;
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
        _cliffTilemap.setDimensions(_columns, _lines);
        _brushTilemap.setDimensions(_columns << 1, _lines << 1);

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

        _cliffTilemap.position = getCenter() + _mapPosition;
        _cliffTilemap.size = _mapSize;

        _brushTilemap.position = getCenter() + _mapPosition;
        _brushTilemap.size = _mapSize;

        _endTile = getTilePos();
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
                if (hasControlModifier() && hasAltModifier()) {
                    _brushId = -1;
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
            case 1:
                _positionMouse = (getMousePosition() - (_tilemap.position - _tilemap.size / 2f)) / _zoom;
                _startTile = getTilePos();
                _endTile = _startTile;

                if (hasControlModifier() && hasAltModifier()) {
                    _cliffId = -1;
                }
                else if (hasControlModifier()) {
                    addEventListener("mousemove", &_onCopyCliffTool);
                    _onCopyCliffTool();
                }
                else if (hasAltModifier()) {
                    addEventListener("mousemove", &_onEraseCliffTool);
                    _onEraseCliffTool();
                }
                else {
                    addEventListener("mousemove", &_onPasteCliffTool);
                    _onPasteCliffTool();
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
                removeEventListener("mousemove", &_onCopyBrushTool);
                removeEventListener("mousemove", &_onPasteBrushTool);
                removeEventListener("mousemove", &_onEraseBrushTool);
                _positionMouse = Vec2f.zero;
                break;
            case 1:
                _endTile = getTilePos();

                removeEventListener("mousemove", &_onCopyCliffTool);
                removeEventListener("mousemove", &_onPasteCliffTool);
                removeEventListener("mousemove", &_onEraseCliffTool);
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

        immutable Vec2i[4] cornerOffsets = [
            Vec2i(0, 0), Vec2i(1, 0), Vec2i(1, 1), Vec2i(0, 1)
        ];

        Vec2f origin = _tilemap.position - _tilemap.size / 2f;
        uint frame;

        switch (_toolbox.getTool()) {
        case 0:
            _rectangle.size = Vec2f.one * 8f * _zoom;

            Vec2i coords;
            for (uint y; y < _tileset.lines; ++y) {
                for (uint x; x < _tileset.columns; ++x) {
                    int cliffId = _cliffTilemap.getTile(x, y);
                    int cliffMask = 0b1111;
                    if (cliffId >= 0) {
                        cliffMask = TerrainMap.cliffMasks[cliffId];
                    }

                    for (uint i; i < 4; ++i) {
                        coords.x = (x << 1) + cornerOffsets[i].x;
                        coords.y = (y << 1) + cornerOffsets[i].y;
                        Vec4f clip = Vec4f(coords.x, coords.y, 1f, 1f) * 8f * _zoom;

                        int brushId = _brushTilemap.getTile(coords.x, coords.y);

                        if ((cliffMask & (1 << i)) > 0) {
                            if (brushId == _brushId) {
                                _rectangle.color = Atelier.theme.accent;
                                _rectangle.draw(origin + clip.xy);
                                drawText(origin + Vec2f(2f, 8f - 2f) + clip.xy,
                                    to!dstring(brushId), Atelier.theme.font, Atelier.theme.onAccent);
                            }
                            else {
                                drawText(origin + Vec2f(2f, 8f - 2f) + clip.xy,
                                    to!dstring(brushId), Atelier.theme.font, Atelier
                                        .theme.onNeutral);
                            }
                        }
                        else {
                            _rectangle.color = Atelier.theme.danger;
                            _rectangle.draw(origin + clip.xy);
                        }

                        Atelier.renderer.drawRect(origin + clip.xy, clip.zw, Atelier.theme.neutral, 1f, false);
                    }

                    frame++;
                }
            }
            break;
        case 1:
            _cliffTilemap.draw();

            _rectangle.size = Vec2f.one * 16f * _zoom;

            for (uint y; y < _tileset.lines; ++y) {
                for (uint x; x < _tileset.columns; ++x) {
                    Vec4f clip = Vec4f(x, y, 1f, 1f) * 16f * _zoom;

                    Atelier.renderer.drawRect(origin + clip.xy, clip.zw,
                        Atelier.theme.neutral, 1f, false);

                    frame++;
                }
            }

            if (hasAltModifier()) {
                Atelier.renderer.drawRect(origin + (cast(Vec2f) _endTile) * 16f * _zoom,
                    Vec2f.one * 16f * _zoom, Atelier.theme.neutral, 1f, false);
            }
            else if (hasControlModifier()) {
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
            break;
        }
    }

    private Vec2i getTilePos() {
        if (_tileset.tileSize.x == 0 || _tileset.tileSize.y == 0)
            return Vec2i.zero;

        Vec2f mousePos = (getMousePosition() - (_tilemap.position - _tilemap.size / 2f)) / _zoom;
        Vec2i tilePos = (cast(Vec2i) mousePos) / cast(Vec2i) _tileset.tileSize;
        return tilePos;
    }

    private Vec2i getSubTilePos() {
        if (_tileset.tileSize.x == 0 || _tileset.tileSize.y == 0)
            return Vec2i.zero;

        Vec2f mousePos = (getMousePosition() - (_tilemap.position - _tilemap.size / 2f)) / _zoom;
        Vec2i tilePos = (2 * cast(Vec2i) mousePos) / cast(Vec2i) _tileset.tileSize;
        return tilePos;
    }

    private void _onCopyBrushTool() {
        Vec2i tilePos = getSubTilePos();
        if (!_isSubTileValid(tilePos))
            return;
        _brushId = _brushTilemap.getTile(tilePos.x, tilePos.y);
        _toolbox.setBrushId(_brushId);
    }

    private void _onPasteBrushTool() {
        Vec2i tilePos = getSubTilePos();
        if (!_isSubTileValid(tilePos))
            return;
        _brushTilemap.setTile(tilePos.x, tilePos.y, hasAltModifier() ? -1 : _brushId);
        setDirty();
    }

    private void _onEraseBrushTool() {
        Vec2i tilePos = getSubTilePos();
        if (!_isSubTileValid(tilePos))
            return;
        _brushTilemap.setTile(tilePos.x, tilePos.y, -1);
        setDirty();
    }

    private Vec4i getSelectionRect() {
        Vec2i startPos = _startTile.min(_endTile);
        Vec2i endPos = _startTile.max(_endTile);

        return Vec4i(startPos, endPos);
    }

    private void _onCopyCliffTool() {
        _endTile = getTilePos();

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
                _selection.tiles[iy][ix] = _cliffTilemap.getTile(startPos.x + ix,
                    startPos.y + iy);
            }
        }
        _selection.isValid = true;

        updateSelectionPreview();

    }

    private void _onPasteCliffTool() {
        _endTile = getTilePos();

        if (_selection.isValid) {
            _cliffTilemap.setTiles(_endTile.x, _endTile.y, _selection.tiles);
            setDirty();
        }
    }

    private void _onEraseCliffTool() {
        _endTile = getTilePos();
        Vec2i tilePos = getTilePos();
        _cliffTilemap.setTile(tilePos.x, tilePos.y, -1);
        setDirty();
    }

    private bool _isSubTileValid(Vec2i pos) {
        if (pos.x < 0 || pos.y < 0)
            return false;

        Vec2i cliffPos = pos >> 1;
        int cliffId = _cliffTilemap.getTile(cliffPos.x, cliffPos.y);
        if (cliffId < 0)
            return true;

        /*
            x: 0, y: 0 -> 0
            x: 1, y: 0 -> 1
            x: 1, y: 1 -> 2
            x: 0, y: 1 -> 3
        */

        int shift;
        if (pos.x & 0x1) {
            shift = 1 + (pos.y & 0x1);
        }
        else {
            shift = (pos.y & 0x1) * 3;
        }

        int cliffMask = TerrainMap.cliffMasks[cliffId];
        return ((cliffMask & (1 << shift)) > 0);
    }
}
