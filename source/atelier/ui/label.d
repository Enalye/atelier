module atelier.ui.label;

import std.algorithm.comparison : min;
import std.conv : to;
import std.stdio;

import atelier.common;
import atelier.render;
import atelier.ui.element;

/// Label
final class Label : UIElement {
    private {
        dstring _text;
        Font _font;
        float _charScale = 1f, _charSpacing = 0f;
    }

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
            return _charSpacing = charSpacing_;
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
        Vec2f pos = Vec2f.zero;
        dchar prevChar;
        foreach (dchar ch; _text) {
            if (ch == '\n') {
                pos.x = 0f;
                pos.y += _font.lineSkip * _charScale;
                prevChar = 0;
            }
            else {
                Glyph glyph = _font.getGlyph(ch);
                if (!glyph.exists)
                    continue;
                pos.x += _font.getKerning(prevChar, ch) * _charScale;

                float x = pos.x + glyph.offsetX * _charScale;
                float y = pos.y - glyph.offsetY * _charScale;

                glyph.draw(Vec2f(x, y), _charScale, Color.white, 1f);
                pos.x += (glyph.advance + _charSpacing) * _charScale;
                prevChar = ch;
            }
        }
    }

    private void _reload() {
        Vec2f totalSize_ = Vec2f(0f, _font.ascent - _font.descent) * _charScale;
        float lineWidth = 0f;

        dchar prevChar;
        foreach (dchar ch; _text) {
            if (ch == '\n') {
                lineWidth = 0f;
                totalSize_.y += _font.lineSkip * _charScale;
            }
            else {
                const Glyph glyph = _font.getGlyph(ch);
                lineWidth += _font.getKerning(prevChar, ch) * _charScale;
                lineWidth += glyph.advance * _charScale;
                if (lineWidth > totalSize_.x)
                    totalSize_.x = lineWidth;
                prevChar = ch;
            }
        }

        setSize(totalSize_);
    }
}
