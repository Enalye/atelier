/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editors.texteditor;

import std.algorithm.mutation;
import std.array;
import std.ascii;
import std.conv : to;
import std.file;
import std.math;
import std.stdio;
import std.string;
import std.typecons;
import atelier;
import studio.editors.base;
import atelier.core.data.vera;

Font font;

final class TextEditor : ContentEditor {
    private {
        Surface _linesSurface;
        UIElement _textContainer;
        Line[] _lines;
        Label[] _lineCountLabels;
        Label[] _lineTextLabels;
        uint _borderX = 10;
        uint _borderY = 5;
        uint _startLine = 0;
        uint _endLine = 0;
        uint _startColumn = 0;
        uint _endColumn = 0;
        uint _currentLine, _currentColumn, _maxColumn;
        uint _selectionLine, _selectionColumn;
        uint charSize = 0;

        // Historique
        bool _isHistoryEnabled = true;
        TextState _currentState;
        TextState[] _prevStates, _nextStates;
        bool _isInsertingText = false;

        // Couleurs
        Color _cursorColor;
        Color _cursorSelectionColor;
        Color _selectionColor;
        Color _currentLineColor;
        Color _stepLineColor;
        Color _otherLineColor;
        Color _columnBarColor;
        Color _lineBarColor;
    }

    this(string path_, Vec2f windowSize) {
        super(path_, windowSize);

        font = TrueTypeFont.fromMemory(veraMonoFontData, 16);
        charSize = font.getGlyph('a').advance();

        auto file = File(path_);
        foreach (textLine; file.byLine) {
            Line line = new Line;
            line.setText(to!dstring(textLine.chomp()));
            _lines ~= line;
        }

        _linesSurface = new Surface;
        _linesSurface.setAlign(UIAlignX.left, UIAlignY.top);
        _linesSurface.setSize(Vec2f(64f, getHeight()));
        addUI(_linesSurface);

        _textContainer = new UIElement;
        _textContainer.focusable = true;
        _textContainer.setAlign(UIAlignX.right, UIAlignY.top);

        _textContainer.setSize(Vec2f(getWidth() - 64f, getHeight()));
        addUI(_textContainer);

        _textContainer.addEventListener("wheel", &_onWheel);
        _textContainer.addEventListener("mousedown", &_onMouseDown);
        _textContainer.addEventListener("mouserelease", &_onMouseRelease);
        _textContainer.addEventListener("text", &_onText);
        _textContainer.addEventListener("key", &_onKey);
        addEventListener("draw", &_onDraw);
        addEventListener("size", &updateLines);

        float accentHue = HSLColor.fromColor(Atelier.theme.accent).h;

        _cursorColor = HSLColor(accentHue, 1f, 0.4f).toColor();
        _selectionColor = HSLColor(accentHue + 120f, 1f, 0.4f).toColor();
        _cursorSelectionColor = HSLColor(accentHue - 120f, 1f, 0.4f).toColor();
        _currentLineColor = HSLColor(accentHue, 0.25f, 1f).toColor();
        _stepLineColor = HSLColor(accentHue, 0.13f, 0.77f).toColor();
        _otherLineColor = HSLColor(accentHue, 0.05f, 0.4f).toColor();
        _columnBarColor = HSLColor(accentHue, 0.03f, 0.18f).toColor();
        _lineBarColor = HSLColor(accentHue, 0.03f, 0.25f).toColor();

        updateLines();
    }

    private uint _getMouseLine() {
        uint line = cast(uint)(_textContainer.getMousePosition().y / font.lineSkip());
        line += _startLine;

        if (line >= _lines.length) {
            line = _lines.length > 0 ? (cast(uint) _lines.length) - 1 : 0;
        }
        return line;
    }

    private uint _getMouseColumn(uint line) {
        if (line >= _lines.length)
            return 0;

        uint maxLength = getLineLength(line);
        uint column = cast(uint)(_textContainer.getMousePosition().x / charSize);
        column += _startColumn;

        if (column > maxLength) {
            column = maxLength;
        }

        return column;
    }

    private void _onWheel() {
        _isInsertingText = false;

        int step = 1;
        if (hasControlModifier())
            step = 4;

        Vec2i delta = getManager().input().asMouseWheel().wheel;
        if (delta.sum() > 0) {
            _moveUp(step);
        }
        else {
            _moveDown(step);
        }

        if (!hasShiftModifier()) {
            _selectionLine = _currentLine;
            _selectionColumn = _currentColumn;
        }
        updateLines();
    }

    private void _onMouseDown() {
        uint line = _getMouseLine();
        uint column = _getMouseColumn(_currentLine);

        if (line != _currentLine || column != _currentColumn) {
            _currentLine = line;
            _currentColumn = column;
            _selectionLine = _currentLine;
            _selectionColumn = _currentColumn;
            _maxColumn = _currentColumn;
            updateLines();
        }
        addEventListener("mousemove", &_onMouseMove);
    }

