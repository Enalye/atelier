module atelier.world.dialog.text;

import std.regex;
import std.algorithm.comparison : min;
import std.utf, std.random;
import std.conv : to;
import std.string;
import atelier.common;
import atelier.render;
import atelier.ui;

/// Version modifiée de la classe Text d’Atelier
final class DialogText : UIElement {
    private {
        Font _font;
        Timer _timer, _effectTimer;
        dstring _text, _renderText;

        size_t _currentIndex = 0;
        float _currentTimer = 0f;
        float _currentSpeed = 60f;
        float _speed = 60f;

        Token[] _tokens;
        int _charSpacing = 0;
        float _charScale = 1f;
        double _duration = .0;
    }

    @property {
        /// Text
        string text() const {
            return to!string(_text);
        }
        /// Ditto
        string text(string text_) {
            _text = to!dstring(text_);
            restart();
            _tokenize();
            return text_;
        }

        /// Font
        Font font() const {
            return cast(Font) _font;
        }
        /// Ditto
        Font font(Font font_) {
            _font = font_;
            restart();
            _tokenize();
            return _font;
        }

        /// Is the text still being displayed ?
        bool isPlaying() const {
            return _timer.isRunning() || (_currentIndex < _renderText.length);
        }

        /// Characters per second
        float cps() const {
            return _speed;
        }
        /// Ditto
        float cps(float cps_) {
            _speed = cps_ / 60f;
            _currentSpeed = _speed;
            return _speed;
        }

        /// Default additionnal spacing between each character
        int charSpacing() const {
            return _charSpacing;
        }
        /// Ditto
        int charSpacing(int charSpacing_) {
            return _charSpacing = charSpacing_;
        }
    }

    /// Build text with default font
    this(Font font_) {
        isEnabled = false;
        _font = font_;
        _tokenize();
        _effectTimer.mode = Timer.Mode.loop;
        _effectTimer.start(60);

        addEventListener("update", &_onUpdate);
        addEventListener("draw", &_onDraw);
    }

    /// Ditto
    this(string text_, Font font_) {
        _text = to!dstring(text_);
        this(font_);
    }

    /// Restart the reading from the beginning
    void restart() {
        _currentIndex = 0;
        _currentSpeed = _speed;
        _currentTimer = 0f;
        _timer.reset();
    }

    /// Add to current text
    void append(string text_) {
        _text ~= to!dstring(text_);
        _tokenize();
    }

    void skip() {
        _currentIndex = _renderText.length;
        _timer.reset();
    }

    private struct Token {
        enum Type {
            character,
            line,
            scale,
            charSpacing,
            color,
            speed,
            pause,
            effect
        }

        Type type;
        size_t position;

        union {
            CharToken character;
            ScaleToken scale;
            SpacingToken charSpacing;
            ColorToken color;
            SpeedToken speed;
            PauseToken pause;
            EffectToken effect;
        }

        struct CharToken {
            dchar character;
        }

        struct ScaleToken {
            float scale;
        }

        struct SpacingToken {
            int charSpacing;
        }

        struct ColorToken {
            Color color;
        }

        struct SpeedToken {
            float speed;
        }

        struct PauseToken {
            uint duration;
        }

        struct EffectToken {
            enum Type {
                none,
                wave,
                bounce,
                shake,
                rainbow
            }

            Type type;
        }
    }

    Color _parseColorCode(dstring code) {
        switch (code) {
        case "white":
            return Color.white;
        case "red":
            return Color.red;
        case "blue":
            return Color.blue;
        case "green":
            return Color.green;
        case "yellow":
            return Color.yellow;
        case "orange":
            return Color.orange;
        case "black":
            return Color.black;
        case "cyan":
            return Color.cyan;
        case "pink":
            return Color.pink;
        default:
            return Color.white;
        }
    }

    void addColorToken(Color color) {
        Token token;
        token.position = _renderText.length;
        token.type = Token.Type.color;
        token.color.color = color;
        _tokens ~= token;
    }

    struct ArgumentResult {
        size_t position;
        dstring value;
    }

    private ArgumentResult _parseArgument(size_t i) {
        ArgumentResult result;
        result.position = i;

        if (i >= _text.length)
            return result;

        if (_text[i] != '[')
            return result;

        i++;
        size_t startIdx = i;
        for (; i < _text.length; ++i) {
            if (_text[i] == ']') {
                result.value = _text[startIdx .. i];
                result.position = i + 1;
                break;
            }
        }

        return result;
    }

    private size_t _parseToken(size_t i) {
        i++;

        if (i >= _text.length)
            return i;

        dchar ch = _text[i];
        i++;

        switch (ch) {
        case 'c':
            ArgumentResult arg = _parseArgument(i);
            Color color = _parseColorCode(arg.value);
            i = arg.position;
            addColorToken(color);
            break;
        default:
            break;
        }
        return i;
    }

