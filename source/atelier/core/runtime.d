/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.core.runtime;

import core.thread;
import std.stdio : writeln;
import std.path, std.file, std.exception;
import std.datetime, std.conv;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.input;
import atelier.render;
import atelier.scene;
import atelier.script;
import atelier.ui;

import atelier.core.loader;
import atelier.core.window;

private void _print(string msg) {
    writeln(msg);
}

final class Atelier {
    static private {
        // Grimoire
        GrEngine _engine;
        GrLibrary[] _libraries;
        GrBytecode _bytecode;

        // Événements
        GrEvent _inputEvent, _lateInputEvent;

        // Ressources
        Archive.File[] _resourceFiles, _compiledResourceFiles;

        // IPS
        float _currentFps;
        long _tickStartFrame;
        int _nominalFPS = 60;

        // Modules
        Window _window;
        Renderer _renderer;
        UIManager _uiManager;
        InputManager _inputManager;
        ResourceManager _resourceManager;
        AudioManager _audioManager;
        SceneManager _sceneManager;
    }

    static @property pragma(inline) {
        Window window() {
            return _window;
        }

        Renderer renderer() {
            return _renderer;
        }

        /// Le gestionnaire d’interfaces
        UIManager ui() {
            return _uiManager;
        }

        /// Gestionnaire de ressources
        ResourceManager res() {
            return _resourceManager;
        }

        /// Le gestionnaire audio
        AudioManager audio() {
            return _audioManager;
        }

        /// Le gestionnaire d’entrés
        InputManager input() {
            return _inputManager;
        }

        /// Le gestionnaire de scènes
        SceneManager scene() {
            return _sceneManager;
        }

        /// La machine virtuelle Grimoire
        GrEngine vm() {
            return _engine;
        }
    }

    this(GrBytecode bytecode, GrLibrary[] libraries, uint windowWidth,
        uint windowHeight, string windowTitle) {
        _bytecode = bytecode;
        _libraries = libraries;

        // Initialisation des modules
        _window = new Window(windowWidth, windowHeight);
        _renderer = new Renderer(_window);
        _renderer.setupKernel();

        _uiManager = new UIManager();
        _inputManager = new InputManager();
        _audioManager = new AudioManager();
        _sceneManager = new SceneManager();
        _resourceManager = new ResourceManager();

        setupDefaultResourceLoaders(_resourceManager);
    }

    private void _startup() {
        writeln("[ATELIER] Compilation des ressources...");
        long startTime = Clock.currStdTime();

        foreach (Archive.File file; _resourceFiles) {
            OutStream stream = new OutStream;
            stream.write!string(Atelier_Resource_Compiled_MagicWord);

            Json json = new Json(file.data);
            Json[] resNodes = json.getObjects("resources", []);

            stream.write!uint(cast(uint) resNodes.length);
            foreach (resNode; resNodes) {
                string resType = resNode.getString("type");
                stream.write!string(resType);

                ResourceManager.Loader loader = res.getLoader(resType);
                loader.compile(dirName(file.path), resNode, stream);
            }

            file.data = cast(ubyte[]) stream.data;
            _compiledResourceFiles ~= file;
        }
        _resourceFiles.length = 0;

        double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        writeln("  > Effectué en " ~ to!string(loadDuration) ~ "sec");

        writeln("[ATELIER] Chargement des ressources...");
        startTime = Clock.currStdTime();

        foreach (Archive.File file; _compiledResourceFiles) {
            InStream stream = new InStream;
            stream.data = cast(ubyte[]) file.data;
            enforce(stream.read!string() == Atelier_Resource_Compiled_MagicWord,
                "format du fichier de ressource `" ~ file.path ~ "` invalide");

            uint nbRes = stream.read!uint();
            for (uint i; i < nbRes; ++i) {
                string resType = stream.read!string();
                ResourceManager.Loader loader = res.getLoader(resType);
                loader.load(stream);
            }
        }
        _compiledResourceFiles.length = 0;

        loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        writeln("  > Effectué en " ~ to!string(loadDuration) ~ "sec");

        writeln("[ATELIER] Initialisation de la machine virtuelle...");
        startTime = Clock.currStdTime();

        _engine = new GrEngine(Atelier_Version_ID);

        foreach (GrLibrary library; _libraries) {
            _engine.addLibrary(library);
        }

        enforce(_engine.load(_bytecode), "version du bytecode invalide");

        _engine.callEvent("app");

        _inputEvent = _engine.getEvent("input", [grGetNativeType("InputEvent")]);
        _lateInputEvent = _engine.getEvent("lateInput", [
                grGetNativeType("InputEvent")
            ]);

        grSetOutputFunction(&_print);

        loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        writeln("  > Effectué en " ~ to!string(loadDuration) ~ "sec");
    }

    void loadResources(string path) {
        writeln("[ATELIER] Chargement de l’archive `" ~ path ~ "`...");
        long startTime = Clock.currStdTime();

        Archive archive = new Archive;

        if (isDir(path)) {
            enforce(exists(path), "le dossier `" ~ path ~ "` n’existe pas");
            archive.pack(path);
        }
        else if (extension(path) == Atelier_Archive_Extension) {
            enforce(exists(path), "l’archive `" ~ path ~ "` n’existe pas");
            archive.load(path);
        }

        foreach (file; archive) {
            const string ext = extension(file.name);
            switch (ext) {
            case Atelier_Resource_Extension:
                _resourceFiles ~= file;
                break;
            case Atelier_Resource_Compiled_Extension:
                _compiledResourceFiles ~= file;
                break;
            default:
                res.write(file.path, file.data);
                break;
            }
        }

        double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        writeln("  > Effectué en " ~ to!string(loadDuration) ~ "sec");
    }

    void run() {
        _startup();

        _tickStartFrame = Clock.currStdTime();
        float accumulator = 0f;

        while (!_inputManager.hasQuit()) {
            long deltaTicks = Clock.currStdTime() - _tickStartFrame;
            double deltatime = (cast(float)(deltaTicks) / 10_000_000f) * _nominalFPS;
            _currentFps = (deltatime == .0f) ? .0f : (10_000_000f / cast(float)(deltaTicks));
            _tickStartFrame = Clock.currStdTime();

            accumulator += deltatime;

            // Màj
            while (accumulator >= 1f) {
                InputEvent[] inputEvents = _inputManager.pollEvents();

                _audioManager.update();
                
                _window.update();

                _uiManager.dispatch(inputEvents);

                if (_engine) {
                    /*if (_inputEvent) {
                    foreach (InputEvent inputEvent; inputEvents) {
                        _engine.callEvent(_inputEvent, [GrValue(inputEvent)]);
                    }
                }*/

                    if (_engine.hasTasks) {
                        _engine.process();
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

                _sceneManager.update();
                _uiManager.update();

                accumulator -= 1f;
            }

            // Rendu
            _renderer.startRenderPass();
            _sceneManager.draw(cast(Vec2f) _renderer.center);
            _uiManager.draw();
            _renderer.endRenderPass();
        }
    }

    void callEvent(GrEvent event, GrValue[] parameters = []) {
        if (!_engine)
            return;

        _engine.callEvent(event, parameters);
    }
}
