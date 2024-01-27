/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.audio.soundvoice;

import audioformats;
import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.audio.config;
import atelier.audio.sound;
import atelier.audio.voice;

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
        _stream = SDL_NewAudioStream(AUDIO_F32, _sound.channels, _sound.sampleRate,
            AUDIO_F32, Atelier_Audio_Channels, Atelier_Audio_Frequency);
        const int rc = SDL_AudioStreamPut(_stream, _sound.buffer.ptr,
            cast(int)(_sound.buffer.length * float.sizeof));
        if (rc < 0) {
            _isAlive = false;
        }
    }

    size_t process(out float[Atelier_Audio_BufferSize] buffer) {
        int gotten = SDL_AudioStreamGet(_stream, buffer.ptr,
            cast(int)(float.sizeof * Atelier_Audio_BufferSize));
        gotten >>= 2;

        if (gotten <= 0) {
            _isAlive = false;
        }
        else {
            /*for (size_t i; i < gotten; i++) {
                buffer[i] = converted[i];
            }*/
        }

        return gotten;

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
