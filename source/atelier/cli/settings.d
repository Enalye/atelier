/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.cli.settings;

import std.file;
import farfadet;

final class ProjectSettings {
    class Config {
        private {
            string _name;
            string _srcPath, _exportPath, _srcName;

            bool[string] _resources;

            bool _hasWindow;
            string _title;
            string _icon;
            uint _width, _height;
        }

        this(string name_) {
            _name = name_;
        }

        void setSourceFile(string name) {
            _srcName = name;
        }

        void setSource(string path) {
            _srcPath = path;
        }

        void setExport(string path) {
            _exportPath = path;
        }

        void clearRessourceFolders() {
            _resources.clear();
        }

        void addRessourceFolder(string name, bool isArchived) {
            _resources[name] = isArchived;
        }

        bool[string] getRessourceFolders() {
            return _resources;
        }

        void setWindow(uint width, uint height, string title, string icon) {
            _width = width;
            _height = height;
            _title = title;
            _icon = icon;
            _hasWindow = true;
        }

        void removeWindow() {
            _hasWindow = false;
        }

        void load(Farfadet ffd) {
            _name = ffd.get!string(0);
            _srcPath = ffd.getNode("source", 1).get!string(0);
            _exportPath = ffd.getNode("export", 1).get!string(0);

            _resources.clear();
            foreach (resNode; ffd.getNodes("resource", 2)) {
                string name = resNode.get!string(0);
                bool isArchived = resNode.get!bool(1);
                _resources[name] = isArchived;
            }

            _hasWindow = ffd.hasNode("window");

            if (_hasWindow) {
                Farfadet windowNode = ffd.getNode("window");
                Farfadet sizeNode = windowNode.getNode("size", 2);
                _width = sizeNode.get!uint(0);
                _height = sizeNode.get!uint(1);

                _title = "";
                if (windowNode.hasNode("title")) {
                    _title = windowNode.getNode("title", 1).get!string(0);
                }
                _icon = "";
                if (windowNode.hasNode("icon")) {
                    _icon = windowNode.getNode("icon", 1).get!string(0);
                }
            }
        }

        void save(Farfadet ffd) {
            Farfadet configNode = ffd.addNode("config").add(_name);
            configNode.addNode("source").add(_srcPath);
            configNode.addNode("export").add(_exportPath);

            foreach (name, isArchived; _resources) {
                configNode.addNode("resource").add(name).add(isArchived);
            }

            if (_hasWindow) {
                Farfadet windowNode = configNode.addNode("window");
                windowNode.addNode("size").add(_width).add(_height);
                if (_title.length)
                    windowNode.addNode("title").add(_title);
                if (_icon.length)
                    windowNode.addNode("icon").add(_icon);
            }
        }
    }

    private {
        Config[string] _configs;
        string _defaultConfig;
    }

    void setDefaultConfig(string name) {
        _defaultConfig = name;
    }

    string getDefaultConfig() const {
        return _defaultConfig;
    }

    bool hasConfig(string name) {
        auto p = name in _configs;
        return p !is null;
    }

    Config addConfig(string name) {
        Config cfg = getConfig(name);
        if (cfg)
            return cfg;
        cfg = new Config(name);
        _configs[name] = cfg;
        return cfg;
    }

    Config getConfig(string name) {
        auto p = name in _configs;
        return p ? *p : null;
    }

    void load(string filePath) {
        Farfadet ffd = Farfadet.fromFile(filePath);
        _defaultConfig = ffd.getNode("default", 1).get!string(0);

        _configs.clear();
        foreach (configNode; ffd.getNodes("config", 1)) {
            Config config = new Config(configNode.get!string(0));
            config.load(configNode);
            _configs[config._name] = config;
        }
    }

    void save(string filePath) {
        Farfadet ffd = new Farfadet;
        if (_defaultConfig.length)
            ffd.addNode("default").add(_defaultConfig);
        foreach (config; _configs) {
            config.save(ffd);
        }
        ffd.save(filePath);
    }
}
