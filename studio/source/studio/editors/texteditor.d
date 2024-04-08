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
        uint _currentLine, _currentColumn, _maxColumn;
        uint _selectionLine, _selectionColumn;
        uint charSize = 0;
    }

    this(string path_) {
        super(path_);

        font = TrueTypeFont.fromMemory(veraMonoFontData, 16);
        charSize = font.getGlyph('a').advance();

        auto file = File(path_);
        uint lineId;
        foreach (textLine; file.byLine) {
            Line line = new Line(this, lineId);
            line.setText(to!dstring(textLine.chomp()));
            _lines ~= line;

            lineId++;
        }
        {
            Line line = new Line(this, lineId);
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

        _textContainer.addEventListener("key", &_onKey);
        addEventListener("draw", &_onDraw);
        addEventListener("size", &updateLines);

        updateLines();
    }

    private void _onDraw() {
        uint textWindowHeight = cast(uint)(getHeight() / font.lineSkip());
        uint halfTextWindowHeight = textWindowHeight >> 1;
        uint startLine = 0;

        if (halfTextWindowHeight > _currentLine) {
            startLine = 0;
        }
        else {
            startLine = _currentLine - halfTextWindowHeight;
        }

        uint lineOffset = _currentLine - startLine;

        uint textWindowWidth = cast(uint)(_textContainer.getWidth() / charSize);
        uint halfTextWindowWidth = textWindowWidth >> 1;
        uint startColumn = 0;

        if (halfTextWindowWidth > _currentColumn) {
            startColumn = 0;
        }
        else {
            startColumn = _currentColumn - halfTextWindowWidth;
        }

        uint columnOffset = _currentColumn - startColumn;

        if (columnOffset > _lines[_currentLine].getLength())
            columnOffset = cast(uint) _lines[_currentLine].getLength();

        Atelier.renderer.drawRect(Vec2f(64f + columnOffset * charSize, 0f),
            Vec2f(charSize, getHeight()), Atelier.theme.container, 1f, true);

        Atelier.renderer.drawRect(Vec2f(64f, lineOffset * font.lineSkip()),
            Vec2f(getWidth(), font.lineSkip()), Atelier.theme.foreground, 1f, true);

        if (_selectionLine != _currentLine || _selectionColumn != _currentColumn) {
            void drawSelectionLine(uint line, uint start, uint end) {
                if (startLine > line || line > startLine + textWindowHeight)
                    return;

                uint selectionLineOffset = line - startLine;

                long selectionStart, selectionWidth;
                selectionStart = start;
                selectionStart -= startColumn;

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
                        font.lineSkip()), Atelier.theme.danger, 1f, true);
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

        Color cursorColor = Atelier.theme.accent;
        if(_currentLine != _selectionLine || _currentColumn != _selectionColumn) {
            cursorColor = Color(cursorColor.r, cursorColor.b, cursorColor.g);
        }

        Atelier.renderer.drawRect(Vec2f(64f + columnOffset * charSize,
                lineOffset * font.lineSkip()), Vec2f(charSize,
                font.lineSkip()), cursorColor, 1f, true);
    }

    private void _onKey() {
        InputEvent event = getManager().input;

        if (event.isPressed()) {
            InputEvent.KeyButton keyEvent = event.asKeyButton();
            switch (keyEvent.button) with (InputEvent.KeyButton.Button) {
            case up:
                int step = 1;
                if (Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl))
                    step = 4;

                if (_selectionLine != _currentLine || _selectionColumn != _currentColumn) {
                    if (!_useSelectionInput()) {
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

                    if (!_useSelectionInput()) {
                        _selectionLine = _currentLine;
                        _selectionColumn = _currentColumn;
                    }
                }
                break;
            case down:
                int step = 1;
                if (Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl))
                    step = 4;

                if (_selectionLine != _currentLine || _selectionColumn != _currentColumn) {
                    if (!_useSelectionInput()) {
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

                    if (!_useSelectionInput()) {
                        _selectionLine = _currentLine;
                        _selectionColumn = _currentColumn;
                    }
                }
                break;
            case left:
                if (_selectionLine != _currentLine || _selectionColumn != _currentColumn) {
                    if (!_useSelectionInput()) {
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
                        if (Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl))
                            _moveWordBorder(-1);
                        else
                            _moveLeft();
                    }
                }
                else {
                    if (Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl))
                        _moveWordBorder(-1);
                    else
                        _moveLeft();

                    if (!_useSelectionInput()) {
                        _selectionLine = _currentLine;
                        _selectionColumn = _currentColumn;
                    }
                }
                break;
            case right:
                if (_selectionLine != _currentLine || _selectionColumn != _currentColumn) {
                    if (!_useSelectionInput()) {
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
                        if (Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl))
                            _moveWordBorder(1);
                        else
                            _moveRight();
                    }
                }
                else {
                    if (Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl))
                        _moveWordBorder(1);
                    else
                        _moveRight();

                    if (!_useSelectionInput()) {
                        _selectionLine = _currentLine;
                        _selectionColumn = _currentColumn;
                    }
                }
                break;
            case home:
                _moveLineBorder(-1);
                if (!_useSelectionInput()) {
                    _selectionLine = _currentLine;
                    _selectionColumn = _currentColumn;
                }
                break;
            case end:
                _moveLineBorder(1);
                if (!_useSelectionInput()) {
                    _selectionLine = _currentLine;
                    _selectionColumn = _currentColumn;
                }
                break;
            case pageup:
                _moveFileBorder(-1);
                if (!_useSelectionInput()) {
                    _selectionLine = _currentLine;
                    _selectionColumn = _currentColumn;
                }
                break;
            case pagedown:
                _moveFileBorder(1);
                if (!_useSelectionInput()) {
                    _selectionLine = _currentLine;
                    _selectionColumn = _currentColumn;
                }
                break;
            case remove:
                _removeSelection(1);
                break;
            case backspace:
                _removeSelection(-1);
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
        uint startLine = 0;
        uint endLine = 0;

        if (halfTextWindowHeight > _currentLine) {
            startLine = 0;
        }
        else {
            startLine = _currentLine - halfTextWindowHeight;
        }

        if (startLine + textWindowHeight > _lines.length) {
            endLine = cast(uint) _lines.length;
        }
        else {
            endLine = startLine + textWindowHeight;
        }

        uint actualTextWindowHeight = cast(uint)(cast(long) endLine - cast(long) startLine);

        uint textWindowWidth = cast(uint)(_textContainer.getWidth() / charSize);
        uint halfTextWindowWidth = textWindowWidth >> 1;
        uint startColumn = 0;
        uint endColumn = 0;

        if (halfTextWindowWidth > _currentColumn) {
            startColumn = 0;
        }
        else {
            startColumn = _currentColumn - halfTextWindowWidth;
        }

        endColumn = startColumn + textWindowWidth;

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
        for (size_t line = startLine; line < endLine; line++) {
            long lineCount = 0;
            if (_currentLine == line) {
                lineCount = _currentLine;
                _lineCountLabels[index].color = Atelier.theme.onNeutral;
                _lineCountLabels[index].setAlign(UIAlignX.center, UIAlignY.top);
                _lineCountLabels[index].setPosition(Vec2f(0f,
                        _lineCountLabels[index].getPosition().y));
            }
            else {
                _lineCountLabels[index].setPosition(Vec2f(16f,
                        _lineCountLabels[index].getPosition().y));
                if (abs((cast(long) _currentLine) - cast(long) line) % 4 == 0) {
                    _lineCountLabels[index].color = Color.fromHex(0xc0ccbd);
                }
                else {
                    _lineCountLabels[index].color = Color.fromHex(0x606a61);
                }

                lineCount = cast(long) line - cast(long) _currentLine;
                _lineCountLabels[index].setAlign(UIAlignX.right, UIAlignY.top);
            }
            _lineCountLabels[index].text = to!string(lineCount);
            _lineTextLabels[index].text = to!string(_lines[line].getText(startColumn, endColumn));
            index++;
        }
    }

    private bool _useSelectionInput() {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftShift) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightShift);
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

        if (_currentColumn > 0)
            _currentColumn--;

        _maxColumn = _currentColumn;
    }

    void _moveRight() {
        if (_currentColumn > _lines[_currentLine].getLength())
            _currentColumn = cast(uint) _lines[_currentLine].getLength();

        if (_currentColumn < _lines[_currentLine].getLength())
            _currentColumn++;

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
        int currentIndex = cast(int) _currentColumn;
        if (direction > 0) {
            for (; currentIndex < getCurrentLineSize(); ++currentIndex) {
                if (isPunctuation(getCurrentLineAt(currentIndex)) ||
                    isWhite(getCurrentLineAt(currentIndex))) {
                    if (currentIndex == _currentColumn)
                        currentIndex++;
                    break;
                }
            }
            _currentColumn = currentIndex;
        }
        else {
            currentIndex--;
            for (; currentIndex >= 0; --currentIndex) {
                if (isPunctuation(getCurrentLineAt(currentIndex)) ||
                    isWhite(getCurrentLineAt(currentIndex))) {
                    if (currentIndex + 1 == _currentColumn)
                        currentIndex--;
                    break;
                }
            }
            _currentColumn = currentIndex + 1;
        }
        _maxColumn = _currentColumn;
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

        if (_currentLine == _selectionLine && _currentColumn == _selectionColumn) {
            if (direction > 0) {
                if (_currentColumn == _lines[_currentLine].getLength()) {
                    if (_currentLine < _lines.length) {
                        _lines[_currentLine].insertAt(_currentColumn,
                            _lines[_currentLine + 1].getText());
                        _lines = _lines.remove(_currentLine + 1);
                    }
                }
                else {
                    _lines[_currentLine].removeAt(_currentColumn);
                }
            }
            else {
                if (_currentColumn == 0) {
                    if (_currentLine > 0) {
                        _currentLine--;
                        _currentColumn = cast(uint) _lines[_currentLine].getLength();
                        _lines[_currentLine].insertAt(_currentColumn,
                            _lines[_currentLine + 1].getText());
                        _lines = _lines.remove(_currentLine + 1);
                    }
                }
                else {
                    _currentColumn--;
                    _lines[_currentLine].removeAt(_currentColumn);
                }
            }
        }
        else {
            if (_currentLine == _selectionLine) {
                uint startCol = min(_currentColumn, _selectionColumn);
                uint endCol = max(_currentColumn, _selectionColumn);
                _lines[_currentLine].removeAt(startCol, endCol);
            }
            else if (_currentLine < _selectionLine) {
                _lines[_currentLine].removeAt(_currentColumn, _lines[_currentLine].getLength());
                _lines[_currentLine].insertAt(_currentColumn, _lines[_selectionLine].getText(_selectionColumn,
                        cast(uint) _lines[_selectionLine].getLength()));
                _lines.remove(tuple(_currentLine + 1, _selectionLine + 1));
            }
            else if (_selectionLine < _currentLine) {
                _lines[_selectionLine].removeAt(_selectionColumn,
                    _lines[_selectionLine].getLength());
                _lines[_selectionLine].insertAt(_selectionColumn,
                    _lines[_currentLine].getText(_currentColumn,
                        cast(uint) _lines[_currentLine].getLength()));
                _lines.remove(tuple(_selectionLine + 1, _currentLine + 1));
                _currentLine = _selectionLine;
                _currentColumn = _selectionColumn;
            }
        }

        _selectionLine = _currentLine;
        _selectionColumn = _currentColumn;
    }
}

private final class Line {
    private {
        uint _lineId;
        TextEditor _editor;
        dstring _text;
    }

    this(TextEditor editor, uint lineId) {
        _editor = editor;
        _lineId = lineId;
    }

    void draw(Vec2f position) {
    }

    void insertAt(size_t col, dstring text) {
        _text.insertInPlace(col, text);
    }

    void removeAt(size_t startCol, size_t endCol) {
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
        return getText(0, _text.length > 0 ? (cast(int) _text.length) - 1 : 0);
    }

    dstring getText(uint startColumn, uint endColumn) const {
        if (startColumn >= _text.length)
            return "";
        if (endColumn >= _text.length) {
            endColumn = cast(uint)((cast(long) _text.length) - 1);
        }
        if (startColumn > endColumn)
            return "";
        return _text[startColumn .. endColumn + 1];
    }

    long getLength() const {
        return _text.length;
    }

    dchar getChar(size_t column) const {
        return _text[column];
    }
}
