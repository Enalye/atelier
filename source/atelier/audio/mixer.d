module atelier.audio.mixer;

import std.stdio;
import std.conv : to;
import std.exception : enforce;
import std.string : fromStringz;
import bindbc.sdl;

import atelier.common;
import atelier.audio.bus;
import atelier.audio.config;
import atelier.audio.effect;
import atelier.audio.fader;
import atelier.audio.input;
import atelier.audio.music;
import atelier.audio.musicplayer;
import atelier.audio.output;
import atelier.audio.player;
import atelier.audio.recorder;
import atelier.audio.sound;
import atelier.audio.soundplayer;

/// Gestionnaire audio
final class AudioMixer {
    private {
        AudioOutput _output;
        AudioInput _input;
        AudioBus _masterBus, _trackBus;
        MusicPlayer[] _tracks;
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
    }

    void close() {
        closeInput();
        _output.close();
    }

    void openInput(string deviceName = "") {
        closeInput();
        _input = new AudioInput(deviceName);
    }

    void closeInput() {
        if (_input) {
            _input.clear();
            _input = null;
        }
    }

    void clear() {
        if (_input) {
            _input.clear();
        }
        _masterBus.clear();
        _trackBus.clear();
        _trackBus.connectTo(_masterBus);
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

    /// Enregistre un son depuis l’entrée audio
    void record(AudioRecorder recorder) {
        if (_input) {
            _input.record(recorder);
        }
    }

    /// Joue un son sur le bus maître
    void play(AudioPlayer player) {
        _masterBus.play(player);
    }

    void playTrack(Music music, float fadeOut) {
        if (_tracks.length) {
            MusicPlayer oldPlayer = _tracks[$ - 1];
            _tracks.length--;

            AudioFader fader = new AudioFader;
            fader.isFadeIn = false;
            fader.duration = fadeOut;
            fader.spline = Spline.linear;

            oldPlayer.addEffect(fader);
            oldPlayer.stop(fadeOut);
        }
        else {
            fadeOut = 0f;
        }
        MusicPlayer player = new MusicPlayer(music, fadeOut);
        _tracks ~= player;
        _trackBus.play(player);
    }

    void stopTrack(float fadeOut) {
        if (_tracks.length) {
            MusicPlayer oldPlayer = _tracks[$ - 1];
            _tracks.length--;

            AudioFader fader = new AudioFader;
            fader.isFadeIn = false;
            fader.duration = fadeOut;
            fader.spline = Spline.linear;

            oldPlayer.addEffect(fader);
            oldPlayer.stop(fadeOut);
        }
    }

    void pushTrack(Music music, float fadeOut) {
        pauseTrack(fadeOut);

        MusicPlayer player = new MusicPlayer(music, fadeOut);
        _tracks ~= player;
        _trackBus.play(player);
    }

    void popTrack(float fadeOut, float delay, float fadeIn) {
        stopTrack(fadeOut);

        if (!_tracks.length)
            return;

        MusicPlayer player = _tracks[$ - 1];

        AudioFader fader = new AudioFader;
        fader.isFadeIn = true;
        fader.duration = fadeIn;
        fader.spline = Spline.linear;
        fader.delay = delay;

        player.addEffect(fader);
        player.resume(delay);
    }

    void pauseTrack(float fadeOut) {
        if (!_tracks.length)
            return;

        MusicPlayer player = _tracks[$ - 1];

        AudioFader fader = new AudioFader;
        fader.isFadeIn = false;
        fader.duration = fadeOut;
        fader.spline = Spline.linear;

        player.addEffect(fader);
        player.pause(fadeOut);
    }

    void resumeTrack(float fadeIn) {
        if (!_tracks.length)
            return;

        MusicPlayer player = _tracks[$ - 1];

        AudioFader fader = new AudioFader;
        fader.isFadeIn = true;
        fader.duration = fadeIn;
        fader.spline = Spline.linear;

        player.addEffect(fader);
        player.resume();
    }

    void playTrackInBetween(Music music, float fadeOut = 2f) {
    }
}
