/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.core.runtime;

import core.thread;
import std.stdio : writeln;
import std.path, std.file, std.exception;
import std.datetime, std.conv;

import grimoire;

import dahu.audio;
import dahu.common;
import dahu.input;
import dahu.render;
import dahu.script;
import dahu.ui;

import dahu.core.loader;
import dahu.core.window;

private void _print(string msg) {
    writeln(msg);
}

final class Dahu {
    static private {
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
        ResourceManager _resourceManager;

        /// Gestionnaire audio
        AudioManager _audioManager;
    }

    static @property pragma(inline) {
        Window window() {
            return _window;
        }

        Renderer renderer() {
            return _renderer;
        }

        UI ui() {
            return _ui;
        }

        /// Gestionnaire de ressources
        ResourceManager res() {
            return _resourceManager;
        }

        /// Le gestionnaire audio
        AudioManager audio() {
            return _audioManager;
        }

        Input input() {
            return _input;
        }

        GrEngine vm() {
            return _grEngine;
        }
    }

    this(GrBytecode bytecode, GrLibrary[] libraries, uint windowWidth,
        uint windowHeight, string windowTitle) {
        _bytecode = bytecode;
        _grEngine = new GrEngine;
        foreach (library; libraries) {
            _grEngine.addLibrary(library);
        }
        _grEngine.load(_bytecode);

        grSetOutputFunction(&_print);

        _window = new Window(windowWidth, windowHeight);
        _renderer = new Renderer(_window);
        _ui = new UI();
        _input = new Input();
        // Initialisation du gestionnaire audio
        _audioManager = new AudioManager();

        // Création du gestionnaire des ressources
        _resourceManager = new ResourceManager();
        setupDefaultResourceLoaders(_resourceManager);

        _grEngine.callEvent("app");
    }

    void run() {
        if (!_grEngine)
            return;

        _tickStartFrame = Clock.currStdTime();
        float accumulator = 0f;

        while (!_input.hasQuit()) {
            long deltaTicks = Clock.currStdTime() - _tickStartFrame;
            double deltatime = (cast(float)(deltaTicks) / 10_000_000f) * _nominalFPS;
            _currentFps = (deltatime == .0f) ? .0f : (10_000_000f / cast(float)(deltaTicks));
            _tickStartFrame = Clock.currStdTime();

            accumulator += deltatime;

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

                    if (_grEngine.hasTasks) {
                        _grEngine.process();
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
        if (!_grEngine)
            return;

        _grEngine.callEvent(event, parameters);
    }
}