    private void _onMouseRelease() {
        removeEventListener("mousemove", &_onMouseMove);
    }

    private void _onMouseMove() {
        if (!_textContainer.hasFocus())
            return;

        uint line = _getMouseLine();
        uint column = _getMouseColumn(_currentLine);

        if (line != _currentLine || column != _currentColumn) {
            _currentLine = line;
            _currentColumn = column;
            _maxColumn = _currentColumn;
            updateLines();
        }
    }

    private void _onDraw() {
        uint textWindowHeight = cast(uint)(getHeight() / font.lineSkip());
        uint textWindowWidth = cast(uint)(_textContainer.getWidth() / charSize);
        uint lineOffset = _currentLine - _startLine;
        uint columnOffset = _currentColumn - _startColumn;

        if (columnOffset > _lines[_currentLine].getLength())
            columnOffset = cast(uint) _lines[_currentLine].getLength();

        Atelier.renderer.drawRect(Vec2f(64f + columnOffset * charSize, 0f),
            Vec2f(charSize, getHeight()), _columnBarColor, 1f, true);

        Atelier.renderer.drawRect(Vec2f(64f, lineOffset * font.lineSkip()),
            Vec2f(getWidth(), font.lineSkip()), _lineBarColor, 1f, true);

        if (hasSelection()) {
            void drawSelectionLine(uint line, uint start, uint end) {
                if (_startLine > line || line > _startLine + textWindowHeight)
                    return;

                uint selectionLineOffset = line - _startLine;

                long selectionStart, selectionWidth;
                selectionStart = start;
                selectionStart -= _startColumn;

                selectionWidth = cast(long) end - cast(long) start;

                if (selectionStart < 0) {
                    selectionWidth += selectionStart;
                    selectionStart = 0;
                }
                if (selectionWidth > textWindowWidth) {
                    selectionWidth = textWindowWidth;
                }

                Atelier.renderer.drawRect(Vec2f(64f + selectionStart * charSize,
                        selectionLineOffset * font.lineSkip()), Vec2f(selectionWidth * charSize,
                        font.lineSkip()), _selectionColor, 1f, true);
            }

            if (_selectionLine == _currentLine) {
                drawSelectionLine(_currentLine, min(_selectionColumn,
                        _currentColumn), max(_selectionColumn, _currentColumn));
            }
            else if (_selectionLine < _currentLine) {
                drawSelectionLine(_selectionLine, _selectionColumn,
                    cast(uint) _lines[_selectionLine].getLength());
                for (uint i = _selectionLine + 1; i < _currentLine; ++i) {
                    drawSelectionLine(i, 0, cast(uint) _lines[i].getLength());
                }
                drawSelectionLine(_currentLine, 0, _currentColumn);
            }
            else if (_currentLine < _selectionLine) {
                drawSelectionLine(_currentLine, _currentColumn,
                    cast(uint) _lines[_currentLine].getLength());
                for (uint i = _currentLine + 1; i < _selectionLine; ++i) {
                    drawSelectionLine(i, 0, cast(uint) _lines[i].getLength());
                }
                drawSelectionLine(_selectionLine, 0, _selectionColumn);
            }
        }

        Color cursorColor = _cursorColor;
        if (hasSelection()) {
            if (_currentLine == _selectionLine && _currentColumn < _selectionColumn)
                cursorColor = _cursorSelectionColor;
            else if (_currentLine < _selectionLine)
                cursorColor = _cursorSelectionColor;
        }

        Atelier.renderer.drawRect(Vec2f(64f + columnOffset * charSize,
                lineOffset * font.lineSkip()), Vec2f(charSize,
                font.lineSkip()), cursorColor, 1f, true);
    }

    private void _onText() {
        bool isInsertingText = _isInsertingText;
        if (!_isInsertingText) {
            startState();
            setStateRegion(_currentLine);
        }

        string text = getManager().input.asTextInput().text;
        insertText(to!dstring(text));

        if (!isInsertingText) {
            endState();
            _isInsertingText = true;
        }

        updateLines();
    }

