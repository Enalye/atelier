/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.audio.musicvoice;

import audioformats;
import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.audio.config;
import atelier.audio.music;
import atelier.audio.voice;

final class MusicVoice : Voice {
    private {
        Music _music;
        size_t _position;
        SDL_AudioStream* _stream;
        bool _isAlive = true;
        AudioStream _decoder;
        float[] _decoderBuffer;
    }

    @property {
        bool isAlive() const {
            return _isAlive;
        }
    }

    this(Music music) {
        _music = music;
        _stream = SDL_NewAudioStream(AUDIO_F32, _music.channels, _music.sampleRate,
            AUDIO_F32, Atelier_Audio_Channels, Atelier_Audio_Frequency);
        _decoderBuffer = new float[cast(size_t)(Atelier_Audio_FrameSize * _music.channels)];

        _initDecoder();
    }

    private void _initDecoder() {
        _decoder.openFromMemory(_music.data);
    }

    private void _decode() {
        int framesRead;
        int framesToRead = Atelier_Audio_FrameSize;

        for (;;) {
            framesRead = _decoder.readSamplesFloat(_decoderBuffer);

            if (framesRead == 0) {
                _initDecoder();
                continue;
            }

            const int rc = SDL_AudioStreamPut(_stream, _decoderBuffer.ptr,
                cast(int)(framesRead * _music.channels * float.sizeof));
            if (rc < 0) {
                _isAlive = false;
            }

            framesToRead -= framesRead;

            if (framesToRead <= 0)
                return;
        }
    }

    size_t process(out float[Atelier_Audio_BufferSize] buffer) {
        _decode();
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
