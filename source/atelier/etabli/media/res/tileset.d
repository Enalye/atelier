module atelier.etabli.media.res.tileset;

import std.array : split;
import std.conv : to, ConvException;
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

final class TilesetResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        string _textureRID;
        Vec4u _clip;
        uint _columns, _lines, _maxCount;
        Vec2i _margin;
        bool _hasMaxCount;
        uint _frameTime;
        Vec2i[] _tileFrames;
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

        if (ffd.hasNode("frameTime")) {
            _frameTime = ffd.getNode("frameTime").get!uint(0);
        }

        if (ffd.hasNode("columns")) {
            _columns = ffd.getNode("columns").get!int(0);
        }

        if (ffd.hasNode("lines")) {
            _lines = ffd.getNode("lines").get!int(0);
        }

        if (ffd.hasNode("maxCount")) {
            _hasMaxCount = true;
            _maxCount = ffd.getNode("maxCount").get!int(0);
        }
        else {
            _maxCount = _lines * _columns;
        }

        if (ffd.hasNode("margin")) {
            _margin = ffd.getNode("margin").get!Vec2i(0);
        }

        foreach (tileFrame; ffd.getNodes("tileFrame", 2)) {
            _tileFrames ~= tileFrame.get!Vec2i(0);
        }

        setTextureRID(_textureRID);

        _parameterWindow = new ParameterWindow(_textureRID, _clip, _columns,
            _lines, _hasMaxCount, _maxCount, _margin, _frameTime, _tileFrames);

        _toolbox = new Toolbox();
        Atelier.ui.addUI(_toolbox);

        _parameterWindow.addEventListener("property_textureRID", {
            _textureRID = _parameterWindow.getTextureRID();
            setTextureRID(_textureRID);
            setDirty();
        });

        _parameterWindow.addEventListener("property_clip", {
            _clip = _parameterWindow.getClip();
            setDirty();
        });

        _parameterWindow.addEventListener("property_misc", {
            _parameterWindow.getMisc(_columns, _lines, _hasMaxCount, _maxCount,
                _margin, _frameTime);
            setDirty();
        });

        _parameterWindow.addEventListener("property_tileFrames", {
            _tileFrames = _parameterWindow.getTileFrames();
            setDirty();
        });

        addEventListener("clip", { _parameterWindow.setClip(_clip); });
        _toolbox.addEventListener("tool", { _tool = _toolbox.getTool(); });
        addEventListener("register", { Atelier.ui.addUI(_toolbox); });
        addEventListener("unregister", { _toolbox.removeUI(); });
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("tileset");
        node.add(_name);
        node.addNode("texture").add(_textureRID);
        node.addNode("clip").add(_clip);
        node.addNode("lines").add(_lines);
        node.addNode("columns").add(_columns);
        if (_hasMaxCount) {
            node.addNode("maxCount").add(_maxCount);
        }
        node.addNode("margin").add(_margin);
        node.addNode("frameTime").add(_frameTime);
        _tileFrames = _parameterWindow.getTileFrames();
        foreach (Vec2i tileFrame; _tileFrames) {
            node.addNode("tileFrame").add(tileFrame);
        }
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

        if (Atelier.etabli.hasResource("texture", rid)) {
            auto info = Atelier.etabli.getResource("texture", rid);
            string filePath = info.farfadet.getNode("file").get!string(0);
            _texture = Texture.fromFile(info.getPath(filePath));
        }
        else {
            _texture = Atelier.res.get!Texture("editor:?");
        }
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

    private void _onDrag() {
        UIManager manager = getManager();
        InputEvent.MouseMotion ev = manager.input.asMouseMotion();
        _position += ev.deltaPosition;
    }

    private void _onDraw() {
        Vec2f origin = _sprite.position - _sprite.size / 2f;
        Vec4f clip = _zoom * cast(Vec4f) _clip;

        Atelier.renderer.drawRect(origin, _sprite.size, Atelier.theme.onNeutral, 1f, false);

        uint maxCount = _hasMaxCount ? _maxCount : (_columns * _lines);

        Color startFrameColor = Atelier.theme.accent;
        HSLColor hsl = HSLColor.fromColor(startFrameColor);
        hsl.h = hsl.h + 180f;
        Color otherFrameColor = hsl.toColor();

        uint frame;
        __gridLoop: for (uint y; y < _lines; ++y) {
            for (uint x; x < _columns; ++x) {
                if (frame >= maxCount) {
                    break __gridLoop;
                }

                Vec2f animClip = Vec2f(x, y) * (clip.zw + cast(Vec2f) _margin);

                Color color;
                if (frame == 0) {
                    color = startFrameColor;
                }
                else {
                    color = otherFrameColor;
                }

                drawText(origin + clip.xy + Vec2f(2f, clip.w - 2f) + animClip,
                    to!dstring(frame), Atelier.theme.font, color);
                Atelier.renderer.drawRect(origin + clip.xy + animClip, clip.zw, color, 1f, false);

                frame++;
            }
        }
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
        _toolbox.saveView();
    }

    override void loadView() {
        _zoom = view.zoom;
        _sprite.size = view.size;
        _position = view.position;
        _toolbox.loadView();
    }
}

