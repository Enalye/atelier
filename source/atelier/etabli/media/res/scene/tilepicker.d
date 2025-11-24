module atelier.etabli.media.res.scene.tilepicker;

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
import atelier.etabli.media.res.scene.selection;
import atelier.etabli.ui;

package(atelier.etabli.media.res.scene) final class TilePicker : UIElement {
    private {
        Tileset _tileset;
        Tilemap _tilemap;
        Vec2i _startSelection, _endSelection, _tileSelection, _hoverSelection;
        Vec2f _position = Vec2f.zero;
        float _zoom = 1f;
        bool _isRect;
        Color _colorMod = Color.white;
        Rectangle _background;
    }

    TilesSelection selection;

    this(float height_ = 384f) {
        setSize(Vec2f(256f, height_));

        {
            _background = Rectangle.fill(getSize());
            _background.color = Atelier.theme.background;
            _background.anchor = Vec2f.zero;
            _background.position = Vec2f.zero;
            addImage(_background);
        }

        {
            SwitchButton bgModeBtn = new SwitchButton(false);
            bgModeBtn.setAlign(UIAlignX.right, UIAlignY.top);
            bgModeBtn.setPosition(Vec2f(4f, 4f));
            bgModeBtn.addEventListener("value", {
                _background.color = bgModeBtn.value ? Atelier.theme.neutral
                    : Atelier.theme.background;
            });
            addUI(bgModeBtn);
        }

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
        _tilemap.color = _colorMod;
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
        _tilemap.position = _position;
    }

    private void _onMouseLeave() {
        removeEventListener("mousemove", &_onDrag);
        removeEventListener("mousemove", &_onRectSelection);
        removeEventListener("mousemove", &_onTileSelection);
    }

    private void _onMouseDown() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case right:
            addEventListener("mousemove", &_onDrag);
            break;
        case left:
            if (_isRect) {
                _startSelection = cast(Vec2i)((getMousePosition() - _position) / _tilemap.tileSize);
                _startSelection = _startSelection.clamp(Vec2i.zero,
                    Vec2i(_tilemap.columns, _tilemap.lines) - 1);
                _endSelection = _startSelection;
            }
            else {
                _tileSelection = _tileSelection.clamp(Vec2i.zero,
                    Vec2i(_tilemap.columns, _tilemap.lines) - 1);
                _tileSelection = cast(Vec2i)((getMousePosition() - _position) / _tilemap.tileSize);
            }
            addEventListener("mousemove", _isRect ? &_onRectSelection : &_onTileSelection);
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
            removeEventListener("mousemove", _isRect ? &_onRectSelection : &_onTileSelection);
            if (_isRect) {
                Vec2i startTile = _startSelection.min(_endSelection);
                Vec2i endTile = _startSelection.max(_endSelection) + Vec2i.one - startTile;

                getTilesAt(startTile.x, startTile.y, endTile.x, endTile.y);
            }
            else {
                getTilesAt(_tileSelection.x, _tileSelection.y, 1, 1);
            }
            dispatchEvent("value", false);
            break;
        default:
            break;
        }
    }

    private void getTilesAt(int x, int y, uint width_, uint height_) {
        x = max(0, x);
        y = max(0, y);
        width_ = min(width_, _tilemap.columns - cast(int) x);
        height_ = min(height_, _tilemap.lines - cast(int) y);

        selection.width = width_;
        selection.height = height_;

        selection.tiles = _tilemap.getTiles(x, y, width_, height_);
        selection.isValid = true;
    }

    private void _onDrag() {
        UIManager manager = getManager();
        InputEvent.MouseMotion ev = manager.input.asMouseMotion();
        _position += ev.deltaPosition;
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

    private void _onDraw() {
        if (_isRect) {
            Vec2f startPos = cast(Vec2f) _startSelection.min(_endSelection);
            Vec2f endPos = cast(Vec2f) _startSelection.max(_endSelection);

            startPos = startPos * _tilemap.tileSize;
            endPos = (endPos + 1) * _tilemap.tileSize;
            Atelier.renderer.drawRect(_position + startPos, endPos - startPos,
                Atelier.theme.accent, 1f, false);
        }
        else {
            Vec2f pos = (cast(Vec2f) _tileSelection) * _tilemap.tileSize;
            Atelier.renderer.drawRect(_position + pos, _tilemap.tileSize,
                Atelier.theme.accent, 1f, false);
        }
    }

    void setRectMode(bool isRect) {
        _isRect = isRect;
    }

    void setColorMod(Color color_) {
        _colorMod = color_;
        if (_tilemap) {
            _tilemap.color = _colorMod;
        }
    }

    private void _onRectSelection() {
        _endSelection = cast(Vec2i)((getMousePosition() - _position) / _tilemap.tileSize);
        _endSelection = _endSelection.clamp(Vec2i.zero, Vec2i(_tilemap.columns, _tilemap.lines) - 1);
    }

    private void _onTileSelection() {
        _tileSelection = cast(Vec2i)((getMousePosition() - _position) / _tilemap.tileSize);
        _tileSelection = _tileSelection.clamp(Vec2i.zero,
            Vec2i(_tilemap.columns, _tilemap.lines) - 1);
    }
}
