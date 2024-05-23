/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editors.res.sprite;

import std.file;
import std.path;
import std.math : abs;
import atelier;
import farfadet;
import studio.editors.res.base;
import studio.project;
import studio.ui;

final class SpriteResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        string _textureRID;
        Vec4u _clip;
        Vec2u _imageSize;
        Previewer _preview;
        ParameterWindow _parameterWindow;
        int _tool;
    }

    this(string path_, Farfadet ffd, Vec2f size) {
        super(path_, size);
        _ffd = ffd;

        _name = ffd.get!string(0);

        if (ffd.hasNode("texture")) {
            _textureRID = ffd.getNode("texture").get!string(0);
        }

        if (ffd.hasNode("clip")) {
            _clip = ffd.getNode("clip").get!Vec4u(0);
        }

        _preview = new Previewer(this);
        _preview.setAlign(UIAlignX.center, UIAlignY.top);
        _preview.setSize(Vec2f(size.x, max(0f, size.y - 200f)));
        _preview.setTextureRID(_textureRID);
        addUI(_preview);

        _parameterWindow = new ParameterWindow(_textureRID, _clip);
        _parameterWindow.setAlign(UIAlignX.center, UIAlignY.bottom);
        _parameterWindow.setSize(Vec2f(size.x, min(size.y, 200f)));
        addUI(_parameterWindow);

        addEventListener("size", &_onSize);

        _parameterWindow.addEventListener("property_textureRID", {
            _textureRID = _parameterWindow.getTextureRID();
            _preview.setTextureRID(_textureRID);
        });

        _parameterWindow.addEventListener("property_clip", {
            _clip = _parameterWindow.getClip();
        });

        _preview.addEventListener("clip", { _parameterWindow.setClip(_clip); });
        _parameterWindow.addEventListener("tool", {
            _tool = _parameterWindow.getTool();
        });
    }

    private void _onSize() {
        Vec2f size = getSize();
        _preview.setSize(Vec2f(size.x, max(0f, size.y - 200f)));
        _parameterWindow.setSize(Vec2f(size.x, min(size.y, 200f)));
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("sprite");
        node.add(_name);
        node.addNode("texture").add(_textureRID);
        node.addNode("clip").add(_clip);
        return node;
    }
}

private final class ParameterWindow : UIElement {
    private {
        SelectButton _textureSelect;
        IntegerField[] _numFields;
        ToolGroup _toolGroup;
        int _tool;
    }

    this(string textureRID, Vec4u clip) {
        /*auto entries = dirEntries(buildNormalizedPath(Project.getMediaDir(), , SpanMode.depth);
        foreach (entry; entries) {

        }*/

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.right, UIAlignY.top);
            hbox.setPosition(Vec2f(4f, 4f));
            hbox.setSpacing(4f);
            addUI(hbox);

            _toolGroup = new ToolGroup;
            foreach (key; ["selection", "move", "corner", "side"]) {
                ToolButton btn = new ToolButton(_toolGroup,
                    "editor:" ~ key ~ "-button", key == "selection");
                btn.setSize(Vec2f(32f, 32f));
                hbox.addUI(btn);
            }
        }

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.left, UIAlignY.top);
        vbox.setPosition(Vec2f(24f, 24f));
        vbox.setSpacing(8f);
        vbox.setChildAlign(UIAlignX.left);
        addUI(vbox);

        {
            HBox hbox = new HBox;
            hbox.setSpacing(8f);
            vbox.addUI(hbox);

            hbox.addUI(new Label("Texture:", Atelier.theme.font));

            _textureSelect = new SelectButton(Studio.getResourceList("texture"), textureRID);
            _textureSelect.addEventListener("value", {
                dispatchEvent("property_textureRID", false);
            });
            hbox.addUI(_textureSelect);
        }

        {
            HBox hbox = new HBox;
            hbox.setSpacing(8f);
            vbox.addUI(hbox);

            IntegerField numField;
            foreach (field; ["x", "y", "w", "h"]) {
                hbox.addUI(new Label(field ~ ":", Atelier.theme.font));

                numField = new IntegerField();
                numField.addEventListener("value", {
                    dispatchEvent("property_clip", false);
                });
                _numFields ~= numField;
                hbox.addUI(numField);
            }

            _numFields[0].value = clip.x;
            _numFields[1].value = clip.y;
            _numFields[2].value = clip.z;
            _numFields[3].value = clip.w;
        }

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });

        addEventListener("update", {
            if (_toolGroup.value != _tool) {
                _tool = _toolGroup.value;
                dispatchEvent("tool", false);
            }
        });
    }

    string getTextureRID() const {
        return _textureSelect.value();
    }

    Vec4u getClip() const {
        return Vec4u(_numFields[0].value(), _numFields[1].value(),
            _numFields[2].value(), _numFields[3].value());
    }

    void setClip(Vec4u clip) {
        Atelier.ui.blockEvents = true;
        _numFields[0].value = clip.x;
        _numFields[1].value = clip.y;
        _numFields[2].value = clip.z;
        _numFields[3].value = clip.w;
        Atelier.ui.blockEvents = false;
    }

    int getTool() const {
        return _toolGroup.value();
    }
}

