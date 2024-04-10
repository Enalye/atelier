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
        bool _isHistoryEnabled = true;
        TextState _currentState;
        TextState[] _prevStates, _nextStates;
    }

    this(string path_) {
        super(path_);

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

        if (hasSelection()) {
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
        if (hasSelection()) {
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

                if (hasSelection()) {
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

                if (hasSelection()) {
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
                if (hasSelection()) {
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
                if (hasSelection()) {
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
                pushHistory();
                break;
            case backspace:
                _removeSelection(-1);
                pushHistory();
                break;
            case c:
                if (hasControlModifier()) {
                    Atelier.input.setClipboard(to!string(getSelection()));
                }
                break;
            case x:
                if (hasControlModifier()) {
                    Atelier.input.setClipboard(to!string(getSelection()));
                    _removeSelection(0);
                    pushHistory();
                }
                break;
            case v:
                if (hasControlModifier()) {
                    if (Atelier.input.hasClipboard()) {
                        insertText(to!dstring(Atelier.input.getClipboard()));
                        pushHistory();
                    }
                }
                break;
            case w:
                if (hasControlModifier()) {
                    undoHistory();
                }
                break;
            case y:
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
                        addHistory(TextState.Type.update, _currentLine);
                        _lines[_currentLine].insertAt(_currentColumn,
                            _lines[_currentLine + 1].getText());

                        addHistory(TextState.Type.remove, _currentLine + 1);
                        _lines = _lines.remove(_currentLine + 1);
                    }
                }
                else {
                    addHistory(TextState.Type.update, _currentLine);
                    _lines[_currentLine].removeAt(_currentColumn);
                }
            }
            else if (direction < 0) {
                if (_currentColumn == 0) {
                    if (_currentLine > 0) {
                        addHistory(TextState.Type.update, _currentLine);
                        _currentLine--;
                        _currentColumn = cast(uint) _lines[_currentLine].getLength();
                        _lines[_currentLine].insertAt(_currentColumn,
                            _lines[_currentLine + 1].getText());

                        addHistory(TextState.Type.remove, _currentLine + 1);
                        _lines = _lines.remove(_currentLine + 1);
                    }
                }
                else {
                    addHistory(TextState.Type.update, _currentLine);
                    _currentColumn--;
                    _lines[_currentLine].removeAt(_currentColumn);
                }
            }
        }
        else {
            if (_currentLine == _selectionLine) {
                uint startCol = min(_currentColumn, _selectionColumn);
                uint endCol = max(_currentColumn, _selectionColumn);

                addHistory(TextState.Type.update, _currentLine);
                _lines[_currentLine].removeAt(startCol, endCol);
            }
            else if (_currentLine < _selectionLine) {
                addHistory(TextState.Type.update, _currentLine);
                _lines[_currentLine].removeAt(_currentColumn, _lines[_currentLine].getLength());
                _lines[_currentLine].insertAt(_currentColumn,
                    _lines[_selectionLine].getText(_selectionColumn, getLineLength(_selectionLine)));

                addHistory(TextState.Type.remove, _currentLine + 1, _selectionLine + 1);
                _lines.remove(tuple(_currentLine + 1, _selectionLine + 1));
            }
            else if (_selectionLine < _currentLine) {
                addHistory(TextState.Type.update, _selectionLine);
                _lines[_selectionLine].removeAt(_selectionColumn,
                    _lines[_selectionLine].getLength());
                _lines[_selectionLine].insertAt(_selectionColumn,
                    _lines[_currentLine].getText(_currentColumn, getLineLength(_currentLine)));

                addHistory(TextState.Type.remove, _selectionLine + 1, _currentLine + 1);
                _lines.remove(tuple(_selectionLine + 1, _currentLine + 1));
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
            addHistory(TextState.Type.update, _currentLine);
            _lines[_currentLine].insertAt(_currentColumn, ntext[0]);
            _currentColumn += ntext[0].length;
        }
        else {
            addHistory(TextState.Type.update, _currentLine);
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

    void insertLine(uint line, dstring text) {
        Line nline = new Line;
        nline.setText(text);
        addHistory(TextState.Type.add, _currentLine);
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
            addHistory(TextState.Type.update, line);
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

    void pushHistory() {
        if (!_isHistoryEnabled)
            return;
        _nextStates.length = 0;
        _prevStates ~= _currentState;
        _currentState.commands.length = 0;
    }

    void addHistory(TextState.Type action, uint line) {
        if (!_isHistoryEnabled)
            return;
        TextState.Command command;
        command.type = action;
        command.line = line;
        command.text = _lines[line].getText().dup;
        _currentState.commands ~= command;
    }

    void addHistory(TextState.Type action, uint startLine, uint endLineExcluded) {
        if (!_isHistoryEnabled)
            return;
        for (uint line = startLine; line < endLineExcluded; ++line) {
            addHistory(action, line);
        }
    }

    void undoHistory() {
        if (!_prevStates.length)
            return;

        _currentState.commands.length = 0;

        _isHistoryEnabled = false;

        TextState state = _prevStates[$ - 1];
        _prevStates.length--;

        TextState nextState;

        foreach (command; state.commands) {
            TextState.Command nextCommand;
            nextCommand.type = command.type;
            nextCommand.line = command.line;
            if (command.line < _lines.length)
                nextCommand.text = _lines[command.line].getText();
            nextState.commands ~= nextCommand;
        }

        foreach (command; state.commands) {
            final switch (command.type) with (TextState.Type) {
            case add:
                _lines = _lines.remove(command.line);
                break;
            case remove:
                insertLine(command.line, command.text.dup);
                break;
            case update:
                _lines[command.line].setText(command.text.dup);
                break;
            }
        }

        _nextStates ~= nextState;

        _isHistoryEnabled = true;
    }

    void redoHistory() {
        if (!_nextStates.length)
            return;

        _currentState.commands.length = 0;

        _isHistoryEnabled = false;

        TextState state = _nextStates[$ - 1];
        _nextStates.length--;

        TextState prevState;

        foreach (command; state.commands) {
            TextState.Command prevCommand;
            prevCommand.line = command.line;
            prevCommand.type = command.type;
            if (command.line < _lines.length)
                prevCommand.text = _lines[command.line].getText();
            prevState.commands ~= prevCommand;
        }

        foreach_reverse (command; state.commands) {
            final switch (command.type) with (TextState.Type) {
            case add:
                insertLine(command.line, command.text.dup);
                break;
            case remove:
                _lines = _lines.remove(command.line);
                break;
            case update:
                _lines[command.line].setText(command.text.dup);
                break;
            }
        }

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
        uint line;
    }

    Command[] commands;
}

private final class Line {
    private {
        dstring _text;
    }

    void draw(Vec2f position) {
    }

    void insertAt(size_t col, dstring text) {
        if (col >= _text.length)
            col = _text.length;
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
