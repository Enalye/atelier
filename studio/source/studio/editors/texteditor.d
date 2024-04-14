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

final class TextEditor : ContentEditor {
    private {
        Surface _linesSurface;
        UIElement _textContainer;
        VScrollbar _scrollbar;
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
        Vec2u[] _bookmarks;
        uint charSize = 0;
        bool _updateScrollbar;

        // Historique
        bool _isHistoryEnabled = true;
        TextState _currentState;
        TextState[] _prevStates, _nextStates;
        bool _isInsertingText = false;

        // Couleurs
        Color _cursorColor;
        Color _cursorSelectionColor;
        Color _selectionColor;
        Color _bookmarkColor;
        Color _currentLineColor;
        Color _stepLineColor;
        Color _otherLineColor;
        Color _columnBarColor;
        Color _lineBarColor;
        Color[] _indentColor;
        Font _font;
    }

    this(string path_, Vec2f windowSize) {
        super(path_, windowSize);

        _font = TrueTypeFont.fromMemory(veraMonoFontData, 16);
        charSize = _font.getGlyph('a').advance();

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
        _textContainer.setPosition(Vec2f(9f, 0f));
        _textContainer.setSize(Vec2f(getWidth() - (64f + 9f), getHeight()));
        addUI(_textContainer);

        _scrollbar = new VScrollbar;
        _scrollbar.setAlign(UIAlignX.right, UIAlignY.top);
        _scrollbar.setHeight(getHeight());
        _scrollbar.setContentSize(_lines.length * _font.lineSkip());
        _scrollbar.setContentPosition(_currentLine * _font.lineSkip());
        addUI(_scrollbar);

        _textContainer.addEventListener("wheel", &_onWheel);
        _textContainer.addEventListener("mousedown", &_onMouseDown);
        _textContainer.addEventListener("mouserelease", &_onMouseRelease);
        _textContainer.addEventListener("text", &_onText);
        _textContainer.addEventListener("key", &_onKey);
        _scrollbar.addEventListener("handlePosition", &_onScrollbar);
        addEventListener("draw", &_onDraw);
        addEventListener("size", &_onSize);

        float accentHue = HSLColor.fromColor(Atelier.theme.accent).h;

        _cursorColor = HSLColor(accentHue, 1f, 0.4f).toColor();
        _selectionColor = HSLColor(accentHue - 120f, 1f, 0.4f).toColor();
        _cursorSelectionColor = HSLColor(accentHue - 60f, 1f, 0.4f).toColor();
        _bookmarkColor = HSLColor(accentHue + 120f, 1f, 0.4f).toColor();
        _currentLineColor = HSLColor(accentHue, 0.25f, 1f).toColor();
        _stepLineColor = HSLColor(accentHue, 0.13f, 0.77f).toColor();
        _otherLineColor = HSLColor(accentHue, 0.05f, 0.4f).toColor();
        _columnBarColor = HSLColor(accentHue, 0.05f, 0.18f).toColor();
        _lineBarColor = HSLColor(accentHue, 0.05f, 0.25f).toColor();

        uint indentColorCount = 6;
        for (int i = 0; i <= indentColorCount; ++i) {
            float t = i / cast(float) indentColorCount;
            _indentColor ~= HSLColor(accentHue, lerp(1f, 0.77f, t) / 3f, lerp(0.42f, 0.88f, t) / 3f).toColor();
        }

        updateLines();
    }

