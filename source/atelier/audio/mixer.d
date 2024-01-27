module atelier.audio.mixer;

import std.stdio;
import std.conv : to;
import std.exception : enforce;
import std.string : fromStringz;
import bindbc.sdl;

import atelier.common;
import atelier.scene;
import atelier.audio.device;
import atelier.audio.sound;
import atelier.audio.bus;

/// Gestionnaire audio
final class AudioMixer {
    private {
        AudioDevice _device;
        AudioBus _masterBus;
    }

    @property {
        AudioBus master() {
            return _masterBus;
        }
    }

    /// Init
    this() {
        _masterBus = AudioBus.createMaster();
        _device = new AudioDevice(_masterBus, 48_000, 128);

        writeln(getDevices(false));
        writeln(getDevices(true));
    }

    ~this() {
        close();
    }

    void close() {
    }

    string[] getDevices(bool capture) {
        string[] devices;
        int captureFlag = capture ? 1 : 0;
        const int count = SDL_GetNumAudioDevices(captureFlag);

        foreach (deviceId; 0 .. count) {
            string deviceName = to!string(fromStringz(SDL_GetAudioDeviceName(deviceId,
                    captureFlag)));
            devices ~= deviceName;
        }

        return devices;
    }

    /// Màj
    void update() {
        //writeln("Mixer: ", _mixer.frame, " Device: ", _device.frame, " success: ",
        //    _device.frameSuccess, " failure: ", _device.frameFailure, " wait: ", _device.waitFrame);
    }

    /// Joue un son
    void play(Sound sound) {
        _masterBus.play(sound.play());
    }

    /// Joue un son
    void play(Sound sound, Entity entity) {
    }

    void playMusic(Sound sound) {
    }

    void stopMusic() {
    }

    void pushMusic(Sound sound) {
    }

    void popMusic() {
    }

    void pauseMusic() {
    }

    void resumeMusic() {
    }

    void playInBetween(Sound sound) {
    }
}