    private void _onKey() {
        InputEvent event = getManager().input;

        if (event.isPressed()) {
            InputEvent.KeyButton keyEvent = event.asKeyButton();
            switch (keyEvent.layout) with (InputEvent.KeyButton.Button) {
            case "Up":
                _isInsertingText = false;

                int step = 1;
                if (hasControlModifier())
                    step = 4;

                if (hasSelection()) {
                    if (!hasShiftModifier()) {
                        if (_currentLine == _selectionLine) {
                            uint minColumn = min(_selectionColumn, _currentColumn);
                            _selectionColumn = minColumn;
                            _currentColumn = minColumn;
                        }
                        else {
                            uint minLine = min(_selectionLine, _currentLine);
                            if (minLine == _currentLine) {
                                _selectionLine = minLine;
                                _selectionColumn = _currentColumn;
                            }
                            else {
                                _currentLine = minLine;
                                _currentColumn = _selectionColumn;
                            }
                        }
                    }
                    else {
                        _moveUp(step);
                    }
                }
                else {
                    _moveUp(step);

                    if (!hasShiftModifier()) {
                        _selectionLine = _currentLine;
                        _selectionColumn = _currentColumn;
                    }
                }
                break;
            case "Down":
                _isInsertingText = false;

                int step = 1;
                if (hasControlModifier())
                    step = 4;

                if (hasSelection()) {
                    if (!hasShiftModifier()) {
                        if (_currentLine == _selectionLine) {
                            uint minColumn = max(_selectionColumn, _currentColumn);
                            _selectionColumn = minColumn;
                            _currentColumn = minColumn;
                        }
                        else {
                            uint minLine = max(_selectionLine, _currentLine);
                            if (minLine == _currentLine) {
                                _selectionLine = minLine;
                                _selectionColumn = _currentColumn;
                            }
                            else {
                                _currentLine = minLine;
                                _currentColumn = _selectionColumn;
                            }
                        }
                    }
                    else {
                        _moveDown(step);
                    }
                }
                else {
                    _moveDown(step);

                    if (!hasShiftModifier()) {
                        _selectionLine = _currentLine;
                        _selectionColumn = _currentColumn;
                    }
                }
                break;
            case "Left":
                _isInsertingText = false;

                if (hasSelection()) {
                    if (!hasShiftModifier()) {
                        if (_currentLine == _selectionLine) {
                            uint minColumn = min(_selectionColumn, _currentColumn);
                            _selectionColumn = minColumn;
                            _currentColumn = minColumn;
                        }
                        else {
                            uint minLine = min(_selectionLine, _currentLine);
                            if (minLine == _currentLine) {
                                _selectionLine = minLine;
                                _selectionColumn = _currentColumn;
                            }
                            else {
                                _currentLine = minLine;
                                _currentColumn = _selectionColumn;
                            }
                        }
                    }
                    else {
                        if (hasControlModifier())
                            _moveWordBorder(-1);
                        else
                            _moveLeft();
                    }
                }
                else {
                    if (hasControlModifier())
                        _moveWordBorder(-1);
                    else
                        _moveLeft();

                    if (!hasShiftModifier()) {
                        _selectionLine = _currentLine;
                        _selectionColumn = _currentColumn;
                    }
                }
                break;
            case "Right":
                _isInsertingText = false;

                if (hasSelection()) {
                    if (!hasShiftModifier()) {
                        if (_currentLine == _selectionLine) {
                            uint minColumn = max(_selectionColumn, _currentColumn);
                            _selectionColumn = minColumn;
                            _currentColumn = minColumn;
                        }
                        else {
                            uint minLine = max(_selectionLine, _currentLine);
                            if (minLine == _currentLine) {
                                _selectionLine = minLine;
                                _selectionColumn = _currentColumn;
                            }
                            else {
                                _currentLine = minLine;
                                _currentColumn = _selectionColumn;
                            }
                        }
                    }
                    else {
                        if (hasControlModifier())
                            _moveWordBorder(1);
                        else
                            _moveRight();
                    }
                }
                else {
                    if (hasControlModifier())
                        _moveWordBorder(1);
                    else
                        _moveRight();

                    if (!hasShiftModifier()) {
                        _selectionLine = _currentLine;
                        _selectionColumn = _currentColumn;
                    }
                }
                break;
            case "Home":
                _isInsertingText = false;

                _moveLineBorder(-1);
                if (!hasShiftModifier()) {
                    _selectionLine = _currentLine;
                    _selectionColumn = _currentColumn;
                }
                break;
            case "End":
                _isInsertingText = false;

                _moveLineBorder(1);
                if (!hasShiftModifier()) {
                    _selectionLine = _currentLine;
                    _selectionColumn = _currentColumn;
                }
                break;
            case "PageUp":
                _isInsertingText = false;

                _moveFileBorder(-1);
                if (!hasShiftModifier()) {
                    _selectionLine = _currentLine;
                    _selectionColumn = _currentColumn;
                }
                break;
            case "PageDown":
                _isInsertingText = false;

                _moveFileBorder(1);
                if (!hasShiftModifier()) {
                    _selectionLine = _currentLine;
                    _selectionColumn = _currentColumn;
                }
                break;
            case "Return":
            case "Keypad Enter":
                startState();
                _removeSelection(0);
                setStateRegion(_currentLine);
                addAction(TextState.Type.update);
                dstring endLine = _lines[_currentLine].getText(_currentColumn,
                    getLineLength(_currentLine));
                _lines[_currentLine].removeAt(_currentColumn, getLineLength(_currentLine));
                _currentLine++;
                _selectionLine = _currentLine;
                _currentColumn = 0;
                _selectionColumn = 0;
                _maxColumn = 0;
                addAction(TextState.Type.add);
                insertLine(_currentLine, endLine);
                endState();
                break;
            case "Delete":
                startState();
                _removeSelection(1);
                endState();
                break;
            case "Backspace":
                startState();
                _removeSelection(-1);
                endState();
                break;
            case "C":
                if (hasControlModifier()) {
                    if (hasSelection()) {
                        Atelier.input.setClipboard(to!string(getSelection()));
                    }
                    else {
                        Atelier.input.setClipboard(
                            to!string(_lines[_currentLine].getText() ~ "\n"));
                    }
                }
                break;
            case "X":
                if (hasControlModifier()) {
                    startState();
                    if (hasSelection()) {
                        Atelier.input.setClipboard(to!string(getSelection()));
                        _removeSelection(0);
                    }
                    else {
                        Atelier.input.setClipboard(
                            to!string(_lines[_currentLine].getText() ~ "\n"));

                        setStateRegion(_currentLine);
                        addAction(TextState.Type.remove);
                        removeLine(_currentLine);
                        _currentColumn = 0;
                        _selectionColumn = 0;
                        _maxColumn = 0;
                    }
                    endState();
                }
                break;
            case "V":
                if (hasControlModifier()) {
                    if (Atelier.input.hasClipboard()) {
                        startState();
                        insertText(to!dstring(Atelier.input.getClipboard()));
                        endState();
                    }
                }
                break;
            case "Z":
                if (hasControlModifier()) {
                    undoHistory();
                }
                break;
            case "Y":
                if (hasControlModifier()) {
                    redoHistory();
                }
                break;
            default:
                break;
            }
        }

        updateLines();
    }

