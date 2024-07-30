/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editor.res.ninepatch;

import std.file;
import std.path;
import std.math : abs;
import atelier;
import farfadet;
import studio.editor.res.base;
import studio.editor.res.editor;
import studio.project;
import studio.ui;

final class NinePatchResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        string _textureRID;
        Vec4u _clip;
        Vec4i _borders;
        Vec2u _imageSize;
        Vec2f _position = Vec2f.zero;
        Texture _texture;
        Sprite _sprite;
        float _zoom = 1f;
        Vec2f _positionMouse = Vec2f.zero;
        Vec2f _deltaMouse = Vec2f.zero;
        Vec2i _clipAnchor, _clipAnchor2;
        bool _isResizingVertical;
        Toolbox _toolbox;
        ParameterWindow _parameterWindow;
        int _tool;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _name = ffd.get!string(0);

        if (ffd.hasNode("texture")) {
            _textureRID = ffd.getNode("texture").get!string(0);
        }

        if (ffd.hasNode("clip")) {
            _clip = ffd.getNode("clip").get!Vec4u(0);
        }

        if (ffd.hasNode("top")) {
            _borders.x = ffd.getNode("top").get!int(0);
        }

        if (ffd.hasNode("bottom")) {
            _borders.y = ffd.getNode("bottom").get!int(0);
        }

        if (ffd.hasNode("left")) {
            _borders.z = ffd.getNode("left").get!int(0);
        }

        if (ffd.hasNode("right")) {
            _borders.w = ffd.getNode("right").get!int(0);
        }

        setTextureRID(_textureRID);

        _parameterWindow = new ParameterWindow(_textureRID, _clip, _borders);

        _toolbox = new Toolbox();
        _toolbox.setTexture(getTexture(), _clip, _borders);
        Atelier.ui.addUI(_toolbox);

        _parameterWindow.addEventListener("property_textureRID", {
            _textureRID = _parameterWindow.getTextureRID();
            setTextureRID(_textureRID);
            _toolbox.setTexture(getTexture(), _clip, _borders);
        });

        _parameterWindow.addEventListener("property_clip", {
            _clip = _parameterWindow.getClip();
            _toolbox.setClip(_clip);
        });

        _parameterWindow.addEventListener("property_borders", {
            _borders = _parameterWindow.getBorders();
            _toolbox.setBorders(_borders);
        });

        addEventListener("clip", {
            _parameterWindow.setClip(_clip);
            _toolbox.setClip(_clip);
        });

        addEventListener("borders", {
            _parameterWindow.setBorders(_borders);
            _toolbox.setBorders(_borders);
        });

        _toolbox.addEventListener("tool", { _tool = _toolbox.getTool(); });
        addEventListener("register", { Atelier.ui.addUI(_toolbox); });
        addEventListener("unregister", { _toolbox.remove(); });
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("ninepatch");
        node.add(_name);
        node.addNode("texture").add(_textureRID);
        node.addNode("clip").add(_clip);
        if (_borders.x > 0)
            node.addNode("top").add(_borders.x);
        if (_borders.y > 0)
            node.addNode("bottom").add(_borders.y);
        if (_borders.z > 0)
            node.addNode("left").add(_borders.z);
        if (_borders.w > 0)
            node.addNode("right").add(_borders.w);
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
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
        _imageSize = Vec2u(_texture.width, _texture.height);
        _sprite = new Sprite(_texture);
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

    Texture getTexture() {
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
        removeEventListener("mousemove", &_onMoveBorder);
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
                Vec4f clip = _zoom * cast(Vec4f) _clip;
                Vec2f origin = _sprite.position - _sprite.size / 2f + clip.xy;
                if (getMousePosition().isBetween(origin, origin + clip.zw)) {
                    addEventListener("mousemove", &_onMoveSelection);
                }
                break;
            case 2:
                Vec2f positionMouse = (getMousePosition() - (_sprite.position - _sprite.size / 2f)) / _zoom;
                bool isResizingRight = positionMouse.x >= (_clip.x + _clip.z / 2f);
                bool isResizingBottom = positionMouse.y >= (_clip.y + _clip.w / 2f);

                _clipAnchor.x = _clip.x + (isResizingRight ? 0 : _clip.z);
                _clipAnchor.y = _clip.y + (isResizingBottom ? 0 : _clip.w);

                addEventListener("mousemove", &_onMoveCorner);
                break;
            case 3:
                Vec2f positionMouse = (getMousePosition() - (_sprite.position - _sprite.size / 2f)) / _zoom;
                bool isResizingRight = positionMouse.x >= (_clip.x + _clip.z / 2f);
                bool isResizingBottom = positionMouse.y >= (_clip.y + _clip.w / 2f);

                Vec2f delta = Vec2f.zero;
                delta.x = positionMouse.x - cast(float)(_clip.x + (isResizingRight ? _clip.z : 0));
                delta.y = positionMouse.y - cast(float)(_clip.y + (isResizingBottom ? _clip.w : 0));

                _isResizingVertical = abs(delta.y) < abs(delta.x);

                if (_isResizingVertical) {
                    if (isResizingBottom) {
                        _clipAnchor = Vec2i(_clip.x, _clip.y);
                        _clipAnchor2 = Vec2i(_clip.x + _clip.z, _clip.y);
                    }
                    else {
                        _clipAnchor = Vec2i(_clip.x, _clip.y + _clip.w);
                        _clipAnchor2 = Vec2i(_clip.x + _clip.z, _clip.y + _clip.w);
                    }
                }
                else {
                    if (isResizingRight) {
                        _clipAnchor = Vec2i(_clip.x, _clip.y);
                        _clipAnchor2 = Vec2i(_clip.x, _clip.y + _clip.w);
                    }
                    else {
                        _clipAnchor = Vec2i(_clip.x + _clip.z, _clip.y);
                        _clipAnchor2 = Vec2i(_clip.x + _clip.z, _clip.y + _clip.w);
                    }
                }
                addEventListener("mousemove", &_onMoveSide);
                break;
            case 4: .. case 7:
                Vec2f mousePosition = (
                    getMousePosition() - (_sprite.position - _sprite.size / 2f)) / _zoom;
                _clipAnchor.x = cast(int) mousePosition.x;
                _clipAnchor.y = cast(int) mousePosition.y;
                addEventListener("mousemove", &_onMoveBorder);
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
            case 4: .. case 7:
                removeEventListener("mousemove", &_onMoveBorder);
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

        if (clip != _clip) {
            _clip = clip;
            dispatchEvent("clip", false);
        }
    }

    private void _onMoveSelection() {
        InputEvent.MouseMotion ev = getManager().input.asMouseMotion();
        _deltaMouse += ev.deltaPosition / _zoom;

        Vec2i move = cast(Vec2i) _deltaMouse;

        if (move.x < 0 && _clip.x < -move.x) {
            move.x = -_clip.x;
        }
        else if (move.x > 0 && _clip.x + _clip.z + move.x > _imageSize.x) {
            move.x = _imageSize.x - (_clip.x + _clip.z);
        }

        if (move.y < 0 && _clip.y < -move.y) {
            move.y = -_clip.y;
        }
        else if (move.y > 0 && _clip.y + _clip.w + move.y > _imageSize.y) {
            move.y = _imageSize.y - (_clip.y + _clip.w);
        }

        _deltaMouse -= cast(Vec2f) move;
        _clip.xy = cast(Vec2u)((cast(Vec2i) _clip.xy) + move);

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

        if (clip != _clip) {
            _clip = clip;
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

        if (clip != _clip) {
            _clip = clip;
            dispatchEvent("clip", false);
        }
    }

    private void _onMoveBorder() {
        Vec2f mousePosition = (getMousePosition() - (_sprite.position - _sprite.size / 2f)) / _zoom;
        mousePosition = mousePosition.clamp(Vec2f.zero, cast(Vec2f) _imageSize);
        Vec2i point = (cast(Vec2i) mousePosition) - (cast(Vec2i) _clip.xy);
        Vec4i borders = _borders;

        switch (_tool) {
        case 4:
            borders.x = clamp(point.y, 0, _clip.w);
            break;
        case 5:
            borders.y = clamp((cast(int) _clip.w) - point.y, 0, _clip.w);
            break;
        case 6:
            borders.z = clamp(point.x, 0, _clip.z);
            break;
        case 7:
            borders.w = clamp((cast(int) _clip.z) - point.x, 0, _clip.z);
            break;
        default:
            return;
        }

        if (borders != _borders) {
            _borders = borders;
            dispatchEvent("borders", false);
        }
    }

    private void _onDrag() {
        UIManager manager = getManager();
        InputEvent.MouseMotion ev = manager.input.asMouseMotion();
        _position += ev.deltaPosition;
    }

    private void _onDraw() {
        Vec4f clip = _zoom * cast(Vec4f) _clip;
        Vec4f borders = _zoom * cast(Vec4f) _borders;

        Vec2f clipOrigin = _sprite.position - _sprite.size / 2f + clip.xy;

        Atelier.renderer.drawRect(_sprite.position - _sprite.size / 2f,
            _sprite.size, Atelier.theme.onNeutral, 1f, false);

        HSLColor hsl = HSLColor.fromColor(Atelier.theme.accent);

        if (borders.x > 0f) {
            HSLColor c = hsl;
            c.h = c.h + 72f;
            Atelier.renderer.drawLine(clipOrigin + Vec2f(0f, borders.x),
                clipOrigin + Vec2f(clip.z, borders.x), c.toColor(), 1f);
        }
        if (borders.y > 0f) {
            HSLColor c = hsl;
            c.h = c.h + 144f;
            Atelier.renderer.drawLine(clipOrigin + Vec2f(0f, clip.w - borders.y),
                clipOrigin + Vec2f(clip.z, clip.w - borders.y), c.toColor(), 1f);
        }
        if (borders.z > 0f) {
            HSLColor c = hsl;
            c.h = c.h + 216f;
            Atelier.renderer.drawLine(clipOrigin + Vec2f(borders.z, 0f),
                clipOrigin + Vec2f(borders.z, clip.w), c.toColor(), 1f);
        }
        if (borders.w > 0f) {
            HSLColor c = hsl;
            c.h = c.h + 288f;
            Atelier.renderer.drawLine(clipOrigin + Vec2f(clip.z - borders.w, 0f),
                clipOrigin + Vec2f(clip.z - borders.w, clip.w), c.toColor(), 1f);
        }

        Atelier.renderer.drawRect(clipOrigin, clip.zw, Atelier.theme.accent, 1f, false);
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

private class Toolbox : Modal {
    private {
        NinePatch _ninepatch;
        ToolGroup _toolGroup;
        int _tool;
    }

    this() {
        setSize(Vec2f(200f, 300f));
        setAlign(UIAlignX.left, UIAlignY.top);
        setPosition(Vec2f(258f, 75f));

        {
            Label title = new Label("Outils", Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 8f));
            addUI(title);
        }

        {
            VBox vbox = new VBox;
            vbox.setAlign(UIAlignX.center, UIAlignY.top);
            vbox.setPosition(Vec2f(0f, 32f));
            vbox.setSpacing(4f);
            addUI(vbox);

            _toolGroup = new ToolGroup;

            {
                HBox hbox = new HBox;
                hbox.setSpacing(4f);
                vbox.addUI(hbox);

                foreach (key; ["selection", "move", "corner", "side"]) {
                    ToolButton btn = new ToolButton(_toolGroup,
                        "editor:" ~ key ~ "-button", key == "selection");
                    btn.setSize(Vec2f(32f, 32f));
                    hbox.addUI(btn);
                }
            }

            {
                HBox hbox = new HBox;
                hbox.setSpacing(4f);
                vbox.addUI(hbox);

                HSLColor hsl = HSLColor.fromColor(Atelier.theme.accent);
                foreach (key; ["top", "bottom", "left", "right"]) {
                    hsl.h = hsl.h + 72f;
                    ToolButton btn = new ToolButton(_toolGroup, "editor:" ~ key ~ "-button", false);
                    btn.setSize(Vec2f(32f, 32f));
                    btn.setIconColor(hsl.toColor());
                    hbox.addUI(btn);
                }
            }
        }

        {
            Rectangle rect = Rectangle.outline(Vec2f.one * (getWidth() - 16f), 1f);
            rect.color = Atelier.theme.onNeutral;
            rect.anchor = Vec2f(0.5f, 1f);
            rect.position = Vec2f(getCenter().x, getHeight() - 8f);
            addImage(rect);
        }

        addEventListener("update", {
            if (_toolGroup.value != _tool) {
                _tool = _toolGroup.value;
                dispatchEvent("tool", false);
            }
        });
    }

    int getTool() const {
        return _toolGroup.value();
    }

    void setTexture(Texture texture, Vec4u clip, Vec4i borders) {
        if (_ninepatch)
            _ninepatch.remove();
        _ninepatch = new NinePatch(texture, clip, borders.x, borders.y, borders.z, borders.w);
        _ninepatch.anchor = Vec2f(0.5f, 1f);
        _ninepatch.position = Vec2f(getCenter().x, getHeight() - 8f);
        _ninepatch.size = Vec2f.one * (getWidth() - 16f);
        addImage(_ninepatch);
    }

    void setClip(Vec4u clip) {
        if (_ninepatch)
            _ninepatch.clip = clip;
    }

    void setBorders(Vec4i borders) {
        if (_ninepatch) {
            _ninepatch.top = borders.x;
            _ninepatch.bottom = borders.y;
            _ninepatch.left = borders.z;
            _ninepatch.right = borders.w;
        }
    }
}

private final class ParameterWindow : UIElement {
    private {
        SelectButton _textureSelect;
        IntegerField[] _clipFields, _bordersFields;
    }

    this(string textureRID, Vec4u clip, Vec4i borders) {
        VList vlist = new VList;
        vlist.setPosition(Vec2f(8f, 8f));
        vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        vlist.setAlign(UIAlignX.left, UIAlignY.top);
        vlist.setColor(Atelier.theme.surface);
        vlist.setSpacing(8f);
        vlist.setChildAlign(UIAlignX.left);
        addUI(vlist);

        {
            LabelSeparator sep = new LabelSeparator("Propriétés", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Texture:", Atelier.theme.font));

            _textureSelect = new SelectButton(Studio.getResourceList("texture"), textureRID);
            _textureSelect.setWidth(200f);
            _textureSelect.addEventListener("value", {
                dispatchEvent("property_textureRID", false);
            });
            hlayout.addUI(_textureSelect);
        }

        {
            LabelSeparator sep = new LabelSeparator("Région", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            foreach (field; ["Position X", "Position Y", "Largeur", "Hauteur"]) {
                IntegerField numField = new IntegerField();
                numField.setMinValue(0);
                numField.addEventListener("value", {
                    dispatchEvent("property_clip", false);
                });
                _clipFields ~= numField;

                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(284f, 0f));
                vlist.addList(hlayout);

                hlayout.addUI(new Label(field ~ ":", Atelier.theme.font));
                hlayout.addUI(numField);
            }

            _clipFields[0].value = clip.x;
            _clipFields[1].value = clip.y;
            _clipFields[2].value = clip.z;
            _clipFields[3].value = clip.w;
        }

        {
            LabelSeparator sep = new LabelSeparator("Bordures", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            foreach (field; ["Haut", "Bas", "Gauche", "Droite"]) {
                IntegerField numField = new IntegerField();
                numField.setRange(0, int.max);
                numField.addEventListener("value", {
                    dispatchEvent("property_borders", false);
                });
                _bordersFields ~= numField;

                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(284f, 0f));
                vlist.addList(hlayout);

                hlayout.addUI(new Label(field ~ ":", Atelier.theme.font));
                hlayout.addUI(numField);
            }

            _bordersFields[0].value = borders.x;
            _bordersFields[1].value = borders.y;
            _bordersFields[2].value = borders.z;
            _bordersFields[3].value = borders.w;
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });
    }

    string getTextureRID() const {
        return _textureSelect.value();
    }

    Vec4u getClip() const {
        return Vec4u(_clipFields[0].value(), _clipFields[1].value(),
            _clipFields[2].value(), _clipFields[3].value());
    }

    Vec4i getBorders() const {
        return Vec4i(_bordersFields[0].value(), _bordersFields[1].value(),
            _bordersFields[2].value(), _bordersFields[3].value());
    }

    void setClip(Vec4u clip) {
        Atelier.ui.blockEvents = true;
        _clipFields[0].value = clip.x;
        _clipFields[1].value = clip.y;
        _clipFields[2].value = clip.z;
        _clipFields[3].value = clip.w;
        Atelier.ui.blockEvents = false;
    }

    void setBorders(Vec4i borders) {
        Atelier.ui.blockEvents = true;
        _bordersFields[0].value = borders.x;
        _bordersFields[1].value = borders.y;
        _bordersFields[2].value = borders.z;
        _bordersFields[3].value = borders.w;
        Atelier.ui.blockEvents = false;
    }
}
