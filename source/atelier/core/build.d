module atelier.core.build;

import core.thread;
import std.datetime, std.conv;
import std.exception : enforce;
import std.format;
import std.file;
import std.path;
import std.process;
import std.string;
import std.zlib;

import farfadet;
import grimoire;

import atelier.common;
import atelier.physics;
import atelier.script;
import atelier.render;
import atelier.ui;
import atelier.core.runtime;

private enum ProgressStatus {
    none,
    success,
    failure
}

private {
    float _progressValue = 0f;
}

private shared {
    ProgressStatus _progressStatus;
    string _exeLog;
}

final class ProjectBuilder : Modal {
    private struct ArchiveData {
        string path;
        bool isArchived;
    }

    private enum Step {
        starting,
        cleaningFolder,
        buildingConfig,
        packingArchives,
        compilingScripts,
        compilingExe,
        finished
    }

    private {
        Label _title;
        ProgressBar _progressBar;
        AccentButton _okBtn;
        Label _logLabel;

        GrCompiler _compiler;
        ArchiveData[] _archives;
        CompileExeThread _appThread;
        string _log;

        Step _currentStep = Step.starting;
        uint _iteration, _maxIteration;
        Timer _timer;
        uint _titleDots;
    }

    this() {
        setAlign(UIAlignX.center, UIAlignY.center);
        setSize(Vec2f(600f, 200f));

        _progressValue = 0f;

        {
            _title = new Label("Export en cours", Atelier.theme.font);
            _title.setAlign(UIAlignX.center, UIAlignY.top);
            _title.setPosition(Vec2f(0f, 4f));
            addUI(_title);
        }

        {
            _progressBar = new ProgressBar;
            _progressBar.setAlign(UIAlignX.center, UIAlignY.bottom);
            _progressBar.setPosition(Vec2f(0f, 125f));
            addUI(_progressBar);
        }

        {
            _logLabel = new Label("", Atelier.theme.font);
            _logLabel.setPosition(Vec2f(0f, 75f));
            _logLabel.setAlign(UIAlignX.center, UIAlignY.bottom);
            addUI(_logLabel);
        }

        {
            _okBtn = new AccentButton("OK");
            _okBtn.setAlign(UIAlignX.center, UIAlignY.bottom);
            _okBtn.setPosition(Vec2f(0f, 10f));
            _okBtn.isEnabled = false;
            _okBtn.addEventListener("click", &removeUI);
            addUI(_okBtn);
        }

        addEventListener("update", &_onUpdate);
    }

    private void _setStep(Step step) {
        _currentStep = step;
        _iteration = 0;
    }

    private void _cleanExportFolder() {
        _maxIteration = 1;
        _log = "Préparation du dossier.";

        // Nettoie le dossier export
        void clearDir(DirEntry dir) {
            auto entries = dirEntries(dir, SpanMode.shallow);
            foreach (entry; entries) {
                try {
                    if (entry.isDir) {
                        clearDir(entry);
                        entry.remove();
                    }
                    else if (entry.isFile) {
                        entry.remove();
                    }
                }
                catch (Exception e) {
                    Atelier.log("Erreur suppression: ", entry.name, " - ", e.msg);
                }
            }
        }

        string exportPath = buildNormalizedPath(getcwd(), Atelier_Export_Folder);
        clearDir(DirEntry(exportPath));

        _setStep(Step.buildingConfig);
    }

    private void _buildConfig() {
        _maxIteration = 1;
        _log = "Configuration du projet.";

        _setupCompiler();

        // Configuration
        string configPath = buildNormalizedPath(getcwd(), Atelier_Configuration);
        if (!exists(configPath)) {
            Atelier.log("[ATELIER] Aucun fichier de projet, fin de l’export");
            return;
        }

        Farfadet configFfd = Farfadet.fromFile(configPath);
        foreach (mediaNode; configFfd.getNodes("media")) {
            string folder = mediaNode.get!string(0);
            bool isArchived = mediaNode.get!bool(1);

            string path = buildNormalizedPath(getcwd(), "media", folder);

            if (!exists(path)) {
                Atelier.log("Aucune archive `", folder, "` trouvé");
                continue;
            }
            _archives ~= ArchiveData(path, isArchived);
        }

        Physics.HurtboxLayer[32] hurtboxLayers;
        if (configFfd.hasNode("physics")) {
            Farfadet node = configFfd.getNode("physics");
            foreach (hurtboxLayerNode; node.getNodes("hurtboxLayer")) {
                uint layer = hurtboxLayerNode.get!uint(0);
                if (layer < 32) {
                    Physics.HurtboxLayer data;
                    data.load(hurtboxLayerNode);
                    hurtboxLayers[layer] = data;
                }
            }
        }

        string configExportPath = buildNormalizedPath(getcwd(), Atelier_Export_Folder, Atelier_Configuration_Compiled);
        OutStream stream = new OutStream;
        stream.write!string(Atelier_Environment_MagicWord);
        stream.write!uint(cast(uint) _archives.length);
        foreach (archiveData; _archives) {
            stream.write!string(archiveData.path);
            stream.write!bool(archiveData.isArchived);
        }
        for (uint i; i < 32; ++i) {
            hurtboxLayers[i].serialize(stream);
        }
        std.file.write(configExportPath, compress(stream.data));

        _setStep(Step.packingArchives);
    }