private final class Previewer : UIElement {
    private {
        Texture _texture;
        Sprite _sprite;
        float _zoom = 1f;
        SpriteResourceEditor _editor;
        Vec2f _positionMouse = Vec2f.zero;
        Vec2f _deltaMouse = Vec2f.zero;
        Vec2i _clipAnchor, _clipAnchor2;
        bool _isResizingVertical;
    }

    this(SpriteResourceEditor editor) {
        _editor = editor;
    }

    void setTextureRID(string rid) {
        bool mustLoad = _texture is null;
        _zoom = 1f;

        if (_sprite) {
            _sprite.remove();
        }

        auto info = Studio.getResource("texture", rid);
        string path = info.farfadet.getNode("file").get!string(0);
        _texture = Texture.fromFile(info.getPath(path));
        _editor._imageSize = Vec2u(_texture.width, _texture.height);
        _sprite = new Sprite(_texture);
        _sprite.position = getCenter();
        addImage(_sprite);

        if (mustLoad) {
            addEventListener("draw", &_onDraw);
            addEventListener("wheel", &_onWheel);
            addEventListener("mousedown", &_onMouseDown);
            addEventListener("mouseup", &_onMouseUp);
            addEventListener("mouseleave", {
                removeEventListener("mousemove", &_onDrag);
                removeEventListener("mousemove", &_onMakeSelection);
                _positionMouse = Vec2f.zero;
                removeEventListener("mousemove", &_onMoveSelection);
                _deltaMouse = Vec2f.zero;
                removeEventListener("mousemove", &_onMoveCorner);
                removeEventListener("mousemove", &_onMoveSide);
            });
        }
    }

