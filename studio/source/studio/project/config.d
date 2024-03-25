/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.project.config;

import std.file;
import farfadet;

final class ProjectSettings {
    private {
        Config[] _configs;
        string _defaultConfig;
    }

    void load(string filePath) {
        Farfadet ffd = Farfadet.fromFile(filePath);
        _defaultConfig = ffd.getNode("default", 1).get!string(0);

        _configs.length = 0;
        foreach (configNode; ffd.getNodes("config")) {
            Config config = new Config;
            config.load(configNode);
            _configs ~= config;
        }
    }

    void save(string filePath) {
        Farfadet ffd = new Farfadet;
        ffd.addNode("default").add(_defaultConfig);
        foreach (config; _configs) {
            config.save(ffd);
        }
        ffd.save(filePath);
    }
}

final class Config {
    class Resource {
        string name;
        string path;
        bool isArchived;
    }

    private {
        string _name;
        string _srcPath, _exportPath;

        Resource[] _resources;

        bool _hasWindow;
        string _title;
        string _icon;
        uint _width, _height;
    }

    this() {

    }

    void load(Farfadet ffd) {
        _name = ffd.get!string(0);
        _srcPath = ffd.getNode("source", 1).get!string(0);
        _exportPath = ffd.getNode("export", 1).get!string(0);

        _resources.length = 0;
        foreach (resNode; ffd.getNodes("resource", 1)) {
            Resource res = new Resource;
            res.name = resNode.get!string(0);
            res.path = resNode.getNode("path", 1).get!string(0);
            res.isArchived = resNode.getNode("archived", 1).get!bool(0);
            _resources ~= res;
        }

        _hasWindow = ffd.hasNode("window");

        if (_hasWindow) {
            Farfadet windowNode = ffd.getNode("window");
            Farfadet sizeNode = windowNode.getNode("size", 2);
            _width = sizeNode.get!uint(0);
            _height = sizeNode.get!uint(1);

            _title = "";
            if (windowNode.hasNode("title")) {
                _title = windowNode.getNode("title").get!string(0);
            }
            _icon = "";
            if (windowNode.hasNode("icon")) {
                _icon = windowNode.getNode("icon").get!string(0);
            }
        }
    }

    void save(Farfadet ffd) {
        Farfadet configNode = ffd.addNode("config").add(_name);
        configNode.addNode("source").add(_srcPath);
        configNode.addNode("export").add(_exportPath);

        foreach (res; _resources) {
            Farfadet resNode = configNode.addNode("resource").add(res.name);
            resNode.addNode("path").add(res.path);
            resNode.addNode("archived").add(res.isArchived);
        }

        if (_hasWindow) {
            Farfadet windowNode = configNode.addNode("window");
            windowNode.addNode("size").add(_width).add(_height);
            windowNode.addNode("title").add(_title);
            windowNode.addNode("icon").add(_icon);
        }
    }
}
