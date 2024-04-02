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

private enum Default_SourceFileContent = `
event app {
    // Début du programme
    print("Bonjour le monde !");
}
`;

private enum Default_GitIgnoreContent = `
# Dossiers
export/

# Fichiers
*.pqt
*.atl
*.exe
*.dll
*.so
`;

final class Project {
    static private {
        ProjectSettings _settings;
        ProjectSettings.Config _currentConfig;
        string _directory, _path;
        bool _isOpen, _isDirty;
    }

    static string getDirectory() {
        return _directory;
    }

    static string getPath() {
        return _path;
    }

    static string getResPath() {
        return buildNormalizedPath(_directory, "res");
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
            _path = buildNormalizedPath(_directory, "atelier.ffd");
        }
        else {
            _path = path;
            _directory = dirName(_path);
        }
        _settings = new ProjectSettings;
        _settings.load(_path);
        _currentConfig = _settings.getConfig(_settings.getDefaultConfig());
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
        _path = buildNormalizedPath(_directory, "atelier.ffd");

        if (!exists(_directory))
            mkdir(_directory);

        string resPath = buildNormalizedPath(_directory, "res");
        if (!exists(resPath))
            mkdir(resPath);

        string exportPath = buildNormalizedPath(_directory, "export");
        if (!exists(exportPath))
            mkdir(exportPath);

        _settings = new ProjectSettings();
        _settings.setDefaultConfig(configName);
        _currentConfig = _settings.addConfig(configName);
        _currentConfig.setSource("src");
        _currentConfig.setExport("export");
        _currentConfig.setSourceFile(sourceFile);
        _currentConfig.setWindow(800, 600, configName, "");
        _settings.save(_path);

        std.file.write(buildNormalizedPath(_directory, ".gitignore"), Default_GitIgnoreContent);
        std.file.write(buildNormalizedPath(_directory, sourceFile), Default_SourceFileContent);
        _isOpen = true;
        _isDirty = false;

        updateTitle();
    }

    static void clearRessourceFolders() {
        if (!isOpen())
            return;

        _currentConfig.clearRessourceFolders();
    }

    static void addRessourceFolder(string name, bool isArchived) {
        if (!isOpen())
            return;

        _currentConfig.addRessourceFolder(name, isArchived);
    }

    static bool[string] getRessourceFolders() {
        if (!isOpen())
            return (bool[string]).init;

        return _currentConfig.getRessourceFolders();
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