    private void _onMouseDown() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case right:
            addEventListener("mousemove", &_onDrag);
            break;
        case left:
            switch (_editor._tool) {
            case 0:
                _positionMouse = (getMousePosition() - (_sprite.position - _sprite.size / 2f)) / _zoom;
                addEventListener("mousemove", &_onMakeSelection);
                break;
            case 1:
                Vec4f clip = _zoom * cast(Vec4f) _editor._clip;
                Vec2f origin = _sprite.position - _sprite.size / 2f + clip.xy;
                if (getMousePosition().isBetween(origin, origin + clip.zw)) {
                    addEventListener("mousemove", &_onMoveSelection);
                }
                break;
            case 2:
                Vec2f positionMouse = (getMousePosition() - (_sprite.position - _sprite.size / 2f)) / _zoom;
                bool isResizingRight = positionMouse.x >= (_editor._clip.x + _editor._clip.z / 2f);
                bool isResizingBottom = positionMouse.y >= (_editor._clip.y + _editor._clip.w / 2f);

                _clipAnchor.x = _editor._clip.x + (isResizingRight ? 0 : _editor._clip.z);
                _clipAnchor.y = _editor._clip.y + (isResizingBottom ? 0 : _editor._clip.w);

                addEventListener("mousemove", &_onMoveCorner);
                break;
            case 3:
                Vec2f positionMouse = (getMousePosition() - (_sprite.position - _sprite.size / 2f)) / _zoom;
                bool isResizingRight = positionMouse.x >= (_editor._clip.x + _editor._clip.z / 2f);
                bool isResizingBottom = positionMouse.y >= (_editor._clip.y + _editor._clip.w / 2f);

                Vec2f delta = Vec2f.zero;
                delta.x = positionMouse.x - cast(float)(_editor._clip.x + (isResizingRight ?
                        _editor._clip.z : 0));
                delta.y = positionMouse.y - cast(float)(_editor._clip.y + (isResizingBottom ?
                        _editor._clip.w : 0));

                _isResizingVertical = abs(delta.y) < abs(delta.x);

                if (_isResizingVertical) {
                    if (isResizingBottom) {
                        _clipAnchor = Vec2i(_editor._clip.x, _editor._clip.y);
                        _clipAnchor2 = Vec2i(_editor._clip.x + _editor._clip.z, _editor._clip.y);
                    }
                    else {
                        _clipAnchor = Vec2i(_editor._clip.x, _editor._clip.y + _editor._clip.w);
                        _clipAnchor2 = Vec2i(_editor._clip.x + _editor._clip.z,
                            _editor._clip.y + _editor._clip.w);
                    }
                }
                else {
                    if (isResizingRight) {
                        _clipAnchor = Vec2i(_editor._clip.x, _editor._clip.y);
                        _clipAnchor2 = Vec2i(_editor._clip.x, _editor._clip.y + _editor._clip.w);
                    }
                    else {
                        _clipAnchor = Vec2i(_editor._clip.x + _editor._clip.z, _editor._clip.y);
                        _clipAnchor2 = Vec2i(_editor._clip.x + _editor._clip.z,
                            _editor._clip.y + _editor._clip.w);
                    }
                }
                addEventListener("mousemove", &_onMoveSide);
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
            switch (_editor._tool) {
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

        startClip = startClip.clamp(Vec2f.zero, cast(Vec2f) _editor._imageSize);
        endClip = endClip.clamp(Vec2f.zero, cast(Vec2f) _editor._imageSize);

        Vec4u clip = Vec4u(cast(uint) startClip.x, cast(uint) startClip.y,
            cast(uint)(endClip.x - startClip.x), cast(uint)(endClip.y - startClip.y));

        if (clip != _editor._clip) {
            _editor._clip = clip;
            dispatchEvent("clip", false);
        }
    }

    private void _onMoveSelection() {
        InputEvent.MouseMotion ev = getManager().input.asMouseMotion();
        _deltaMouse += ev.deltaPosition / _zoom;

        Vec2i move = cast(Vec2i) _deltaMouse;

        if (move.x < 0 && _editor._clip.x < -move.x) {
            move.x = -_editor._clip.x;
        }
        else if (move.x > 0 && _editor._clip.x + _editor._clip.z + move.x > _editor._imageSize.x) {
            move.x = _editor._imageSize.x - (_editor._clip.x + _editor._clip.z);
        }

        if (move.y < 0 && _editor._clip.y < -move.y) {
            move.y = -_editor._clip.y;
        }
        else if (move.y > 0 && _editor._clip.y + _editor._clip.w + move.y > _editor._imageSize.y) {
            move.y = _editor._imageSize.y - (_editor._clip.y + _editor._clip.w);
        }

        _deltaMouse -= cast(Vec2f) move;
        _editor._clip.xy = cast(Vec2u)((cast(Vec2i) _editor._clip.xy) + move);

        if (move != Vec2i.zero) {
            dispatchEvent("clip", false);
        }
    }

    private void _onMoveCorner() {
        Vec2f mousePosition = (getMousePosition() - (_sprite.position - _sprite.size / 2f)) / _zoom;
        mousePosition = mousePosition.clamp(Vec2f.zero, cast(Vec2f) _editor._imageSize);
        Vec2i corner = cast(Vec2i) mousePosition;

        Vec4i rect;
        rect.xy = corner.min(_clipAnchor);
        rect.zw = corner.max(_clipAnchor);

        Vec4u clip;
        clip.xy = cast(Vec2u) rect.xy;
        clip.zw = cast(Vec2u)(rect.zw - rect.xy);

        if (clip != _editor._clip) {
            _editor._clip = clip;
            dispatchEvent("clip", false);
        }
    }

    private void _onMoveSide() {
        Vec2f mousePosition = (getMousePosition() - (_sprite.position - _sprite.size / 2f)) / _zoom;
        mousePosition = mousePosition.clamp(Vec2f.zero, cast(Vec2f) _editor._imageSize);
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

        if (clip != _editor._clip) {
            _editor._clip = clip;
            dispatchEvent("clip", false);
        }
    }

    private void _onDrag() {
        UIManager manager = getManager();
        InputEvent.MouseMotion ev = manager.input.asMouseMotion();
        _sprite.position += ev.deltaPosition;
    }

    private void _onDraw() {
        Atelier.renderer.drawRect(_sprite.position - _sprite.size / 2f,
            _sprite.size, Atelier.theme.onNeutral, 1f, false);

        Vec4f clip = _zoom * cast(Vec4f) _editor._clip;
        Atelier.renderer.drawRect(_sprite.position - _sprite.size / 2f + clip.xy,
            clip.zw, Atelier.theme.accent, 1f, false);
    }

    private void _onWheel() {
        UIManager manager = getManager();
        InputEvent.MouseWheel ev = manager.input.asMouseWheel();
        float zoomDelta = 1f + (ev.wheel.sum() * 0.25f);
        _zoom *= zoomDelta;
        _sprite.size = (cast(Vec2f) _sprite.clip.zw) * _zoom;
        Vec2f delta = _sprite.position - getMousePosition();
        _sprite.position = delta * zoomDelta + getMousePosition();
    }
}
