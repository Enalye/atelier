module atelier.env.system;

import std.conv : to;
import std.path : buildNormalizedPath, setExtension;

import atelier.env.data;

final class Env {
    private {
        EnvData _current;
    }

    this() {
        _current = new EnvData;
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

    void load(int index) {
        _current.load(getFilePath(index));
    }

    void save(int index) {
        _current.save(getFilePath(index));
    }

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