    private void updateLines() {
        _linesSurface.setHeight(getHeight());
        _textContainer.setSize(Vec2f(getWidth() - 64f, getHeight()));

        uint textWindowHeight = cast(uint)(getHeight() / font.lineSkip());
        uint halfTextWindowHeight = textWindowHeight >> 1;

        if ((_borderY << 1) >= textWindowHeight) {
            if (halfTextWindowHeight > _currentLine) {
                _startLine = 0;
            }
            else {
                _startLine = _currentLine - halfTextWindowHeight;
            }

            if (_startLine + textWindowHeight > _lines.length) {
                _endLine = cast(uint) _lines.length;
            }
            else {
                _endLine = _startLine + textWindowHeight;
            }
        }
        else if (_startLine + _borderY > _currentLine) {
            if (_currentLine < _borderY) {
                _startLine = 0;
            }
            else {
                _startLine = _currentLine - _borderY;
            }
            _endLine = _startLine + textWindowHeight;
        }
        else if (_currentLine + _borderY > _endLine) {
            if (_currentLine + _borderY >= _lines.length) {
                _endLine = cast(uint) _lines.length;
            }
            else {
                _endLine = _currentLine + _borderY;
            }
            _startLine = _endLine - textWindowHeight;
        }

        uint actualTextWindowHeight = cast(uint)(cast(long) _endLine - cast(long) _startLine);

        uint textWindowWidth = cast(uint)(_textContainer.getWidth() / charSize);
        uint halfTextWindowWidth = textWindowWidth >> 1;

        if ((_borderX << 1) >= textWindowWidth) {
            if (halfTextWindowWidth > _currentColumn) {
                _startColumn = 0;
            }
            else {
                _startColumn = _currentColumn - halfTextWindowWidth;
            }

            _endColumn = _startColumn + textWindowWidth;
        }
        else if (_startColumn + _borderX > _currentColumn) {
            if (_currentColumn < _borderX) {
                _startColumn = 0;
            }
            else {
                _startColumn = _currentColumn - _borderX;
            }
            _endColumn = _startColumn + textWindowWidth;
        }
        else if (_currentColumn + _borderX > _endColumn) {
            _endColumn = _currentColumn + _borderX;
            _startColumn = _endColumn - textWindowWidth;
        }

        if (actualTextWindowHeight > _lineCountLabels.length) {
            for (size_t i = _lineCountLabels.length; i < actualTextWindowHeight; ++i) {
                Label lineCountLabel = new Label("", font);
                lineCountLabel.setAlign(UIAlignX.right, UIAlignY.top);
                lineCountLabel.setPosition(Vec2f(16f, font.lineSkip() * i));
                _lineCountLabels ~= lineCountLabel;
                _linesSurface.addUI(lineCountLabel);
            }
        }
        else if (actualTextWindowHeight < _lineCountLabels.length) {
            for (size_t i = actualTextWindowHeight; i < _lineCountLabels.length; ++i) {
                _lineCountLabels[i].remove();
            }
            _lineCountLabels.length = actualTextWindowHeight;
        }

        if (actualTextWindowHeight > _lineTextLabels.length) {
            for (size_t i = _lineTextLabels.length; i < actualTextWindowHeight; ++i) {
                Label lineTextLabel = new Label("", font);
                lineTextLabel.setAlign(UIAlignX.left, UIAlignY.top);
                lineTextLabel.setPosition(Vec2f(0f, font.lineSkip() * i));
                _lineTextLabels ~= lineTextLabel;
                _textContainer.addUI(lineTextLabel);
            }
        }
        else if (actualTextWindowHeight < _lineTextLabels.length) {
            for (size_t i = actualTextWindowHeight; i < _lineTextLabels.length; ++i) {
                _lineTextLabels[i].remove();
            }
            _lineTextLabels.length = actualTextWindowHeight;
        }

        size_t index;
        for (size_t line = _startLine; line < _endLine; line++) {
            long lineCount = 0;
            if (_currentLine == line) {
                lineCount = _currentLine;
                _lineCountLabels[index].color = _currentLineColor;
                _lineCountLabels[index].setAlign(UIAlignX.center, UIAlignY.top);
                _lineCountLabels[index].setPosition(Vec2f(0f,
                        _lineCountLabels[index].getPosition().y));
            }
            else {
                _lineCountLabels[index].setPosition(Vec2f(16f,
                        _lineCountLabels[index].getPosition().y));
                if (abs((cast(long) _currentLine) - cast(long) line) % 4 == 0) {
                    _lineCountLabels[index].color = _stepLineColor;
                }
                else {
                    _lineCountLabels[index].color = _otherLineColor;
                }

                lineCount = cast(long) line - cast(long) _currentLine;
                _lineCountLabels[index].setAlign(UIAlignX.right, UIAlignY.top);
            }
            _lineCountLabels[index].text = to!string(lineCount);
            _lineTextLabels[index].text = to!string(_lines[line].getText(_startColumn, _endColumn));
            index++;
        }
    }

