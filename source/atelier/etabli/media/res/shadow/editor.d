module atelier.etabli.media.res.shadow.editor;

import std.algorithm.sorting : sort;
import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.input;
import atelier.render;
import atelier.ui;
import atelier.world;
import atelier.etabli.ui;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.editor;
import atelier.etabli.media.res.shadow.parameter;
import atelier.etabli.media.res.shadow.toolbox;

final class ShadowResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        ParameterWindow _parameterWindow;
        Toolbox _toolbox;

        ShadowData _data;

        Vec2f _originPosition = Vec2f.zero;
        float _zoom = 1f;

        Sprite _sprite;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _name = ffd.get!string(0);

        _data.load(ffd);

        _parameterWindow = new ParameterWindow(_data);

        _toolbox = new Toolbox();

        _parameterWindow.addEventListener("property_sprite", {
            _data = _parameterWindow.getData();
            _cacheSprite();
            setDirty();
        });

        _parameterWindow.addEventListener("property_data", {
            _data = _parameterWindow.getData();
            setDirty();
        });

        addEventListener("draw", &_onDraw);
        addEventListener("wheel", &_onWheel);
        addEventListener("mousedown", &_onMouseDown);
        addEventListener("mouseup", &_onMouseUp);
        addEventListener("mouseleave", {
            removeEventListener("mousemove", &_onDrag);
        });
        addEventListener("register", { Atelier.ui.addUI(_toolbox); });
        addEventListener("unregister", { _toolbox.removeUI(); });

        _cacheSprite();
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("shadow").add(_name);
        _data.save(node);
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    private void _onMouseDown() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case right:
            addEventListener("mousemove", &_onDrag);
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
        default:
            break;
        }
    }

    private void _onDrag() {
        UIManager manager = getManager();
        InputEvent.MouseMotion ev = manager.input.asMouseMotion();
        _originPosition += ev.deltaPosition;
    }

    private void _onWheel() {
        UIManager manager = getManager();
        InputEvent.MouseWheel ev = manager.input.asMouseWheel();
        float zoomDelta = 1f + (ev.wheel.sum() * 0.25f);

        Vec2f mouseOffset = getMousePosition() - getCenter();
        Vec2f delta = (mouseOffset - _originPosition) / _zoom;
        _zoom *= zoomDelta;
        Vec2f delta2 = (mouseOffset - _originPosition) / _zoom;

        _originPosition += (delta2 - delta) * _zoom;
    }

    private void _cacheSprite() {
        if (_data.sprite.length) {
            _sprite = Atelier.etabli.getSprite(_data.sprite);
            _sprite.anchor = Vec2f.half;
        }
    }

    private void _drawBox(int altitude) {
        Vec3f hitboxSize = Vec3f.one * 16f * _zoom;
        Vec2f offset = Vec2f.one * 8f * _zoom;
        Vec2f basePosition = _originPosition + getCenter() + Vec2f(0, -altitude * _zoom);

        Atelier.renderer.drawRect(basePosition - offset,
            hitboxSize.xy, Atelier.theme.onNeutral, 0.2f, false);

        Atelier.renderer.drawRect(basePosition - (offset + Vec2f(0f,
                hitboxSize.z)), hitboxSize.xy, Color.yellow, 0.2f, true);

        Atelier.renderer.drawRect(basePosition + Vec2f(0f,
                hitboxSize.y) - (offset + Vec2f(0f, hitboxSize.z)),
            hitboxSize.xz, Color.orange, 0.2f, true);

        Atelier.renderer.drawRect(basePosition - (offset + Vec2f(0f,
                hitboxSize.z)), hitboxSize.xy, Atelier.theme.onNeutral, 1f, false);

        Atelier.renderer.drawRect(basePosition - (offset + Vec2f(0f,
                hitboxSize.z)), hitboxSize.xy + Vec2f(0f, hitboxSize.z),
            Atelier.theme.onNeutral, 1f, false);
    }

    private void _onDraw() {
        if (!_sprite)
            return;

        int altitude = lerp(0, _data.maxAltitude, _toolbox.getAltitude());
        _drawBox(altitude);

        float t = easeInOutSine(clamp(altitude, 0, _data.maxAltitude) /  //
                (cast(float) _data.maxAltitude));
        _sprite.alpha = lerp(_data.groundAlpha, _data.highAlpha, t);
        _sprite.size = (cast(Vec2f) _sprite.clip.zw) * lerp(_data.groundScale, _data.highScale, t) * _zoom;
        _sprite.angle = _data.isTurning ? _toolbox.getAngle() : 0f;
        _sprite.draw(_originPosition + getCenter());
    }
}
