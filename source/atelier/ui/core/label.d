module atelier.ui.core.label;

import std.algorithm.comparison : min;
import std.conv : to;
import std.math : abs;
import std.stdio;

import atelier.common;
import atelier.render;
import atelier.ui.core.element;

/// Label
final class Label : UIElement {
    private {
        dstring _text;
        Font _font;
        float _charScale = 1f, _charSpacing = 0f;
    }

    Color textColor = Color.white, outlineColor = Color.black;

    @property {
        /// Texte affiché
        string text() const {
            return to!string(_text);
        }
        /// Ditto
        string text(string text_) {
            _text = to!dstring(text_);
            _reload();
            return text_;
        }

        /// La police de caractère utilisée
        Font font() const {
            return cast(Font) _font;
        }
        /// Ditto
        Font font(Font font_) {
            _font = font_;
            _reload();
            return _font;
        }

        /// Espacement additionnel entre chaque lettre
        float charSpacing() const {
            return _charSpacing;
        }
        /// Ditto
        float charSpacing(float charSpacing_) {
            if (_charSpacing != charSpacing_) {
                _charSpacing = charSpacing_;
                _reload();
            }
            return _charSpacing;
        }
    }

    /// Constructor
    this(string text_ = "", Font font_) {
        _text = to!dstring(text_);
        _font = font_;
        _reload();
        isEnabled = false;

        addEventListener("draw", &_onDraw);
    }

    private void _onDraw() {
        drawText(Vec2f(0f, _font.outline + _font.ascent), _text,
            _font, textColor, outlineColor, _charScale, _charSpacing);
    }

    size_t getIndexOf(Vec2f position_) {
        return getIndexOfText(_font, _text, _charScale, _charSpacing, position_);
    }

    Vec2f getTextSize(size_t start = 0, size_t end = size_t.max) {
        return getSizeOfText(_font, _text, _charScale, _charSpacing, start, end);
    }

    private void _reload() {
        setSize(getTextSize());
    }
}

final class ColoredLabel : UIElement {
    private {
        dstring _text;
        Font _font;
        float _charScale = 1f, _charSpacing = 0f;
    }

    struct Token {
        size_t index;
        Color textColor, outlineColor;
    }

    Token[] tokens;

    @property {
        /// Texte affiché
        string text() const {
            return to!string(_text);
        }
        /// Ditto
        string text(string text_) {
            _text = to!dstring(text_);
            _reload();
            return text_;
        }

        /// La police de caractère utilisée
        Font font() const {
            return cast(Font) _font;
        }
        /// Ditto
        Font font(Font font_) {
            _font = font_;
            _reload();
            return _font;
        }

        /// Espacement additionnel entre chaque lettre
        float charSpacing() const {
            return _charSpacing;
        }
        /// Ditto
        float charSpacing(float charSpacing_) {
            if (_charSpacing != charSpacing_) {
                _charSpacing = charSpacing_;
                _reload();
            }
            return _charSpacing;
        }
    }

    /// Constructor
    this(string text_ = "", Font font_) {
        _text = to!dstring(text_);
        _font = font_;
        _reload();
        isEnabled = false;

        addEventListener("draw", &_onDraw);
    }

    private void _onDraw() {
        drawText(Vec2f(0f, _font.outline + _font.ascent), _text,
            _font, tokens, _charScale, _charSpacing);
    }

    size_t getIndexOf(Vec2f position_) {
        return getIndexOfText(_font, _text, _charScale, _charSpacing, position_);
    }

    Vec2f getTextSize(size_t start = 0, size_t end = size_t.max) {
        return getSizeOfText(_font, _text, _charScale, _charSpacing, start, end);
    }

    private void _reload() {
        setSize(getTextSize());
    }
}

Vec2f getSizeOfText(Font font, dstring text, float scale, float spacing,
    size_t start = 0, size_t end = size_t.max) {
    start = min(start, text.length);
    end = min(end, text.length);

    Vec2f totalSize_ = Vec2f(0f, font.ascent - font.descent) * scale;
    float lineWidth = 0f;

    dchar prevChar;
    for (; start < end; ++start) {
        dchar ch = text[start];

        if (ch == '\n') {
            lineWidth = 0f;
            totalSize_.y += font.lineSkip * scale;
        }
        else {
            const Glyph glyph = font.getGlyph(ch);
            lineWidth += font.getKerning(prevChar, ch) * scale;
            lineWidth += (glyph.advance + spacing) * scale;
            if (lineWidth > totalSize_.x)
                totalSize_.x = lineWidth;
            prevChar = ch;
        }
    }

    if (text.length > 0)
        totalSize_ += font.outline << 1;

    return totalSize_;
}

size_t getIndexOfText(Font font, dstring text, float scale, float spacing, Vec2f position_) {
    size_t index;
    Vec2f currentPosition = Vec2f(0f, font.ascent - font.descent) * scale / 2f;
    Vec2f nearestDelta = Vec2f.zero;
    size_t nearestIndex = 0;
    bool isInit = true;

    currentPosition -= font.outline;

    dchar prevChar;
    float advance = 0f;
    for (; index < text.length; ++index) {
        dchar ch = text[index];

        if (ch == '\n') {
            currentPosition.y += font.lineSkip * scale;
            if (!isInit && abs(position_.y - currentPosition.y) > nearestDelta.y) {
                break;
            }
            currentPosition.x = 0f;
        }
        else {
            const Glyph glyph = font.getGlyph(ch);
            bool half;
            if (currentPosition.x == 0f) {
                half = true;
            }
            advance = 0f;
            advance += font.getKerning(prevChar, ch) * scale;
            advance += (glyph.advance + spacing) * scale;
            currentPosition.x += advance;
            if (half) {
                currentPosition.x /= 2f;
            }

            Vec2f delta = Vec2f(abs(position_.y - currentPosition.y),
                abs(position_.x - currentPosition.x));

            if (isInit) {
                isInit = false;
                nearestDelta = delta;
            }

            if (delta.x <= nearestDelta.x && delta.y <= nearestDelta.y) {
                nearestDelta = delta;
                nearestIndex = index;
            }
            prevChar = ch;
        }
    }

    if (text.length && position_.x > (currentPosition.x + advance / 2f)) {
        nearestIndex++;
    }

    return nearestIndex;
}

