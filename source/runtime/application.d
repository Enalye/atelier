/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module runtime.application;

import std.stdio : writeln;
import std.path, std.file, std.exception;
import std.datetime, std.conv;
import core.thread;

import grimoire;

import common, window;

import runtime.loader;

private void _print(string msg) {
    writeln(msg);
}

final class Runtime {
    private {
        string _filePath;

        // Grimoire
        GrEngine _engine;
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
    }

    version (DahuDebug) this() {
        string path = buildNormalizedPath("test", "main.gr");

        _load(path);
    }

    version (DahuRT) this() {

    }

    version (DahuDev) this(string path) {
        _load(path);
    }

    private void _load(string path) {
        enforce(exists(path), "boot file does not exist `" ~ _filePath ~ "`");

        _stdLib = grLoadStdLibrary();
writeln("A");
        version (DahuRT) {
            _bytecode = new GrBytecode(path);
        }
        else {
            GrCompiler compiler = new GrCompiler;
            compiler.addLibrary(_stdLib);

            version (DahuDev) {
                _bytecode = compiler.compileFile(path, GrOption.symbols, GrLocale.fr_FR);
            }
            else version (DahuDebug) {
writeln("aa");
                _bytecode = compiler.compileFile(path,
                    GrOption.profile | GrOption.symbols | GrOption.safe, GrLocale.fr_FR);
writeln("aab");
            }

writeln("aac");
            if (!_bytecode) {
                writeln(compiler.getError().prettify(GrLocale.fr_FR));
                return;
            }
        }
writeln("B");

        _engine = new GrEngine;
        _engine.addLibrary(_stdLib);
        _engine.load(_bytecode);

        _engine.callEvent("main");

        grSetOutputFunction(&_print);

        _window = new Window(800, 600);

        loadResources();
writeln("C");
    }

    void run() {
        if (!_engine)
            return;

        _tickStartFrame = Clock.currStdTime();

        while (true) {
            //InputEvent[] inputEvents = currentApplication.pollEvents();

            if (_engine) {
                /*if (_inputEvent) {
                    foreach (InputEvent inputEvent; inputEvents) {
                        _engine.callEvent(_inputEvent, [GrValue(inputEvent)]);
                    }
                }*/

                if (_engine.hasTasks)
                    _engine.process();
                else {
                    _engine = null;
                    return;
                }

                //remove!(a => a.isAccepted)(inputEvents);

                if (_engine.isPanicking) {
                    string err = "panique: " ~ _engine.panicMessage ~ "\n";
                    foreach (trace; _engine.stackTraces) {
                        err ~= "[" ~ to!string(
                            trace.pc) ~ "] dans " ~ trace.name ~ " à " ~ trace.file ~ "(" ~ to!string(
                            trace.line) ~ "," ~ to!string(trace.column) ~ ")\n";
                    }
                    _engine = null;
                    writeln(err);
                    return;
                }
            }

            long deltaTicks = Clock.currStdTime() - _tickStartFrame;
            if (deltaTicks < (10_000_000 / _nominalFPS))
                Thread.sleep(dur!("hnsecs")((10_000_000 / _nominalFPS) - deltaTicks));

            deltaTicks = Clock.currStdTime() - _tickStartFrame;
            _deltatime = (cast(float)(deltaTicks) / 10_000_000f) * _nominalFPS;
            _currentFps = (_deltatime == .0f) ? .0f : (10_000_000f / cast(float)(deltaTicks));
            _tickStartFrame = Clock.currStdTime();
        }
    }
}
