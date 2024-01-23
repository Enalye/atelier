module atelier.audio.manager;

import std.exception : enforce;
import bindbc.openal;

import atelier.common;
import atelier.scene;
import atelier.audio.device;
import atelier.audio.context;
import atelier.audio.sound;
import atelier.audio.source;
import atelier.audio.trackplayer;
import atelier.audio.voice;

/// Gestionnaire audio
final class AudioManager {
    private {
        AudioDevice _device;
        TrackPlayer _trackContext;
        AudioContext _globalContext;
        Array!AudioContext _sceneContextes;
    }

    /// Init
    this() {
        _device = new AudioDevice();
        _globalContext = new AudioContext(_device, null);
        _trackContext = new TrackPlayer(_device);
        _sceneContextes = new Array!AudioContext;
    }

    AudioContext createContext(Scene scene) {
        AudioContext context = new AudioContext(_device, scene);
        _sceneContextes ~= context;
        return context;
    }

    /// Màj
    void update() {
        _globalContext.update();

        foreach (i, context; _sceneContextes) {
            context.update();
        }

        _trackContext.update();
        _globalContext.setCurrent();
    }

    /// Joue un son
    void play(Sound sound) {
        _globalContext.play(sound);
    }

    /// Joue un son
    void play(Sound sound, Entity entity) {
        if (entity.scene) {
            entity.scene.audio.play(sound, entity);
        }
        else {
            play(sound);
        }
    }

    void playMusic(Sound sound) {
        _trackContext.play(sound);
    }

    void stopMusic() {
        _trackContext.stop();
    }

    void pushMusic(Sound sound) {
        _trackContext.push(sound);
    }

    void popMusic() {
        _trackContext.pop();
    }

    void pauseMusic() {
        _trackContext.pause();
    }

    void resumeMusic() {
        _trackContext.resume();
    }

    void playInBetween(Sound sound) {
        _trackContext.playInBetween(sound);
    }
}
