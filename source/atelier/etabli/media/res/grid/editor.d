module atelier.etabli.media.res.grid.editor;

import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.render;
import atelier.etabli.ui;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.editor;
import atelier.etabli.media.res.grid.gridmap;
import atelier.etabli.media.res.grid.toolbox;
import atelier.etabli.media.res.grid.parameter;
import atelier.etabli.media.res.grid.selection;

final class GridResourceEditor(T) : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        Vec2u _gridSize;
        Vec2f _position = Vec2f.zero;
        GridMap!T _gridmap;
        float _zoom = 1f;
        Vec2f _positionMouse = Vec2f.zero;
        Vec2f _deltaMouse = Vec2f.zero;
        Toolbox!T _toolbox;
        ParameterWindow _parameterWindow;
        int _tool;
        TilesSelection!T _selection;
        bool _isApplyingTool;
        GridMap!T _previewSelectionGM;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _name = ffd.get!string(0);

        if (ffd.hasNode("size")) {
            _gridSize = ffd.getNode("size").get!Vec2u(0);
        }
        _gridSize = _gridSize.max(Vec2u.one);

        _gridmap = new GridMap!T(_gridSize.x, _gridSize.y);
        addImage(_gridmap);

        if (ffd.hasNode("values")) {
            _gridmap.setValues(0, 0, ffd.getNode("values").get!(T[][])(0));
        }

        _parameterWindow = new ParameterWindow(_gridSize);

        _toolbox = new Toolbox!T();

        _parameterWindow.addEventListener("property_gradient", {
            // À FAIRE
        });

        _parameterWindow.addEventListener("property_size", {
            _gridSize = _parameterWindow.getGridSize();
            _gridmap.setSize(_gridSize.x, _gridSize.y);
            _gridmap.size = Vec2f(32f * _gridmap.columns, 32f * _gridmap.lines) * _zoom;
            setDirty();
        });

        addEventListener("gridSize", {
            _parameterWindow.setGridSize(_gridSize);
            setDirty();
        });

        _toolbox.addEventListener("tool", { _tool = _toolbox.getTool(); });
        addEventListener("register", { Atelier.ui.addUI(_toolbox); });
        addEventListener("unregister", { _toolbox.removeUI(); });

        addEventListener("update", &_onUpdate);
        addEventListener("draw", &_onDraw);
        addEventListener("wheel", &_onWheel);
        addEventListener("mousedown", &_onMouseDown);
        addEventListener("mouseup", &_onMouseUp);
        addEventListener("mouseleave", &_onMouseLeave);
        addEventListener("clickoutside", &_onMouseLeave);
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("grid");
        node.add(_name);
        static if (is(T == float)) {
            node.add("type").add("float");
        }
        else static if (is(T == uint)) {
            node.add("type").add("uint");
        }
        else static if (is(T == int)) {
            node.add("type").add("int");
        }
        else static if (is(T == bool)) {
            node.add("type").add("bool");
        }
        else
            static assert(false);
        node.addNode("size").add(_gridSize);
        node.addNode("values").add(_gridmap.getValues());
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    private void _onUpdate() {
        _gridmap.position = getCenter() + _position;
    }

    bool hasControlModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightControl);
    }

    bool hasShiftModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftShift) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightShift);
    }

    bool hasAltModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftAlt) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightAlt);
    }

    private void _onMouseLeave() {
        _isApplyingTool = false;
        _positionMouse = Vec2f.zero;
        _deltaMouse = Vec2f.zero;
        removeEventListener("mousemove", &_onDrag);
        removeEventListener("mousemove", &_onCopySelectionTool);
        removeEventListener("mousemove", &_onPasteSelectionTool);
        removeEventListener("mousemove", &_onCopyBrushTool);
        removeEventListener("mousemove", &_onPasteBrushTool);
        removeEventListener("mousemove", &_onElevatorTool);
    }

    private void _onMouseDown() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case right:
            addEventListener("mousemove", &_onDrag);
            break;
        case left:
            _isApplyingTool = true;
            switch (_tool) {
            case 0:
                _positionMouse = (getMousePosition() - (_gridmap.position - _gridmap.size / 2f)) / _zoom;
                if (hasControlModifier()) {
                    addEventListener("mousemove", &_onCopySelectionTool);
                    _onCopySelectionTool();
                }
                else {
                    addEventListener("mousemove", &_onPasteSelectionTool);
                    _onPasteSelectionTool();
                }
                break;
            case 1:
                _positionMouse = (getMousePosition() - (_gridmap.position - _gridmap.size / 2f)) / _zoom;
                if (hasControlModifier()) {
                    addEventListener("mousemove", &_onCopyBrushTool);
                    _onCopyBrushTool();
                }
                else {
                    addEventListener("mousemove", &_onPasteBrushTool);
                    _onPasteBrushTool();
                }
                break;
            case 2:
                _positionMouse = (getMousePosition() - (_gridmap.position - _gridmap.size / 2f)) / _zoom;
                Vec2i tilePos = getTilePos();
                _fillTilesAt(tilePos.x, tilePos.y, _toolbox.getBrushValue());
                break;
            case 3:
                _positionMouse = (getMousePosition() - (_gridmap.position - _gridmap.size / 2f)) / _zoom;
                addEventListener("mousemove", &_onElevatorTool);
                _onElevatorTool();
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
            _isApplyingTool = false;
            switch (_tool) {
            case 0:
                removeEventListener("mousemove", &_onCopySelectionTool);
                removeEventListener("mousemove", &_onPasteSelectionTool);
                _positionMouse = Vec2f.zero;
                break;
            case 1:
                removeEventListener("mousemove", &_onCopyBrushTool);
                removeEventListener("mousemove", &_onPasteBrushTool);
                _positionMouse = Vec2f.zero;
                break;
            case 3:
                removeEventListener("mousemove", &_onElevatorTool);
                _positionMouse = Vec2f.zero;
                break;
            default:
                break;
            }
            break;

        default:
            break;
        }
    }

    private Vec4i getSelectionRect() {
        Vec2f endPositionMouse = (getMousePosition() - (_gridmap.position - _gridmap.size / 2f)) / _zoom;

        Vec2i pos1 = (cast(Vec2i) _positionMouse) / Vec2i(32, 32);
        Vec2i pos2 = (cast(Vec2i) endPositionMouse) / Vec2i(32, 32);

        pos1 = pos1.clamp(Vec2i.zero, Vec2i(_gridmap.columns, _gridmap.lines) - 1);
        pos2 = pos2.clamp(Vec2i.zero, Vec2i(_gridmap.columns, _gridmap.lines) - 1);

        Vec2i startPos = pos1.min(pos2);
        Vec2i endPos = pos1.max(pos2);

        return Vec4i(startPos, endPos);
    }

    private void _onCopySelectionTool() {
        Vec4i rect = getSelectionRect();
        Vec2i startPos = rect.xy;
        Vec2i endPos = rect.zw;

        int width_ = endPos.x + 1 - startPos.x;
        int height_ = endPos.y + 1 - startPos.y;

        _selection.width = width_;
        _selection.height = height_;
        _selection.tiles = new T[][](width_, height_);

        for (int iy; iy < height_; ++iy) {
            for (int ix; ix < width_; ++ix) {
                _selection.tiles[ix][iy] = _gridmap.getValue(startPos.x + ix, startPos.y + iy);
            }
        }
        _selection.isValid = true;

        updateSelectionPreview();
    }

    private void updateSelectionPreview() {
        if (_previewSelectionGM) {
            _previewSelectionGM.remove();
        }

        _previewSelectionGM = new GridMap!T(_selection.width, _selection.height);
        _previewSelectionGM.setValues(0, 0, _selection.tiles);
        _previewSelectionGM.anchor = Vec2f.zero;
        _previewSelectionGM.isVisible = false;
        addImage(_previewSelectionGM);
    }

    private void _onPasteSelectionTool() {
        Vec2f endPositionMouse = (getMousePosition() - (_gridmap.position - _gridmap.size / 2f)) / _zoom;
        Vec2i tilePos = (cast(Vec2i) endPositionMouse) / Vec2i(32, 32);
        tilePos = tilePos.clamp(Vec2i.zero, Vec2i(_gridmap.columns, _gridmap.lines));

        if (_selection.isValid) {
            _gridmap.setValues(tilePos.x, tilePos.y, _selection.tiles);
            setDirty();
        }
    }

    private Vec2i getTilePos() {
        Vec2f mousePos = (getMousePosition() - (_gridmap.position - _gridmap.size / 2f)) / _zoom;
        Vec2i tilePos = (cast(Vec2i) mousePos) / Vec2i(32, 32);
        tilePos = tilePos.clamp(Vec2i.zero, Vec2i(_gridmap.columns, _gridmap.lines) - 1);
        return tilePos;
    }

    private void _onCopyBrushTool() {
        Vec2i tilePos = getTilePos();
        _toolbox.setBrushValue(_gridmap.getValue(tilePos.x, tilePos.y));
    }

    private void _pasteBrushTool(T value) {
        int brushSize = _toolbox.getBrushSize();
        Vec2i tilePos = getTilePos();

        int offset = brushSize & 0x1;
        Vec2i startTile = tilePos - ((brushSize >> 1) + offset);
        float brushSize2 = (brushSize / 2f) - (offset ? 0.5f : 0f);
        Vec2f center = (cast(Vec2f) tilePos) - (offset ? Vec2f.zero : Vec2f.half);

        static if (is(T == float) || is(T == uint) || is(T == int)) {
            T stepValue = _toolbox.getBrushStep();
            bool soften = _toolbox.getBrushSoften();
            SplineFunc splineFunc = getSplineFunc(_toolbox.getBrushSpline());

            for (int y; y <= brushSize + offset; ++y) {
                for (int x; x <= brushSize + offset; ++x) {
                    Vec2i tile = startTile + Vec2i(x, y);
                    float dist = (cast(Vec2f) tile).distance(center);
                    if (tile.x < 0 || tile.y < 0 || tile.x >= _gridmap.columns ||
                        tile.y >= _gridmap.lines || dist > brushSize2)
                        continue;

                    if (soften) {
                        T tileValue = _gridmap.getValue(tile.x, tile.y);

                        static if (is(T == uint) || is(T == int)) {
                            import std.math : ceil;

                            tileValue = cast(T) ceil(lerp(cast(double) value,
                                    cast(double) tileValue, splineFunc(dist / brushSize2)));
                        }
                        else {
                            tileValue = lerp(value, tileValue, splineFunc(dist / brushSize2));
                        }
                        _gridmap.setValue(tile.x, tile.y, tileValue);
                    }
                    else {
                        _gridmap.setValue(tile.x, tile.y, value);
                    }
                }
            }
        }
        else static if (is(T == bool)) {
            for (int y; y <= brushSize + offset; ++y) {
                for (int x; x <= brushSize + offset; ++x) {
                    Vec2i tile = startTile + Vec2i(x, y);
                    if (tile.x < 0 || tile.y < 0 || tile.x >= _gridmap.columns ||
                        tile.y >= _gridmap.lines || (cast(Vec2f) tile).distance(center) > brushSize2)
                        continue;
                    _gridmap.setValue(tile.x, tile.y, value);
                }
            }
        }
        setDirty();
    }

    private void _onPasteBrushTool() {
        _pasteBrushTool(_toolbox.getBrushValue());
    }

    private void _onElevatorTool() {
        static if (is(T == float) || is(T == uint) || is(T == int)) {
            int brushSize = _toolbox.getBrushSize();
            T stepValue = _toolbox.getBrushStep();
            bool soften = _toolbox.getBrushSoften();
            SplineFunc splineFunc = getSplineFunc(_toolbox.getBrushSpline());

            Vec2i tilePos = getTilePos();
            int offset = brushSize & 0x1;
            Vec2i startTile = tilePos - ((brushSize >> 1) + offset);
            float brushSize2 = (brushSize / 2f) - (offset ? 0.5f : 0f);
            Vec2f center = (cast(Vec2f) tilePos) - (offset ? Vec2f.zero : Vec2f.half);

            for (int y; y <= brushSize + offset; ++y) {
                for (int x; x <= brushSize + offset; ++x) {
                    Vec2i tile = startTile + Vec2i(x, y);
                    float dist = (cast(Vec2f) tile).distance(center);

                    if (tile.x < 0 || tile.y < 0 || tile.x >= _gridmap.columns ||
                        tile.y >= _gridmap.lines || dist > brushSize2)
                        continue;
                    T value = _gridmap.getValue(tile.x, tile.y);
                    if (soften) {
                        value += cast(T)(stepValue * splineFunc(1f - (dist / brushSize2)));
                    }
                    else {
                        value += stepValue;
                    }
                    _gridmap.setValue(tile.x, tile.y, value);
                }
            }
            setDirty();
        }
    }

    private void _fillTilesAt(int x, int y, T value) {
        Vec2i[] getNeighbors(ref Vec2i tile) {
            Vec2i[] neighbors;
            if (tile.x > 0)
                neighbors ~= Vec2i(tile.x - 1, tile.y);
            if (tile.x + 1 < _gridmap.columns)
                neighbors ~= Vec2i(tile.x + 1, tile.y);
            if (tile.y > 0)
                neighbors ~= Vec2i(tile.x, tile.y - 1);
            if (tile.y + 1 < _gridmap.lines)
                neighbors ~= Vec2i(tile.x, tile.y + 1);
            return neighbors;
        }

        x = clamp(x, 0, _gridmap.columns - 1);
        y = clamp(y, 0, _gridmap.lines - 1);

        const T valueToReplace = _gridmap.getValue(x, y);

        if (valueToReplace == value)
            return;

        Vec2i[] frontiers;
        frontiers ~= Vec2i(x, y);
        _gridmap.setValue(x, y, value);

        static if (is(T == float) || is(T == uint) || is(T == int)) {
            T tolerance = _toolbox.getBrushTolerance();
            T valueMin = valueToReplace - tolerance;
            T valueMax = valueToReplace + tolerance;

            static if (is(T == uint)) {
                if (valueToReplace < tolerance) {
                    valueMin = 0;
                }
            }
        }

        while (frontiers.length) {
            Vec2i current = frontiers[0];
            frontiers = frontiers[1 .. $];

            foreach (ref neighbor; getNeighbors(current)) {
                T neighborValue = _gridmap.getValue(neighbor.x, neighbor.y);
                static if (is(T == float) || is(T == uint) || is(T == int)) {
                    if (neighborValue == value || neighborValue > valueMax ||
                        neighborValue < valueMin)
                        continue;
                }
                else static if (is(T == bool)) {
                    if (neighborValue != valueToReplace)
                        continue;
                }

                /*if (_gridmap.getValue(neighbor.x, neighbor.y) != valueToReplace)
                    continue;*/
                _gridmap.setValue(neighbor.x, neighbor.y, value);
                frontiers ~= neighbor;
            }
        }
        setDirty();
    }

    private void _onDrag() {
        UIManager manager = getManager();
        InputEvent.MouseMotion ev = manager.input.asMouseMotion();
        _position += ev.deltaPosition;
    }

    private void _onDraw() {
        Atelier.renderer.drawRect(_gridmap.position - _gridmap.size / 2f,
            _gridmap.size, Atelier.theme.onNeutral, 1f, false);

        if (_previewSelectionGM) {
            _previewSelectionGM.isVisible = false;
        }

        switch (_tool) {
        case 0:
            if (hasControlModifier()) {
                if (_isApplyingTool) {
                    Vec4i rect = getSelectionRect();
                    Vec2i startPos = rect.xy;
                    Vec2i endPos = rect.zw;

                    Vec2f origin = _gridmap.position - _gridmap.size / 2f;
                    Atelier.renderer.drawRect(origin + (cast(Vec2f) startPos) * _gridmap.tileSize,
                        cast(Vec2f)(endPos + 1 - startPos) * _gridmap.tileSize,
                        Atelier.theme.danger, 1f, false);
                }
            }
            else {
                if (_selection.isValid) {
                    Vec2f positionMouse = (
                        getMousePosition() - (_gridmap.position - _gridmap.size / 2f)) / _zoom;
                    Vec2i pos = (cast(Vec2i) positionMouse) / Vec2i(32, 32);

                    Vec2f origin = _gridmap.position - _gridmap.size / 2f;

                    if (_previewSelectionGM) {
                        _previewSelectionGM.isVisible = true;
                        _previewSelectionGM.size = Vec2f(_selection.width,
                            _selection.height) * _gridmap.tileSize;
                        _previewSelectionGM.position = origin + (cast(Vec2f) pos) *
                            _gridmap.tileSize;
                    }

                    Atelier.renderer.drawRect(origin + (cast(Vec2f) pos) * _gridmap.tileSize,
                        Vec2f(_selection.width, _selection.height) * _gridmap.tileSize, _isApplyingTool ?
                            Atelier.theme.accent : Atelier.theme.onAccent, 1f, false);
                }
            }
            break;
        default:
            break;
        }

        /*Vec4f clip = _zoom * cast(Vec4f) _clip;
        Atelier.renderer.drawRect(_gridmap.position - _gridmap.size / 2f + clip.xy,
            clip.zw, Atelier.theme.accent, 1f, false);*/
    }

    private void _onWheel() {
        UIManager manager = getManager();
        InputEvent.MouseWheel ev = manager.input.asMouseWheel();
        float zoomDelta = 1f + (ev.wheel.sum() * 0.25f);
        _zoom *= zoomDelta;

        Vec2f mouseOffset = getMousePosition() - getCenter();
        Vec2f delta = (mouseOffset - _position) / _gridmap.size;
        _gridmap.size = Vec2f(32f * _gridmap.columns, 32f * _gridmap.lines) * _zoom;
        Vec2f delta2 = (mouseOffset - _position) / _gridmap.size;

        _position += (delta2 - delta) * _gridmap.size;
    }
}