    bool hasControlModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightControl);
    }

    bool hasShiftModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftShift) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightShift);
    }

    bool hasSelection() const {
        return _selectionLine != _currentLine || _selectionColumn != _currentColumn;
    }

    void _moveUp(int step) {
        if (_currentLine > step)
            _currentLine -= step;
        else
            _currentLine = 0;

        if (_currentColumn < _maxColumn) {
            _currentColumn = _maxColumn;
        }
        if (_currentColumn >= _lines[_currentLine].getLength()) {
            _currentColumn = cast(uint) _lines[_currentLine].getLength();
        }
    }

    void _moveDown(int step) {
        if (_currentLine + step + 1 < _lines.length)
            _currentLine += step;
        else
            _currentLine = (cast(uint) _lines.length) - 1;

        if (_currentColumn < _maxColumn) {
            _currentColumn = _maxColumn;
        }
        if (_currentColumn >= _lines[_currentLine].getLength()) {
            _currentColumn = cast(uint) _lines[_currentLine].getLength();
        }
    }

    void _moveLeft() {
        if (_currentColumn > _lines[_currentLine].getLength())
            _currentColumn = cast(uint) _lines[_currentLine].getLength();

        if (_currentColumn > 0) {
            _currentColumn--;
        }
        else if (_currentLine > 0) {
            _currentLine--;
            _currentColumn = getLineLength(_currentLine);
        }

        _maxColumn = _currentColumn;
    }

    void _moveRight() {
        if (_currentColumn > _lines[_currentLine].getLength())
            _currentColumn = cast(uint) _lines[_currentLine].getLength();

        if (_currentColumn < _lines[_currentLine].getLength()) {
            _currentColumn++;
        }
        else if (_currentLine + 1 < _lines.length) {
            _currentLine++;
            _currentColumn = 0;
        }

        _maxColumn = _currentColumn;
    }

    int getCurrentLineSize() {
        return cast(int) _lines[_currentLine].getLength();
    }

    dchar getCurrentLineAt(int col) {
        assert(col >= 0 && col < _lines[_currentLine].getLength());
        return _lines[_currentLine].getChar(col);
    }

    private void _moveWordBorder(int direction) {
        if (direction > 0) {
            _moveRight();

            for (; _currentColumn < getCurrentLineSize(); ++_currentColumn) {
                if (!isWhite(getCurrentLineAt(_currentColumn))) {
                    break;
                }
            }

            if (_currentColumn < getCurrentLineSize()) {
                if (isPunctuation(getCurrentLineAt(_currentColumn))) {
                    for (; _currentColumn < getCurrentLineSize(); ++_currentColumn) {
                        if (!isPunctuation(getCurrentLineAt(_currentColumn))) {
                            break;
                        }
                    }
                }
                else {
                    for (; _currentColumn < getCurrentLineSize(); ++_currentColumn) {
                        if (isWhite(getCurrentLineAt(_currentColumn)) ||
                            isPunctuation(getCurrentLineAt(_currentColumn))) {
                            break;
                        }
                    }
                }
            }

            _maxColumn = _currentColumn;
        }
        else {
            _moveLeft();

            if (_currentColumn >= getLineLength(_currentLine) && _currentColumn > 0)
                _currentColumn--;

            for (; _currentColumn > 0; --_currentColumn) {
                if (!isWhite(getCurrentLineAt(_currentColumn - 1))) {
                    break;
                }
            }

            if (_currentColumn > 0) {
                if (isPunctuation(getCurrentLineAt(_currentColumn))) {
                    for (; _currentColumn > 0; --_currentColumn) {
                        if (!isPunctuation(getCurrentLineAt(_currentColumn - 1))) {
                            break;
                        }
                    }
                }
                else {
                    for (; _currentColumn > 0; --_currentColumn) {
                        if (isWhite(getCurrentLineAt(_currentColumn - 1)) ||
                            isPunctuation(getCurrentLineAt(_currentColumn - 1))) {
                            break;
                        }
                    }
                }
            }

            _maxColumn = _currentColumn;
        }
    }

    private void _moveLineBorder(int direction) {
        if (direction > 0) {
            _currentColumn = cast(uint) _lines[_currentLine].getLength();
        }
        else {
            int startIndex;
            for (; startIndex < _currentColumn; ++startIndex) {
                if (!isWhite(getCurrentLineAt(startIndex))) {
                    break;
                }
            }
            _currentColumn = (_currentColumn == startIndex) ? 0 : startIndex;
        }
        _maxColumn = _currentColumn;
    }

    private void _moveFileBorder(int direction) {
        if (direction > 0) {
            _currentLine = cast(uint)((cast(long) _lines.length) - 1);
        }
        else {
            _currentLine = 0;
        }

        if (_currentColumn < _maxColumn) {
            _currentColumn = _maxColumn;
        }
        if (_currentColumn >= _lines[_currentLine].getLength()) {
            _currentColumn = cast(uint) _lines[_currentLine].getLength();
        }
    }

    private void _removeSelection(int direction) {
        if (!_lines.length)
            return;

        if (!hasSelection()) {
            if (direction > 0) {
                if (_currentColumn == _lines[_currentLine].getLength()) {
                    if (_currentLine + 1 < _lines.length) {
                        setStateRegion(_currentLine);
                        addAction(TextState.Type.update);
                        addAction(TextState.Type.remove);

                        _lines[_currentLine].insertAt(_currentColumn,
                            _lines[_currentLine + 1].getText());

                        removeLine(_currentLine + 1);
                    }
                }
                else {
                    setStateRegion(_currentLine);
                    addAction(TextState.Type.update);
                    _lines[_currentLine].removeAt(_currentColumn);
                }
            }
            else if (direction < 0) {
                if (_currentColumn == 0) {
                    if (_currentLine > 0) {
                        setStateRegion(_currentLine);
                        addAction(TextState.Type.update);
                        addAction(TextState.Type.remove);

                        _currentLine--;
                        _currentColumn = cast(uint) _lines[_currentLine].getLength();
                        _lines[_currentLine].insertAt(_currentColumn,
                            _lines[_currentLine + 1].getText());

                        removeLine(_currentLine + 1);
                    }
                }
                else {
                    setStateRegion(_currentLine);
                    addAction(TextState.Type.update);
                    _currentColumn--;
                    _lines[_currentLine].removeAt(_currentColumn);
                }
            }
        }
        else {
            if (_currentLine == _selectionLine) {
                uint startCol = min(_currentColumn, _selectionColumn);
                uint endCol = max(_currentColumn, _selectionColumn);

                setStateRegion(_currentLine);
                addAction(TextState.Type.update);
                _lines[_currentLine].removeAt(startCol, endCol);
            }
            else if (_currentLine < _selectionLine) {
                setStateRegion(_currentLine);
                addAction(TextState.Type.update);
                addActions(TextState.Type.remove, _selectionLine);

                _lines[_currentLine].removeAt(_currentColumn, _lines[_currentLine].getLength());
                _lines[_currentLine].insertAt(_currentColumn,
                    _lines[_selectionLine].getText(_selectionColumn, getLineLength(_selectionLine)));

                removeLines(_currentLine + 1, _selectionLine);
            }
            else if (_selectionLine < _currentLine) {
                setStateRegion(_selectionLine);
                addAction(TextState.Type.update);
                addActions(TextState.Type.remove, _currentLine);

                _lines[_selectionLine].removeAt(_selectionColumn,
                    _lines[_selectionLine].getLength());
                _lines[_selectionLine].insertAt(_selectionColumn,
                    _lines[_currentLine].getText(_currentColumn, getLineLength(_currentLine)));

                removeLines(_selectionLine + 1, _currentLine);
                _currentLine = _selectionLine;
                _currentColumn = _selectionColumn;
            }
        }

        if (_currentLine == _selectionLine) {
            _currentColumn = _selectionColumn = min(_currentColumn, _selectionColumn);
        }
        else if (_currentLine < _selectionLine) {
            _selectionLine = _currentLine;
            _selectionColumn = _currentColumn;
        }
        else {
            _currentLine = _selectionLine;
            _currentColumn = _selectionColumn;
        }
        _maxColumn = _currentColumn;
    }

    void insertText(dstring text) {
        _removeSelection(0);

        dstring[] ntext;
        foreach (textLine; text.split('\n')) {
            ntext ~= to!dstring(textLine.chomp());
        }
        if (ntext.length == 0)
            return;

        if (ntext.length == 1) {
            setStateRegion(_currentLine);
            addAction(TextState.Type.update);

            _lines[_currentLine].insertAt(_currentColumn, ntext[0]);
            _currentColumn += ntext[0].length;
        }
        else {
            setStateRegion(_currentLine);
            addAction(TextState.Type.update);
            for (uint i = 1; i < ntext.length; ++i) {
                addAction(TextState.Type.add);
            }

            dstring endLine = _lines[_currentLine].getText(_currentColumn,
                getLineLength(_currentLine));
            _lines[_currentLine].removeAt(_currentColumn, getLineLength(_currentLine));
            _lines[_currentLine].insertAt(_currentColumn, ntext[0]);
            foreach (dstring line; ntext[1 .. $]) {
                _currentLine++;
                insertLine(_currentLine, line);
            }
            appendAt(_currentLine, endLine);
            _currentColumn = cast(uint) ntext[$ - 1].length;
        }

        _selectionColumn = _currentColumn;
        _selectionLine = _currentLine;
        _maxColumn = _currentColumn;
    }

    void removeLine(uint line) {
        if (line >= _lines.length)
            return;

        _lines = _lines.remove(line);
    }

    void removeLines(uint startLine, uint endLine) {
        if (startLine >= _lines.length || endLine == 0)
            return;

        if (endLine >= _lines.length)
            endLine = cast(uint)((cast(long) _lines.length) - 1);

        _lines = _lines.remove(tuple(startLine, endLine + 1));
    }

    void insertLine(uint line, dstring text) {
        Line nline = new Line;
        nline.setText(text);
        if (line > _lines.length) {
            _lines ~= nline;
        }
        else {
            _lines.insertInPlace(line, nline);
        }
    }

    void insertAt(uint line, uint col, dstring text) {
        if (line >= _lines.length) {
            insertLine(line, text);
        }
        else {
            _lines[line].insertAt(col, text);
        }
    }

    void appendAt(uint line, dstring text) {
        insertAt(line, getLineLength(line), text);
    }

    uint getLineLength(uint line) const {
        if (line >= _lines.length) {
            return 0;
        }
        return _lines[line].getLength();
    }

    dstring getSelection() {
        if (!hasSelection())
            return "";

        dstring result;
        if (_currentLine == _selectionLine) {
            uint startCol = min(_selectionColumn, _currentColumn);
            uint endCol = max(_selectionColumn, _currentColumn);
            result = _lines[_currentLine].getText(startCol, endCol);
        }
        else if (_currentLine < _selectionLine) {
            result = _lines[_currentLine].getText(_currentColumn,
                getLineLength(_currentLine)) ~ "\n";

            for (uint i = _currentLine + 1; i < _selectionLine; ++i) {
                result ~= _lines[i].getText() ~ "\n";
            }
            result ~= _lines[_selectionLine].getText(0, _selectionColumn);
        }
        else if (_selectionLine < _currentLine) {
            result = _lines[_selectionLine].getText(_selectionColumn,
                getLineLength(_selectionLine)) ~ "\n";

            for (uint i = _selectionLine + 1; i < _currentLine; ++i) {
                result ~= _lines[i].getText() ~ "\n";
            }
            result ~= _lines[_currentLine].getText(0, _currentColumn);
        }

        return result;
    }

    void startState() {
        _isInsertingText = false;

        if (!_isHistoryEnabled)
            return;
        _nextStates.length = 0;
        _currentState.commands.length = 0;
        _currentState._line = _currentLine;
        _currentState._column = _currentColumn;
    }

    void setStateRegion(uint line) {
        _currentState.region = line;
    }

    void endState() {
        if (!_isHistoryEnabled)
            return;
        _prevStates ~= _currentState;
        _currentState.commands.length = 0;
    }

    void addAction(TextState.Type action) {
        if (!_isHistoryEnabled)
            return;
        TextState.Command command;
        command.type = action;
        command.text = _lines[_currentState.region + _currentState.commands.length].getText().dup;
        _currentState.commands ~= command;
    }

    void addActions(TextState.Type action, uint upTo) {
        if (!_isHistoryEnabled)
            return;
        uint currentLine = _currentState.region + cast(uint) _currentState.commands.length;
        for (uint i = currentLine; i <= upTo; ++i) {
            addAction(action);
        }
    }

    void undoHistory() {
        _isInsertingText = false;

        if (!_prevStates.length)
            return;

        _currentState.commands.length = 0;

        _isHistoryEnabled = false;

        TextState state = _prevStates[$ - 1];
        _prevStates.length--;

        TextState nextState;
        nextState._line = _currentLine;
        nextState._column = _currentColumn;
        nextState.region = state.region;

        uint line = state.region;
        foreach (command; state.commands) {
            TextState.Command nextCommand;
            nextCommand.type = command.type;
            if (line < _lines.length)
                nextCommand.text = _lines[line].getText();
            nextState.commands ~= nextCommand;
            line++;
        }

        line = state.region;
        foreach (command; state.commands) {
            final switch (command.type) with (TextState.Type) {
            case add:
                removeLine(line);
                break;
            case remove:
                insertLine(line, command.text.dup);
                line++;
                break;
            case update:
                _lines[line].setText(command.text.dup);
                line++;
                break;
            }
        }

        _currentLine = state._line;
        _currentColumn = state._column;
        _selectionLine = _currentLine;
        _selectionColumn = _currentColumn;
        _maxColumn = _currentColumn;

        _nextStates ~= nextState;

        _isHistoryEnabled = true;
    }

    void redoHistory() {
        _isInsertingText = false;

        if (!_nextStates.length)
            return;

        _currentState.commands.length = 0;

        _isHistoryEnabled = false;

        TextState state = _nextStates[$ - 1];
        _nextStates.length--;

        TextState prevState;
        prevState._line = _currentLine;
        prevState._column = _currentColumn;
        prevState.region = state.region;

        uint line = state.region;
        foreach (command; state.commands) {
            TextState.Command prevCommand;
            prevCommand.type = command.type;
            if (line < _lines.length)
                prevCommand.text = _lines[line].getText();
            prevState.commands ~= prevCommand;
            line++;
        }

        line = state.region;
        foreach (command; state.commands) {
            final switch (command.type) with (TextState.Type) {
            case add:
                insertLine(line, command.text.dup);
                line++;
                break;
            case remove:
                removeLine(line);
                break;
            case update:
                _lines[line].setText(command.text.dup);
                line++;
                break;
            }
        }

        _currentLine = state._line;
        _currentColumn = state._column;
        _selectionLine = _currentLine;
        _selectionColumn = _currentColumn;
        _maxColumn = _currentColumn;

        _prevStates ~= prevState;

        _isHistoryEnabled = true;
    }
}

