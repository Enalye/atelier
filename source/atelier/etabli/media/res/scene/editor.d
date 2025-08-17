module atelier.etabli.media.res.scene.editor;

import std.algorithm;
import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.editor;
import atelier.etabli.media.res.scene.common;
import atelier.etabli.media.res.scene.parameter;

final class SceneResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        SceneDefinition _definition;

        Vec2f _mapPosition = Vec2f.zero;
        float _zoom = 1f;
        Vec2f _mapSize = Vec2f.zero;
        Vec2f _nominalMapSize = Vec2f.zero;
        ParameterWindow _parameterWindow;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _definition = new SceneDefinition;
        _definition.load(_ffd);

        _nominalMapSize = Vec2f(_definition.getWidth(), _definition.getHeight()) * 16f;
        _mapSize = _nominalMapSize;

        _parameterWindow = new ParameterWindow(_definition);

        addEventListener("update", &_onUpdate);
        addEventListener("draw", &_onDraw);
        addEventListener("wheel", &_onWheel);
        addEventListener("mousedown", &_onMouseDown);
        addEventListener("mousemove", &_onMouseMove);
        addEventListener("mouseup", &_onMouseUp);
        addEventListener("mouseleave", {
            removeEventListener("mousemove", &_onDrag);
            _parameterWindow.endTool(getMousePosition());
        });

        _parameterWindow.addEventListener("property_settings", {
            _zoom = 1f;
            _nominalMapSize = Vec2f(_definition.getWidth(), _definition.getHeight()) * 16f;
            _mapSize = _nominalMapSize;
            _mapPosition = Vec2f.zero;
            _parameterWindow.updateView(getCenter(), _mapPosition, _zoom);
        });
        _parameterWindow.addEventListener("property_layer", {});
        _parameterWindow.addEventListener("property_dirty", &setDirty);

        addEventListener("register", { _parameterWindow.openToolbox(); });
        addEventListener("unregister", { _parameterWindow.closeToolbox(); });
    }

    override Farfadet save(Farfadet ffd) {
        return _definition.save(ffd);
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    private void _onUpdate() {
        foreach (layer; _definition.getTerrainLayers()) {
            layer.tilemap.position = getCenter() + _mapPosition + Vec2f(0f,
                -_definition.getLevel(layer.level) * _zoom);
            layer.tilemap.size = _mapSize;
        }

        foreach (size_t level, Tilemap layer; _definition.topologicMap.lowerTilemaps) {
            layer.anchor = Vec2f.zero;
            layer.position = getCenter() + _mapPosition + Vec2f(0f,
                -_definition.getLevel(cast(uint) level) * _zoom) - _mapSize / 2f;
            layer.size = Vec2f(_definition.getWidth(), _definition.getHeight() + level) * 16f *
                _zoom;
        }

        foreach (size_t level, Tilemap layer; _definition.topologicMap.upperTilemaps) {
            layer.anchor = Vec2f.zero;
            layer.position = getCenter() + _mapPosition + Vec2f(0f,
                -_definition.getLevel(cast(uint) level) * _zoom) - _mapSize / 2f;
            layer.size = Vec2f(_definition.getWidth(), _definition.getHeight() + level) * 16f *
                _zoom;
        }

        foreach (layer; _definition.getParallaxLayers()) {
            layer.tilemap.position = getCenter() + _mapPosition / layer.distance;
            layer.tilemap.size = Vec2f(layer.getWidth(), layer.getHeight()) * 16f * _zoom;
        }

        foreach (layer; _definition.getCollisionLayers()) {
            layer.tilemap.position = getCenter() + _mapPosition + Vec2f(0f,
                -_definition.getLevel(layer.level) * _zoom);
            layer.tilemap.size = _mapSize;
        }

        foreach (i, entity; _definition.getEntities()) {
            if (!entity.isAlive) {
                _definition.getEntities().mark(i);
                continue;
            }
            entity.update(getCenter() + _mapPosition - _mapSize / 2f, _zoom);
        }
        _definition.getEntities().sweep();
        sort!((a, b) => (a.yOrder < b.yOrder), SwapStrategy.stable)(
            _definition.getEntities().array);

        foreach (i, light; _definition.getLights()) {
            if (!light.isAlive) {
                _definition.getLights().mark(i);
                continue;
            }
            light.update(getCenter() + _mapPosition - _mapSize / 2f, _zoom);
        }
        _definition.getLights().sweep();

        _parameterWindow.updateView(getCenter(), _mapPosition, _zoom);
    }

    private void _onMouseDown() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case right:
            addEventListener("mousemove", &_onDrag);
            break;
        case left:
            _parameterWindow.startTool(getMousePosition());
            break;
        default:
            break;
        }
    }

    private void _onMouseMove() {
        _parameterWindow.updateTool(getMousePosition());
    }

    private void _onMouseUp() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case right:
            removeEventListener("mousemove", &_onDrag);
            break;
        case left:
            _parameterWindow.endTool(getMousePosition());
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

        _parameterWindow.updateView(getCenter(), _mapPosition, _zoom);
    }

    private void _onDraw() {
        foreach_reverse (layer; _definition.getParallaxLayers()) {
            if (!layer.isVisible)
                continue;

            layer.tilemap.draw();
        }

        int levelToShow;
        bool limitLevel;

        if (Atelier.input.isPressed(InputEvent.KeyButton.Button.f1)) {
            limitLevel = true;
            levelToShow = 0;
        }
        else if (Atelier.input.isPressed(InputEvent.KeyButton.Button.f2)) {
            limitLevel = true;
            levelToShow = 1;
        }
        else if (Atelier.input.isPressed(InputEvent.KeyButton.Button.f3)) {
            limitLevel = true;
            levelToShow = 2;
        }
        else if (Atelier.input.isPressed(InputEvent.KeyButton.Button.f4)) {
            limitLevel = true;
            levelToShow = 3;
        }

        foreach (entity; _definition.getEntities()) {
            if (entity.yOrder >= -16f)
                continue;

            entity.draw();
        }
        for (int y = 0; y < _definition.getHeight() + _definition.getLevels(); ++y) {
            int levels = _definition.levels;
            Tilemap[] lowerTopographicLayers = _definition.topologicMap.lowerTilemaps;
            Tilemap[] upperTopographicLayers = _definition.topologicMap.upperTilemaps;
            for (size_t level; level < levels; ++level) {
                if (!limitLevel || (limitLevel && levelToShow == level)) {
                    if (level < lowerTopographicLayers.length) {
                        lowerTopographicLayers[level].drawLine(y);
                    }

                    if (level < upperTopographicLayers.length) {
                        upperTopographicLayers[level].drawLine(y);
                    }
                }

                if (y > 0) {
                    foreach_reverse (layer; _definition.getTerrainLayers()) {
                        if (layer.level != level || !layer.isVisible)
                            continue;

                        layer.tilemap.drawLine(y - 1);
                    }
                }

                foreach (entity; _definition.getEntities()) {
                    if (entity.level != level || entity.yOrder < ((y - 1) * 16) ||
                        entity.yOrder >= ((y) * 16f))
                        continue;

                    entity.draw();
                }
            }

            foreach_reverse (layer; _definition.getTerrainLayers()) {
                if (layer.level <= levels || !layer.isVisible)
                    continue;

                layer.tilemap.drawLine(y);
            }
        }

        foreach (entity; _definition.getEntities()) {
            if (entity.yOrder < (_definition.getHeight() - 1) * 16f)
                continue;

            entity.draw();
        }

        foreach_reverse (layer; _definition.getCollisionLayers()) {
            if (!layer.isVisible)
                continue;

            layer.tilemap.draw();
        }

        Vec4f layerClip = _parameterWindow.getCurrentLayerClip();
        if (layerClip.z > 0 && layerClip.w > 0) {
            Atelier.renderer.drawRect(layerClip.xy, layerClip.zw, Atelier.theme.danger, 1f, false);
        }

        foreach (light; _definition.getLights()) {
            light.draw();
        }

        _parameterWindow.renderTool();
    }

    override void saveView() {
        view.zoom = _zoom;
        view.mapPosition = _mapPosition;
        view.nominalMapSize = _nominalMapSize;
        _parameterWindow.saveView();
    }

    override void loadView() {
        _zoom = view.zoom;
        _mapPosition = view.mapPosition;
        _nominalMapSize = view.nominalMapSize;
        _mapSize = _nominalMapSize * _zoom;
        _parameterWindow.loadView();
    }
}

private {
    struct EditorView {
        Vec2f mapPosition = Vec2f.zero;
        float zoom = 1f;
        Vec2f nominalMapSize = Vec2f.zero;
    }

    EditorView view;
}
