module atelier.etabli.media.res.texture;

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
import atelier.etabli.media.res.editor;
import atelier.etabli.ui;

final class TextureResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        string _filePath;
        bool _isSmooth;
        Vec2u _imageSize;
        Vec2f _position = Vec2f.zero;
        Texture _texture;
        Sprite _sprite;
        float _zoom = 1f;
        ParameterWindow _parameterWindow;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _name = ffd.get!string(0);

        if (ffd.hasNode("file")) {
            _filePath = ffd.getNode("file").get!string(0);
        }

        if (ffd.hasNode("isSmooth")) {
            _isSmooth = ffd.getNode("isSmooth").get!bool(0);
        }

        _parameterWindow = new ParameterWindow(path(), _filePath, _isSmooth);
        _filePath = _parameterWindow.getFile();
        setFile(_filePath, _isSmooth);

        _parameterWindow.addEventListener("property_file", {
            _filePath = _parameterWindow.getFile();
            setFile(_filePath, _isSmooth);
            setDirty();
        });

        _parameterWindow.addEventListener("property_isSmooth", {
            _isSmooth = _parameterWindow.getIsSmooth();
            setFile(_filePath, _isSmooth);
            setDirty();
        });
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("texture");
        node.add(_name);
        node.addNode("file").add(_filePath);
        node.addNode("isSmooth").add(_isSmooth);
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    void setFile(string filePath, bool isSmooth) {
        bool mustLoad = _texture is null;
        _zoom = 1f;

        if (_sprite) {
            _sprite.remove();
        }

        if (!filePath.length)
            return;

        filePath = buildNormalizedPath(dirName(path()), filePath);

        if (!exists(filePath))
            return;

        _texture = Texture.fromFile(filePath, isSmooth);
        _imageSize = Vec2u(_texture.width, _texture.height);
        _sprite = new Sprite(_texture);
        addImage(_sprite);

        if (mustLoad) {
            addEventListener("update", &_onUpdate);
            addEventListener("draw", &_onDraw);
            addEventListener("wheel", &_onWheel);
            addEventListener("mousedown", &_onMouseDown);
            addEventListener("mouseup", &_onMouseUp);
            addEventListener("mouseleave", {
                removeEventListener("mousemove", &_onDrag);
            });
        }
    }

    private void _onUpdate() {
        _sprite.position = getCenter() + _position;
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
        _position += ev.deltaPosition;
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
    }

    override void loadView() {
        _zoom = view.zoom;
        _sprite.size = view.size;
        _position = view.position;
    }
}

private {
    struct EditorView {
        float zoom = 1f;
        Vec2f position = Vec2f.zero;
        Vec2f size = Vec2f.zero;
    }

    EditorView view;
}

private final class ParameterWindow : UIElement {
    private {
        SelectButton _fileSelect;
        Checkbox _isSmoothCheck;
    }

    this(string resPath, string filePath, bool isSmooth) {
        string p = buildNormalizedPath(relativePath(resPath, Atelier.etabli.getMediaDir()));
        auto split = pathSplitter(p);
        if (!split.empty) {
            p = split.front;
        }

        string dir = dirName(resPath);
        auto entries = dirEntries(buildNormalizedPath(Atelier.etabli.getMediaDir(), p), SpanMode
                .depth);
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

            hlayout.addUI(new Label("Fichier:", Atelier.theme.font));

            _fileSelect = new SelectButton(files, filePath);
            _fileSelect.setWidth(200f);
            _fileSelect.addEventListener("value", {
                dispatchEvent("property_file", false);
            });
            hlayout.addUI(_fileSelect);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Lissage:", Atelier.theme.font));

            _isSmoothCheck = new Checkbox(isSmooth);
            _isSmoothCheck.addEventListener("value", {
                dispatchEvent("property_isSmooth", false);
            });
            hlayout.addUI(_isSmoothCheck);
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });
    }

    string getFile() const {
        return _fileSelect.value();
    }

    bool getIsSmooth() const {
        return _isSmoothCheck.value();
    }
}
