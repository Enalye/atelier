module atelier.audio.phoneme;

import std.exception : enforce;
import std.file;
import audioformats;
import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.audio.sound;

/// Représente les données d’un phonème
struct PhonemeData {
    string sound;
    float offset = -1f;
    float consonant = -1f;
    float vowel = -1f;
    float cutoff = -1f;
    float attack = 0f;
    bool isLooping = false;

    mixin Serializer;
}

/// Ditto
final class Phoneme : Resource!Phoneme {
    private {
        Sound _sound;
        float _offset = -1f;
        float _cutoff = -1f;
        float _consonant = -1f;
        float _vowel = -1f;
        float _attack = 0f;
        bool _isLooping = false;
    }

    @property {
        /// Son utilisé
        Sound sound() {
            return _sound;
        }

        // Ditto
        const(Sound) sound() const {
            return _sound;
        }

        /// Ditto
        Sound sound(Sound sound_) {
            return _sound = sound_;
        }

        bool isLooping() const {
            return _isLooping;
        }

        bool isLooping(bool value) {
            return _isLooping = value;
        }

        float offset() const {
            return _offset;
        }

        float offset(float value) {
            return _offset = value;
        }

        float cutoff() const {
            return _cutoff;
        }

        float cutoff(float value) {
            return _cutoff = value;
        }

        float consonant() const {
            return _consonant;
        }

        float consonant(float value) {
            return _consonant = value;
        }

        float vowel() const {
            return _vowel;
        }

        float vowel(float value) {
            return _vowel = value;
        }

        float attack() const {
            return _attack;
        }

        float attack(float value) {
            return _attack = value;
        }

        /// Gain entre 0 et 1
        float gain() const {
            return _sound.gain;
        }

        /// Volume entre 0 et 1
        float volume() const {
            return _sound.volume;
        }

        /// Ditto
        float volume(float volume_) {
            return _sound.volume = volume;
        }

        const(float[]) buffer() const {
            return _sound.buffer;
        }

        ubyte channels() const {
            return _sound.channels;
        }

        ulong samples() const {
            return _sound.samples;
        }

        int sampleRate() const {
            return _sound.sampleRate;
        }
    }

    this() {
    }

    /// Copie
    this(Phoneme other) {
        _sound = other._sound;
        _offset = other._offset;
        _cutoff = other._cutoff;
        _consonant = other._consonant;
        _vowel = other._vowel;
        _attack = other._attack;
        _isLooping = other._isLooping;
    }

    this(PhonemeData data, Sound sound_) {
        _sound = sound_;
        _offset = data.offset;
        _cutoff = data.cutoff;
        _consonant = data.consonant;
        _vowel = data.vowel;
        _attack = data.attack;
        _isLooping = data.isLooping;
    }

    /// Accès à la ressource
    Phoneme fetch() {
        return this;
    }
}
