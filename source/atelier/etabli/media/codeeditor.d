module atelier.etabli.media.codeeditor;

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

import grimoire;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.ui;
import atelier.etabli.media.base;
import atelier.core.data.vera;
import atelier.etabli.media.texteditor;
import atelier.etabli.syntax;
import atelier.etabli.ui;

final class CodeEditor : TextEditor {
    private {
        GrCompiler _compiler;
        Linter _linter;
    }

    this(string path_, Vec2f windowSize) {
        super(path_, windowSize);
        _linter = new Linter;

        Atelier.etabli.reloadResources();

        _compile();

        setSyntaxHighlighter(new GrimoireSyntaxHighlighter);
        updateLines();
    }

    private void _compile() {
        GrLibrary[] libraries = Atelier.script.getLibraries();
        _compiler = new GrCompiler(Atelier_Version_ID);
        foreach (library; libraries) {
            _compiler.addLibrary(library);
        }

        foreach (sourceFile; Atelier.etabli.getScripts()) {
            _compiler.addFile(sourceFile);
        }

        if (!_compiler.compile(GrOption.all, GrLocale.fr_FR)) {
            Atelier.log(_compiler.getError().prettify(GrLocale.fr_FR));
        }
    }

    override void onSaveFile() {
        _compile();
    }

    override void onUpdateLines() {
        _showLinter();
    }

    override void onCtrlLeftClick() {
        _moveToDefinition();
    }

    private void _moveToDefinition() {
        GrDefinition definition = _compiler.fetchDefinition(path(), getCurrentLine() + 1, getCurrentColumn());

        GrLexeme decl = definition.getDeclaration();
        if (decl.type == GrLexeme.Type.nothing)
            return;

        uint line = cast(uint) decl.rawLine;
        uint column = cast(uint) decl.column;

        if (path() == decl.getFile()) {
            gotoPosition(line, column);
        }
        else {
            Atelier.etabli.editFile(decl.getFile());
            CodeEditor editor = cast(CodeEditor) Atelier.etabli.getCurrentEditor();
            if (editor) {
                editor.gotoPosition(line, column);
            }
        }
    }

    private void _moveToError() {
        GrError err = _compiler.getError();

        if (!err)
            return;

        uint line = cast(uint) err.line;
        uint column = cast(uint) err.column;

        if (line > 0) {
            line--;
        }

        if (path() == err.filePath) {
            gotoPosition(line, column);
        }
        else {
            Atelier.etabli.editFile(err.filePath);
            CodeEditor editor = cast(CodeEditor) Atelier.etabli.getCurrentEditor();
            if (editor) {
                editor.gotoPosition(line, column);
            }
        }
    }

    private void _showLinter() {
        if (!_compiler)
            return;

        GrError err = _compiler.getError();

        if (err) {
            _linter.setText(err.prettify(GrLocale.fr_FR, false), true);
            setLinter(_linter);
        }
        else {
            GrDefinition definition = _compiler.fetchDefinition(path(), getCurrentLine() + 1, getCurrentColumn());

            GrLexeme decl = definition.getDeclaration();
            if (decl.type == GrLexeme.Type.nothing) {
                setLinter(null);
            }
            else {
                _linter.setText(definition.getName(), false);
                setLinter(_linter);
            }
        }
    }

    override void onKeyboardEvent(string key) {
        switch (key) with (InputEvent.KeyButton.Button) {
        case "E":
            if (Atelier.input.hasCtrl) {
                _moveToError();
            }
            break;
        default:
            break;
        }
    }
}

private final class Linter : UIElement {
    private {
        RoundedRectangle _background, _outline;
        Label _msgLabel;
    }

    this() {
        setAlign(UIAlignX.left, UIAlignY.top);
        isEnabled = false;

        _background = RoundedRectangle.fill(getSize(), Atelier.theme.corner);
        _background.anchor = Vec2f.zero;
        _background.color = Atelier.theme.surface;
        addImage(_background);

        _outline = RoundedRectangle.outline(getSize(), Atelier.theme.corner, 1f);
        _outline.anchor = Vec2f.zero;
        _outline.color = Atelier.theme.background;
        addImage(_outline);

        addEventListener("size", &_onSizeChange);

        Font font = TrueTypeFont.fromMemory(veraMonoFontData, 16);
        _msgLabel = new Label("", font);
        _msgLabel.setAlign(UIAlignX.center, UIAlignY.center);
        addUI(_msgLabel);

        setSize(Vec2f(_msgLabel.getWidth() + 8f, _msgLabel.getHeight() + 8f));
    }

    void setText(string txt, bool isDanger) {
        if (isDanger) {
            _background.color = Atelier.theme.danger;
            _msgLabel.color = Atelier.theme.onDanger;
        }
        else {
            _background.color = Atelier.theme.surface;
            _msgLabel.color = Atelier.theme.onNeutral;
        }
        _msgLabel.text = txt;
        setSize(Vec2f(_msgLabel.getWidth() + 8f, _msgLabel.getHeight() + 8f));
    }

    private void _onSizeChange() {
        _background.size = getSize();
        _outline.size = getSize();
    }
}
