module atelier.console.error;

import std.exception;

/// Décrit une erreur de farfadet
class ConsoleException : Exception {
    mixin basicExceptionCtors;
}

/// Décrit une erreur de syntaxe de farfadet. \
/// Utilisez `tokenLine()` et `tokenColumn()` pour récupèrer les informations
/// sur la position de l’erreur.
final class ConsoleSyntaxException : ConsoleException {
    private {
        size_t _tokenLine, _tokenColumn;
    }

    @property {
        size_t tokenLine() const {
            return _tokenLine;
        }

        size_t tokenColumn() const {
            return _tokenColumn;
        }
    }

    this(string msg, size_t tokenLine_, size_t tokenColumn_, string file = __FILE__,
        size_t line = __LINE__, Throwable next = null) @nogc @safe pure nothrow {
        _tokenLine = tokenLine_;
        _tokenColumn = tokenColumn_;
        super(msg, file, line, next);
    }
}
