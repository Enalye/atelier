module atelier.etabli.syntax.base;

import atelier;

class SyntaxHighlighter {
    private {
        Color[Token.Type.max] _theme;
    }

    struct Token {
        enum Type {
            none,
            invalid,
            comment,
            keyword,
            identifier,
            operator,
            string_,
            escape_character,
            number,
            boolean,
            character,
            max
        }

        Type type;
        size_t index;
    }

    this() {
        _theme[Token.Type.none] = Color.fromHex(0xffffff);
        _theme[Token.Type.invalid] = Color.fromHex(0xff5370);
        _theme[Token.Type.comment] = Color.fromHex(0x546e7a);
        _theme[Token.Type.keyword] = Color.fromHex(0x59e884);
        _theme[Token.Type.identifier] = Color.fromHex(0xcccccc);
        _theme[Token.Type.operator] = Color.fromHex(0xb1b5d8);
        _theme[Token.Type.string_] = Color.fromHex(0xaa97e2);
        _theme[Token.Type.escape_character] = Color.fromHex(0x53cadf);
        _theme[Token.Type.number] = Color.fromHex(0xa1a3ff);
        _theme[Token.Type.boolean] = Color.fromHex(0xe7de8e);
        _theme[Token.Type.character] = Color.fromHex(0xff95bd);
    }

    final ColoredLabel.Token[] getColorTokens(size_t lineCount,
        size_t startColumn, size_t endColumnExcluded) {
        ColoredLabel.Token[] coloredTokens;

        Token[] tokens = getLine(lineCount);
        size_t i;
        Token lastToken;
        bool hasLastToken;
        for (; i < tokens.length && i < startColumn; ++i) {
            if (tokens[i].index < startColumn) {
                lastToken = tokens[i];
                hasLastToken = true;
                continue;
            }
        }

        void addColoredToken(Token token) {
            ColoredLabel.Token coloredToken;
            coloredToken.index = (token.index > startColumn) ? (token.index - startColumn) : 0;

            coloredToken.textColor = _theme[token.type];
            /*
            final switch (token.type) with (Token.Type) {
            case none:
                coloredToken.textColor = Color.fromHex(0xffffff);
                break;
            case invalid:
                coloredToken.textColor = Color.red;
                break;
            case comment:
                coloredToken.textColor = Color.fromHex(0x546e7a);
                break;
            case operator:
                coloredToken.textColor = Color.fromHex(0xb1b5d8);
                break;
            case number:
                coloredToken.textColor = Color.green;
                break;
            case boolean:
                coloredToken.textColor = Color.green;
                break;
            case character:
                coloredToken.textColor = Color.green;
                break;
            case string_:
                coloredToken.textColor = Color.fromHex(0x9d95bd);
                break;
            case escape_character:
                coloredToken.textColor = Color.fromHex(0x777777);
                break;
            case keyword:
                coloredToken.textColor = Atelier.theme.accent;
                break;
            case identifier:
                coloredToken.textColor = Color.fromHex(0xf1fdfd);
                break;
            }*/

            coloredTokens ~= coloredToken;
        }

        if (hasLastToken) {
            addColoredToken(lastToken);
        }

        for (; i < tokens.length && i < endColumnExcluded; ++i) {
            addColoredToken(tokens[i]);
        }

        return coloredTokens;
    }

    void setLine(size_t lineCount, dstring text) {

    }

    Token[] getLine(size_t lineCount) {
        return [];
    }
}