private {
    struct EditorView {
        float zoom = 1f;
        Vec2f position = Vec2f.zero;
        Vec2f size = Vec2f.zero;
        int tool = 0;
    }

    EditorView view;
}

private class Toolbox : Modal {
    private {
        ToolGroup _toolGroup;
        int _tool;
    }

    this() {
        setSize(Vec2f(200f, 100f));
        setAlign(UIAlignX.left, UIAlignY.top);
        setPosition(Vec2f(258f, 75f));

        {
            Label title = new Label("Outils", Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 8f));
            addUI(title);
        }

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.center, UIAlignY.top);
            hbox.setPosition(Vec2f(0f, 32f));
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

    void saveView() {
        view.tool = _toolGroup.value;
    }

    void loadView() {
        _toolGroup.value = view.tool;
    }
}

private final class ParameterWindow : UIElement {
    private {
        RessourceButton _textureSelect;
        IntegerField[] _clipFields, _marginFields, _countFields;
        IntegerField _frameTimeField;
        Checkbox _hasMaxCountCB;
        VList _tileFramesList;
    }

    this(string textureRID, Vec4u clip, uint columns, uint lines, bool hasMaxCount,
        uint maxCount, Vec2i margin, uint frameTime, Vec2i[] tileFrames) {
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

            _textureSelect = new RessourceButton(textureRID, "texture", [
                    "texture"
                ]);
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
            foreach (field; ["Marge X", "Marge Y"]) {
                IntegerField numField = new IntegerField();
                numField.addEventListener("value", {
                    dispatchEvent("property_misc", false);
                });
                _marginFields ~= numField;

                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(284f, 0f));
                vlist.addList(hlayout);

                hlayout.addUI(new Label(field ~ ":", Atelier.theme.font));
                hlayout.addUI(numField);
            }

