module atelier.etabli.media.res.shadedtexture;

import std.conv : to;
import std.file;
import std.math : abs;
import std.path;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.render;

import atelier.etabli.media.res.base;
import atelier.etabli.media.res.editor;
import atelier.etabli.ui;

final class ShadedTextureResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        string _filePath;

        Color _sourceColorA = Color.white;
        Color _sourceColorB = Color.black;
        Color _targetColorA = Color.white;
        Color _targetColorB = Color.white;

        float _sourceAlphaA = 1f;
        float _sourceAlphaB = 1f;
        float _targetAlphaA = 1f;
        float _targetAlphaB = 0f;

        string _spline = to!string(Spline.linear);

        Vec2u _imageSize;
        Vec2f _position = Vec2f.zero;
        ShadedTexture _texture;
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

        if (ffd.hasNode("sourceColorA")) {
            _sourceColorA = ffd.getNode("sourceColorA").get!Color(0);
        }

        if (ffd.hasNode("sourceColorB")) {
            _sourceColorB = ffd.getNode("sourceColorB").get!Color(0);
        }

        if (ffd.hasNode("targetColorA")) {
            _targetColorA = ffd.getNode("targetColorA").get!Color(0);
        }

        if (ffd.hasNode("targetColorB")) {
            _targetColorB = ffd.getNode("targetColorB").get!Color(0);
        }

        if (ffd.hasNode("sourceAlphaA")) {
            _sourceAlphaA = ffd.getNode("sourceAlphaA").get!float(0);
        }

        if (ffd.hasNode("sourceAlphaB")) {
            _sourceAlphaB = ffd.getNode("sourceAlphaB").get!float(0);
        }

        if (ffd.hasNode("targetAlphaA")) {
            _targetAlphaA = ffd.getNode("targetAlphaA").get!float(0);
        }

        if (ffd.hasNode("targetAlphaB")) {
            _targetAlphaB = ffd.getNode("targetAlphaB").get!float(0);
        }

        if (ffd.hasNode("spline")) {
            _spline = ffd.getNode("spline").get!string(0);
        }

        _parameterWindow = new ParameterWindow(path(), _filePath, _sourceColorA, _sourceColorB, _targetColorA, _targetColorB, _sourceAlphaA, _sourceAlphaB, _targetAlphaA, _targetAlphaB, _spline);
        _filePath = _parameterWindow.getFile();
        setFile(_filePath);

        _parameterWindow.addEventListener("property_file", {
            _filePath = _parameterWindow.getFile();
            setFile(_filePath);
            setDirty();
        });

        _parameterWindow.addEventListener("property_color", {
            _sourceColorA = _parameterWindow.getSourceColorA();
            _sourceColorB = _parameterWindow.getSourceColorB();
            _targetColorA = _parameterWindow.getTargetColorA();
            _targetColorB = _parameterWindow.getTargetColorB();
            _sourceAlphaA = _parameterWindow.getSourceAlphaA();
            _sourceAlphaB = _parameterWindow.getSourceAlphaB();
            _targetAlphaA = _parameterWindow.getTargetAlphaA();
            _targetAlphaB = _parameterWindow.getTargetAlphaB();
            _spline = _parameterWindow.getSpline();
            setFile(_filePath, true);
            setDirty();
        });
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("shadedtexture");
        node.add(_name);
        node.addNode("file").add(_filePath);
        node.addNode("sourceColorA").add(_sourceColorA);
        node.addNode("sourceAlphaA").add(_sourceAlphaA);
        node.addNode("sourceColorB").add(_sourceColorB);
        node.addNode("sourceAlphaB").add(_sourceAlphaB);
        node.addNode("targetColorA").add(_targetColorA);
        node.addNode("targetAlphaA").add(_targetAlphaA);
        node.addNode("targetColorB").add(_targetColorB);
        node.addNode("targetAlphaB").add(_targetAlphaB);
        node.addNode("spline").add(_spline);
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    void setFile(string filePath, bool keepView = false) {
        bool mustLoad = _texture is null;

        if (!keepView) {
            _zoom = 1f;
        }

        if (_sprite) {
            _sprite.remove();
        }

        if (!filePath.length)
            return;

        filePath = buildNormalizedPath(dirName(path()), filePath);

        if (!exists(filePath))
            return;

        _texture = ShadedTexture.fromFile(filePath);
        _texture.sourceColorA = _sourceColorA;
        _texture.sourceColorB = _sourceColorB;
        _texture.targetColorA = _targetColorA;
        _texture.targetColorB = _targetColorB;
        _texture.sourceAlphaA = _sourceAlphaA;
        _texture.sourceAlphaB = _sourceAlphaB;
        _texture.targetAlphaA = _targetAlphaA;
        _texture.targetAlphaB = _targetAlphaB;

        try {
            _texture.spline = to!Spline(_spline);
        }
        catch (Exception e) {
            _texture.spline = Spline.linear;
        }

        _texture.generate();
        _imageSize = Vec2u(_texture.data.width, _texture.data.height);
        _sprite = new Sprite(_texture.data);

        if (keepView) {
            _sprite.position = getCenter() + _position;
            _sprite.size = (cast(Vec2f) _sprite.clip.zw) * _zoom;
        }

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
        ColorButton _sourceColorABtn, _sourceColorBBtn;
        ColorButton _targetColorABtn, _targetColorBBtn;
        float _sourceAlphaA, _sourceAlphaB, _targetAlphaA, _targetAlphaB;
        CarouselButton _splineSelect;
    }

    this(string resPath, string filePath, Color sourceColorA, Color sourceColorB, Color targetColorA, Color targetColorB, float sourceAlphaA, float sourceAlphaB, float targetAlphaA, float targetAlphaB, string spline) {
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

            hlayout.addUI(new Label("Source A:", Atelier.theme.font));

            _sourceColorABtn = new ColorButton();
            _sourceColorABtn.value = sourceColorA;
            _sourceColorABtn.addEventListener("value", {
                dispatchEvent("property_color");
            });
            hlayout.addUI(_sourceColorABtn);
        }

        {
            _sourceAlphaA = sourceAlphaA;

            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Alpha:", Atelier.theme.font));

            HSlider alphaSlider = new HSlider;
            alphaSlider.minValue = 0f;
            alphaSlider.maxValue = 1f;
            alphaSlider.steps = 100;
            alphaSlider.fvalue = _sourceAlphaA;
            hlayout.addUI(alphaSlider);

            NumberField alphaField = new NumberField;
            alphaField.setRange(0f, 1f);
            alphaField.setStep(.1f);
            alphaField.value = _sourceAlphaA;
            hlayout.addUI(alphaField);

            alphaSlider.addEventListener("value", {
                _sourceAlphaA = alphaSlider.fvalue;
                alphaField.value = alphaSlider.fvalue;
                dispatchEvent("property_color");
            });
            alphaField.addEventListener("value", {
                _sourceAlphaA = alphaField.value;
                alphaSlider.fvalue = alphaField.value;
                dispatchEvent("property_color");
            });
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Source B:", Atelier.theme.font));

            _sourceColorBBtn = new ColorButton();
            _sourceColorBBtn.value = sourceColorB;
            _sourceColorBBtn.addEventListener("value", {
                dispatchEvent("property_color");
            });
            hlayout.addUI(_sourceColorBBtn);
        }

        {
            _sourceAlphaB = sourceAlphaB;

            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Alpha:", Atelier.theme.font));

            HSlider alphaSlider = new HSlider;
            alphaSlider.minValue = 0f;
            alphaSlider.maxValue = 1f;
            alphaSlider.steps = 100;
            alphaSlider.fvalue = _sourceAlphaB;
            hlayout.addUI(alphaSlider);

            NumberField alphaField = new NumberField;
            alphaField.setRange(0f, 1f);
            alphaField.setStep(.1f);
            alphaField.value = _sourceAlphaB;
            hlayout.addUI(alphaField);

            alphaSlider.addEventListener("value", {
                _sourceAlphaB = alphaSlider.fvalue;
                alphaField.value = alphaSlider.fvalue;
                dispatchEvent("property_color");
            });
            alphaField.addEventListener("value", {
                _sourceAlphaB = alphaField.value;
                alphaSlider.fvalue = alphaField.value;
                dispatchEvent("property_color");
            });
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Destination A:", Atelier.theme.font));

            _targetColorABtn = new ColorButton();
            _targetColorABtn.value = targetColorA;
            _targetColorABtn.addEventListener("value", {
                dispatchEvent("property_color");
            });
            hlayout.addUI(_targetColorABtn);
        }

        {
            _targetAlphaA = targetAlphaA;

            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Alpha:", Atelier.theme.font));

            HSlider alphaSlider = new HSlider;
            alphaSlider.minValue = 0f;
            alphaSlider.maxValue = 1f;
            alphaSlider.steps = 100;
            alphaSlider.fvalue = _targetAlphaA;
            hlayout.addUI(alphaSlider);

            NumberField alphaField = new NumberField;
            alphaField.setRange(0f, 1f);
            alphaField.setStep(.1f);
            alphaField.value = _targetAlphaA;
            hlayout.addUI(alphaField);

            alphaSlider.addEventListener("value", {
                _targetAlphaA = alphaSlider.fvalue;
                alphaField.value = alphaSlider.fvalue;
                dispatchEvent("property_color");
            });
            alphaField.addEventListener("value", {
                _targetAlphaA = alphaField.value;
                alphaSlider.fvalue = alphaField.value;
                dispatchEvent("property_color");
            });
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Destination B:", Atelier.theme.font));

            _targetColorBBtn = new ColorButton();
            _targetColorBBtn.value = targetColorB;
            _targetColorBBtn.addEventListener("value", {
                dispatchEvent("property_color");
            });
            hlayout.addUI(_targetColorBBtn);
        }

        {
            _targetAlphaB = targetAlphaB;

            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Alpha:", Atelier.theme.font));

            HSlider alphaSlider = new HSlider;
            alphaSlider.minValue = 0f;
            alphaSlider.maxValue = 1f;
            alphaSlider.steps = 100;
            alphaSlider.fvalue = _targetAlphaB;
            hlayout.addUI(alphaSlider);

            NumberField alphaField = new NumberField;
            alphaField.setRange(0f, 1f);
            alphaField.setStep(.1f);
            alphaField.value = _targetAlphaB;
            hlayout.addUI(alphaField);

            alphaSlider.addEventListener("value", {
                _targetAlphaB = alphaSlider.fvalue;
                alphaField.value = alphaSlider.fvalue;
                dispatchEvent("property_color");
            });
            alphaField.addEventListener("value", {
                _targetAlphaB = alphaField.value;
                alphaSlider.fvalue = alphaField.value;
                dispatchEvent("property_color");
            });
        }

        {
            vlist.addList(new Label("Interpolation:", Atelier.theme.font));

            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            _splineSelect = new CarouselButton([
                    __traits(allMembers, Spline)
                ], spline, false);
            hlayout.addUI(_splineSelect);

            SplineGraph splineGraph = new SplineGraph();
            splineGraph.setSpline(spline);
            hlayout.addUI(splineGraph);

            _splineSelect.addEventListener("value", {
                splineGraph.setSpline(_splineSelect.value);
                dispatchEvent("property_color");
            });
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

    Color getSourceColorA() const {
        return _sourceColorABtn.value();
    }

    Color getSourceColorB() const {
        return _sourceColorBBtn.value();
    }

    Color getTargetColorA() const {
        return _targetColorABtn.value();
    }

    Color getTargetColorB() const {
        return _targetColorBBtn.value();
    }

    float getSourceAlphaA() const {
        return _sourceAlphaA;
    }

    float getSourceAlphaB() const {
        return _sourceAlphaB;
    }

    float getTargetAlphaA() const {
        return _targetAlphaA;
    }

    float getTargetAlphaB() const {
        return _targetAlphaB;
    }

    string getSpline() const {
        return _splineSelect.value;
    }
}
