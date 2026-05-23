module atelier.state.system;

import std.format;
import std.random;
import std.algorithm;
import std.conv : to;
import std.path;
import std.file;
import std.datetime;
import std.zlib;

import farfadet;

import atelier.common;
import atelier.state.data;
import atelier.state.game;

final class SaveFile {
    uint order;
    string path;
    StateData data;
}

final class State {
    private {
        StateData _current;
        SaveFile _autoSaveFile;
        SaveFile[] _saveFiles;
    }

    this() {
        _current = new StateData;
    }

    private string getFilePath(int index) {
        string fileName;
        if (index < 0) {
            fileName = "auto";
        }
        else {
            fileName = to!string(index);
        }

        return buildNormalizedPath("save", setExtension(fileName, "save"));
    }

    /// Recherche et charge les sauvegardes sur le disque
    void loadSaves() {
        _autoSaveFile = null;
        _saveFiles.length = 0;

        string basePath = buildNormalizedPath("save");
        string autoSaveFilePath = buildNormalizedPath(basePath, setExtension("auto", "save"));

        if (exists(autoSaveFilePath)) {
            _autoSaveFile = _loadSaveFile(autoSaveFilePath);
        }

        auto files = dirEntries(basePath, "{*.save}", SpanMode.shallow);
        foreach (file; files) {
            if (file.isDir || baseName(file) == "auto")
                continue;

            SaveFile saveFile = _loadSaveFile(file);
            if (saveFile) {
                _saveFiles ~= saveFile;
            }
        }

        sort!((a, b) => (a.order < b.order), SwapStrategy.stable)(_saveFiles);
    }

    private SaveFile _loadSaveFile(string path) {
        try {
            InStream stream = new InStream;
            stream.set(cast(ubyte[]) uncompress(std.file.read(path)));

            if (stream.read!string() != "atelier.save")
                return null;

            SaveFile saveFile = new SaveFile;
            saveFile.path = path;
            saveFile.order = stream.read!uint();

            Farfadet ffd = Farfadet.fromBytes(stream.read!(ubyte[]));

            saveFile.data = new StateData;
            saveFile.data.load(ffd);
            return saveFile;
        }
        catch (Exception e) {
            return null;
        }
    }

    private void _writeSaveFile(SaveFile saveFile) {
        OutStream stream = new OutStream;

        stream.write!string("atelier.save");
        stream.write!uint(saveFile.order);

        Farfadet ffd = new Farfadet;
        saveFile.data.save(ffd);
        stream.write!(ubyte[])(cast(ubyte[]) ffd.generate(0));

        std.file.write(saveFile.path, cast(ubyte[]) compress(stream.data));
    }

    StateData getAutoSave() {
        return _autoSaveFile ? _autoSaveFile.data : null;
    }

    StateData[] getSaves() {
        StateData[] result;
        foreach (saveFile; _saveFiles) {
            result ~= saveFile.data;
        }
        return result;
    }

    void loadState(StateData state) {
        _current = state;
    }

    void saveAutoFile() {
        if (!_autoSaveFile)
            _autoSaveFile = new SaveFile;
        _autoSaveFile.path = buildNormalizedPath("save", setExtension("auto", "save"));
        _autoSaveFile.data = _current;
        _writeSaveFile(_autoSaveFile);
    }

    void loadAutoFile() {
        _current = _autoSaveFile.data;
    }

    void saveAsNewFile() {
        SaveFile saveFile = new SaveFile;
        string name;

        auto random = Random(unpredictableSeed);
        do {
            name = format("%d", random.uniform!uint());
            saveFile.path = buildNormalizedPath("save", setExtension(name, "save"));
        }
        while (exists(saveFile.path));

        if (_saveFiles.length) {
            _saveFiles = saveFile ~ _saveFiles;
        }
        else {
            _saveFiles ~= saveFile;
        }

        saveFile.data = _current;

        for (int i; i < _saveFiles.length; ++i) {
            _saveFiles[i].order = i;
            _writeSaveFile(_saveFiles[i]);
        }
    }

    void saveAsFile(uint index) {
        if (index >= _saveFiles.length)
            return;

        SaveFile saveFile = _saveFiles[index];
        saveFile.data = _current;

        _saveFiles.remove(index);
        _saveFiles = saveFile ~ _saveFiles;

        for (int i; i < _saveFiles.length; ++i) {
            _saveFiles[i].order = i;
            _writeSaveFile(_saveFiles[i]);
        }
    }

    void setGameData(BaseGameStateData data) {
        _current.setGameData(data);
    }

    void loadDefault() {
        _current.loadDefault();
    }
    /*
    void load(int index) {
        _current.load(getFilePath(index));
    }

    void save(int index) {
        _current.save(getFilePath(index));
    }*/

    void setPlayerActor(string id) {
        _current.setPlayerActor(id);
    }

    string getPlayerActor() {
        return _current.getPlayerActor();
    }

    void setPlayerController(string id) {
        _current.setPlayerController(id);
    }

    string getPlayerController() {
        return _current.getPlayerController();
    }

    void setScene(string scene, string teleporter) {
        _current.setScene(scene, teleporter);
    }

    string getScene() {
        return _current.getScene();
    }

    string getTeleporter() {
        return _current.getTeleporter();
    }

    void setTeleporterDirection(int dir) {
        _current.setTeleporterDirection(dir);
    }

    int getTeleporterDirection() {
        return _current.getTeleporterDirection();
    }

    T get(T)(string id) if (isEnvType!T) {
        return _current.get!T(id);
    }

    void set(T)(string id, T value) if (isEnvType!T) {
        _current.set!T(id, value);
    }

    void has(T)(string id) if (isEnvType!T) {
        _current.set!T(id);
    }
}
