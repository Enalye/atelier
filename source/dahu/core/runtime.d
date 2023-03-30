/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.core.runtime;

import std.stdio : writeln;
import std.path, std.file, std.exception;
import std.datetime, std.conv;
import core.thread;

import grimoire;

import dahu.common, dahu.ui, dahu.input, dahu.render, dahu.script;

import dahu.core.loader, dahu.core.window;

private void _print(string msg) {
    writeln(msg);
}

private {
    Runtime _app;
}

@property pragma(inline) {
    Runtime app() {
        return _app;
    }
}

final class Runtime {
    private {
        string _filePath;

        // Grimoire
        GrEngine _grEngine;
        GrLibrary _stdLib;
        GrLibrary _dhLib;
        GrBytecode _bytecode;

        // Événements
        GrEvent _inputEvent, _lateInputEvent;

        // IPS
        float _deltatime = 1f;
        float _currentFps;
        long _tickStartFrame;
        int _nominalFPS = 60;

        Window _window;
        Renderer _renderer;
        UI _ui;
        Input _input;
    }

    @property {
        pragma(inline) Window window() {
            return _window;
        }

        pragma(inline) Renderer renderer() {
            return _renderer;
        }

        pragma(inline) UI ui() {
            return _ui;
        }

        pragma(inline) Input input() {
            return _input;
        }
    }

    version (DahuDebug) this() {
        _app = this;
        string path = buildNormalizedPath("test", "main.gr");

        _load(path);
    }

    version (DahuRT) this() {
        _app = this;

    }

    version (DahuDev) this(string path) {
        _app = this;
        _load(path);
    }

    private void _load(string path) {
        enforce(exists(path), "boot file does not exist `" ~ _filePath ~ "`");

        _stdLib = grLoadStdLibrary();
        _dhLib = loadLibrary();

        version (DahuRT) {
            _bytecode = new GrBytecode(path);
        }
        else {
            GrCompiler compiler = new GrCompiler;
            compiler.addLibrary(_stdLib);
            compiler.addLibrary(_dhLib);

            compiler.addFile(path);

            version (DahuDev) {
                _bytecode = compiler.compile(GrOption.symbols, GrLocale.fr_FR);
            }
            else version (DahuDebug) {
                _bytecode = compiler.compile(GrOption.profile | GrOption.symbols | GrOption.safe,
                    GrLocale.fr_FR);
            }

            if (!_bytecode) {
                writeln(compiler.getError().prettify(GrLocale.fr_FR));
                return;
            }
            //writeln(_bytecode.prettify());
        }

        _grEngine = new GrEngine;
        _grEngine.addLibrary(_stdLib);
        _grEngine.addLibrary(_dhLib);
        _grEngine.load(_bytecode);

        _grEngine.callEvent("main");

        grSetOutputFunction(&_print);

        _window = new Window(800, 600);
        _renderer = new Renderer(_window);
        _ui = new UI();
        _input = new Input();

        loadResources();
    }

    void run() {
        if (!_grEngine)
            return;

        _tickStartFrame = Clock.currStdTime();
        float accumulator = 0f;

        while (!_input.hasQuit()) {
            long deltaTicks = Clock.currStdTime() - _tickStartFrame;
            //if (deltaTicks < (10_000_000 / _nominalFPS))
            //    Thread.sleep(dur!("hnsecs")((10_000_000 / _nominalFPS) - deltaTicks));

            deltaTicks = Clock.currStdTime() - _tickStartFrame;
            _deltatime = (cast(float)(deltaTicks) / 10_000_000f) * _nominalFPS;
            _currentFps = (_deltatime == .0f) ? .0f : (10_000_000f / cast(float)(deltaTicks));
            _tickStartFrame = Clock.currStdTime();

            accumulator += _deltatime;

            // Màj
            while (accumulator >= 1f) {
                InputEvent[] inputEvents = _input.pollEvents();

                _ui.dispatch(inputEvents);

                if (_grEngine) {
                    /*if (_inputEvent) {
                    foreach (InputEvent inputEvent; inputEvents) {
                        _grEngine.callEvent(_inputEvent, [GrValue(inputEvent)]);
                    }
                }*/

                    if (_grEngine.hasTasks)
                        _grEngine.process();
                    else {
                        _grEngine = null;
                        return;
                    }

                    //remove!(a => a.isAccepted)(inputEvents);

                    if (_grEngine.isPanicking) {
                        string err = "panique: " ~ _grEngine.panicMessage ~ "\n";
                        foreach (trace; _grEngine.stackTraces) {
                            err ~= "[" ~ to!string(
                                trace.pc) ~ "] dans " ~ trace.name ~ " à " ~ trace.file ~ "(" ~ to!string(
                                trace.line) ~ "," ~ to!string(trace.column) ~ ")\n";
                        }
                        _grEngine = null;
                        writeln(err);
                        return;
                    }
                }

                _ui.update();

                accumulator -= 1f;
            }

            // Rendu
            _ui.draw();

            _renderer.render();
        }
    }

    void callEvent(GrEvent event, GrValue[] parameters = []) {
        if(!_grEngine)
            return;
        
        _grEngine.callEvent(event, parameters);
    }
}
