/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editors.res.texture;

import std.file;
import std.path;
import std.math : abs;
import atelier;
import farfadet;
import studio.editors.res.base;
import studio.project;
import studio.ui;

final class TextureResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        string _filePath;
        Vec2u _imageSize;
        Previewer _preview;
        ParameterWindow _parameterWindow;
    }

    this(string path_, Farfadet ffd, Vec2f size) {
        super(path_, size);
        _ffd = ffd;

        _name = ffd.get!string(0);

        if (ffd.hasNode("file")) {
            _filePath = ffd.getNode("file").get!string(0);
        }

        _preview = new Previewer(this);
        _preview.setAlign(UIAlignX.center, UIAlignY.top);
        _preview.setSize(Vec2f(size.x, max(0f, size.y - 200f)));
        _preview.setFile(path(), _filePath);
        addUI(_preview);

        _parameterWindow = new ParameterWindow(path(), _filePath);
        _parameterWindow.setAlign(UIAlignX.center, UIAlignY.bottom);
        _parameterWindow.setSize(Vec2f(size.x, min(size.y, 200f)));
        addUI(_parameterWindow);

        addEventListener("size", &_onSize);

        _parameterWindow.addEventListener("property_file", {
            _filePath = _parameterWindow.getFile();
            _preview.setFile(path(), _filePath);
        });
    }

    private void _onSize() {
        Vec2f size = getSize();
        _preview.setSize(Vec2f(size.x, max(0f, size.y - 200f)));
        _parameterWindow.setSize(Vec2f(size.x, min(size.y, 200f)));
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("texture");
        node.add(_name);
        node.addNode("file").add(_filePath);
        return node;
    }
}

private final class ParameterWindow : UIElement {
    private {
        SelectButton _fileSelect;
    }

    this(string resPath, string filePath) {
        string p = buildNormalizedPath(relativePath(resPath, Project.getMediaDir()));
        auto split = pathSplitter(p);
        if (!split.empty) {
            p = split.front;
        }

        string dir = dirName(resPath);
        auto entries = dirEntries(buildNormalizedPath(Project.getMediaDir(), p), SpanMode.depth);
        string[] files;
        foreach (entry; entries) {
            if (!entry.isDir) {
                switch (extension(entry)) {
                case ".png":
                case ".jpg":
                case ".jpeg":
                case ".gif":
                case ".tga":
                case ".bmp":
                    files ~= relativePath(entry, dir);
                    break;
                default:
                    break;
                }
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

            _fileSelect = new SelectButton(files, filePath);
            _fileSelect.addEventListener("value", {
                dispatchEvent("property_file", false);
            });
            hbox.addUI(_fileSelect);
        }

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });
    }

    string getFile() const {
        return _fileSelect.value();
    }
}

private final class Previewer : UIElement {
    private {
        Texture _texture;
        Sprite _sprite;
        float _zoom = 1f;
        TextureResourceEditor _editor;
    }

    this(TextureResourceEditor editor) {
        _editor = editor;
    }

    void setFile(string resPath, string path) {
        bool mustLoad = _texture is null;
        _zoom = 1f;

        if (_sprite) {
            _sprite.remove();
        }

        _texture = Texture.fromFile(buildNormalizedPath(dirName(resPath), path));
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
            });
        }
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
        _sprite.position += ev.deltaPosition;
    }

    private void _onDraw() {
        Atelier.renderer.drawRect(_sprite.position - _sprite.size / 2f,
            _sprite.size, Atelier.theme.onNeutral, 1f, false);
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
