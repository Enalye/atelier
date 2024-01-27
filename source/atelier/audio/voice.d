module atelier.audio.voice;

import std.stdio;
import audioformats;
import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.audio.sound;

interface Voice {
    @property {
        bool isAlive() const;
    }

    void render(float*, size_t);
}

final class SoundVoice : Voice {
    private {
        Sound _sound;
        size_t _position;
        SDL_AudioStream* _stream;
        bool _isAlive = true;
    }

    @property {
        bool isAlive() const {
            return _isAlive;
        }
    }

    this(Sound sound) {
        _sound = sound;
        _stream = SDL_NewAudioStream(AUDIO_F32, _sound.channels,
            _sound.sampleRate, AUDIO_F32, 2, 48_000);
        const int rc = SDL_AudioStreamPut(_stream, _sound.buffer.ptr,
            cast(int)(_sound.buffer.length * float.sizeof));
        if (rc < 0) {
            _isAlive = false;
        }
    }

    void render(float* buffer, size_t len) {
        float[] converted = new float[len];

        int gotten = SDL_AudioStreamGet(_stream, converted.ptr, cast(int)(float.sizeof * len));
        gotten >>= 2;

        if (gotten <= 0) {
            _isAlive = false;
        }
        else {
            for (size_t i; i < gotten; i++) {
                buffer[i] += converted[i];
            }
        }

        /*
        for (size_t i; (i < len) && (i + _position < _sound._buffer.length); i++) {
            buffer[i] += _sound._buffer[i + _position];
        }
        _position += len;

        if (_position >= _sound._buffer.length) {
            _isAlive = false;
            writeln("END OF SOUND: ", _position, ", ", _sound._buffer.length, ", ", len);
        }*/
    }
}
