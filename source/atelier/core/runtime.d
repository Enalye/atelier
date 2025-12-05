module atelier.core.runtime;

import core.thread;
import std.path, std.file, std.exception;
import std.datetime, std.conv;
import std.zlib;

import farfadet;
import grimoire;

import atelier.audio;
import atelier.common;
import atelier.env;
import atelier.input;
import atelier.locale;
import atelier.nav;
import atelier.physics;
import atelier.render;
import atelier.script;
import atelier.ui;
import atelier.world;
import atelier.console;
import atelier.etabli;

import atelier.core.build;
import atelier.core.loader;
import atelier.core.logger;
import atelier.core.theme;
import atelier.core.window;
import atelier.core.vignette;
import atelier.core.overlay;

final class Atelier {
    static private {
        // Informations
        bool _isRedist, _isRunning;
        bool _mustReload, _mustReloadResources, _mustReloadScript;
        string[] _startCommands;

        // Événements
        GrEvent _inputEvent, _lateInputEvent;

        // Ressources
        struct ArchiveData {
            string path;
            bool isArchived;
        }

        ArchiveData[] _archives;
        Archive.File[] _resourceFiles, _compiledResourceFiles;

        alias ResourceLoaderFunc = void function(ResourceManager);
        alias ModuleLoaderFunc = GrModuleLoader[]function();
        ResourceLoaderFunc _loader;

        // IPS
        float _currentFps;
        long _tickStartFrame;
        int _nominalFPS = 60;
        uint _freezeFrames = 0;
        float _timeScale = 1f;

        bool _isSlowingDown = false;
        uint _slowDownFrames = 0;
        float _slowDownFactor = 1f;
        float _currentSlowDownFactor = 1f;
        uint _slowDownDurationIn;
        uint _slowDownDurationOut;
        SplineFunc _slowDownSplineFuncIn;
        SplineFunc _slowDownSplineFuncOut;

        // Modules
        Window _window;
        Renderer _renderer;
        UIManager _uiManager;
        InputManager _inputManager;
        Physics _physics;
        ResourceManager _resourceManager;
        AudioMixer _audioMixer;
        World _world;
        NavMesh _navMesh;
        Env _env;
        Console _console;
        Script _script;
        RNG _rng;
        Theme _theme;
        Overlay _overlay;
        Vignette _vignette;
        Locale _locale;

        version (AtelierEtabli) {
            Etabli _etabli;
        }
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

        /// Le gestionnaire de la physique
        Physics physics() {
            return _physics;
        }

        /// Le gestionnaire du monde
        World world() {
            return _world;
        }

        /// Le navigation
        NavMesh nav() {
            return _navMesh;
        }

        /// Environnement
        Env env() {
            return _env;
        }

        /// Le terminal de commande
        Console console() {
            return _console;
        }

        /// Générateur standard de pseudo-aléatoire
        RNG rng() {
            return _rng;
        }

        /// Système de script
        Script script() {
            return _script;
        }

        Theme theme() {
            return _theme;
        }

        Locale locale() {
            return _locale;
        }

        /// Éditeur
        version (AtelierEtabli) {
            Etabli etabli() {
                return _etabli;
            }
        }
        else {
            Etabli etabli() {
                enforce(false, "[Atelier] Atelier n’est pas en configuration d’éditeur");
                return null;
            }
        }
    }

    static void openLogger(bool isRedist_) {
        _logger_openLogger(isRedist_);
    }

    static void closeLogger() {
        _logger_closeLogger();
    }

