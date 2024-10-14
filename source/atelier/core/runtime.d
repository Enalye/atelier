/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.core.runtime;

import core.thread;
import std.path, std.file, std.exception;
import std.datetime, std.conv;

import farfadet;
import grimoire;

import atelier.audio;
import atelier.common;
import atelier.input;
import atelier.render;
import atelier.scene;
import atelier.script;
import atelier.ui;

import atelier.core.loader;
import atelier.core.logger;
import atelier.core.theme;
import atelier.core.window;

private void _print(string msg) {
    log(msg);
}

final class Atelier {
    static private {
        // Grimoire
        alias CompileFunc = GrBytecode delegate(GrLibrary[]);
        GrEngine _engine;
        GrLibrary[] _libraries;
        GrBytecode _bytecode;
        CompileFunc _compileFunc;

        // Informations
        bool _isRedist, _isRunning;
        bool _mustReload, _mustReloadResources, _mustReloadScript;

        // Événements
        GrEvent _inputEvent, _lateInputEvent;

        // Ressources
        string[] _archives;
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
        AudioMixer _audioMixer;
        World _sceneManager;
        RNG _rng;
        Theme _theme;
    }

    static @property pragma(inline) {
        /// L’application est en mode export ?
        bool isRedist() {
            return _isRedist;
        }

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
        AudioMixer audio() {
            return _audioMixer;
        }

        /// Le gestionnaire d’entrés
        InputManager input() {
            return _inputManager;
        }

        /// Le gestionnaire de scènes
        World scene() {
            return _sceneManager;
        }

        /// Générateur standard de pseudo-aléatoire
        RNG rng() {
            return _rng;
        }

        /// La machine virtuelle Grimoire
        GrEngine vm() {
            return _engine;
        }

        Theme theme() {
            return _theme;
        }
    }

    /// Demande le rechargement de l’application (valide seulement en mode développement)
    static void reload(bool mustReloadResources, bool mustReloadScript) {
        if (_isRedist)
            return;
        _mustReload = true;
        _mustReloadResources = mustReloadResources;
        _mustReloadScript = mustReloadScript;
    }

    static void close() {
        _isRunning = false;
    }

    this(uint windowWidth, uint windowHeight, string windowTitle) {
        this(false, null, [], windowWidth, windowHeight, windowTitle);
    }

    this(bool isRedist_, CompileFunc compileFunc, GrLibrary[] libraries,
        uint windowWidth, uint windowHeight, string windowTitle) {
        _isRedist = isRedist_;
        _compileFunc = compileFunc;
        _libraries = libraries;
        _isRunning = true;

        // Initialisation des modules
        _window = new Window(windowWidth, windowHeight);
        _window.title = windowTitle;
        _renderer = new Renderer(_window);
        _renderer.setupKernel();

        _uiManager = new UIManager();
        _inputManager = new InputManager();
        _audioMixer = new AudioMixer();
        _sceneManager = new World();
        _resourceManager = new ResourceManager();
        _rng = new RNG();
        _theme = new Theme();

        setupDefaultResourceLoaders(_resourceManager);
    }

    void addArchive(string path) {
        _archives ~= path;
    }

    private void _loadArchives() {
        foreach (path; _archives) {
            log("[ATELIER] Chargement de l’archive `" ~ path ~ "`...");
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
            log("  > Effectué en " ~ to!string(loadDuration) ~ "sec");
        }
    }

    private void _compileResources() {
        log("[ATELIER] Compilation des ressources...");
        long startTime = Clock.currStdTime();

        foreach (Archive.File file; _resourceFiles) {
            OutStream stream = new OutStream;
            stream.write!string(Atelier_Resource_Compiled_MagicWord);

            try {
                Farfadet ffd = Farfadet.fromBytes(file.data);

                stream.write!uint(cast(uint) ffd.getNodes().length);
                foreach (resNode; ffd.getNodes()) {
                    stream.write!string(resNode.name);

                    ResourceManager.Loader loader = res.getLoader(resNode.name);
                    loader.compile(dirName(file.path) ~ Archive.Separator, resNode, stream);
                }
            }
            catch (FarfadetSyntaxException e) {
                string msg = file.path ~ "(" ~ to!string(
                    e.tokenLine) ~ "," ~ to!string(e.tokenColumn) ~ "): ";
                e.msg = msg ~ e.msg;
                throw e;
            }

            file.data = cast(ubyte[]) stream.data;
            _compiledResourceFiles ~= file;
        }
        _resourceFiles.length = 0;

        double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        log("  > Effectué en " ~ to!string(loadDuration) ~ "sec");
    }

    private void _loadResources() {
        log("[ATELIER] Chargement des ressources...");
        long startTime = Clock.currStdTime();

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

        double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        log("  > Effectué en " ~ to!string(loadDuration) ~ "sec");
    }

    private void _startVM() {
        if (!_bytecode)
            return;

        log("[ATELIER] Initialisation de la machine virtuelle...");
        long startTime = Clock.currStdTime();

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

        _engine.setPrintOutput(&_print);

        double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        log("  > Effectué en " ~ to!string(loadDuration) ~ "sec");
    }

    void _reload() {
        _mustReload = false;

        _audioMixer.clear();
        _uiManager.clearUI();
        _sceneManager.clear();
        _theme.setDefault();

        if (_mustReloadResources) {
            _resourceManager = new ResourceManager();
            setupDefaultResourceLoaders(_resourceManager);
            _resourceFiles.length = 0;
            _compiledResourceFiles.length = 0;
            loadResources();
        }

        if (_mustReloadScript && _compileFunc) {
            _bytecode = _compileFunc(_libraries);
        }
        _startVM();
    }

    void loadResources() {
        _loadArchives();
        _compileResources();
        _loadResources();
    }

    void run() {
        if (_compileFunc) {
            _bytecode = _compileFunc(_libraries);
        }
        _startVM();

        _tickStartFrame = Clock.currStdTime();
        float accumulator = 0f;

        while (!_inputManager.hasQuit() && _isRunning) {
            long deltaTicks = Clock.currStdTime() - _tickStartFrame;
            double deltatime = (cast(float)(deltaTicks) / 10_000_000f) * _nominalFPS;
            _currentFps = (deltatime == .0f) ? .0f : (10_000_000f / cast(float)(deltaTicks));
            _tickStartFrame = Clock.currStdTime();

            accumulator += deltatime;

            if (_mustReload) {
                _reload();
            }

            // Màj
            while (accumulator >= 1f) {
                InputEvent[] inputEvents = _inputManager.pollEvents();

                _window.update();

                foreach (InputEvent event; inputEvents) {
                    _uiManager.dispatch(event);
                }

                if (_engine) {
                    if (_engine.hasTasks) {
                        _engine.process();
                    }

                    if (_engine.isPanicking) {
                        string err = "panique: " ~ _engine.panicMessage ~ "\n";
                        foreach (trace; _engine.stackTraces) {
                            err ~= "[" ~ to!string(
                                trace.pc) ~ "] dans " ~ trace.name ~ " à " ~ trace.file ~ "(" ~ to!string(
                                trace.line) ~ "," ~ to!string(trace.column) ~ ")\n";
                        }
                        _engine = null;
                        log(err);
                        return;
                    }
                }

                _sceneManager.update(inputEvents);
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
