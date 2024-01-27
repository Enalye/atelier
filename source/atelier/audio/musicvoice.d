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
        int _currentFrame, _startLoopFrame, _endLoopFrame;
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
            AUDIO_F32, Atelier_Audio_Channels, Atelier_Audio_SampleRate);
        _decoderBuffer = new float[cast(size_t)(Atelier_Audio_FrameSize * _music.channels)];

        _startLoopFrame = 0;
        _endLoopFrame = cast(int) _music.samples;

        if (_music.loopStart > 0f) {
            _startLoopFrame = clamp(cast(int)(_music.loopStart * _music.sampleRate),
                0, cast(int) _music.samples);
        }

        if (_music.loopEnd > 0f) {
            _endLoopFrame = clamp(cast(int)(_music.loopEnd * _music.sampleRate),
                _startLoopFrame, cast(int) _music.samples);
        }

        if (_startLoopFrame >= _endLoopFrame) {
            _startLoopFrame = 0;
        }

        _initDecoder();
    }

    private void _initDecoder() {
        _decoder.openFromMemory(_music.data);
    }

    private void _decode() {
        int framesRead;
        int framesToRead = Atelier_Audio_FrameSize;

        for (;;) {
            if (_currentFrame >= _endLoopFrame) {
                _initDecoder();
                _decoder.seekPosition(_startLoopFrame);
                _currentFrame = _startLoopFrame;
            }
            else if (_currentFrame + framesToRead > _endLoopFrame) {
                framesToRead = _endLoopFrame - _currentFrame;
            }

            framesRead = _decoder.readSamplesFloat(_decoderBuffer.ptr, framesToRead);

            if (framesRead == 0) {
                _initDecoder();
                _decoder.seekPosition(_startLoopFrame);
                _currentFrame = _startLoopFrame;
                continue;
            }

            const int rc = SDL_AudioStreamPut(_stream, _decoderBuffer.ptr,
                cast(int)(framesRead * _music.channels * float.sizeof));
            if (rc < 0) {
                _isAlive = false;
            }

            _currentFrame += framesRead;
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

        return gotten;
    }
}