    private void _tokenize() {
        _tokens.length = 0;
        _renderText.length = 0;

        size_t i;
        while (i < _text.length) {
            if (_text[i] == '\\') {
                if (i + 1 < _text.length) {
                    if (_text[i + 1] == '\\') {
                        _renderText ~= '\\';
                        i += 2;
                    }
                    else {
                        i = _parseToken(i);
                    }
                    continue;
                }
            }
            _renderText ~= _text[i];
            i++;
        }

        reload();
    }
    /*
    private void tokenize() {
        size_t current = 0;
        _tokens.length = 0;
        while (current < _text.length) {
            if (_text[current] == '\n') {
                current++;
                Token token;
                token.type = Token.Type.line;
                _tokens ~= token;
            }
            else if (_text[current] == '{') {
                current++;
                size_t endOfBrackets = indexOf(_text, "}", current);
                if (endOfBrackets == -1)
                    break;
                dstring brackets = _text[current .. endOfBrackets];
                current = endOfBrackets + 1;

                foreach (modifier; brackets.split(",")) {
                    if (!modifier.length)
                        continue;
                    auto parameters = splitter(modifier, regex("[:=]"d));
                    if (parameters.empty)
                        continue;
                    const dstring cmd = parameters.front;
                    parameters.popFront();
                    switch (cmd) {
                    case "c":
                    case "color":
                        Token token;
                        token.type = Token.Type.color;
                        if (!parameters.empty) {
                            if (!parameters.front.length)
                                continue;
                            if (parameters.front[0] == '#') {
                                continue;
                                // TODO: #FFFFFF RGB color format
                            }
                            else {
                                switch (parameters.front) {
                                case "red":
                                    token.color.color = Color.red;
                                    break;
                                case "blue":
                                    token.color.color = Color.blue;
                                    break;
                                case "white":
                                    token.color.color = Color.white;
                                    break;
                                case "black":
                                    token.color.color = Color.black;
                                    break;
                                case "yellow":
                                    token.color.color = Color.yellow;
                                    break;
                                case "cyan":
                                    token.color.color = Color.cyan;
                                    break;
                                case "magenta":
                                    token.color.color = Color.magenta;
                                    break;
                                case "silver":
                                    token.color.color = Color.silver;
                                    break;
                                case "gray":
                                case "grey":
                                    token.color.color = Color.gray;
                                    break;
                                case "maroon":
                                    token.color.color = Color.maroon;
                                    break;
                                case "olive":
                                    token.color.color = Color.olive;
                                    break;
                                case "green":
                                    token.color.color = Color.green;
                                    break;
                                case "purple":
                                    token.color.color = Color.purple;
                                    break;
                                case "teal":
                                    token.color.color = Color.teal;
                                    break;
                                case "navy":
                                    token.color.color = Color.navy;
                                    break;
                                case "pink":
                                    token.color.color = Color.pink;
                                    break;
                                case "orange":
                                    token.color.color = Color.orange;
                                    break;
                                default:
                                    continue;
                                }
                            }
                        }
                        else
                            continue;
                        _tokens ~= token;
                        break;
                    case "s":
                    case "scale":
                    case "size":
                    case "sz":
                        Token token;
                        token.type = Token.Type.scale;
                        if (!parameters.empty)
                            token.scale.scale = parameters.front.to!float;
                        else
                            continue;
                        _tokens ~= token;
                        break;
                    case "l":
                    case "ln":
                    case "line":
                    case "br":
                        Token token;
                        token.type = Token.Type.line;
                        _tokens ~= token;
                        break;
                    case "w":
                    case "wait":
                    case "p":
                    case "pause":
                        Token token;
                        token.type = Token.Type.pause;
                        //if (!parameters.empty)
                        //    token.pause.duration = parameters.front.to!float;
                        //else
                        //    continue;
                        _tokens ~= token;
                        break;
                    case "fx":
                    case "effect":
                        Token token;
                        token.type = Token.Type.effect;
                        token.effect.type = Token.EffectToken.Type.none;
                        if (!parameters.empty) {
                            switch (parameters.front) {
                            case "wave":
                                token.effect.type = Token.EffectToken.Type.wave;
                                break;
                            case "bounce":
                                token.effect.type = Token.EffectToken.Type.bounce;
                                break;
                            case "shake":
                                token.effect.type = Token.EffectToken.Type.shake;
                                break;
                            case "rainbow":
                                token.effect.type = Token.EffectToken.Type.rainbow;
                                break;
                            default:
                                token.effect.type = Token.EffectToken.Type.none;
                                break;
                            }
                        }
                        else
                            continue;
                        _tokens ~= token;
                        break;
                    case "d":
                    case "dl":
                    case "delay":
                        Token token;
                        token.type = Token.Type.delay;
                        if (!parameters.empty)
                            token.delay.duration = parameters.front.to!uint;
                        else
                            continue;
                        _tokens ~= token;
                        break;
                    case "cps":
                        Token token;
                        token.type = Token.Type.delay;
                        if (!parameters.empty) {
                            const uint cps = parameters.front.to!uint;
                            //token.delay.duration = (cps == 0) ? 0f : (60f / cps);
                        }
                        else
                            continue;
                        _tokens ~= token;
                        break;
                    default:
                        continue;
                    }
                }
            }
            else {
                Token token;
                token.type = Token.Type.character;
                token.character.character = _text[current];
                _tokens ~= token;
                current++;
            }
        }
        reload();
    }*/

