module atelier.audio.trackplayer;

import std.exception : enforce;

import bindbc.openal;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.scene;

import atelier.audio.device;
import atelier.audio.sound;
import atelier.audio.voice;

/// Contexte audio
final class TrackPlayer {
    private {
        ALCcontext* _context;
        bool _isAlive = true;
        Array!TrackVoice _oldTracks;
        TrackVoice[] _tracks;
    }

    @property {
        bool isAlive() const {
            return _isAlive;
        }
    }

    /// Init
    package this(AudioDevice device) {
        _context = alcCreateContext(device.handle, null);
        _assertAlc();
        enforce(_context, "[Audio] impossible de créer le contexte");

        _oldTracks = new Array!TrackVoice;
    }

    package void setCurrent() {
        enforce(alcMakeContextCurrent(_context) == ALC_TRUE,
            "[Audio] impossible de mettre à jour le contexte");
        _assertAlc();
    }

    /// Update
    package void update() {
        setCurrent();
/*
        foreach (track; _tracks) {
            track.update();
        }

        foreach (i, track; _oldTracks) {
            track.update();

            if(!track.isPlaying)
                track.remove();

            if(!track.isAlive)
                _oldTracks.mark(i);
        }
        _oldTracks.sweep();
*/
        _assertAlc();
    }

    void remove() {
        if (!_isAlive)
            return;
        _isAlive = false;

        foreach (track; _tracks) {
            track.remove();
        }
        _tracks.length = 0;

        foreach (track; _oldTracks) {
            track.remove();
        }
        _oldTracks.clear();

        alcDestroyContext(_context);
    }

    /// Joue le son
    void play(Sound sound) {
        setCurrent();
        /*stop();
        TrackVoice voice = new TrackVoice(sound);
        _tracks ~= voice;
        voice.play();
        _assertAlc();*/
    }

    void stop() {
        setCurrent();
        /*if (_tracks.length) {
            _tracks[$ - 1].fadeOut();
            _oldTracks ~= _tracks[$ - 1];
            _tracks.length--;

            foreach (track; _tracks) {
                track.remove();
            }
            _tracks.length = 0;
        }*/
    }

    void push(Sound sound) {
        setCurrent();
        /*if (_tracks.length) {
            _tracks[$ - 1].fadeOut();
        }
        _tracks ~= sound;
        sound.play();*/
    }

    void pop() {
        setCurrent();
        /*if (_tracks.length) {
            _oldTracks ~= _tracks[$ - 1];
            _tracks[$ - 1].stop(60);
        }
        _tracks.length--;

        if (_tracks.length) {
            _tracks[$ - 1].start(0, 30);
        }*/
    }

    void pause() {
        setCurrent();
       /*if (_tracks.length) {
            _tracks[$ - 1].pause();
        }*/
    }

    void resume() {
        setCurrent();
        /*if (_tracks.length) {
            _tracks[$ - 1].resume();
        }*/
    }

    void playInBetween(Sound sound) {
        setCurrent();
        /*push(sound);*/

    }

    private void _assertAlc() {
        const ALCenum error = alcGetError(_context);
        switch (error) {
        case ALC_NO_ERROR:
            return;
        case ALC_INVALID_DEVICE:
            throw new Exception("ALC: matériel invalide");
        case ALC_INVALID_CONTEXT:
            throw new Exception("ALC: contexte invalide");
        case ALC_INVALID_ENUM:
            throw new Exception("ALC: énum invalide");
        case ALC_INVALID_VALUE:
            throw new Exception("ALC: valeur invalide");
        case ALC_OUT_OF_MEMORY:
            throw new Exception("ALC: mémoire manquante");
        default:
            throw new Exception("ALC: erreur inconnue");
        }
    }
}
