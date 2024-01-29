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
import atelier.audio.music;
import atelier.audio.musicvoice;
import atelier.audio.soundvoice;
import atelier.audio.voice;
import atelier.audio.effect;
import atelier.audio.oscillator;

/// Gestionnaire audio
final class AudioMixer {
    private {
        AudioOutput _output;
        AudioBus _masterBus, _trackBus;
        MusicVoice[] _tracks;
    }

    @property {
        AudioBus master() {
            return _masterBus;
        }
    }

    /// Init
    this() {
        _masterBus = AudioBus.getMaster();
        _trackBus = new AudioBus();
        _trackBus.connectTo(_masterBus);

        _output = new AudioOutput(_masterBus);
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

    /// Joue une musique
    void play(Music music) {
        _masterBus.play(new MusicVoice(music));
    }

    void playTrack(Music music, float fadeOut) {
        if (_tracks.length) {
            MusicVoice oldVoice = _tracks[$ - 1];
            _tracks.length--;
            oldVoice.addEffect(new AudioFader(false, fadeOut, getSplineFunc(Spline.linear), 0f));
            oldVoice.stop(fadeOut);
        }
        else {
            fadeOut = 0f;
        }
        MusicVoice voice = new MusicVoice(music, fadeOut);
        _tracks ~= voice;
        _trackBus.play(voice);
    }

    void stopTrack(float fadeOut) {
        if (_tracks.length) {
            MusicVoice oldVoice = _tracks[$ - 1];
            _tracks.length--;
            oldVoice.addEffect(new AudioFader(false, fadeOut, getSplineFunc(Spline.linear), 0f));
            oldVoice.stop(fadeOut);
        }
    }

    void pushTrack(Music music, float fadeOut) {
        pauseTrack(fadeOut);

        MusicVoice voice = new MusicVoice(music, fadeOut);
        _tracks ~= voice;
        _trackBus.play(voice);
    }

    void popTrack(float fadeOut, float delay, float fadeIn) {
        stopTrack(fadeOut);

        if (!_tracks.length)
            return;

        MusicVoice voice = _tracks[$ - 1];
        voice.addEffect(new AudioFader(true, fadeIn, getSplineFunc(Spline.linear), delay));
        voice.resume(delay);
    }

    void pauseTrack(float fadeOut) {
        if (!_tracks.length)
            return;

        MusicVoice voice = _tracks[$ - 1];
        voice.addEffect(new AudioFader(false, fadeOut, getSplineFunc(Spline.linear), 0f));
        voice.pause(fadeOut);
    }

    void resumeTrack(float fadeIn) {
        if (!_tracks.length)
            return;

        MusicVoice voice = _tracks[$ - 1];
        voice.addEffect(new AudioFader(true, fadeIn, getSplineFunc(Spline.linear), 0f));
        voice.resume();
    }

    void playTrackInBetween(Music music, float fadeOut = 2f) {
    }
}
