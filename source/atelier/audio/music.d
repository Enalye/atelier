/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.audio.music;

import std.stdio;
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
        float _loopStart = -1f;
        float _loopEnd = -1f;
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
        float loopStart() const {
            return _loopStart;
        }

        /// Ditto
        float loopStart(float loopStart_) {
            return _loopStart = loopStart_;
        }

        /// Fin de la boucle
        float loopEnd() const {
            return _loopEnd;
        }

        /// Ditto
        float loopEnd(float loopEnd_) {
            return _loopEnd = loopEnd_;
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

    /// Charge depuis un fichier
    this(string filePath) {
        AudioStream stream;
        _data = Atelier.res.read(filePath);
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
        _loopStart = music._loopStart;
        _loopEnd = music._loopEnd;
    }

    /// Accès à la ressource
    Music fetch() {
        return this;
    }
}
