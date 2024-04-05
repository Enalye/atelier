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

final class TextEditor : ContentEditor {
    private {
        Array!Line _lines;
        uint _currentLine, _currentColumn;
    }

    this(string path_) {
        super(path_);

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

        addEventListener("key", &_onKey);
        addEventListener("draw", &_onDraw);
    }

    private void _onDraw() {
        uint windowSize = 10;
        uint startLine = 0;
        uint endLine = 0;

        if (windowSize > _currentLine) {
            startLine = 0;
        }
        else {
            startLine = _currentLine - windowSize;
        }

        if (_currentLine + windowSize > _lines.length) {
            endLine = cast(uint) _lines.length;
        }
        else {
            endLine = _currentLine + windowSize;
        }

        uint lineOffset = _currentLine - startLine;
        uint columnOffset = _currentColumn;

        if (columnOffset > _lines[_currentLine]._glyphs.length)
            columnOffset = cast(uint) _lines[_currentLine]._glyphs.length;

        for (size_t line = startLine; line < endLine; line++) {
            if (line != _currentLine && abs((cast(long) _currentLine) - cast(long) line) % 4 == 0) {
                Atelier.renderer.drawRect(Vec2f(64f, (line - startLine) * 18f),
                    Vec2f(getWidth(), 18f), Atelier.theme.surface, 1f, true);
            }
        }

        Atelier.renderer.drawRect(Vec2f(64f + columnOffset * 8f, 0f), Vec2f(8f,
                getHeight()), Atelier.theme.container, 1f, true);

        Atelier.renderer.drawRect(Vec2f(64f, lineOffset * 18f),
            Vec2f(getWidth(), 18f), Atelier.theme.foreground, 1f, true);

        Atelier.renderer.drawRect(Vec2f(64f + columnOffset * 8f,
                lineOffset * 18f), Vec2f(8f, 18f), Atelier.theme.accent, 1f, true);

        for (size_t line = startLine; line < endLine; line++) {
            _lines[line].draw(Vec2f(64f, (line - startLine) * 18f));
        }
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
            default:
                break;
            }
        }
    }

    void _moveUp(int step) {
        if (_currentLine > step)
            _currentLine -= step;
        else
            _currentLine = 0;
    }

    void _moveDown(int step) {
        if (_currentLine + step + 1 < _lines.length)
            _currentLine += step;
        else
            _currentLine = (cast(uint) _lines.length) - 1;
    }

    void _moveLeft() {
        if (_currentColumn > _lines[_currentLine]._glyphs.length)
            _currentColumn = cast(uint) _lines[_currentLine]._glyphs.length;

        if (_currentColumn > 0)
            _currentColumn--;
    }

    void _moveRight() {
        if (_currentColumn > _lines[_currentLine]._glyphs.length)
            _currentColumn = cast(uint) _lines[_currentLine]._glyphs.length;

        if (_currentColumn < _lines[_currentLine]._glyphs.length)
            _currentColumn++;
    }

    int getCurrentLineSize() {
        return cast(int) _lines[_currentLine]._glyphs.length;
    }

    dchar getCurrentLineAt(int col) {
        assert(col >= 0 && col < _lines[_currentLine]._characters.length);
        return _lines[_currentLine]._characters[col];
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
    }
}

private final class Line {
    private {
        uint _lineId;
        TextEditor _editor;
        dchar[] _characters;
        Glyph[] _glyphs;
    }

    this(TextEditor editor, uint lineId) {
        _editor = editor;
        _lineId = lineId;
        //writeln(getSize(), ": ", getPosition());
    }

    void draw(Vec2f position) {
        float y = position.y;
        float x = position.x;
        for (size_t i; i < _glyphs.length; i++) {
            _glyphs[i].draw(Vec2f(x, y), 1f, Color.white, 1f);
            x += 8f;
            //Etabli.renderer.drawRect(Vec2f.zero, getSize(), Color.random(), 1f, true);
        }
    }

    void setText(dstring text) {
        _characters = text.dup;

        for (size_t i; i < _characters.length; i++) {
            _glyphs ~= Atelier.theme.font.getGlyph(_characters[i]);
        }
    }
}