    private void reload() {
        Vec2f totalSize_ = Vec2f(0f, _font.ascent - _font.descent);
        size_t tokenIndex = 0;
        float lineWidth = 0f;
        dchar prevChar;
        int charSpacing_ = _charSpacing;
        float charScale_ = _charScale;

        void updateToken(size_t index) {
            while (tokenIndex < _tokens.length && _tokens[tokenIndex].position == index) {
                switch (_tokens[tokenIndex].type) with (Token.Type) {
                case line:
                    prevChar = 0;
                    lineWidth = 0f;
                    totalSize_.y += _font.lineSkip * charScale_;
                    break;
                case charSpacing:
                    charSpacing_ = _tokens[tokenIndex].charSpacing.charSpacing;
                    break;
                case scale:
                    charScale_ = _tokens[tokenIndex].scale.scale;
                    break;
                default:
                    break;
                }
                tokenIndex++;
            }
        }

        foreach (size_t index, dchar ch; _renderText) {
            updateToken(index);

            if (ch == '\n') {
                prevChar = 0;
                lineWidth = 0f;
                totalSize_.y += _font.lineSkip * charScale_;
            }
            else {
                const Glyph glyph = _font.getGlyph(ch);
                if (!glyph.exists)
                    continue;

                lineWidth += _font.getKerning(prevChar, ch) * charScale_;
                lineWidth += (glyph.advance + charSpacing_) * charScale_;

                if (lineWidth > totalSize_.x)
                    totalSize_.x = lineWidth;
                prevChar = ch;
            }
        }

        setSize(totalSize_);
    }

    private void _onUpdate() {
        _timer.update();
        _effectTimer.update();
        _duration++;

        if (_currentIndex < _renderText.length) {
            size_t tokenIndex = 0;
            void updateToken(size_t index) {
                while (tokenIndex < _tokens.length && _tokens[tokenIndex].position == index) {
                    switch (_tokens[tokenIndex].type) with (Token.Type) {
                    case speed:
                        _currentSpeed = _tokens[tokenIndex].speed.speed;
                        break;
                    default:
                        break;
                    }
                    tokenIndex++;
                }
            }

            while (_currentTimer >= 1f && _currentIndex < _renderText.length) {
                _currentTimer -= 1f;
                updateToken(_currentIndex);
                if (_renderText[_currentIndex] == '\n') {
                    _currentIndex++;
                }
                _currentIndex++;
            }

            _currentTimer += _currentSpeed;
        }
    }

    private void playSpeechSound() {

    }

