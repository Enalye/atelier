module atelier.etabli.common.tile.singletilepicker;

import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.render;

import atelier.etabli.media.res.base;
import atelier.etabli.media.res.terrain.selection;
import atelier.etabli.ui;

final class SingleTilePicker : UIElement {
    private {
        Tileset _tileset;
        Tilemap _tilemap;
        Vec2i _tileSelection, _hoverSelection;
        int _tileId;
    }

    this() {
        setSize(Vec2f(200f, 128f));

        {
            Rectangle rect = Rectangle.outline(getSize(), 1f);
            rect.color = Atelier.theme.neutral;
            rect.anchor = Vec2f.zero;
            rect.position = Vec2f.zero;
            addImage(rect);
        }
    }

    void setTileset(string rid) {
        Tileset tileset = Atelier.etabli.getTileset(rid);
        bool mustLoad = _tilemap is null;
        if (_tilemap)
            _tilemap.remove();
        _tilemap = new Tilemap(tileset, tileset.columns, tileset.lines);
        _tilemap.anchor = Vec2f.zero;
        addImage(_tilemap);

        int id;
        __tilesetLoop: for (int y; y < tileset.lines; ++y) {
            for (int x; x < tileset.columns; ++x) {
                _tilemap.setTile(x, y, id);
                id++;
                if (id >= tileset.maxCount)
                    break __tilesetLoop;
            }
        }

        if (mustLoad) {
            addEventListener("draw", &_onDraw);
            addEventListener("mousedown", &_onMouseDown);
            addEventListener("mouseup", &_onMouseUp);
            addEventListener("mouseleave", &_onMouseLeave);
            addEventListener("clickoutside", &_onMouseLeave);
        }
    }

    private void _onMouseLeave() {
        removeEventListener("mousemove", &_onTileSelection);
    }

    private void _onMouseDown() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case left:
            _tileSelection = _tileSelection.clamp(Vec2i.zero,
                Vec2i(_tilemap.columns, _tilemap.lines) - 1);
            _tileSelection = cast(Vec2i)(getMousePosition() / _tilemap.tileSize);

            addEventListener("mousemove", &_onTileSelection);
            break;
        default:
            break;
        }
    }

    private void _onMouseUp() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case left:
            removeEventListener("mousemove", &_onTileSelection);

            uint x = max(0, _tileSelection.x);
            uint y = max(0, _tileSelection.y);
            _tileId = _tilemap.getTile(x, y);

            dispatchEvent("value", false);
            break;
        default:
            break;
        }
    }

    private void _onDraw() {
        Vec2f pos = (cast(Vec2f) _tileSelection) * _tilemap.tileSize;
        Atelier.renderer.drawRect(pos, _tilemap.tileSize, Atelier.theme.accent, 1f, false);
    }

    private void _onTileSelection() {
        _tileSelection = cast(Vec2i)(getMousePosition() / _tilemap.tileSize);
        _tileSelection = _tileSelection.clamp(Vec2i.zero,
            Vec2i(_tilemap.columns, _tilemap.lines) - 1);
    }

    int getTileId() const {
        return _tileId;
    }
}
