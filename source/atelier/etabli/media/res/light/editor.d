module atelier.etabli.media.res.light.editor;

import std.algorithm.sorting : sort;
import std.conv : to;
import std.file;
import std.math : abs;
import std.path;

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

        Vec2u _imageSize;
        Vec2f _position = Vec2f.zero;
        float _zoom = 1f;
        Vec2f _positionMouse = Vec2f.zero;
        Vec2f _deltaMouse = Vec2f.zero;
        Vec2i _clipAnchor, _clipAnchor2;
        bool _isResizingVertical;
        Vec2f _anchorPosition = Vec2f.zero;

        ShadedTexture _texture;
        Sprite _sprite;
        int _tool;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _name = ffd.get!string(0);

        _data.load(ffd);

        setTexture();

        _parameterWindow = new ParameterWindow(_data);

        _toolbox = new Toolbox();
        _toolbox.setTexture(getTexture(), _data.clip);
        Atelier.ui.addUI(_toolbox);

        _parameterWindow.addEventListener("property_tex", {
            _data = _parameterWindow.getData();
            setTexture();
            _toolbox.setTexture(getTexture(), _data.clip);
            setDirty();
        });

        _parameterWindow.addEventListener("property_data", {
            _data = _parameterWindow.getData();
            _toolbox.setClip(_data.clip);
            setDirty();
        });

        addEventListener("clip", {
            _parameterWindow.setClip(_data.clip);
            _toolbox.setClip(_data.clip);
            setDirty();
        });

        addEventListener("anchor", {
            _parameterWindow.setAnchor(_data.anchor);
            setDirty();
        });
        _toolbox.addEventListener("tool", { _tool = _toolbox.getTool(); });
        addEventListener("register", { Atelier.ui.addUI(_toolbox); });
        addEventListener("unregister", { _toolbox.removeUI(); });
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("light").add(_name);
        _data.save(node);
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    void setTexture() {
        bool mustLoad = _texture is null;
        _zoom = 1f;

        if (_sprite) {
            _sprite.remove();
        }

        if (Atelier.etabli.hasResource("shadedtexture", _data.shadedtexture)) {
            auto info = Atelier.etabli.getResource("shadedtexture", _data.shadedtexture);
            string filePath = info.farfadet.getNode("file").get!string(0);
            _texture = ShadedTexture.fromFile(info.getPath(filePath));

            if (info.farfadet.hasNode("sourceColorB")) {
                _texture.sourceColorB = info.farfadet.getNode("sourceColorB").get!Color(0);
            }

            if (info.farfadet.hasNode("targetColorA")) {
                _texture.targetColorA = info.farfadet.getNode("targetColorA").get!Color(0);
            }

            if (info.farfadet.hasNode("targetColorB")) {
                _texture.targetColorB = info.farfadet.getNode("targetColorB").get!Color(0);
            }

            if (info.farfadet.hasNode("sourceAlphaA")) {
                _texture.sourceAlphaA = info.farfadet.getNode("sourceAlphaA").get!float(0);
            }

            if (info.farfadet.hasNode("sourceAlphaB")) {
                _texture.sourceAlphaB = info.farfadet.getNode("sourceAlphaB").get!float(0);
            }

            if (info.farfadet.hasNode("targetAlphaA")) {
                _texture.targetAlphaA = info.farfadet.getNode("targetAlphaA").get!float(0);
            }

            if (info.farfadet.hasNode("targetAlphaB")) {
                _texture.targetAlphaB = info.farfadet.getNode("targetAlphaB").get!float(0);
            }

            if (info.farfadet.hasNode("spline")) {
                try {
                    _texture.spline = to!Spline(info.farfadet.getNode("spline").get!string(0));
                }
                catch (Exception e) {
                    _texture.spline = Spline.linear;
                }
            }

            _texture.generate();
        }
        else {
            _texture = null;
            return;
        }
        _imageSize = Vec2u(_texture.data.width, _texture.data.height);
        _sprite = new Sprite(_texture.data);
        addImage(_sprite);

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
        _sprite.position = getCenter() + _position;
    }

    ShadedTexture getTexture() {
        return _texture;
    }

    private void _onMouseLeave() {
        _positionMouse = Vec2f.zero;
        _deltaMouse = Vec2f.zero;
        removeEventListener("mousemove", &_onDrag);
        removeEventListener("mousemove", &_onMakeSelection);
        removeEventListener("mousemove", &_onMoveSelection);
        removeEventListener("mousemove", &_onMoveCorner);
        removeEventListener("mousemove", &_onMoveSide);
    }

    private void _onMouseDown() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case right:
            addEventListener("mousemove", &_onDrag);
            break;
        case left:
            switch (_tool) {
            case 0:
                _positionMouse = (getMousePosition() - (_sprite.position - _sprite.size / 2f)) / _zoom;
                addEventListener("mousemove", &_onMakeSelection);
                break;
            case 1:
                Vec4f clip = _zoom * cast(Vec4f) _data.clip;
                Vec2f origin = _sprite.position - _sprite.size / 2f + clip.xy;
                if (getMousePosition().isBetween(origin, origin + clip.zw)) {
                    addEventListener("mousemove", &_onMoveSelection);
                }
                break;
            case 2:
                Vec2f positionMouse = (getMousePosition() - (_sprite.position - _sprite.size / 2f)) / _zoom;
                bool isResizingRight = positionMouse.x >= (_data.clip.x + _data.clip.z / 2f);
                bool isResizingBottom = positionMouse.y >= (_data.clip.y + _data.clip.w / 2f);

                _clipAnchor.x = _data.clip.x + (isResizingRight ? 0 : _data.clip.z);
                _clipAnchor.y = _data.clip.y + (isResizingBottom ? 0 : _data.clip.w);

                addEventListener("mousemove", &_onMoveCorner);
                break;
            case 3:
                Vec2f positionMouse = (getMousePosition() - (_sprite.position - _sprite.size / 2f)) / _zoom;
                bool isResizingRight = positionMouse.x >= (_data.clip.x + _data.clip.z / 2f);
                bool isResizingBottom = positionMouse.y >= (_data.clip.y + _data.clip.w / 2f);

                Vec2f delta = Vec2f.zero;
                delta.x = positionMouse.x - cast(float)(_data.clip.x + (isResizingRight ? _data.clip.z
                        : 0));
                delta.y = positionMouse.y - cast(float)(_data.clip.y + (isResizingBottom ? _data.clip.w
                        : 0));

                _isResizingVertical = abs(delta.y) < abs(delta.x);

                if (_isResizingVertical) {
                    if (isResizingBottom) {
                        _clipAnchor = Vec2i(_data.clip.x, _data.clip.y);
                        _clipAnchor2 = Vec2i(_data.clip.x + _data.clip.z, _data.clip.y);
                    }
                    else {
                        _clipAnchor = Vec2i(_data.clip.x, _data.clip.y + _data.clip.w);
                        _clipAnchor2 = Vec2i(_data.clip.x + _data.clip.z, _data.clip.y + _data
                                .clip.w);
                    }
                }
                else {
                    if (isResizingRight) {
                        _clipAnchor = Vec2i(_data.clip.x, _data.clip.y);
                        _clipAnchor2 = Vec2i(_data.clip.x, _data.clip.y + _data.clip.w);
                    }
                    else {
                        _clipAnchor = Vec2i(_data.clip.x + _data.clip.z, _data.clip.y);
                        _clipAnchor2 = Vec2i(_data.clip.x + _data.clip.z, _data.clip.y + _data
                                .clip.w);
                    }
                }
                addEventListener("mousemove", &_onMoveSide);
                break;
            case 4:
                _onPlaceAnchor();
                addEventListener("mousemove", &_onPlaceAnchor);
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
            switch (_tool) {
            case 0:
                removeEventListener("mousemove", &_onMakeSelection);
                _positionMouse = Vec2f.zero;
                break;
            case 1:
                removeEventListener("mousemove", &_onMoveSelection);
                _deltaMouse = Vec2f.zero;
                break;
            case 2:
                removeEventListener("mousemove", &_onMoveCorner);
                break;
            case 3:
                removeEventListener("mousemove", &_onMoveSide);
                break;
            case 4:
                removeEventListener("mousemove", &_onPlaceAnchor);
                break;
            default:
                break;
            }
            break;
        default:
            break;
        }
    }

    private void _onMakeSelection() {
        Vec2f endPositionMouse = (getMousePosition() - (_sprite.position - _sprite.size / 2f)) / _zoom;

        Vec2f startClip = _positionMouse.min(endPositionMouse).floor();
        Vec2f endClip = _positionMouse.max(endPositionMouse).ceil();

        startClip = startClip.clamp(Vec2f.zero, cast(Vec2f) _imageSize);
        endClip = endClip.clamp(Vec2f.zero, cast(Vec2f) _imageSize);

        Vec4u clip = Vec4u(cast(uint) startClip.x, cast(uint) startClip.y,
            cast(uint)(endClip.x - startClip.x), cast(uint)(endClip.y - startClip.y));

        if (clip != _data.clip) {
            _data.clip = clip;
            dispatchEvent("clip", false);
        }
    }

    private void _onMoveSelection() {
        InputEvent.MouseMotion ev = getManager().input.asMouseMotion();
        _deltaMouse += ev.deltaPosition / _zoom;

        Vec2i move = cast(Vec2i) _deltaMouse;

        if (move.x < 0 && _data.clip.x < -move.x) {
            move.x = -_data.clip.x;
        }
        else if (move.x > 0 && _data.clip.x + _data.clip.z + move.x > _imageSize.x) {
            move.x = _imageSize.x - (_data.clip.x + _data.clip.z);
        }

        if (move.y < 0 && _data.clip.y < -move.y) {
            move.y = -_data.clip.y;
        }
        else if (move.y > 0 && _data.clip.y + _data.clip.w + move.y > _imageSize.y) {
            move.y = _imageSize.y - (_data.clip.y + _data.clip.w);
        }

        _deltaMouse -= cast(Vec2f) move;
        _data.clip.xy = cast(Vec2u)((cast(Vec2i) _data.clip.xy) + move);

        if (move != Vec2i.zero) {
            dispatchEvent("clip", false);
        }
    }

    private void _onMoveCorner() {
        Vec2f mousePosition = (getMousePosition() - (_sprite.position - _sprite.size / 2f)) / _zoom;
        mousePosition = mousePosition.clamp(Vec2f.zero, cast(Vec2f) _imageSize);
        Vec2i corner = cast(Vec2i) mousePosition;

        Vec4i rect;
        rect.xy = corner.min(_clipAnchor);
        rect.zw = corner.max(_clipAnchor);

        Vec4u clip;
        clip.xy = cast(Vec2u) rect.xy;
        clip.zw = cast(Vec2u)(rect.zw - rect.xy);

        if (clip != _data.clip) {
            _data.clip = clip;
            dispatchEvent("clip", false);
        }
    }

    private void _onMoveSide() {
        Vec2f mousePosition = (getMousePosition() - (_sprite.position - _sprite.size / 2f)) / _zoom;
        mousePosition = mousePosition.clamp(Vec2f.zero, cast(Vec2f) _imageSize);
        Vec2i point = cast(Vec2i) mousePosition;

        Vec4u clip;
        if (_isResizingVertical) {
            clip.x = min(_clipAnchor.x, _clipAnchor2.x);
            clip.z = max(_clipAnchor.x, _clipAnchor2.x) - clip.x;
            clip.y = min(point.y, _clipAnchor.y);
            clip.w = max(point.y, _clipAnchor.y) - clip.y;
        }
        else {
            clip.x = min(point.x, _clipAnchor.x);
            clip.z = max(point.x, _clipAnchor.x) - clip.x;
            clip.y = min(_clipAnchor.y, _clipAnchor2.y);
            clip.w = max(_clipAnchor.y, _clipAnchor2.y) - clip.y;
        }

        if (clip != _data.clip) {
            _data.clip = clip;
            dispatchEvent("clip", false);
        }
    }

    private void _onPlaceAnchor() {
        _anchorPosition = (getMousePosition() - (_sprite.position - _sprite.size / 2f)) / _zoom;
        _anchorPosition = _anchorPosition.clamp(
            cast(Vec2f)(_data.clip.xy),
            cast(Vec2f)(_data.clip.xy + _data.clip.zw));
        _data.anchor = ((_anchorPosition - cast(Vec2f) _data.clip.xy) / cast(Vec2f) _data.clip.zw)
            .clamp(Vec2f.zero, Vec2f.one);
        dispatchEvent("anchor", false);
    }

    private void _onDrag() {
        UIManager manager = getManager();
        InputEvent.MouseMotion ev = manager.input.asMouseMotion();
        _position += ev.deltaPosition;
    }

    private void _onDraw() {
        Vec2f spriteOrigin = _sprite.position - _sprite.size / 2f;

        Atelier.renderer.drawRect(spriteOrigin,
            _sprite.size, Atelier.theme.onNeutral, 1f, false);

        Vec4f clip = _zoom * cast(Vec4f) _data.clip;
        Atelier.renderer.drawRect(spriteOrigin + clip.xy,
            clip.zw, Atelier.theme.accent, 1f, false);

        Vec2f anchorPos = clip.xy + _zoom * _data.anchor * (cast(Vec2f) _data.clip.zw);
        Atelier.renderer.drawLine(spriteOrigin + Vec2f(anchorPos.x, 0f),
            spriteOrigin + Vec2f(anchorPos.x, _sprite.size.y), Color.yellow, 1f);

        Atelier.renderer.drawLine(spriteOrigin + Vec2f(0f, anchorPos.y),
            spriteOrigin + Vec2f(_sprite.size.x, anchorPos.y), Color.yellow, 1f);
    }

    private void _onWheel() {
        UIManager manager = getManager();
        InputEvent.MouseWheel ev = manager.input.asMouseWheel();
        float zoomDelta = 1f + (ev.wheel.sum() * 0.25f);
        _zoom *= zoomDelta;

        Vec2f mouseOffset = getMousePosition() - getCenter();
        Vec2f delta = (mouseOffset - _position) / _sprite.size;
        _sprite.size = (cast(Vec2f) _sprite.clip.zw) * _zoom;
        Vec2f delta2 = (mouseOffset - _position) / _sprite.size;

        _position += (delta2 - delta) * _sprite.size;
    }

    override void saveView() {
        view.zoom = _zoom;
        view.size = _sprite.size;
        view.position = _position;
        _toolbox.saveView(view);
    }

    override void loadView() {
        _zoom = view.zoom;
        _sprite.size = view.size;
        _position = view.position;
        _toolbox.loadView(view);
    }
}

package {
    struct EditorView {
        float zoom = 1f;
        Vec2f position = Vec2f.zero;
        Vec2f size = Vec2f.zero;
        int tool = 0;
    }

    EditorView view;
}