    /*
    private void _onDraw() {
        Vec2f pos = Vec2f.zero;
        dchar prevChar;
        Color charColor_ = color;
        uint charDelay_ = _delay;
        float charScale_ = min(cast(int) scale.x, cast(int) scale.y);
        int charSpacing_ = _charSpacing;
        Token.EffectToken.Type charEffect_ = Token.EffectToken.Type.none;
        Vec2f totalSize_ = Vec2f.zero;
        Timer waveTimer = _effectTimer;
        foreach (size_t index, Token token; _tokens) {
            final switch (token.type) with (Token.Type) {
            case character:
                if (_currentIndex == index) {
                    if (_timer.isRunning)
                        break;
                    if (charDelay_ > 0f)
                        _timer.start(charDelay_);
                    playSpeechSound();
                    _currentIndex++;
                }
                Glyph metrics = _font.getGlyph(token.character.character);
                pos.x += _font.getKerning(prevChar, token.character.character) * charScale_;
                Vec2f drawPos = Vec2f(pos.x + metrics.offsetX * charScale_,
                    pos.y - metrics.offsetY * charScale_);

                final switch (charEffect_) with (Token.EffectToken.Type) {
                case none:
                    break;
                case wave:
                    waveTimer.update();
                    waveTimer.update();
                    waveTimer.update();
                    waveTimer.update();
                    waveTimer.update();
                    waveTimer.update();
                    if (waveTimer.value01 < .5f)
                        drawPos.y -= lerp!float(_font.descent, _font.ascent,
                            easeInOutSine(waveTimer.value01 * 2f));
                    else
                        drawPos.y -= lerp!float(_font.ascent, _font.descent,
                            easeInOutSine((waveTimer.value01 - .5f) * 2f));
                    break;
                case bounce:
                    if (_effectTimer.value01 < .5f)
                        drawPos.y -= lerp!float(_font.descent, _font.ascent,
                            easeOutSine(_effectTimer.value01 * 2f));
                    else
                        drawPos.y -= lerp!float(_font.ascent, _font.descent,
                            easeInSine((_effectTimer.value01 - .5f) * 2f));
                    break;
                case shake:
                    drawPos += Vec2f(noise(_duration * .02107 * uniform01()), noise(
                            _duration * .0105 * uniform01())) * charScale_ * 2f;
                    break;
                case rainbow:
                    break;
                }

                metrics.draw(drawPos, charScale_, charColor_, 1f);
                pos.x += (metrics.advance + charSpacing_) * charScale_;
                prevChar = token.character.character;
                if (pos.x > totalSize_.x) {
                    totalSize_.x = pos.x;
                }
                if (((_font.ascent - _font.descent) * charScale_) > totalSize_.y) {
                    totalSize_.y = (_font.ascent - _font.descent) * charScale_;
                }
                break;
            case line:
                if (_currentIndex == index)
                    _currentIndex++;
                pos.x = 0f;
                pos.y += _font.lineSkip * charScale_;
                if (pos.y > totalSize_.y) {
                    totalSize_.y = pos.y;
                }
                break;
            case scale:
                if (_currentIndex == index)
                    _currentIndex++;
                charScale_ = token.scale.scale;
                break;
            case charSpacing:
                if (_currentIndex == index)
                    _currentIndex++;
                charSpacing_ = token.charSpacing.charSpacing;
                break;
            case color:
                if (_currentIndex == index)
                    _currentIndex++;
                charColor_ = token.color.color;
                break;
            case delay:
                if (_currentIndex == index)
                    _currentIndex++;
                charDelay_ = token.delay.duration;
                break;
            case pause:
                if (_currentIndex == index) {
                    if (_timer.isRunning)
                        break;
                    if (token.pause.duration > 0f)
                        _timer.start(token.pause.duration);
                    _currentIndex++;
                }
                break;
            case effect:
                if (_currentIndex == index)
                    _currentIndex++;
                charEffect_ = token.effect.type;
                break;
            }
            if (index == _currentIndex)
                break;
        }
    }*/

    private void _onDraw() {
        dchar prevChar;
        size_t tokenIndex = 0;
        Color textColor = Color.white;
        Color outlineColor = Color.black;
        int spacing = 0;
        float charScale = _charScale;

        Vec2f position = Vec2f(0f, _font.outline + _font.ascent);

        void updateToken(size_t index) {
            while (tokenIndex < _tokens.length && _tokens[tokenIndex].position == index) {
                switch (_tokens[tokenIndex].type) with (Token.Type) {
                case color:
                    textColor = _tokens[tokenIndex].color.color;
                    break;
                case line:
                    position.x = 0f;
                    position.y += font.lineSkip * charScale;
                    prevChar = 0;
                    break;
                default:
                    break;
                }
                //outlineColor = _tokens[tokenIndex].outlineColor;
                tokenIndex++;
            }
        }

        if (font.outline > 0) {
            Vec2f origin = position;
            foreach (size_t index, dchar ch; _renderText) {
                updateToken(index);

                if (ch == '\n') {
                    position.x = 0f;
                    position.y += font.lineSkip * charScale;
                    prevChar = 0;
                }
                else {
                    Glyph glyph = font.getGlyphOutline(ch);
                    if (!glyph.exists)
                        continue;
                    position.x += font.getKerning(prevChar, ch) * charScale;

                    float x = position.x + glyph.offsetX * charScale;
                    float y = position.y - glyph.offsetY * charScale;

                    x += font.outline;
                    y -= font.outline;

                    glyph.draw(Vec2f(x, y), charScale, outlineColor, 1f);
                    position.x += (glyph.advance + spacing) * charScale;
                    prevChar = ch;
                }
            }
            position = origin;
        }

        tokenIndex = 0;

        foreach (size_t index, dchar ch; _renderText) {
            updateToken(index);

            if (index > _currentIndex)
                break;

            if (ch == '\n') {
                position.x = 0f;
                position.y += font.lineSkip * charScale;
                prevChar = 0;
            }
            else {
                Glyph glyph = font.getGlyph(ch);
                if (!glyph.exists)
                    continue;
                position.x += font.getKerning(prevChar, ch) * charScale;

                float x = position.x + glyph.offsetX * charScale;
                float y = position.y - glyph.offsetY * charScale;

                glyph.draw(Vec2f(x, y), charScale, textColor, 1f);
                position.x += (glyph.advance + spacing) * charScale;
                prevChar = ch;
            }
        }
    }
}
