/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editors.res.sprite;

import std.file;
import std.path;
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
        Previewer _preview;
        ParameterWindow _parameterWindow;
    }

    this(Farfadet ffd, Vec2f size) {
        super(size);
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
    }

    this(string textureRID, Vec4u clip) {
        /*auto entries = dirEntries(buildNormalizedPath(Project.getMediaDir(), , SpanMode.depth);
        foreach (entry; entries) {

        }*/
        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.left, UIAlignY.top);
        vbox.setPosition(Vec2f(32f, 16f));
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
    }

    string getTextureRID() const {
        return _textureSelect.value();
    }

    Vec4u getClip() const {
        return Vec4u(_numFields[0].value(), _numFields[1].value(),
            _numFields[2].value(), _numFields[3].value());
    }
}

private final class Previewer : UIElement {
    private {
        Texture _texture;
        Sprite _sprite;
        float _zoom = 1f;
        SpriteResourceEditor _editor;
    }

    this(SpriteResourceEditor editor) {
        _editor = editor;

        HBox hbox = new HBox;
        hbox.setAlign(UIAlignX.right, UIAlignY.top);
        hbox.setSpacing(8f);
        addUI(hbox);

        foreach (key; ["select", "bord", "coin"]) {
            NeutralButton btn = new NeutralButton(key);
            hbox.addUI(btn);
        }
    }

    void setTextureRID(string rid) {
        bool mustLoad = _texture is null;
        _zoom = 1f;

        if(_sprite) {
            _sprite.remove();
        }

        auto info = Studio.getResource("texture", rid);
        string path = info.farfadet.getNode("file").get!string(0);
        _texture = Texture.fromFile(info.getPath(path));
        _sprite = new Sprite(_texture);
        _sprite.position = getCenter();
        addImage(_sprite);

        if (mustLoad) {
            addEventListener("draw", &_onDraw);
            addEventListener("wheel", &_onWheel);
            addEventListener("mousedown", &_onMouseDown);
            addEventListener("mouseup", &_onMouseUp);
        }
    }

    private void _onMouseDown() {
        addEventListener("mousemove", &_onDrag);
    }

    private void _onMouseUp() {
        removeEventListener("mousemove", &_onDrag);
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