void drawText(Vec2f position, dstring text, Font font, Color textColor = Color.white,
    Color outlineColor = Color.black, float scale = 1f, float spacing = 0f) {
    dchar prevChar;
    if (font.outline > 0) {
        Vec2f origin = position;
        foreach (dchar ch; text) {
            if (ch == '\n') {
                position.x = 0f;
                position.y += font.lineSkip * scale;
                prevChar = 0;
            }
            else {
                Glyph glyph = font.getGlyphOutline(ch);
                if (!glyph.exists)
                    continue;
                position.x += font.getKerning(prevChar, ch) * scale;

                float x = position.x + glyph.offsetX * scale;
                float y = position.y - glyph.offsetY * scale;

                x += font.outline;
                y -= font.outline;

                glyph.draw(Vec2f(x, y), scale, outlineColor, 1f);
                position.x += (glyph.advance + spacing) * scale;
                prevChar = ch;
            }
        }
        position = origin;
    }

    foreach (dchar ch; text) {
        if (ch == '\n') {
            position.x = 0f;
            position.y += font.lineSkip * scale;
            prevChar = 0;
        }
        else {
            Glyph glyph = font.getGlyph(ch);
            if (!glyph.exists)
                continue;
            position.x += font.getKerning(prevChar, ch) * scale;

            //import atelier.core;

            //Atelier.log(ch, ", ", glyph.offsetY);

            float x = position.x + glyph.offsetX * scale;
            float y = position.y - glyph.offsetY * scale;

            glyph.draw(Vec2f(x, y), scale, textColor, 1f);
            position.x += (glyph.advance + spacing) * scale;
            prevChar = ch;
        }
    }
}

void drawText(Vec2f position, dstring text, Font font,
    ColoredLabel.Token[] tokens = [], float scale = 1f, float spacing = 0f) {
    dchar prevChar;
    size_t colorTokenIndex = 0;
    Color textColor = Color.white;
    Color outlineColor = Color.black;

    void updateColor(size_t index) {
        while (colorTokenIndex < tokens.length && tokens[colorTokenIndex].index == index) {
            textColor = tokens[colorTokenIndex].textColor;
            outlineColor = tokens[colorTokenIndex].outlineColor;
            colorTokenIndex++;
        }
    }

    if (font.outline > 0) {
        Vec2f origin = position;
        foreach (size_t index, dchar ch; text) {
            updateColor(index);

            if (ch == '\n') {
                position.x = 0f;
                position.y += font.lineSkip * scale;
                prevChar = 0;
            }
            else {
                Glyph glyph = font.getGlyphOutline(ch);
                if (!glyph.exists)
                    continue;
                position.x += font.getKerning(prevChar, ch) * scale;

                float x = position.x + glyph.offsetX * scale;
                float y = position.y - glyph.offsetY * scale;

                x += font.outline;
                y -= font.outline;

                glyph.draw(Vec2f(x, y), scale, outlineColor, 1f);
                position.x += (glyph.advance + spacing) * scale;
                prevChar = ch;
            }
        }
        position = origin;
    }

    colorTokenIndex = 0;

    foreach (size_t index, dchar ch; text) {
        updateColor(index);

        if (ch == '\n') {
            position.x = 0f;
            position.y += font.lineSkip * scale;
            prevChar = 0;
        }
        else {
            Glyph glyph = font.getGlyph(ch);
            if (!glyph.exists)
                continue;
            position.x += font.getKerning(prevChar, ch) * scale;

            float x = position.x + glyph.offsetX * scale;
            float y = position.y - glyph.offsetY * scale;

            glyph.draw(Vec2f(x, y), scale, textColor, 1f);
            position.x += (glyph.advance + spacing) * scale;
            prevChar = ch;
        }
    }
}

struct ColoredTextFormat {
    string text;
    ColoredLabel.Token[] tokens;
}

ColoredTextFormat formatColoredText(string text) {
    ColoredTextFormat result;

    size_t _parseCode(size_t i) {
        size_t startIdx = i;
        if (text[i] == '[')
            i++;

        string code;
        for (; i < text.length; ++i) {
            if (text[i] == ']') {
                i++;
                break;
            }
            else {
                code ~= text[i];
            }
        }
        ColoredLabel.Token token;
        token.index = result.text.length;
        switch (code) {
        case "white":
            token.textColor = Color.white;
            break;
        case "red":
            token.textColor = Color.red;
            break;
        case "blue":
            token.textColor = Color.blue;
            break;
        case "green":
            token.textColor = Color.green;
            break;
        case "yellow":
            token.textColor = Color.yellow;
            break;
        case "orange":
            token.textColor = Color.orange;
            break;
        case "black":
            token.textColor = Color.black;
            break;
        case "cyan":
            token.textColor = Color.cyan;
            break;
        case "pink":
            token.textColor = Color.pink;
            break;
        default:
            result.text ~= text[startIdx .. i];
            return i;
        }
        result.tokens ~= token;
        return i;
    }

    for (size_t i; i < text.length; ++i) {
        if (text[i] == '[') {
            i = _parseCode(i);
        }
        if (i < text.length) {
            result.text ~= text[i];
        }
    }

    return result;
}