    private void _packArchives() {
        _maxIteration = cast(uint) _archives.length;

        if (_iteration >= _archives.length) {
            _setStep(Step.compilingScripts);
            return;
        }

        // Archives
        ArchiveData archiveData = _archives[_iteration];
        _iteration++;
        {
            _log = format("Préparation de l’archive `%s` (%d/%d).", archiveData.path, _iteration + 1, _maxIteration);

            Archive archive = new Archive;
            string exportPath = buildNormalizedPath(getcwd(), Atelier_Export_Folder,
                baseName(archiveData.path));

            if (!exists(archiveData.path)) {
                _log = format("le dossier `%s` n’existe pas", archiveData.path);
                _progressStatus = ProgressStatus.failure;
                return;
            }

            archive.pack(archiveData.path);

            if (archiveData.isArchived) {
                exportPath = setExtension(exportPath, Atelier_Archive_Extension);

                foreach (file; archive) {
                    const string ext = extension(file.name);
                    switch (ext) {
                    case Atelier_Resource_Extension:
                        Atelier.compileResource(file);
                        break;
                    case Atelier_Script_Extension:
                        _compiler.addSource(cast(string) file.data, file.path, 1);
                        file.isIgnored = true;
                        break;
                    default:
                        break;
                    }
                }
                archive.save(exportPath);
            }
            else {
                archive.unpack(exportPath);
            }
        }
    }

    // Init Script
    private void _setupCompiler() {
        _compiler = new GrCompiler(Atelier_Version_ID);
        foreach (library; Atelier.script.getLibraries()) {
            _compiler.addLibrary(library);
        }
    }

    // Compilation des scripts
    private void _compileScripts() {
        _maxIteration = 1;

        _log = "Compilation des scripts.";

        //GrOption options = GrOption.safe | GrOption.profile | GrOption.symbols;
        GrBytecode bytecode = _compiler.compile(GrOption.none, GrLocale.fr_FR);
        enforce!GrCompilerException(bytecode, _compiler.getError().prettify(GrLocale.fr_FR));

        string bytecodePath = buildNormalizedPath(getcwd(), Atelier_Export_Folder, Atelier_Bytecode_Compiled);
        bytecode.save(bytecodePath);

        _setStep(Step.compilingExe);
    }

    private void _compileExe() {
        _maxIteration = 1;
        if (_exeLog.length) {
            _log = format("Génération de l’exécutable.\n(%s)", _exeLog);
        }
        else {
            _log = "Génération de l’exécutable.";
        }

        if (_iteration == 0) {
            _appThread = new CompileExeThread();
            _appThread.start();
            _iteration = 1;
        }
        else {
            if (_appThread) {
                if (_appThread.isRunning())
                    _okBtn.isEnabled = false;
                else {
                    _appThread = null;

                    if (_progressStatus == ProgressStatus.success) {
                        _log = "Compilation réussie.";
                        _logLabel.text = _log;
                    }
                    else {
                        if (_exeLog.length) {
                            _log = format("Échec de la compilation.\n(%s)", _exeLog);
                        }
                        else {
                            _log = "Échec de la compilation.";
                        }
                        _logLabel.text = _log;
                    }
                    _setStep(Step.finished);
                }
            }
        }
    }