    static void log(T...)(T args) {
        _logger_log(args);
        if (_console) {
            _console.log(args);
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

        if (_audioMixer) {
            _audioMixer.close();
        }
    }

    static void addStartCommand(string command) {
        _startCommands ~= command;
    }

    static void setVignette(bool enable, Color color, uint duration) {
        _vignette.set(enable, color, duration);
    }

    static void setOverlay(Color color, float alpha, uint duration, Spline spline) {
        _overlay.set(color, alpha, duration, spline);
    }

    static void freeze(uint frames) {
        _freezeFrames = frames;
    }

    static void setTimeScale(float scale) {
        _timeScale = scale;
    }

    static float getTimeScale() {
        return _timeScale;
    }

    static void slowDown(float factor, uint inDuration, uint outDuration, Spline inSpline, Spline outSpline) {
        if (_isSlowingDown)
            return;

        _slowDownFactor = clamp(factor, 0f, 1f);
        _slowDownDurationIn = inDuration;
        _slowDownDurationOut = outDuration;
        _slowDownSplineFuncIn = getSplineFunc(inSpline);
        _slowDownSplineFuncOut = getSplineFunc(outSpline);
        _isSlowingDown = true;
        _slowDownFrames = 0;

        if (_slowDownDurationIn == 0) {
            _currentSlowDownFactor = _slowDownFactor;

            if (_slowDownDurationOut == 0) {
                _currentSlowDownFactor = 1f;
                _isSlowingDown = false;
            }
        }
    }

    this(uint windowWidth, uint windowHeight, string windowTitle, ResourceLoaderFunc resLoader, ModuleLoaderFunc libLoader) {
        this(false, windowWidth, windowHeight, windowTitle, resLoader, libLoader);
    }

    this(bool isRedist_, uint windowWidth,
        uint windowHeight, string windowTitle,
        ResourceLoaderFunc resLoader, ModuleLoaderFunc libLoader) {
        _isRedist = isRedist_;
        _isRunning = true;

        // Initialisation des modules
        _window = new Window(windowWidth, windowHeight);
        _window.title = windowTitle;
        _renderer = new Renderer(_window);
        _renderer.setupKernel();

        _uiManager = new UIManager();
        _inputManager = new InputManager();
        _audioMixer = new AudioMixer();
        _resourceManager = new ResourceManager();
        _world = new World();
        _navMesh = new NavMesh();
        _env = new Env();
        _physics = new Physics();
        _rng = new RNG();
        _theme = new Theme();
        _console = new Console();
        _script = new Script(libLoader);
        _vignette = new Vignette();
        _overlay = new Overlay();
        _locale = new Locale();

        version (AtelierEtabli) {
            _etabli = new Etabli;
        }

        _loader = resLoader;
        setupDefaultResourceLoaders(_resourceManager);
        if (_loader) {
            _loader(_resourceManager);
        }
    }

    static void addArchive(string path, bool isArchived = true) {
        _archives ~= ArchiveData(path, isArchived);
    }

    private static void _loadArchives() {
        foreach (archiveData; _archives) {
            log("[ATELIER] Chargement de l’archive `" ~ archiveData.path ~ "`...");
            long startTime = Clock.currStdTime();

            Archive archive = new Archive;

            if (isDir(archiveData.path)) {
                enforce(exists(archiveData.path), "le dossier `" ~ archiveData.path ~ "` n’existe pas");
                archive.pack(archiveData.path);
            }
            else if (extension(archiveData.path) == Atelier_Archive_Extension) {
                enforce(exists(archiveData.path), "l’archive `" ~ archiveData.path ~ "` n’existe pas");
                archive.load(archiveData.path);
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
                case Atelier_Script_Extension:
                    _script.addFile(file);
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

    static void build() {
        ProjectBuilder modal = new ProjectBuilder();
        Atelier.ui.pushModalUI(modal);
    }

    static void compileResource(Archive.File file) {
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
    }

    private static void _compileResources() {
        log("[ATELIER] Compilation des ressources...");
        long startTime = Clock.currStdTime();

        foreach (Archive.File file; _resourceFiles) {
            compileResource(file);
            _compiledResourceFiles ~= file;
        }
        _resourceFiles.length = 0;

        double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        log("  > Effectué en " ~ to!string(loadDuration) ~ "sec");
    }

    private static void _loadResources() {
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

    private static void _reload() {
        _mustReload = false;

        _audioMixer.clear();
        _uiManager.clearUI();
        _world.clear();
        _navMesh.clear();
        _physics.clear();
        _theme.setDefault();
        _console.clear();
        _vignette.clear();
        _overlay.clear();

        if (_mustReloadResources) {
            _resourceManager = new ResourceManager();
            setupDefaultResourceLoaders(_resourceManager);
            if (_loader) {
                _loader(_resourceManager);
            }
            _resourceFiles.length = 0;
            _compiledResourceFiles.length = 0;
            loadResources();
        }

        if (_mustReloadScript) {
            _script.reload();
        }
        _script.start();
    }

    static void loadConfig() {
        version (AtelierDebug) {
            string configPath = buildNormalizedPath(getcwd(), Atelier_Configuration);
            if (!exists(configPath))
                return;

            Farfadet configFfd = Farfadet.fromFile(configPath);
            foreach (mediaNode; configFfd.getNodes("media")) {
                string folder = mediaNode.get!string(0);
                bool isArchived = mediaNode.get!bool(1);

                string path = buildNormalizedPath(getcwd(), "media", folder);

                if (!exists(path)) {
                    Atelier.log("Aucune archive `", folder, "` trouvé");
                    continue;
                }
                addArchive(path, isArchived);
            }
            _physics.load(configFfd);
        }
        else {
            string configPath = buildNormalizedPath(getcwd(), Atelier_Configuration_Compiled);
            InStream stream = new InStream;
            stream.data = cast(ubyte[]) uncompress(std.file.read(configPath));
            if (stream.read!string() != Atelier_Environment_MagicWord)
                return;

            _archives.length = stream.read!uint();
            for (uint i; i < _archives.length; ++i) {
                _archives[i].path = stream.read!string();
                _archives[i].isArchived = stream.read!bool();
            }
            _physics.deserialize(stream);
        }
    }

    static void loadResources() {
        _loadArchives();
        _compileResources();
        _loadResources();
    }

    static void run() {
        _script.reload();
        _script.start();

        _tickStartFrame = Clock.currStdTime();
        float accumulator = 0f;

        foreach (command; _startCommands) {
            _console.runCommand(command);
        }
        _startCommands.length = 0;

        while (!_inputManager.hasQuit() && _isRunning) {
            long deltaTicks = Clock.currStdTime() - _tickStartFrame;
            double deltatime = (cast(float)(deltaTicks) / 10_000_000f) * _nominalFPS;
            _currentFps = (deltatime == .0f) ? .0f : (10_000_000f / cast(float)(deltaTicks));
            _tickStartFrame = Clock.currStdTime();

            if (_isSlowingDown) {
                if (_slowDownFrames > _slowDownDurationIn) {
                    float t = (_slowDownFrames - _slowDownDurationIn) / cast(float) _slowDownDurationOut;
                    _currentSlowDownFactor = lerp(_slowDownFactor, 1f, _slowDownSplineFuncOut(t));
                    _slowDownFrames++;

                    if (_slowDownFrames > (_slowDownDurationIn + _slowDownDurationOut)) {
                        _isSlowingDown = false;
                        _currentSlowDownFactor = 1f;
                    }
                }
                else {
                    float t = _slowDownFrames / cast(float) _slowDownDurationIn;
                    _currentSlowDownFactor = lerp(1f, _slowDownFactor, _slowDownSplineFuncIn(t));
                    _slowDownFrames++;

                    if (_slowDownFrames > _slowDownDurationIn) {
                        _currentSlowDownFactor = _slowDownFactor;
                    }
                }
            }
            accumulator += deltatime * _currentSlowDownFactor * _timeScale;

            if (_mustReload) {
                _reload();
            }

            // Màj
            while (accumulator >= 1f) {
                if (_freezeFrames > 0) {
                    accumulator -= 1f;
                    _freezeFrames--;
                    continue;
                }

                InputEvent[] inputEvents = _inputManager.pollEvents();

                _window.update();

                foreach (InputEvent event; inputEvents) {
                    if (!_console.dispatch(event)) {
                        _uiManager.dispatch(event);
                    }
                }
                //long startTime = Clock.currStdTime();

                _script.update();
                _world.update(inputEvents);
                _physics.update();
                _vignette.update();
                _uiManager.update();
                _overlay.update();

                //double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);

                /*if (loadDuration < _minDur) {
                    _minDur = loadDuration;
                }
                if (loadDuration > _maxDur) {
                    _maxDur = loadDuration;
                }
                import std.stdio;

                writeln("World.draw(ms) min: ", _minDur, ", max: ", _maxDur, " curr: ", loadDuration);
*/
                accumulator -= 1f;
            }

            // Rendu

            _renderer.startRenderPass();
            long startTime = Clock.currStdTime();
            _world.draw(cast(Vec2f) _renderer.center);
            _vignette.draw();
            _overlay.draw();
            _uiManager.draw();
            double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000.0);
            _renderer.endRenderPass();
            if (loadDuration < _minDur) {
                _minDur = loadDuration;
            }
            if (loadDuration > _maxDur) {
                _maxDur = loadDuration;
            }
            import std.stdio;

            //writeln("World.draw(ms) min: ", _minDur, ", max: ", _maxDur, " curr: ", loadDuration);

        }

        close();
    }

    private static {
        double _minDur = 1000.0;
        double _maxDur = 0.0;
    }
}
