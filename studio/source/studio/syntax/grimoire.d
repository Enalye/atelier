/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.syntax.grimoire;

import std.algorithm.searching : canFind;
import studio.syntax.base;

final class GrimoireSyntaxHighlighter : SyntaxHighlighter {
    private {
        Line[] _lines;
    }

    private class Line {
        Token[] tokens;
        bool isOverflowing;

        struct Scope {
            size_t interpolationLevel;
        }

        Scope[] scopeLevel;
    }

    private struct Tokenizer {
        Line line;
        size_t current;
        dstring text;

        void addToken(Token.Type tokenType) {
            Token token;
            token.type = tokenType;
            token.index = current;
            line.tokens ~= token;
        }

        void skipMultilineComment() {
            while (current < text.length) {
                if (text[current] == '*' && (current + 1) < text.length) {
                    switch (text[current + 1]) {
                    case '/':
                        current += 2;
                        addToken(Token.Type.none);
                        return;
                    default:
                        break;
                    }
                }
                current++;
            }

            line.isOverflowing = true;
        }

        void skipString() {
            while (current < text.length) {
                switch (text[current]) {
                case '\"':
                    current++;
                    addToken(Token.Type.none);
                    return;
                case '\\':
                    scanEscapeCharacter();
                    addToken(Token.Type.string_);
                    break;
                case '#':
                    current++;

                    if (current < text.length && text[current] == '{') {
                        current++;
                        addToken(Token.Type.none);
                        line.scopeLevel[$ - 1].interpolationLevel++;
                        return;
                    }
                    break;
                default:
                    break;
                }
                current++;
            }

            line.isOverflowing = true;
        }

        private void scanNumber() {
            bool isStart = true;
            bool isPrefix, isMaybeFloat, isFloat, isDouble, isUnsigned, isByte;
            bool isBinary, isOctal, isHexadecimal;

            addToken(Token.Type.number);

            for (;;) {
                dchar symbol = text[current];

                if (isBinary) {
                    if (symbol != '0' && symbol != '1' && symbol != '_') {
                        break;
                    }
                }
                else if (isOctal) {
                    if (!(symbol >= '0' && symbol <= '7') && symbol != '_') {
                        break;
                    }
                }
                else if (isHexadecimal) {
                    if (!(symbol >= '0' && symbol <= '9') && !(symbol >= 'a' &&
                            symbol <= 'f') && !(symbol >= 'A' && symbol <= 'F') && symbol != '_') {
                        break;
                    }
                }
                else if (isPrefix && (symbol == 'b' || symbol == 'B')) {
                    isPrefix = false;
                    isBinary = true;
                }
                else if (isPrefix && (symbol == 'o' || symbol == 'O')) {
                    isPrefix = false;
                    isOctal = true;
                }
                else if (isPrefix && (symbol == 'x' || symbol == 'X')) {
                    isPrefix = false;
                    isHexadecimal = true;
                }
                else if (symbol >= '0' && symbol <= '9') {
                    if (isStart && symbol == '0') {
                        isPrefix = true;
                    }
                    else if (isMaybeFloat) {
                        isMaybeFloat = false;
                        isFloat = true;
                        isDouble = true;
                    }
                }
                else if (symbol == '_') {
                    // On ne fait rien, c’est purement visuel (par ex: 1_000_000)
                }
                else if (symbol == '.') {
                    isMaybeFloat = true;
                    isDouble = true;
                }
                else if (symbol == 'f' || symbol == 'F') {
                    isFloat = true;
                    isDouble = false;
                    current++;
                    break;
                }
                else if (symbol == 'd' || symbol == 'D') {
                    isFloat = true;
                    isDouble = true;
                    current++;
                    break;
                }
                else if (symbol == 'u' || symbol == 'U') {
                    isUnsigned = true;
                    current++;
                    break;
                }
                else if (symbol == 'b' || symbol == 'B') {
                    isByte = true;
                    current++;
                    break;
                }
                else {
                    break;
                }

                current++;
                isStart = false;

                if (current >= text.length)
                    break;
            }

            addToken(Token.Type.none);
        }

