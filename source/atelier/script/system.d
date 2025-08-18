module atelier.script.system;

version (AtelierEtabli) {
    import std.file : exists;
}

import std.conv : to;
import std.datetime;
import std.exception;
import grimoire;
import atelier.common;
import atelier.core;

import atelier.script.audio;
import atelier.script.common;
import atelier.script.core;
import atelier.script.input;
import atelier.script.render;
import atelier.script.world;
import atelier.script.ui;

private void _print(string msg) {
    Atelier.log(msg);
}

final class Script {
    private {
        GrEngine _engine;
        GrLibrary[] _libraries;
        GrBytecode _bytecode;
        Archive.File[] _files;
        bool _isEnabled = true;

        version (AtelierEtabli) {
            string[] _customFiles;
        }

        alias ModuleLoaderFunc = GrModuleLoader[]function();
        ModuleLoaderFunc _loader;
    }

    this(ModuleLoaderFunc loader) {
        _loader = loader;
        _libraries ~= grGetStandardLibrary();
        _libraries ~= _getScriptLibrary();
    }

    void setEnabled(bool value) {
        _isEnabled = value;

        if (!_isEnabled) {
            _engine = null;
            _bytecode = null;
        }
    }

    GrBytecode getBytecode() {
        return _bytecode;
    }

    GrLibrary[] getLibraries() {
        return _libraries;
    }

    /// Charge la bibliothèque
    private GrLibrary _getScriptLibrary() {
        GrLibrary library = new GrLibrary(0);

        foreach (loader; _getLibraryLoaders()) {
            library.addModule(loader);
        }

        return library;
    }

    /// Retourne les fonctions de chargement de la bibliothèque
    private GrModuleLoader[] _getLibraryLoaders() {
        GrModuleLoader[] loaders;

        static foreach (pack; [
                &getLibLoaders_audio, //
                &getLibLoaders_common, //
                &getLibLoaders_core, //
                &getLibLoaders_input, //
                &getLibLoaders_render, //
                &getLibLoaders_world, //
                &getLibLoaders_ui, //
            ]) {
            loaders ~= pack();
        }

        if (_loader) {
            loaders ~= _loader();
        }

        return loaders;
    }

    version (AtelierEtabli) {
        void setCustomFiles(string[] files) {
            _customFiles = files;
        }

        void addFile(Archive.File file) {
        }
    }
    else {
        void setCustomFiles(string[] files) {
        }

        void addFile(Archive.File file) {
            _files ~= file;
        }
    }

    private void _compile() {
        if (!_isEnabled)
            return;

        long startTime = Clock.currStdTime();

        version (AtelierEtabli) {
            Atelier.log("[ATELIER] Compilation des scripts personnalisés...");
        }
        else {
            Atelier.log("[ATELIER] Compilation des scripts...");
        }

        GrCompiler compiler = new GrCompiler(Atelier_Version_ID);
        foreach (library; _libraries) {
            compiler.addLibrary(library);
        }

        version (AtelierEtabli) {
            foreach (sourceFile; _customFiles) {
                if (exists(sourceFile)) {
                    compiler.addFile(sourceFile);
                }
            }
        }
        else {
            foreach (file; _files) {
                compiler.addSource(cast(string) file.data, file.path, 1);
            }
        }

        _bytecode = compiler.compile(
            GrOption.safe | GrOption.profile | GrOption.symbols,
            GrLocale.fr_FR);

        enforce!GrCompilerException(_bytecode, compiler.getError().prettify(GrLocale.fr_FR));

        double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        Atelier.log("  > Effectué en " ~ to!string(loadDuration) ~ "sec");
    }

    void reload() {
        version (AtelierEtabli) {
            try {
                _compile();
            }
            catch (GrCompilerException e) {
                Atelier.log("Erreur: ", e.msg);
            }
        }
        else {
            _compile();
        }
        //if (_compileFunc) {
        //    _bytecode = _compileFunc(_libraries);
        //}
        //else {
        //    _bytecode = null;
        //}
    }

    void start() {
        if (!_bytecode)
            return;

        Atelier.log("[ATELIER] Initialisation de la machine virtuelle...");
        long startTime = Clock.currStdTime();

        _engine = new GrEngine(Atelier_Version_ID);

        foreach (GrLibrary library; _libraries) {
            _engine.addLibrary(library);
        }

        enforce(_engine.load(_bytecode), "version du bytecode invalide");
        /*
        _engine.callEvent("app");

        _inputEvent = _engine.getEvent("input", [grGetNativeType("InputEvent")]);
        _lateInputEvent = _engine.getEvent("lateInput", [
                grGetNativeType("InputEvent")
            ]);*/

        _engine.setPrintOutput(&_print);

        double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        Atelier.log("  > Effectué en " ~ to!string(loadDuration) ~ "sec");
    }

    void update() {
        //Atelier.log("running: ", _engine);
        if (!_engine)
            return;

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
            Atelier.log(err);
            return;
        }
    }

    void killTasks() {
        if (!_engine)
            return;

        _engine.killTasks();
    }

    GrTask callEvent(const string name, const GrType[] signature = [], GrValue[] parameters = [
        ]) {
        if (!_engine)
            return null;

        return _engine.callEvent(name, signature, parameters);
    }

    GrTask callEvent(GrEvent event, GrValue[] parameters = []) {
        if (!_engine)
            return null;

        return _engine.callEvent(event, parameters);
    }

    /// Récupère l’événement correspondant au nom indiqué.
    GrEvent getEvent(const string name, const GrType[] signature = []) const {
        if (!_engine)
            return null;

        return _engine.getEvent(name, signature);
    }
}