    private uint _getMouseLine() {
        uint line = cast(uint)(_textContainer.getMousePosition().y / _font.lineSkip());
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
        uint textWindowHeight = cast(uint)(getHeight() / _font.lineSkip());
        uint textWindowWidth = cast(uint)(_textContainer.getWidth() / charSize);
        uint lineOffset = _currentLine - _startLine;
        uint columnOffset = _currentColumn - _startColumn;

        if (_currentLine >= _lines.length) {
            lineOffset = 0;
            columnOffset = 0;
        }
        else if (columnOffset > _lines[_currentLine].getLength()) {
            columnOffset = cast(uint) _lines[_currentLine].getLength();
        }

        Atelier.renderer.drawRect(Vec2f(64f + columnOffset * charSize, 0f),
            Vec2f(charSize, getHeight()), _columnBarColor, 1f, true);

        Atelier.renderer.drawRect(Vec2f(64f, lineOffset * _font.lineSkip()),
            Vec2f(getWidth(), _font.lineSkip()), _lineBarColor, 1f, true);

        if (_indentColor.length) {
            for (uint line = _startLine, index; line < _endLine && line < _lines.length;
                ++line, ++index) {
                uint indent = _lines[line].getIndent() >> 2;
                for (uint i; i < indent; ++i) {
                    Atelier.renderer.drawRect(Vec2f(i * charSize * 4f + 64f,
                            index * _font.lineSkip()), Vec2f(charSize << 2, _font.lineSkip()),
                        _indentColor[i % _indentColor.length], 1f, true);
                }
            }
        }

        foreach (bookmark; _bookmarks) {
            if (_startLine > bookmark.y || bookmark.y >= _endLine ||
                _startColumn > bookmark.x || bookmark.x >= _endColumn)
                continue;

            uint bookmarkColumnOffset = bookmark.x - _startColumn;
            uint bookmarkLineOffset = bookmark.y - _startLine;
            Atelier.renderer.drawRect(Vec2f(64f + bookmarkColumnOffset * charSize,
                    bookmarkLineOffset * _font.lineSkip()), Vec2f(charSize,
                    _font.lineSkip()), _bookmarkColor, 1f, true);
        }

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
                        selectionLineOffset * _font.lineSkip()), Vec2f(selectionWidth * charSize,
                        _font.lineSkip()), _selectionColor, 1f, true);
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
                lineOffset * _font.lineSkip()), Vec2f(charSize,
                _font.lineSkip()), cursorColor, 1f, true);

        foreach (bookmark; _bookmarks) {
            if (_startLine > bookmark.y || bookmark.y >= _endLine ||
                _startColumn > bookmark.x || bookmark.x >= _endColumn)
                continue;

            uint bookmarkColumnOffset = bookmark.x - _startColumn;
            uint bookmarkLineOffset = bookmark.y - _startLine;
            Atelier.renderer.drawRect(Vec2f(64f + bookmarkColumnOffset * charSize,
                    bookmarkLineOffset * _font.lineSkip()), Vec2f(charSize,
                    _font.lineSkip()), _bookmarkColor, 1f, false);
        }
    }

    private void _onText() {
        bool isInsertingText = _isInsertingText;
        if (!_isInsertingText) {
            startState();
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

                if (hasAltModifier()) {
                    uint startLine = min(_currentLine, _selectionLine);
                    uint endLine = max(_currentLine, _selectionLine);
                    step = min(startLine, step);

                    if (step > 0) {
                        startState();
                        for (uint i = startLine - step; i <= endLine; ++i) {
                            addAction(TextState.Type.update, i);
                        }

                        dstring[] linesToSwap;
                        for (uint i = startLine; i <= endLine; ++i) {
                            linesToSwap ~= _lines[i].getText();
                        }
                        for (uint i = startLine - step; i < startLine; ++i) {
                            linesToSwap ~= _lines[i].getText();
                        }
                        for (uint i = startLine - step, j; i <= endLine; ++i, ++j) {
                            _lines[i].setText(linesToSwap[j]);
                        }

                        Vec2u[] movedBookmarks = _moveBookmarksLine(0,
                            (endLine - startLine) + 1, 0, 0, startLine - step, startLine - 1);
                        _moveBookmarksLine(step, 0, 0, 0, startLine, endLine, movedBookmarks);

                        _currentLine -= step;
                        _selectionLine -= step;
                        endState();
                    }
                }
                else if (hasSelection()) {
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

                if (hasAltModifier()) {
                    uint startLine = min(_currentLine, _selectionLine);
                    uint endLine = max(_currentLine, _selectionLine);

                    if (endLine >= _lines.length) {
                        step = 0;
                    }
                    else {
                        step = min(_lines.length - (endLine + 1), step);
                    }

                    if (step > 0) {
                        startState();
                        for (uint i = startLine; i <= endLine + step; ++i) {
                            addAction(TextState.Type.update, i);
                        }

                        dstring[] linesToSwap;
                        for (uint i = endLine + 1; i <= endLine + step; ++i) {
                            linesToSwap ~= _lines[i].getText();
                        }
                        for (uint i = startLine; i <= endLine; ++i) {
                            linesToSwap ~= _lines[i].getText();
                        }
                        for (uint i = startLine, j; i <= endLine + step; ++i, ++j) {
                            _lines[i].setText(linesToSwap[j]);
                        }

                        Vec2u[] movedBookmarks = _moveBookmarksLine((endLine - startLine) + 1,
                            0, 0, 0, endLine + 1, endLine + step);
                        _moveBookmarksLine(0, step, 0, 0, startLine, endLine, movedBookmarks);

                        _currentLine += step;
                        _selectionLine += step;
                        endState();
                    }
                }
                else if (hasSelection()) {
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

                if (hasControlModifier()) {
                    _moveToBookmark(-1);
                }
                else {
                    _moveFileBorder(-1);
                }
                if (!hasShiftModifier()) {
                    _selectionLine = _currentLine;
                    _selectionColumn = _currentColumn;
                }
                break;
            case "PageDown":
                _isInsertingText = false;

                if (hasControlModifier()) {
                    _moveToBookmark(1);
                }
                else {
                    _moveFileBorder(1);
                }

                if (!hasShiftModifier()) {
                    _selectionLine = _currentLine;
                    _selectionColumn = _currentColumn;
                }
                break;
            case "Return":
            case "Keypad Enter":
                startState();
                _removeSelection(0);
                uint indent = _lines[_currentLine].getIndent();
                if (hasShiftModifier()) {
                    addAction(TextState.Type.add, _currentLine);
                    insertLine(_currentLine, "", indent);
                    _selectionLine = _currentLine;
                    _currentColumn = indent;
                    _selectionColumn = indent;
                    _maxColumn = indent;
                }
                else if (hasControlModifier()) {
                    _currentLine++;
                    addAction(TextState.Type.add, _currentLine);
                    insertLine(_currentLine, "", indent);
                    _selectionLine = _currentLine;
                    _currentColumn = indent;
                    _selectionColumn = indent;
                    _maxColumn = indent;
                }
                else {
                    addAction(TextState.Type.update, _currentLine);
                    addAction(TextState.Type.add, _currentLine + 1);
                    dstring endLine = _lines[_currentLine].getText(_currentColumn,
                        getLineLength(_currentLine));
                    _lines[_currentLine].removeAt(_currentColumn, getLineLength(_currentLine));
                    _currentLine++;
                    _selectionLine = _currentLine;
                    _currentColumn = indent;
                    _selectionColumn = indent;
                    _maxColumn = indent;
                    insertLine(_currentLine, endLine, indent);
                }
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
            case "Tab":
                _isInsertingText = false;
                startState();

                if (hasShiftModifier() && hasControlModifier()) {
                    uint targetIndent;
                    bool isFirstLine = true;
                    for (uint line = min(_currentLine, _selectionLine); line <= max(_currentLine,
                            _selectionLine); ++line) {
                        addAction(TextState.Type.update, line);
                        uint currentIndent = _lines[line].getIndent();

                        if (isFirstLine) {
                            isFirstLine = false;
                            targetIndent = currentIndent & ~0x2;
                        }

                        if (currentIndent > targetIndent) {
                            uint indent = currentIndent - targetIndent;
                            _moveBookmarks(0, 0, indent, 0, line, 0, line, getLineLength(line));
                            _lines[line].removeAt(0, indent);

                            if (line == _currentLine) {
                                _currentColumn = _currentColumn > indent ? (_currentColumn - indent)
                                    : 0;
                            }
                            if (line == _selectionLine) {
                                _selectionColumn = _selectionColumn > indent ? (
                                    _selectionColumn - indent) : 0;
                            }
                        }
                        else if (currentIndent < targetIndent) {
                            uint indent = targetIndent - currentIndent;
                            dstring txt = "";
                            for (uint i; i < indent; ++i) {
                                txt ~= " ";
                            }
                            _moveBookmarks(0, 0, 0, indent, line, 0, line, getLineLength(line));
                            _lines[line].insertAt(0, txt);

                            if (line == _currentLine) {
                                _currentColumn += txt.length;
                            }
                            if (line == _selectionLine) {
                                _selectionColumn += txt.length;
                            }
                        }
                    }
                }
                else if (hasShiftModifier()) {
                    for (uint line = min(_currentLine, _selectionLine); line <= max(_currentLine,
                            _selectionLine); ++line) {
                        addAction(TextState.Type.update, line);

                        uint currentIndent = _lines[line].getIndent();
                        if (currentIndent > 0) {
                            uint indent = currentIndent % 4;
                            indent = indent > 0 ? indent : 4;
                            _moveBookmarks(0, 0, indent, 0, line, 0, line, getLineLength(line));
                            _lines[line].removeAt(0, indent);

                            if (line == _currentLine) {
                                _currentColumn = _currentColumn > indent ? (_currentColumn - indent)
                                    : 0;
                            }
                            if (line == _selectionLine) {
                                _selectionColumn = _selectionColumn > indent ? (
                                    _selectionColumn - indent) : 0;
                            }
                        }
                    }
                }
                else if (hasControlModifier()) {
                    for (uint line = min(_currentLine, _selectionLine); line <= max(_currentLine,
                            _selectionLine); ++line) {
                        addAction(TextState.Type.update, line);

                        uint currentIndent = _lines[line].getIndent();
                        uint indent = 4 - (currentIndent % 4);
                        dstring txt = "";
                        for (uint i; i < indent; ++i) {
                            txt ~= " ";
                        }
                        _moveBookmarks(0, 0, 0, indent, line, 0, line, getLineLength(line));
                        _lines[line].insertAt(0, txt);

                        if (line == _currentLine) {
                            _currentColumn += txt.length;
                        }
                        if (line == _selectionLine) {
                            _selectionColumn += txt.length;
                        }
                    }
                }
                else {
                    _removeSelection(0);
                    addAction(TextState.Type.update, _currentLine);
                    uint indent = 4 - (_currentColumn % 4);
                    dstring txt = "";
                    for (uint i; i < indent; ++i) {
                        txt ~= " ";
                    }
                    _moveBookmarks(0, 0, 0, indent, _currentLine,
                        _currentColumn, _currentLine, getLineLength(_currentLine));
                    _lines[_currentLine].insertAt(_currentColumn, txt);
                    _currentColumn += txt.length;

                    _selectionLine = _currentLine;
                    _selectionColumn = _currentColumn;
                    _maxColumn = _currentColumn;
                }
                endState();
                break;
            case "Q":
                if (hasControlModifier()) {
                    _isInsertingText = false;

                    uint tempLine = _currentLine;
                    uint tempColumn = _currentColumn;
                    _currentLine = _selectionLine;
                    _currentColumn = _selectionColumn;
                    _selectionLine = tempLine;
                    _selectionColumn = tempColumn;
                }
                break;
            case "A":
                if (hasControlModifier()) {
                    _isInsertingText = false;

                    _selectionLine = 0;
                    _selectionColumn = 0;
                    _currentLine = _lines.length > 0 ? (cast(uint) _lines.length) - 1 : 0;
                    _currentColumn = getLineLength(_currentLine);
                    _maxColumn = _currentColumn;
                }
                break;
            case "W":
                if (hasControlModifier()) {
                    _isInsertingText = false;

                    _selectWord();
                }
                break;
            case "B":
                if (hasControlModifier()) {
                    _isInsertingText = false;
                    _addBookmark();
                }
                break;
            case "D":
                if (hasControlModifier()) {
                    _isInsertingText = false;
                    _removeBookmarks(_currentLine, _currentColumn,
                        _selectionLine, _selectionColumn);
                }
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

                        addAction(TextState.Type.remove, _currentLine);
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
            case "S":
                if (hasControlModifier()) {
                    saveFile();
                }
                break;
            default:
                break;
            }
        }

        updateLines();
    }

    private void _onScrollbar() {
        if (!_lines.length && !_updateScrollbar)
            return;

        updateLines(true);
    }

    private void _onSize() {
        _linesSurface.setHeight(getHeight());
        _textContainer.setSize(Vec2f(getWidth() - (64f + 9f), getHeight()));
        _scrollbar.setHeight(getHeight());
        _scrollbar.setContentSize(_lines.length * _font.lineSkip());
        _scrollbar.setContentPosition(_currentLine * _font.lineSkip());

        updateLines();
    }

    private void updateLines(bool useView = false) {
        uint textWindowHeight = cast(uint)(getHeight() / _font.lineSkip());
        uint halfTextWindowHeight = textWindowHeight >> 1;

        if (useView) {
            float linePos = _scrollbar.getContentPosition() / _font.lineSkip();
            _startLine = cast(uint)(linePos.round());
            _endLine = _startLine + textWindowHeight;
        }
        else if ((_borderY << 1) >= textWindowHeight) {
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

        if (!useView) {
            _updateScrollbar = true;
            _scrollbar.setContentPosition(_startLine * _font.lineSkip());
            _updateScrollbar = false;
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
                Label lineCountLabel = new Label("", _font);
                lineCountLabel.setAlign(UIAlignX.right, UIAlignY.top);
                lineCountLabel.setPosition(Vec2f(16f, _font.lineSkip() * i));
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
                Label lineTextLabel = new Label("", _font);
                lineTextLabel.setAlign(UIAlignX.left, UIAlignY.top);
                lineTextLabel.setPosition(Vec2f(0f, _font.lineSkip() * i));
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

        for (size_t line = _startLine, index; line < _endLine; ++line, ++index) {
            if (line >= _lines.length) {
                _lineCountLabels[index].isVisible = false;
                _lineTextLabels[index].isVisible = false;
                continue;
            }
            else {
                _lineCountLabels[index].isVisible = true;
                _lineTextLabels[index].isVisible = true;
            }
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

    bool hasAltModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftAlt) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightAlt);
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

    private void _addBookmark() {
        foreach (bookmark; _bookmarks) {
            if (bookmark.y == _currentLine && bookmark.x == _currentColumn) {
                return;
            }
        }
        _bookmarks ~= Vec2u(_currentColumn, _currentLine);
    }

    private Vec4u _makeSelectionClip(uint lineA, uint colA, uint lineB, uint colB) {
        uint startLine, endLine, startColumn, endColumn;

        if (lineA == lineB) {
            startLine = lineA;
            endLine = lineA;
            startColumn = min(colA, colB);
            endColumn = max(colA, colB);
        }
        else if (lineA < lineB) {
            startLine = lineA;
            endLine = lineB;
            startColumn = colA;
            endColumn = colB;
        }
        else {
            startLine = lineB;
            endLine = lineA;
            startColumn = colB;
            endColumn = colA;
        }

        return Vec4u(startLine, startColumn, endLine, endColumn);
    }

    private Vec2u _moveBookmark(Vec2u bookmark, uint up, uint down, uint left, uint right) {
        if (up >= bookmark.y)
            bookmark.y = 0;
        else
            bookmark.y -= up;

        if (bookmark.y + down >= _lines.length)
            bookmark.y = _lines.length > 0 ? (cast(uint) _lines.length) - 1 : 0;
        else
            bookmark.y += down;

        if (left >= bookmark.x)
            bookmark.x = 0;
        else
            bookmark.x -= left;

        if (bookmark.x + right >= getLineLength(bookmark.y))
            bookmark.x = getLineLength(bookmark.y);
        else
            bookmark.x += right;

        return bookmark;
    }

    private Vec2u[] _moveBookmarksLine(uint up, uint down, uint left, uint right,
        uint lineA, uint lineB, Vec2u[] excepted = []) {
        if (lineA > _lines.length) {
            lineA = _lines.length > 0 ? (cast(uint) _lines.length) - 1 : 0;
        }
        if (lineB > _lines.length) {
            lineB = _lines.length > 0 ? (cast(uint) _lines.length) - 1 : 0;
        }
        uint endCol = getLineLength(lineB);
        return _moveBookmarks(up, down, left, right, lineA, 0, lineB, endCol, excepted);
    }

    private Vec2u[] _moveBookmarks(uint up, uint down, uint left, uint right,
        uint lineA, uint colA, uint lineB, uint colB, Vec2u[] excepted = []) {
        Vec4u clip = _makeSelectionClip(lineA, colA, lineB, colB);
        uint startLine = clip.x;
        uint startColumn = clip.y;
        uint endLine = clip.z;
        uint endColumn = clip.w;
        Vec2u[] result;

        if (startLine == endLine) {
            __bmLoop1: foreach (ref bookmark; _bookmarks) {
                if (bookmark.y == startLine && bookmark.x >= startColumn && bookmark.x <= endColumn) {
                    foreach (exceptedBookmark; excepted) {
                        if (exceptedBookmark == bookmark) {
                            continue __bmLoop1;
                        }
                    }
                    bookmark = _moveBookmark(bookmark, up, down, left, right);
                    result ~= bookmark;
                }
            }
        }
        else {
            __bmLoop2: foreach (ref bookmark; _bookmarks) {
                if ((bookmark.y == endLine && bookmark.x <= endColumn) ||
                    (bookmark.y == startLine && bookmark.x >= startColumn) ||
                    (bookmark.y > startLine && bookmark.y < endLine)) {
                    foreach (exceptedBookmark; excepted) {
                        if (exceptedBookmark == bookmark) {
                            continue __bmLoop2;
                        }
                    }
                    bookmark = _moveBookmark(bookmark, up, down, left, right);
                    result ~= bookmark;
                }
            }
        }
        return result;
    }

    private void _removeBookmarks(uint lineA, uint colA, uint lineB, uint colB) {
        Vec4u clip = _makeSelectionClip(lineA, colA, lineB, colB);
        uint startLine = clip.x;
        uint startColumn = clip.y;
        uint endLine = clip.z;
        uint endColumn = clip.w;

        if (endLine == startLine) {
            _bookmarks = _bookmarks.remove!(a => (a.y == startLine &&
                    a.x >= startColumn && a.x <= endColumn), SwapStrategy.unstable)();
        }
        else {
            _bookmarks = _bookmarks.remove!(a => ((a.y > startLine &&
                    a.y < endLine) || (a.y == startLine && a.x >= startColumn) ||
                    (a.y == endLine && a.x <= endColumn)), SwapStrategy.unstable)();
        }
    }

    private void _moveToBookmark(int direction) {
        Vec2u target;
        bool hasTarget;

        if (direction > 0) {
            uint endLine = max(_currentLine, _selectionLine);
            uint endColumn;
            if (_currentLine == _selectionLine) {
                endColumn = max(_currentColumn, _selectionColumn);
            }
            else if (_currentLine > _selectionLine) {
                endColumn = _currentColumn;
            }
            else {
                endColumn = _selectionColumn;
            }

            foreach (bookmark; _bookmarks) {
                if ((bookmark.y == endLine && bookmark.x > endColumn) || bookmark.y > endLine) {
                    if ((bookmark.y == target.y && bookmark.x < target.x) ||
                        bookmark.y < target.y || !hasTarget) {
                        target = bookmark;
                        hasTarget = true;
                    }
                }
            }
        }
        else {
            uint startLine = min(_currentLine, _selectionLine);
            uint startColumn;
            if (_currentLine == _selectionLine) {
                startColumn = min(_currentColumn, _selectionColumn);
            }
            else if (_currentLine < _selectionLine) {
                startColumn = _currentColumn;
            }
            else {
                startColumn = _selectionColumn;
            }

            foreach (bookmark; _bookmarks) {
                if ((bookmark.y == startLine && bookmark.x < startColumn) || bookmark.y < startLine) {
                    if ((bookmark.y == target.y && bookmark.x > target.x) ||
                        bookmark.y > target.y || !hasTarget) {
                        target = bookmark;
                        hasTarget = true;
                    }
                }
            }
        }

        if (hasTarget) {
            _currentLine = target.y;
            _currentColumn = target.x;
            _maxColumn = _currentColumn;
        }
    }

    private void _selectWord() {
        _selectionLine = _currentLine;
        _selectionColumn = _currentColumn;
        for (; _selectionColumn > 0; --_selectionColumn) {
            if (isWhite(getCurrentLineAt(_selectionColumn - 1)) ||
                isPunctuation(getCurrentLineAt(_selectionColumn - 1))) {
                break;
            }
        }

        for (; _currentColumn < getCurrentLineSize(); ++_currentColumn) {
            if (isWhite(getCurrentLineAt(_currentColumn)) ||
                isPunctuation(getCurrentLineAt(_currentColumn))) {
                break;
            }
        }
        _maxColumn = _currentColumn;
    }

    private void _removeSelection(int direction) {
        if (!_lines.length)
            return;

        if (!hasSelection()) {
            if (direction > 0) {
                if (_currentColumn == _lines[_currentLine].getLength()) {
                    if (_currentLine + 1 < _lines.length) {
                        addAction(TextState.Type.update, _currentLine);
                        addAction(TextState.Type.remove, _currentLine + 1);

                        _lines[_currentLine].insertAt(_currentColumn,
                            _lines[_currentLine + 1].getText());

                        removeLine(_currentLine + 1);
                    }
                }
                else {
                    addAction(TextState.Type.update, _currentLine);
                    _removeBookmarks(_currentLine, _currentColumn, _currentLine, _currentColumn);
                    _moveBookmarks(0, 0, 1, 0, _currentLine, _currentColumn,
                        _currentLine, getLineLength(_currentLine));
                    _lines[_currentLine].removeAt(_currentColumn);
                }
            }
            else if (direction < 0) {
                if (_currentColumn == 0) {
                    if (_currentLine > 0) {
                        addAction(TextState.Type.update, _currentLine);
                        addAction(TextState.Type.remove, _currentLine);

                        _currentLine--;
                        _currentColumn = cast(uint) _lines[_currentLine].getLength();
                        _lines[_currentLine].insertAt(_currentColumn,
                            _lines[_currentLine + 1].getText());

                        removeLine(_currentLine + 1);
                    }
                }
                else {
                    addAction(TextState.Type.update, _currentLine);
                    _currentColumn--;
                    _removeBookmarks(_currentLine, _currentColumn, _currentLine, _currentColumn);
                    _moveBookmarks(0, 0, 1, 0, _currentLine, _currentColumn,
                        _currentLine, getLineLength(_currentLine));
                    _lines[_currentLine].removeAt(_currentColumn);
                }
            }
        }
        else {
            if (_currentLine == _selectionLine) {
                uint startCol = min(_currentColumn, _selectionColumn);
                uint endCol = max(_currentColumn, _selectionColumn);

                addAction(TextState.Type.update, _currentLine);
                _removeBookmarks(_currentLine, startCol, _currentLine, endCol);
                _moveBookmarks(0, 0, endCol - startCol, 0, _currentLine, endCol,
                    _currentLine, getLineLength(_currentLine));
                _lines[_currentLine].removeAt(startCol, endCol);
            }
            else if (_currentLine < _selectionLine) {
                addAction(TextState.Type.update, _currentLine);
                addActions(TextState.Type.remove, _currentLine + 1, _selectionLine);

                _lines[_currentLine].removeAt(_currentColumn, _lines[_currentLine].getLength());
                _lines[_currentLine].insertAt(_currentColumn,
                    _lines[_selectionLine].getText(_selectionColumn, getLineLength(_selectionLine)));

                _moveBookmarks(_selectionLine - _currentLine, 0,
                    _currentColumn < _selectionColumn ? _selectionColumn - _currentColumn : 0,
                    _selectionColumn < _currentColumn ?
                    _currentColumn - _selectionColumn : 0, _selectionLine,
                    _selectionColumn, _selectionLine, getLineLength(_selectionLine));
                removeLines(_currentLine + 1, _selectionLine);
            }
            else if (_selectionLine < _currentLine) {
                addAction(TextState.Type.update, _selectionLine);
                addActions(TextState.Type.remove, _selectionLine + 1, _currentLine);

                _lines[_selectionLine].removeAt(_selectionColumn,
                    _lines[_selectionLine].getLength());
                _lines[_selectionLine].insertAt(_selectionColumn,
                    _lines[_currentLine].getText(_currentColumn, getLineLength(_currentLine)));

                _moveBookmarks(_currentLine - _selectionLine, 0,
                    _selectionColumn < _currentColumn ? _currentColumn - _selectionColumn : 0,
                    _currentColumn < _selectionColumn ?
                    _selectionColumn - _currentColumn : 0, _currentLine,
                    _currentColumn, _currentLine, getLineLength(_currentLine));
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
            addAction(TextState.Type.update, _currentLine);

            _lines[_currentLine].insertAt(_currentColumn, ntext[0]);
            _moveBookmarks(0, 0, 0, cast(uint) ntext[0].length, _currentLine,
                _currentColumn, _currentLine, getLineLength(_currentLine));
            _currentColumn += ntext[0].length;
        }
        else {
            addAction(TextState.Type.update, _currentLine);
            if (_currentLine + ntext.length > 1) {
                addActions(TextState.Type.add, _currentLine + 1,
                    cast(uint)(_currentLine + ntext.length) - 1);
            }

            dstring endLine = _lines[_currentLine].getText(_currentColumn,
                getLineLength(_currentLine));

            _removeBookmarks(_currentLine, _currentColumn, _currentLine,
                getLineLength(_currentLine));
            _lines[_currentLine].removeAt(_currentColumn, getLineLength(_currentLine));
            _lines[_currentLine].insertAt(_currentColumn, ntext[0]);
            uint currentLine = _currentLine;
            foreach (dstring line; ntext[1 .. $]) {
                _currentLine++;
                insertLine(_currentLine, line);
            }
            appendAt(_currentLine, endLine);
            _moveBookmarksLine(0, (cast(uint) ntext.length) - 1, 0, 0,
                currentLine, cast(uint) _lines.length);

            _currentColumn = cast(uint) ntext[$ - 1].length;
        }

        _selectionColumn = _currentColumn;
        _selectionLine = _currentLine;
        _maxColumn = _currentColumn;
    }

    void removeLine(uint line) {
        if (line >= _lines.length)
            return;

        _removeBookmarks(line, 0, line, getLineLength(line));
        _lines = _lines.remove(line);
    }

    void removeLines(uint startLine, uint endLine) {
        if (startLine >= _lines.length || endLine == 0)
            return;

        if (endLine >= _lines.length)
            endLine = cast(uint)((cast(long) _lines.length) - 1);

        _removeBookmarks(startLine, 0, endLine, getLineLength(endLine));
        _lines = _lines.remove(tuple(startLine, endLine + 1));
    }

    void insertLine(uint line, dstring text, uint indent = 0) {
        Line nline = new Line;
        dstring txt = "";
        for (uint i; i < indent; ++i) {
            txt ~= " ";
        }
        txt ~= text;
        nline.setText(txt);
        if (line > _lines.length) {
            _lines ~= nline;
        }
        else {
            _moveBookmarksLine(0, 1, 0, 0, line, cast(uint) _lines.length);
            _lines.insertInPlace(line, nline);
        }
    }

    void insertAt(uint line, uint col, dstring text) {
        if (line >= _lines.length) {
            insertLine(line, text);
        }
        else {
            _moveBookmarks(0, 0, 0, 1, line, col, line, getLineLength(line));
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
        _currentState.line = _currentLine;
        _currentState.column = _currentColumn;
        _currentState.bookmarks = _bookmarks.dup;
    }

    void endState() {
        if (!_isHistoryEnabled)
            return;
        _prevStates ~= _currentState;
        _currentState.commands.length = 0;
    }

    void addAction(TextState.Type action, uint line) {
        addAction(action, line, line);
    }

    void addAction(TextState.Type action, uint lineToCopy, uint lineToApply) {
        if (!_isHistoryEnabled)
            return;
        TextState.Command command;
        command.type = action;
        command.lineToCopy = lineToCopy;
        command.lineToApply = lineToApply;
        if (lineToCopy < _lines.length)
            command.text = _lines[lineToCopy].getText().dup;
        _currentState.commands ~= command;
    }

    void addActions(TextState.Type action, uint startLine, uint endLine) {
        if (!_isHistoryEnabled)
            return;

        for (uint line = startLine, lineToApply; line <= endLine; ++line, ++lineToApply) {
            addAction(action, endLine - lineToApply, startLine);
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
        nextState.line = _currentLine;
        nextState.column = _currentColumn;
        nextState.bookmarks = _bookmarks.dup;

        foreach (command; state.commands) {
            TextState.Command nextCommand;
            nextCommand.type = command.type;
            nextCommand.lineToCopy = command.lineToCopy;
            nextCommand.lineToApply = command.lineToApply;
            if (command.lineToCopy < _lines.length)
                nextCommand.text = _lines[command.lineToCopy].getText();
            nextState.commands ~= nextCommand;
        }

        foreach (command; state.commands) {
            final switch (command.type) with (TextState.Type) {
            case add:
                removeLine(command.lineToApply);
                break;
            case remove:
                insertLine(command.lineToApply, command.text.dup);
                break;
            case update:
                _lines[command.lineToApply].setText(command.text.dup);
                break;
            }
        }

        _bookmarks = state.bookmarks.dup;
        _currentLine = state.line;
        _currentColumn = state.column;
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
        prevState.line = _currentLine;
        prevState.column = _currentColumn;
        prevState.bookmarks = _bookmarks.dup;

        foreach (command; state.commands) {
            TextState.Command prevCommand;
            prevCommand.type = command.type;
            prevCommand.lineToCopy = command.lineToCopy;
            prevCommand.lineToApply = command.lineToApply;
            if (command.lineToCopy < _lines.length)
                prevCommand.text = _lines[command.lineToCopy].getText();
            prevState.commands ~= prevCommand;
        }

        foreach (command; state.commands) {
            final switch (command.type) with (TextState.Type) {
            case add:
                insertLine(command.lineToApply, command.text.dup);
                break;
            case remove:
                removeLine(command.lineToApply);
                break;
            case update:
                _lines[command.lineToApply].setText(command.text.dup);
                break;
            }
        }

        _bookmarks = state.bookmarks.dup;
        _currentLine = state.line;
        _currentColumn = state.column;
        _selectionLine = _currentLine;
        _selectionColumn = _currentColumn;
        _maxColumn = _currentColumn;

        _prevStates ~= prevState;

        _isHistoryEnabled = true;
    }

    void saveFile() {
        string path_ = path();
        string text;
        bool isFirst = true;
        foreach (line; _lines) {
            if (isFirst) {
                isFirst = false;
            }
            else {
                text ~= "\n";
            }
            text ~= to!string(line.getText());
        }

        std.file.write(path, text);
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
        uint lineToCopy, lineToApply;
    }

    uint line, column;
    Vec2u[] bookmarks;
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

    uint getIndent() const {
        uint col;
        for (; col < _text.length; ++col) {
            if (!isWhite(_text[col]))
                return col;
        }

        return col;
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