            _marginFields[0].value = margin.x;
            _marginFields[1].value = margin.y;
        }

        {
            LabelSeparator sep = new LabelSeparator("Tuiles", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            foreach (field; ["Colonnes", "Lignes", "Limite"]) {
                IntegerField numField = new IntegerField();
                numField.setMinValue(0);
                numField.addEventListener("value", {
                    dispatchEvent("property_misc", false);
                });
                _countFields ~= numField;

                if (field == "Limite") {
                    numField.isEnabled = hasMaxCount;

                    _hasMaxCountCB = new Checkbox(hasMaxCount);
                    _hasMaxCountCB.addEventListener("value", {
                        dispatchEvent("property_misc", false);
                        numField.isEnabled = _hasMaxCountCB.value;
                    });

                    HLayout hlayout = new HLayout;
                    hlayout.setPadding(Vec2f(284f, 0f));
                    vlist.addList(hlayout);

                    hlayout.addUI(new Label("Limiter ?", Atelier.theme.font));
                    hlayout.addUI(_hasMaxCountCB);
                }

                {
                    HLayout hlayout = new HLayout;
                    hlayout.setPadding(Vec2f(284f, 0f));
                    vlist.addList(hlayout);

                    hlayout.addUI(new Label(field ~ ":", Atelier.theme.font));
                    hlayout.addUI(numField);
                }
            }

            _countFields[0].value = columns;
            _countFields[1].value = lines;
            _countFields[2].value = maxCount;
        }

        {
            LabelSeparator sep = new LabelSeparator("Tuiles Animées", Atelier.theme.font);
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

            hlayout.addUI(new Label("Délai inter-images:", Atelier.theme.font));

            _frameTimeField = new IntegerField();
            _frameTimeField.setMinValue(0);
            _frameTimeField.addEventListener("value", {
                dispatchEvent("property_misc", false);
            });
            hlayout.addUI(_frameTimeField);

            _frameTimeField.value = frameTime;
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Trames:", Atelier.theme.font));

            _tileFramesList = new VList;
            _tileFramesList.setSize(Vec2f(300f, 250f));

            AccentButton addBtn = new AccentButton("Ajouter");
            addBtn.addEventListener("click", {
                auto elt = new TileFrameElement(0, 0);
                _tileFramesList.addList(elt);
                elt.addEventListener("tileFrame", {
                    dispatchEvent("property_tileFrames", false);
                });
                dispatchEvent("property_tileFrames", false);
            });
            hlayout.addUI(addBtn);

            vlist.addList(_tileFramesList);

            foreach (tileFrame; tileFrames) {
                auto elt = new TileFrameElement(tileFrame.x, tileFrame.y);
                elt.addEventListener("tileFrame", {
                    dispatchEvent("property_tileFrames", false);
                });
                _tileFramesList.addList(elt);
            }
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });
    }

    string getTextureRID() const {
        return _textureSelect.getName();
    }

    Vec4u getClip() const {
        return Vec4u(_clipFields[0].value(), _clipFields[1].value(),
            _clipFields[2].value(), _clipFields[3].value());
    }

    void setClip(Vec4u clip) {
        Atelier.ui.blockEvents = true;
        _clipFields[0].value = clip.x;
        _clipFields[1].value = clip.y;
        _clipFields[2].value = clip.z;
        _clipFields[3].value = clip.w;
        Atelier.ui.blockEvents = false;
    }

    void getMisc(ref uint columns, ref uint lines, ref bool hasMaxCount,
        ref uint maxCount, ref Vec2i margin, ref uint frameTime) {
        columns = _countFields[0].value;
        lines = _countFields[1].value;
        maxCount = _countFields[2].value;
        hasMaxCount = _hasMaxCountCB.value;
        margin = Vec2i(_marginFields[0].value, _marginFields[1].value);
        frameTime = _frameTimeField.value;
    }

    Vec2i[] getTileFrames() {
        Vec2i[] tileFrames;
        TileFrameElement[] elements = cast(TileFrameElement[]) _tileFramesList.getList();
        foreach (TileFrameElement element; elements) {
            tileFrames ~= element.getFrame();
        }
        return tileFrames;
    }
}

final class TileFrameElement : UIElement {
    private {
        IntegerField _sourceTileField, _destTileField;
        DangerButton _removeBtn;
    }

    this(int sourceTileId, int destTileId) {
        setSize(Vec2f(300f, 48f));

        HBox hbox = new HBox;
        hbox.setAlign(UIAlignX.left, UIAlignY.center);
        hbox.setSpacing(8f);
        addUI(hbox);

        _sourceTileField = new IntegerField;
        _sourceTileField.value = sourceTileId;
        _sourceTileField.addEventListener("value", &_onTileChange);
        hbox.addUI(_sourceTileField);

        _destTileField = new IntegerField;
        _destTileField.value = destTileId;
        _destTileField.addEventListener("value", &_onTileChange);
        hbox.addUI(_destTileField);

        _removeBtn = new DangerButton("Retirer");
        _removeBtn.setAlign(UIAlignX.right, UIAlignY.center);
        _removeBtn.addEventListener("click", { _onTileChange(); removeUI(); });
        hbox.addUI(_removeBtn);
    }

    private void _onTileChange() {
        dispatchEvent("tileFrame", false);
    }

    Vec2i getFrame() {
        return Vec2i(_sourceTileField.value, _destTileField.value);
    }
}
