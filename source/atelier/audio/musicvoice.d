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
import atelier.audio.effect;
import atelier.audio.music;
import atelier.audio.voice;

final class MusicVoice : Voice {
    private {
        Music _music;
        Array!AudioEffect _effects;
        int _currentFrame, _startLoopFrame, _endLoopFrame;
        int _delayStartFrame, _delayPauseFrame, _delayStopFrame;
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

    this(Music music, float delay = 0f) {
        _music = music;
        _effects = new Array!AudioEffect;
        _stream = SDL_NewAudioStream(AUDIO_F32, _music.channels, _music.sampleRate,
            AUDIO_F32, Atelier_Audio_Channels, Atelier_Audio_SampleRate);
        _decoderBuffer = new float[cast(size_t)(Atelier_Audio_FrameSize * _music.channels)];

        _delayStartFrame = cast(int)(delay * _music.sampleRate);
        _delayStopFrame = -1;
        _delayPauseFrame = -1;

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

    void addEffect(AudioEffect effect) {
        _effects ~= effect;
    }

    void resume(float delay = 0f) {
        _delayStopFrame = -1;
        _delayPauseFrame = -1;

        if (delay == 0f) {
            _delayStartFrame = 0;
        }
        else {
            _delayStartFrame = cast(int)(delay * _music.sampleRate);
        }
    }

    void pause(float delay = 0f) {
        _delayStopFrame = -1;

        if (delay == 0f) {
            _delayPauseFrame = 0;
        }
        else {
            _delayPauseFrame = cast(int)(delay * _music.sampleRate);
        }
    }

    void stop(float delay = 0f) {
        _delayPauseFrame = -1;

        if (delay == 0f) {
            _isAlive = false;
            _delayStopFrame = 0;
        }
        else {
            _delayStopFrame = cast(int)(delay * _music.sampleRate);
        }
    }

    private void _initDecoder() {
        _decoder.openFromMemory(_music.data);
    }

    private void _decode(int framesToRead = Atelier_Audio_FrameSize) {
        int framesRead;

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
        int framesToRead = Atelier_Audio_FrameSize;

        if (_delayStopFrame >= 0) {
            if (_delayStopFrame >= framesToRead) {
                _delayStopFrame -= framesToRead;
            }
            else {
                framesToRead = _delayStopFrame;
                _isAlive = false;

                if (framesToRead == 0)
                    return 0;
            }
        }

        if (_delayPauseFrame >= 0) {
            if (_delayPauseFrame >= framesToRead) {
                _delayPauseFrame -= framesToRead;
            }
            else {
                framesToRead = _delayPauseFrame;

                if (framesToRead == 0)
                    return 0;
            }
        }

        if (_delayStartFrame >= 0) {
            if (_delayStartFrame >= framesToRead) {
                _delayStartFrame -= framesToRead;
                return 0;
            }
            framesToRead -= _delayStartFrame;
        }

        _decode(framesToRead);
        int gotten = SDL_AudioStreamGet(_stream, buffer.ptr + (_delayStartFrame * (float*)
                .sizeof), cast(int)(float.sizeof * Atelier_Audio_Channels * framesToRead));
        gotten >>= 2;

        foreach (i, effect; _effects) {
            effect.process(buffer);

            if (!effect.isAlive)
                _effects.mark(i);
        }
        _effects.sweep();

        if (gotten <= 0) {
            _isAlive = false;
        }

        return gotten;
    }
}
