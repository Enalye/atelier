/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.audio.music;

import std.stdio;
import audioformats;
import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.audio.musicvoice;

/// Représente les données d’un son
final class Music : Resource!Music {
    private {
        const(ubyte)[] _data;
        ubyte _channels;
        ulong _samples;
        int _sampleRate;
        float _volume = 1f;
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
    this(Music sound) {
        _data = sound._data;
        _channels = sound._channels;
        _samples = sound._samples;
        _sampleRate = sound._sampleRate;
    }

    /// Accès à la ressource
    Music fetch() {
        return this;
    }

    MusicVoice createVoice() {
        return new MusicVoice(this);
    }
}