        private void scanOperator() {
            addToken(Token.Type.operator);

            switch (text[current]) {
            case '{':
            case '}':
            case '(':
            case ')':
            case '[':
            case ']':
            case '.':
            case ';':
            case ',':
            case '@':
            case '$':
                current++;
                break;
            case ':':
                current++;
                if (current >= text.length)
                    break;
                if (text[current] == ':') {
                    current++;
                }
                break;
            case '&':
                current++;
                if (current >= text.length)
                    break;
                switch (text[current]) {
                case '=':
                    current++;
                    break;
                case '&':
                    current++;
                    if (current >= text.length)
                        break;
                    if (text[current] == '=') {
                        current++;
                    }
                    break;
                default:
                    break;
                }
                break;
            case '|':
                current++;
                if (current >= text.length)
                    break;
                switch (text[current]) {
                case '=':
                    current++;
                    break;
                case '|':
                    current++;
                    if (current >= text.length)
                        break;
                    if (text[current] == '=') {
                        current++;
                    }
                    break;
                default:
                    break;
                }
                break;
            case '^':
                current++;
                if (current >= text.length)
                    break;
                if (text[current] == '=') {
                    current++;
                }
                break;
            case '~':
                current++;
                if (current >= text.length)
                    break;
                if (text[current] == '=') {
                    current++;
                }
                break;
            case '+':
                current++;
                if (current >= text.length)
                    break;
                switch (text[current]) {
                case '=':
                    current++;
                    break;
                case '+':
                    current++;
                    break;
                default:
                    break;
                }
                break;
            case '-':
                current++;
                if (current >= text.length)
                    break;
                switch (text[current]) {
                case '=':
                    current++;
                    break;
                case '-':
                    current++;
                    break;
                case '>':
                    current++;
                    break;
                default:
                    break;
                }
                break;
            case '*':
                current++;
                if (current >= text.length)
                    break;
                if (text[current] == '=') {
                    current++;
                }
                else if (text[current] == '*') {
                    current++;
                    if (current + 1 >= text.length)
                        break;
                    if (text[current] == '=') {
                        current++;
                    }
                }
                break;
            case '/':
                current++;
                if (current >= text.length)
                    break;
                if (text[current] == '=') {
                    current++;
                }
                break;
            case '%':
                current++;
                if (current >= text.length)
                    break;
                if (text[current] == '=') {
                    current++;
                }
                break;
            case '=':
                current++;
                if (current >= text.length)
                    break;
                switch (text[current]) {
                case '=':
                    current++;
                    if (current >= text.length)
                        break;
                    if (text[current] == '=') {
                        current++;
                    }
                    break;
                case '>':
                    current++;
                    break;
                default:
                    break;
                }
                break;
            case '<':
                current++;
                if (current >= text.length)
                    break;
                if (text[current] == '=') {
                    current++;
                    if (current >= text.length)
                        break;
                    if (text[current] == '>') {
                        current++;
                    }
                }
                else if (text[current] == '-') {
                    current++;
                }
                else if (text[current] == '<') {
                    current++;
                }
                break;
            case '>':
                current++;
                if (current >= text.length)
                    break;
                if (text[current] == '=') {
                    current++;
                }
                else if (text[current] == '>') {
                    current++;
                }
                break;
            case '!':
                current++;
                if (current >= text.length)
                    break;
                if (text[current] == '=') {
                    current++;
                }
                break;
            case '?':
                current++;
                if (current >= text.length)
                    break;
                if (text[current] == '?') {
                    current++;
                    if (current >= text.length)
                        break;
                    if (text[current] == '=') {
                        current++;
                    }
                }
                break;
            default:
                break;
            }

            addToken(Token.Type.none);
        }

        private void scanEscapeCharacter() {
            addToken(Token.Type.escape_character);
            current++;

            switch (text[current]) {
            case 'u':
                current++;
                if (text[current] != '{')
                    break;

                current++;
                while (current < text.length) {
                    dchar symbol = text[current];
                    if (symbol == '}') {
                        current++;
                        break;
                    }
                    else if ((symbol >= '0' && symbol <= '9') || (symbol >= 'a' &&
                            symbol <= 'f') || (symbol >= 'A' && symbol <= 'F')) {
                        current++;
                    }
                    else {
                        break;
                    }
                }
                break;
            default:
                current++;
                break;
            }
            addToken(Token.Type.none);
        }

        private void scanChar() {
            addToken(Token.Type.character);

            current++;
            if (text[current] == '\\') {
                scanEscapeCharacter();
                addToken(Token.Type.character);
            }
            else {
                current++;
            }

            if (text[current] != '\'') {
                addToken(Token.Type.invalid);
            }
        }

