/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.audio.music;

import std.stdio;
import std.file;
import audioformats;
import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.audio.musicplayer;

/// Représente les données d’un son
final class Music : Resource!Music {
    private {
        const(ubyte)[] _data;
        ubyte _channels;
        ulong _samples;
        int _sampleRate;
        float _volume = 1f;
        float _intro = -1f;
        float _outro = -1f;
    }

    @property {
        /// Volume entre 0 et 1
        float volume() const {
            return _volume;
        }

        /// Ditto
        float volume(float volume_) {
            return _volume = clamp(volume_, 0f, 1f);
        }

        /// Début de la boucle
        float intro() const {
            return _intro;
        }

        /// Ditto
        float intro(float intro_) {
            return _intro = intro_;
        }

        /// Fin de la boucle
        float outro() const {
            return _outro;
        }

        /// Ditto
        float outro(float outro_) {
            return _outro = outro_;
        }

        const(ubyte)[] data() const {
            return _data;
        }

        ubyte channels() const {
            return _channels;
        }

        ulong samples() const {
            return _samples;
        }

        int sampleRate() const {
            return _sampleRate;
        }
    }

    static Music fromMemory(const(ubyte)[] data) {
        return new Music(data);
    }

    static Music fromFile(string filePath) {
        return new Music(cast(const(ubyte)[]) std.file.read(filePath));
    }

    static Music fromResource(string filePath) {
        return new Music(Atelier.res.read(filePath));
    }

    /// Charge depuis un fichier
    this(const(ubyte)[] data) {
        AudioStream stream;
        _data = data;
        stream.openFromMemory(_data);

        _channels = cast(ubyte) stream.getNumChannels();
        _samples = stream.getLengthInFrames();
        assert(_samples != audiostreamUnknownLength);

        _sampleRate = cast(int) stream.getSamplerate();
    }

    /// Copie
    this(Music music) {
        _data = music._data;
        _channels = music._channels;
        _samples = music._samples;
        _sampleRate = music._sampleRate;
        _volume = music._volume;
        _intro = music._intro;
        _outro = music._outro;
    }

    /// Accès à la ressource
    Music fetch() {
        return this;
    }
}
