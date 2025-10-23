module atelier.env.data;

import std.file;
import std.zlib;

import farfadet;

import atelier.common;

package template isEnvType(T) {
    enum isEnvType = is(T == string) ||
        is(T == bool) ||
        is(T == int) ||
        is(T == uint) ||
        is(T == float);
}

final class EnvData {
    private {
        string _playerController;
        string _playerActor;
        string _scene, _teleporter;

        bool[string] _bools;
        int[string] _ints;
        uint[string] _uints;
        float[string] _floats;
        string[string] _strings;
    }

    void setPlayerActor(string id) {
        _playerActor = id;
    }

    string getPlayerActor() {
        return _playerActor;
    }

    void setPlayerController(string id) {
        _playerController = id;
    }

    string getPlayerController() {
        return _playerController;
    }

    void setScene(string scene, string teleporter) {
        _scene = scene;
        _teleporter = teleporter;
    }

    string getScene() {
        return _scene;
    }

    string getTeleporter() {
        return _teleporter;
    }

    T get(T)(string id) if (isEnvType!T) {
        static if (is(T == bool)) {
            return _bools[id];
        }
        else static if (is(T == int)) {
            return _ints[id];
        }
        else static if (is(T == uint)) {
            return _uints[id];
        }
        else static if (is(T == string)) {
            return _strings[id];
        }
        else static if (is(T == float)) {
            return _floats[id];
        }
        else {
            static assert(false, "type `" ~ T.stringof ~ "` non-supporté");
        }
    }

    void set(T)(string id, T value) if (isEnvType!T) {
        static if (is(T == bool)) {
            _bools[id] = value;
        }
        else static if (is(T == int)) {
            _ints[id] = value;
        }
        else static if (is(T == uint)) {
            _uints[id] = value;
        }
        else static if (is(T == string)) {
            _strings[id] = value;
        }
        else static if (is(T == float)) {
            _floats[id] = value;
        }
        else {
            static assert(false, "type `" ~ T.stringof ~ "` non-supporté");
        }
    }

    void has(T)(string id) if (isEnvType!T) {
        static if (is(T == bool)) {
            return (id in _bools) !is null;
        }
        else static if (is(T == int)) {
            return (id in _ints) !is null;
        }
        else static if (is(T == uint)) {
            return (id in _uints) !is null;
        }
        else static if (is(T == string)) {
            return (id in _strings) !is null;
        }
        else static if (is(T == float)) {
            return (id in _floats) !is null;
        }
        else {
            static assert(false, "type `" ~ T.stringof ~ "` non-supporté");
        }
    }

    void save(string filePath) {
        Farfadet ffd = new Farfadet();

        Farfadet envNode = ffd.addNode("env");

        {
            Farfadet playerNode = envNode.addNode("player");
            if (_playerActor.length)
                playerNode.addNode("actor").add(_playerActor);
            if (_playerController.length)
                playerNode.addNode("controller").add(_playerController);
            if (_scene.length)
                playerNode.addNode("scene").add(_scene);
            if (_teleporter.length)
                playerNode.addNode("teleporter").add(_teleporter);
        }

        Farfadet node;
        static foreach (stack; [
                "bool", "int", "uint", "float", "string"
            ]) {
            node = envNode.addNode(stack);

            mixin("foreach (key, value; _", stack, "s) {
                node.addNode(key).add(value);
            }");
        }

        std.file.write(filePath, cast(ubyte[]) compress(ffd.generate(0)));
    }

    void load(string filePath) {
        Farfadet ffd = Farfadet.fromBytes(cast(ubyte[]) uncompress(std.file.read(filePath)));

        Farfadet envNode = ffd.getNode("env");

        if (envNode.hasNode("player")) {
            Farfadet playerNode = envNode.getNode("player");
            if (playerNode.hasNode("actor"))
                _playerActor = playerNode.getNode("actor").get!string(0);
            if (playerNode.hasNode("controller"))
                _playerController = playerNode.getNode("controller").get!string(0);
            if (playerNode.hasNode("scene"))
                _scene = playerNode.getNode("scene").get!string(0);
            if (playerNode.hasNode("teleporter"))
                _teleporter = playerNode.getNode("teleporter").get!string(0);
        }

        static foreach (stack; [
                "bool", "int", "uint", "float", "string"
            ]) {
            if (envNode.hasNode(stack)) {
                Farfadet node = envNode.getNode(stack);
                foreach (subNode; envNode.getNodes()) {
                    mixin("_", stack, "s[subNode.name] = subNode.get!", stack, "(0);");
                }
            }
        }
    }
}
