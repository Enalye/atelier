module atelier.etabli.media.res.light.editor;

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
import atelier.etabli.media.res.light.parameter;
import atelier.etabli.media.res.light.toolbox;

final class LightResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        ParameterWindow _parameterWindow;
        Toolbox _toolbox;

        BaseLightData _data;

        Vec2f _originPosition = Vec2f.zero;
        float _zoom = 1f;

        Animation _anim;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _name = ffd.get!string(0);

        _data.load(ffd);

        _parameterWindow = new ParameterWindow(_data);

        _toolbox = new Toolbox();

        _parameterWindow.addEventListener("property_anim", {
            _data = _parameterWindow.getData();
            _cacheAnim();
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

        _cacheAnim();
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("light").add(_name);
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

    private void _cacheAnim() {
        if (_data.anim.length) {
            _anim = Atelier.etabli.getAnimation(_data.anim);
            _anim.anchor = Vec2f.half;
        }
    }

    private void _onDraw() {
        if (!_anim)
            return;

        _anim.draw(_originPosition + getCenter());
    }
}
