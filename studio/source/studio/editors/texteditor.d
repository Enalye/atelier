/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editors.texteditor;

import std.ascii;
import std.conv : to;
import std.file;
import std.math;
import std.stdio;
import std.string;
import atelier;
import studio.editors.base;
import atelier.core.data.vera;

Font font;

final class TextEditor : ContentEditor {
    private {
        Surface _linesSurface;
        UIElement _textContainer;
        Array!Line _lines;
        Label[] _lineCountLabels;
        Label[] _lineTextLabels;
        uint _currentLine, _currentColumn, _maxColumn;
        uint charSize = 0;
    }

    this(string path_) {
        super(path_);

        font = TrueTypeFont.fromMemory(veraMonoFontData, 16);
        charSize = font.getGlyph('a').advance();

        _lines = new Array!Line;

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

        Atelier.renderer.drawRect(Vec2f(64f + columnOffset * charSize,
                lineOffset * font.lineSkip()), Vec2f(charSize,
                font.lineSkip()), Atelier.theme.accent, 1f, true);
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
                _moveUp(step);
                break;
            case down:
                int step = 1;
                if (Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl))
                    step = 4;
                _moveDown(step);
                break;
            case left:
                if (Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl))
                    _moveWordBorder(-1);
                else
                    _moveLeft();
                break;
            case right:
                if (Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl))
                    _moveWordBorder(1);
                else
                    _moveRight();
                break;
            case home:
                _moveLineBorder(-1);
                break;
            case end:
                _moveLineBorder(1);
                break;
            case pageup:
                _moveFileBorder(-1);
                break;
            case pagedown:
                _moveFileBorder(1);
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
            _currentLine = cast(uint)((cast(long) _lines.length()) - 1);
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

    void setText(dstring text) {
        _text = text.dup;
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

    size_t getLength() const {
        return _text.length;
    }

    dchar getChar(size_t column) const {
        return _text[column];
    }
}
