/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.audio.mixer;

import std.stdio;
import std.conv : to;
import std.exception : enforce;
import std.string : fromStringz;
import bindbc.sdl;

import atelier.common;
import atelier.scene;
import atelier.audio.bus;
import atelier.audio.config;
import atelier.audio.output;
import atelier.audio.sound;
import atelier.audio.voice;

/// Gestionnaire audio
final class AudioMixer {
    private {
        AudioOutput _output;
        AudioBus _masterBus;
    }

    @property {
        AudioBus master() {
            return _masterBus;
        }
    }

    /// Init
    this() {
        _masterBus = AudioBus.getMaster();
        _output = new AudioOutput(_masterBus);

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
        //writeln("Mixer: ", _mixer.frame, " Device: ", _output.frame, " success: ",
        //    _output.frameSuccess, " failure: ", _output.frameFailure, " wait: ", _output.waitFrame);
    }

    /// Joue un son
    void play(Sound sound) {
        _masterBus.play(new SoundVoice(sound));
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
