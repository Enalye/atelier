/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.project.settings;

import std.typecons;
import std.file;
import std.path;
import std.process;
import atelier;
import farfadet;

final class Project {
    static private {
        ProjectSettings _settings;
        ProjectSettings.Config _currentConfig;
        string _directory, _path;
        bool _isOpen, _isDirty;
    }

    static void setDirectory(string dir) {
        _directory = dir;
    }

    static string getDirectory() {
        return _directory;
    }

    static string getPath() {
        return _path;
    }

    static string getMediaDir() {
        return buildNormalizedPath(_directory, "media");
    }

    static bool isOpen() {
        return _isOpen;
    }

    static void close() {
        _isOpen = false;
    }

    static void open(string path) {
        if (isDir(path)) {
            _directory = path;
            _path = buildNormalizedPath(_directory, Atelier_Project_File);
        }
        else {
            _path = path;
            _directory = dirName(_path);
        }
        _settings = new ProjectSettings;
        _settings.load(_path);
        _currentConfig = _settings.getConfig(_settings.getDefault());
        _isOpen = true;
        _isDirty = false;

        updateTitle();
    }

    static void save() {
        if (!_isOpen)
            return;

        _settings.save(_path);

        _isDirty = false;
        updateTitle();
    }

    static void create(string path, string configName, string sourceFile) {
        _directory = path;

        generateProjectLayout(_directory, sourceFile);

        _settings = new ProjectSettings();
        _settings.setDefault(configName);
        _currentConfig = _settings.addConfig(configName);
        _currentConfig.setSource(sourceFile);
        _currentConfig.setWindow(Atelier_Window_Width_Default,
            Atelier_Window_Height_Default, configName, "");

        _path = buildNormalizedPath(_directory, Atelier_Project_File);
        _settings.save(_path);

        _isOpen = true;
        _isDirty = false;

        updateTitle();
    }

    static void clearMedias() {
        if (!isOpen())
            return;

        _currentConfig.clearMedias();
    }

    static void addMedia(string name, bool isArchived) {
        if (!isOpen())
            return;

        _currentConfig.addMedia(name, isArchived);
    }

    static bool[string] getMedias() {
        if (!isOpen())
            return (bool[string]).init;

        return _currentConfig.getMedias();
    }

    static void run() {
        string engine = relativePath("atelier.exe", thisExePath());
        spawnProcess([engine, "run", _directory]);
    }

    static void build() {
        string engine = relativePath("atelier.exe", thisExePath());
        spawnProcess([engine, "build", _directory]);
    }

    static void updateTitle() {
        Atelier.window.title = "Studio Atelier - " ~ getDirectory();
    }
}
