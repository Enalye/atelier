/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editor.codeeditor;

import std.algorithm.mutation;
import std.array;
import std.ascii;
import std.conv : to;
import std.file;
import std.math;
import std.path;
import std.stdio;
import std.string;
import std.typecons;
import atelier;
import grimoire;
import studio.editor.base;
import atelier.core.data.vera;
import studio.editor.texteditor;
import studio.project;
import studio.syntax;
import studio.ui;

final class CodeEditor : TextEditor {
    private {
        GrCompiler _compiler;
    }

    this(string path_, Vec2f windowSize) {
        super(path_, windowSize);

        string sourceFile = Project.getSourcePath();

        /*enforce(exists(sourceFile),
            "le fichier source `" ~ sourceFile ~ "` référencé dans `" ~
            Atelier_Project_File ~ "` n’existe pas");*/

        GrLibrary[] libraries = [grGetStandardLibrary(), getEngineLibrary()];

        _compiler = new GrCompiler(Atelier_Version_ID);
        foreach (library; libraries) {
            _compiler.addLibrary(library);
        }

        _compiler.addFile(sourceFile);
        if (!_compiler.compile(GrOption.all, GrLocale.fr_FR)) {
            writeln(_compiler.getError().prettify(GrLocale.fr_FR));
        }

        setSyntaxHighlighter(new GrimoireSyntaxHighlighter);
    }

    override void onKeyboardEvent(string key) {
        switch (key) with (InputEvent.KeyButton.Button) {
        case "K":
            GrDefinition definition = _compiler.fetchDefinition(path(),
                getCurrentLine() + 1, getCurrentColumn() + 1);

            GrLexeme decl = definition.getDeclaration();
            if (decl.type == GrLexeme.Type.nothing)
                break;

            import std.stdio;
            writeln(decl.getFile(), " - ", decl.line, ":", decl.column);

            uint line = cast(uint) decl.rawLine;
            uint column = cast(uint) decl.column;

            if (path() == decl.getFile()) {
                gotoPosition(line, column);
            }
            else {
                Studio.editFile(decl.getFile());
                CodeEditor editor = cast(CodeEditor) Studio.getCurrentEditor();
                if (editor) {
                    editor.gotoPosition(line, column);
                }
            }
            break;
        case "I":
            break;
        default:
            break;
        }
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
        uint lineToCopy, lineToApply;
    }

    uint line, column;
    Vec2u[] bookmarks;
    Command[] commands;
}

private final class Line {
    private {
        dstring _text;
    }

    void insertAt(size_t col, dstring text) {
        if (col >= _text.length)
            col = _text.length;
        _text.insertInPlace(col, text);
    }

    void removeAt(size_t startCol, size_t endCol) {
        if (startCol >= endCol || startCol >= _text.length)
            return;

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

    uint getIndent() const {
        uint col;
        for (; col < _text.length; ++col) {
            if (!isWhite(_text[col]))
                return col;
        }

        return col;
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