private struct TextState {
    enum Type {
        add,
        remove,
        update
    }

    struct Command {
        Type type;
        dstring text;
    }

    uint region;
    uint _line, _column;
    Command[] commands;
}

private final class Line {
    private {
        dstring _text;
    }

    void insertAt(size_t col, dstring text) {
        if (col >= _text.length)
            col = _text.length;
        _text.insertInPlace(col, text);
    }

    void removeAt(size_t startCol, size_t endCol) {
        if (startCol >= endCol || startCol >= _text.length)
            return;

        dchar[] text = cast(dchar[]) _text;
        text = text.remove!(SwapStrategy.stable)(tuple(startCol, endCol));
        _text = cast(dstring) text;
    }

    void removeAt(size_t col) {
        dchar[] text = cast(dchar[]) _text;
        text = text.remove!(SwapStrategy.stable)(col);
        _text = cast(dstring) text;
    }

    void setText(dstring text) {
        _text = text.dup;
    }

    dstring getText() {
        if (!_text.length)
            return "";
        return getText(0, cast(uint) _text.length);
    }

    dstring getText(uint startColumn, uint endColumnExcluded) const {
        if (startColumn >= _text.length)
            return "";
        if (endColumnExcluded > _text.length) {
            endColumnExcluded = cast(uint) _text.length;
        }
        if (startColumn >= endColumnExcluded)
            return "";
        return _text[startColumn .. endColumnExcluded];
    }

    uint getLength() const {
        return cast(uint) _text.length;
    }

    dchar getChar(size_t column) const {
        return _text[column];
    }
}