    private void _onUpdate() {
        if (_progressStatus != ProgressStatus.failure) {
            final switch (_currentStep) with (Step) {
            case starting:
                _setStep(Step.cleaningFolder);
                break;
            case cleaningFolder:
                _cleanExportFolder();
                _progressValue = 0.1f;
                break;
            case buildingConfig:
                _buildConfig();
                _progressValue = 0.2f;
                break;
            case packingArchives:
                _packArchives();
                _progressValue = lerp(0.2f, 0.7f, (cast(float) _iteration / cast(float) _maxIteration));
                break;
            case compilingScripts:
                _compileScripts();
                _progressValue = 0.8f;
                break;
            case compilingExe:
                _compileExe();
                _progressValue = 0.9f;
                break;
            case finished:
                _progressValue = 1f;
                _maxIteration = 1;
                _okBtn.isEnabled = true;
                _title.text = "Export terminé";
                break;
            }

            if (_timer.isRunning) {
                _timer.update();
            }
            else if (_currentStep != Step.finished) {
                _timer.start(30);
                string txt = "Export en cours";
                _titleDots++;
                if (_titleDots >= 4)
                    _titleDots = 0;

                for (uint i; i < _titleDots; ++i) {
                    txt ~= '.';
                }
                _title.text = txt;
            }

            if (_logLabel.text != _log) {
                _logLabel.text = _log;
            }
        }
        else {
            _title.text = "Échec de l’export";
        }
    }
}

final class ProgressBar : UIElement {
    private {
        WritableTexture _barTexture;
        Sprite _barSprite;
        Timer _timer;
        float _barRatio = 0f;
        float _lastBarRatio = 0f;
    }

    this() {
        setSize(Vec2f(500f, 25f));

        _barTexture = new WritableTexture(500, 25);
        _barSprite = new Sprite(_barTexture);
        _barSprite.anchor = Vec2f.zero;
        addImage(_barSprite);
        _reload();

        _timer.mode = Timer.Mode.bounce;
        _timer.start(30);

        addEventListener("update", &_onUpdate);
    }

    private void _reload() {
        struct RasterData {
            float lastBarRatio, barRatio;
            ProgressStatus status;
        }

        RasterData rasterData;
        rasterData.lastBarRatio = _lastBarRatio;
        rasterData.barRatio = _barRatio;
        rasterData.status = _progressStatus;

        _barTexture.update(function(uint* dest, uint texWidth,
                uint texHeight, void* data_) {
            RasterData* data = cast(RasterData*) data_;
            int greenArea = cast(int)(texWidth * data.lastBarRatio);
            int whiteArea = cast(int)(texWidth * data.barRatio);

            uint color1 = data.status == ProgressStatus.failure ? 0xd95763ff : 0x99e550ff;
            uint color2 = data.status == ProgressStatus.failure ? 0xac3232ff : 0x6abe30ff;

            for (int iy; iy < texHeight; ++iy) {
                for (int ix; ix < texWidth; ++ix) {
                    if ((ix < iy) || ix >= texWidth - (texHeight - iy)) {
                        dest[iy * texWidth + ix] = 0x00000000;
                    }
                    else if ((ix - iy) <= greenArea) {
                        dest[iy * texWidth + ix] = iy < 5 ? color1 : color2;
                    }
                    else if ((ix - iy) <= whiteArea) {
                        dest[iy * texWidth + ix] = iy < 5 ? 0xffffffff : 0xcbdbfcff;
                    }
                    else {
                        dest[iy * texWidth + ix] = iy < 5 ? 0x696a6aff : 0x595652ff;
                    }
                }
            }
        }, &rasterData);
    }

    private void _onUpdate() {
        _timer.update();
        _barRatio = _progressValue;

        _lastBarRatio = lerp(_lastBarRatio, _barRatio, .1f);
        _reload();
    }
}

final class CompileExeThread : Thread {
    this() {
        super(&_run);
    }

    /// thread
    void _run() {
        import std.process;
        import std.stdio : writeln;

        ProcessPipes process;

        try {
            process = pipeProcess(
                [
                "dub", "build", "--compiler=ldmd2", "--config=export",
                "--build=release-nobounds"
            ], Redirect.stdout | Redirect.stderr);
            scope (exit) {
                wait(process.pid);
            }

            long _tickStartFrame;
            _tickStartFrame = Clock.currStdTime();

            for (;;) {
                string txt = process.stdout.readln();

                if (txt.length) {
                    txt = txt.chomp().strip();
                    _exeLog = txt;
                }

                auto call = tryWait(process.pid);
                if (call.terminated) {
                    if (call.status == 0) {
                        _progressStatus = ProgressStatus.success;
                    }
                    else
                        _progressStatus = ProgressStatus.failure;
                    return;
                }

                long deltaTicks = Clock.currStdTime() - _tickStartFrame;
                const long fps = 10;
                if (deltaTicks < (10_000_000 / fps))
                    Thread.sleep(dur!("hnsecs")((10_000_000 / fps) - deltaTicks));
                _tickStartFrame = Clock.currStdTime();
            }
        }
        catch (Exception e) {
            _progressStatus = ProgressStatus.failure;
        }
    }
}