        private void scanWord() {
            immutable dstring[] keywords = [
                "import", "export", "alias", "event", "class", "enum", "where",
                "if", "unless", "else", "switch", "select", "case", "default",
                "while", "do", "until", "for", "loop", "return", "self", "die",
                "exit", "yield", "break", "continue", "as", "try", "catch",
                "throw", "defer", "void", "task", "func", "int", "uint", "byte",
                "char", "float", "bool", "string", "list", "channel", "var",
                "const", "pure", "null", "not", "and", "or", "bit_not",
                "bit_and", "bit_or", "bit_xor"
            ];

            immutable dstring[] literals = ["true", "false"];

            if (text[current] >= '0' && text[current] <= '9')
                return;

            dstring buffer;
            size_t index = current;
            for (;;) {
                if (index >= text.length)
                    break;

                const dchar symbol = text[index];
                if (symbol <= '&' || (symbol >= '(' && symbol <= '/') ||
                    (symbol >= ':' && symbol <= '@') || (symbol >= '[' &&
                        symbol <= '^') || (symbol >= '{' && symbol <= 0x7F))
                    break;

                buffer ~= symbol;
                index++;
            }
            if (keywords.canFind(buffer)) {
                addToken(Token.Type.keyword);
            }
            else if (literals.canFind(buffer)) {
                addToken(Token.Type.keyword);
            }
            else {
                addToken(Token.Type.identifier);
            }
            current = index;
            addToken(Token.Type.none);
        }

        void tokenize(Token.Type overflowTokenType) {
            switch (overflowTokenType) with (Token.Type) {
            case comment:
                addToken(Token.Type.comment);
                skipMultilineComment();
                break;
            case string_:
                addToken(Token.Type.string_);
                skipString();
                break;
            default:
                break;
            }

            while (current < text.length) {
                if (text[current] == '/' && (current + 1) < text.length) {
                    switch (text[current + 1]) {
                    case '/':
                        addToken(Token.Type.comment);
                        return;
                    case '*':
                        addToken(Token.Type.comment);
                        current += 2;
                        skipMultilineComment();
                        if (line.isOverflowing)
                            return;
                        continue;
                    default:
                        break;
                    }
                }

                scanWord();

                if (current >= text.length)
                    return;

                switch (text[current]) {
                case '0': .. case '9':
                    scanNumber();
                    break;
                case '.':
                    if ((current + 1) < text.length && text[current + 1] >= '0' &&
                        text[current + 1] <= '9')
                        scanNumber();
                    else
                        goto case '!';
                    break;
                case '{':
                    line.scopeLevel.length++;
                    current++;
                    break;
                case '}':
                    if (line.scopeLevel.length > 1 && line.scopeLevel[$ - 1].interpolationLevel > 0) {
                        line.scopeLevel[$ - 1].interpolationLevel--;
                        addToken(Token.Type.string_);
                        current++;
                        skipString();
                        if (line.isOverflowing)
                            return;
                    }
                    else if (line.scopeLevel.length > 1) {
                        line.scopeLevel.length--;
                        current++;
                    }
                    else {
                        addToken(Token.Type.invalid);
                        current++;
                    }
                    break;
                case '!':
                case '#': .. case '&':
                case '(': .. case '-':
                case '/':
                case ':': ..
                case '@':
                case '[': .. case '^':
                case '|':
                case '~':
                    scanOperator();
                    break;
                case '\'':
                    scanChar();
                    break;
                case '\"':
                    addToken(Token.Type.string_);
                    current++;
                    skipString();
                    if (line.isOverflowing)
                        return;
                    break;
                default:
                    current++;
                    break;
                }
            }
        }
    }

    override void setLine(size_t lineCount, dstring text) {
        while (lineCount >= _lines.length) {
            _lines ~= new Line;
        }

        Tokenizer tokenizer;
        tokenizer.text = text;
        tokenizer.line = new Line;

        Token.Type overflowTokenType = Token.Type.none;

        if (lineCount > 0) {
            tokenizer.line.scopeLevel = _lines[lineCount - 1].scopeLevel;
            if (_lines[lineCount - 1].isOverflowing && _lines[lineCount - 1].tokens.length) {
                overflowTokenType = _lines[lineCount - 1].tokens[$ - 1].type;
            }
        }
        else {
            tokenizer.line.scopeLevel.length = 1;
        }

        tokenizer.tokenize(overflowTokenType);
        _lines[lineCount] = tokenizer.line;
    }

    override Token[] getLine(size_t lineCount) {
        return _lines[lineCount].tokens;
    }
}
