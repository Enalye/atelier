module atelier.audio.phonemeplayer;

import std.stdio;
import std.math : round;
import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.audio.config;
import atelier.audio.effect;
import atelier.audio.lowpass;
import atelier.audio.phoneme;
import atelier.audio.player;

final class PhonemePlayer : AudioPlayer {
    private {
        Phoneme _phoneme;
        int _currentFrame;
        int _offsetFrame, _cutoffFrame;
        int _consonantFrame, _vowelFrame;
        SDL_AudioStream* _stream;
        float[] _decoderBuffer;
        float _volume = 1f;
        bool _hasLoopEnded;
        bool _isPlaying;
        bool _isReverse;
        float[] _loopBuffer;
        int _loopCount;
        bool _isLoopValid;

        AudioLowPassFilter _lowpass;
        int _dampingStep = 0;
        float _damping = 0.6f;
        Timer _dampingTimer;
    }

    @property {
        float currentPosition() const {
            return cast(float) _currentFrame / cast(float) _phoneme.sampleRate;
        }
    }

    this(Phoneme phoneme, float speed = 1f) {
        _phoneme = phoneme;

        _stream = SDL_NewAudioStream(AUDIO_F32, _phoneme.channels, _phoneme.sampleRate,
            AUDIO_F32, Atelier_Audio_Channels, cast(int)(
                round(Atelier_Audio_SampleRate * (1f / speed))));
        _decoderBuffer = new float[cast(size_t)(Atelier_Audio_FrameSize * _phoneme.channels)];
        _isPlaying = _phoneme.isLooping;

        _setEnveloppe();
        _setLoopBuffer();

        _lowpass = new AudioLowPassFilter();
        _lowpass.leftDamping = 0f;
        _lowpass.rightDamping = 0f;
        addEffect(_lowpass);
    }

    void setVolume(float volume) {
        _volume = volume;
    }

    float getVolume() const {
        return _volume;
    }

    private void _setLoopBuffer() {
        int bufferSize = _vowelFrame - _consonantFrame;
        if (bufferSize < 0 || !_isPlaying)
            return;

        int middlePoint = bufferSize / 2;
        _loopBuffer = new float[cast(size_t)(bufferSize * _phoneme.channels)];

        for (int ch; ch < _phoneme.channels; ++ch) {
            for (int i; i < middlePoint; ++i) {
                _loopBuffer[i * _phoneme.channels + ch] =
                    _phoneme.buffer[(_consonantFrame + middlePoint + i) * _phoneme.channels + ch];
            }

            for (int i = middlePoint, y = 0; i < bufferSize; ++i, ++y) {
                _loopBuffer[(middlePoint + y) * _phoneme.channels + ch] =
                    _phoneme.buffer[(_consonantFrame + y) * _phoneme.channels + ch];
            }
        }

        _isLoopValid = true;
    }

    private void _setEnveloppe() {
        _offsetFrame = 0;
        _cutoffFrame = cast(int) _phoneme.samples;

        if (_phoneme.offset > 0f) {
            _offsetFrame = clamp(cast(int)(_phoneme.offset * _phoneme.sampleRate), 0,
                cast(int) _phoneme.samples);
        }

        if (_phoneme.cutoff > 0f) {
            _cutoffFrame = clamp(cast(int)(_phoneme.cutoff * _phoneme.sampleRate),
                _offsetFrame, cast(int) _phoneme.samples);
        }

        _currentFrame = _offsetFrame;

        _consonantFrame = _offsetFrame;
        _vowelFrame = _cutoffFrame;

        if (_phoneme.consonant > 0f) {
            _consonantFrame = clamp(cast(int)(_phoneme.consonant * _phoneme.sampleRate), _offsetFrame, _cutoffFrame);
        }

        if (_phoneme.vowel > 0f) {
            _vowelFrame = clamp(cast(int)(_phoneme.vowel * _phoneme.sampleRate),
                _consonantFrame, _cutoffFrame);
        }

        if (_consonantFrame >= _vowelFrame) {
            _consonantFrame = _offsetFrame;
        }

        int delta = _vowelFrame - _consonantFrame;
        _consonantFrame = _searchNearestLowSample(_consonantFrame, min(delta / 2, _consonantFrame - _offsetFrame));
        _vowelFrame = _searchNearestLowSample(_vowelFrame, min(delta / 2, _cutoffFrame - _vowelFrame));

        if (_consonantFrame <= _offsetFrame || _consonantFrame >= _cutoffFrame || _consonantFrame >= _vowelFrame
            || _vowelFrame >= _cutoffFrame || _vowelFrame <= _offsetFrame || _offsetFrame >= _cutoffFrame) {
            _isPlaying = false;
        }
    }

    int _searchNearestLowSample(int base, int maxSearch) {
        float getSampleValue(int sample) {
            int channels = _phoneme.channels;
            float sampleValue = 0f;
            for (int ch; ch < channels; ++ch) {
                float value = _phoneme.buffer[sample * channels + ch];
                sampleValue = max(value, sampleValue);
            }
            return sampleValue;
        }

        int lowestSample = base;
        float lowestValue = getSampleValue(base);
        maxSearch = min(_phoneme.samples - (base + 1), base, maxSearch);
        int offset;
        for (int i; i < maxSearch; ++i) {
            float value;
            value = getSampleValue(base + i);
            if (value < lowestValue) {
                lowestValue = value;
                lowestSample = base + i;
                offset = +i;
            }
            value = getSampleValue(base - i);
            if (value < lowestValue) {
                lowestValue = value;
                lowestSample = base - i;
                offset = -i;
            }
        }
        return lowestSample;
    }

    void stop(float delay = 0f) {
        _isPlaying = false;
        /*_delayPauseFrame = -1;

        if (delay == 0f) {
            remove();
            _delayStopFrame = 0;
        }
        else {
            _delayStopFrame = cast(int)(delay * _phoneme.sampleRate);
        }*/
    }

    private void _decode(int framesToRead = Atelier_Audio_FrameSize) {
        int framesRead;

        for (;;) {
            if (_isPlaying) {
                if (_isReverse) {
                    if (_currentFrame <= _consonantFrame) {
                        _currentFrame = _consonantFrame;
                        _isReverse = false;
                    }
                }
                else {
                    if (_currentFrame >= _vowelFrame) {
                        _currentFrame = _vowelFrame;
                        _isReverse = true;
                        _loopCount++;
                    }
                }
                if (_isReverse && _currentFrame < _consonantFrame + framesToRead) {
                    framesToRead = _currentFrame - _consonantFrame;
                }
                else if (!_isReverse && _currentFrame + framesToRead > _vowelFrame) {
                    framesToRead = _vowelFrame - _currentFrame;
                }
            }
            else if (_isLoopValid && !_isReverse && _currentFrame < _vowelFrame && _currentFrame + framesToRead > _vowelFrame) {
                framesToRead = _vowelFrame - _currentFrame;
            }
            else if (!_isReverse && _currentFrame + framesToRead >= _cutoffFrame) {
                if (_isLoopValid && _currentFrame < _vowelFrame) {
                    framesToRead = _vowelFrame - _currentFrame;
                }
                else {
                    framesToRead = _cutoffFrame - _currentFrame;

                    if (framesToRead <= 0) {
                        _hasLoopEnded = true;
                    }
                }
            }
            else if (_isReverse) {
                if (_currentFrame <= _consonantFrame) {
                    _currentFrame = _consonantFrame;
                    _isReverse = false;
                }
                if (_isReverse && _currentFrame < _consonantFrame + framesToRead) {
                    framesToRead = _currentFrame - _consonantFrame;
                }
            }

            framesRead = framesToRead;

            if (_isReverse) {
                int rc = 0;
                int i;
                int loopSize = (_vowelFrame - _consonantFrame);
                int middlePoint = loopSize / 2;
                const(float)* ptr = _phoneme.sound.buffer.ptr + _currentFrame * _phoneme.channels;
                int loopBufferCurrentFrame = loopSize - (
                    _currentFrame - _consonantFrame);
                const(float)* loopPtr = _loopBuffer.ptr + loopBufferCurrentFrame * _phoneme
                    .channels;

                float[Atelier_Audio_Channels] buffer;
                while (rc >= 0 && i < framesToRead) {
                    float t = 0f;
                    if (loopBufferCurrentFrame < middlePoint) {
                        t = lerp(0f, 1f, easeInOutSine(
                                loopBufferCurrentFrame / cast(float) middlePoint));
                    }
                    else {
                        t = lerp(1f, 0f, easeInOutSine(
                                (loopBufferCurrentFrame - middlePoint) / cast(float)(
                                loopSize - middlePoint)));
                    }
                    for (int sample; sample < _phoneme.channels; ++sample) {
                        buffer[sample] = -*(ptr + sample) * t;
                        buffer[sample] += *(loopPtr + sample) * (1f - t);
                    }
                    rc = SDL_AudioStreamPut(_stream,
                        buffer.ptr,
                        cast(int)(_phoneme.channels * float.sizeof));
                    ptr -= _phoneme.channels;
                    loopPtr += _phoneme.channels;
                    i++;
                }
                if (rc < 0) {
                    remove();
                }
                _currentFrame -= framesRead;
            }
            else if (_isLoopValid && _currentFrame >= _consonantFrame && _currentFrame <= _vowelFrame) {
                int rc = 0;
                int i;
                int loopSize = (_vowelFrame - _consonantFrame);
                int middlePoint = loopSize / 2;
                const(float)* ptr = _phoneme.sound.buffer.ptr + _currentFrame * _phoneme.channels;
                int loopBufferCurrentFrame = _currentFrame - _consonantFrame;
                const(float)* loopPtr = _loopBuffer.ptr + loopBufferCurrentFrame * _phoneme
                    .channels;

                float[Atelier_Audio_Channels] buffer;
                while (rc >= 0 && i < framesToRead) {
                    float t = 0f;
                    if (loopBufferCurrentFrame < middlePoint) {
                        if (_loopCount == 0)
                            t = 1f;
                        else
                            t = lerp(0f, 1f, easeInOutSine(
                                    loopBufferCurrentFrame / cast(float) middlePoint));
                    }
                    else {
                        t = lerp(1f, 0f, easeInOutSine(
                                (loopBufferCurrentFrame - middlePoint) / cast(float)(
                                loopSize - middlePoint)));
                    }
                    for (int sample; sample < _phoneme.channels; ++sample) {
                        buffer[sample] = *(ptr + sample) * t;
                        buffer[sample] += *(loopPtr + sample) * (1f - t);
                    }
                    rc = SDL_AudioStreamPut(_stream,
                        buffer.ptr,
                        cast(int)(_phoneme.channels * float.sizeof));
                    ptr += _phoneme.channels;
                    loopPtr += _phoneme.channels;
                    i++;
                }
                if (rc < 0) {
                    remove();
                }
                _currentFrame += framesRead;
            }
            else {
                const int rc = SDL_AudioStreamPut(_stream,
                    _phoneme.sound.buffer.ptr + _currentFrame * _phoneme.channels,
                    cast(int)(framesToRead * _phoneme.channels * float.sizeof));
                if (rc < 0) {
                    remove();
                }
                _currentFrame += framesRead;
            }

            framesToRead -= framesRead;

            if (framesToRead <= 0)
                return;
        }
    }

    override size_t process(out float[Atelier_Audio_BufferSize] buffer) {
        int framesToRead = Atelier_Audio_FrameSize;

        _decode(framesToRead);

        if (_currentFrame > _vowelFrame) {
            if (_dampingStep != 2) {
                _dampingTimer.start(25);
            }
            _dampingStep = 2;
        }
        else if (_currentFrame >= _consonantFrame) {
            if (_dampingStep != 1) {
                _dampingTimer.start(10);
            }
            _dampingStep = 1;
        }

        if (_dampingTimer.isRunning()) {
            _dampingTimer.update();

            float value = 0f;
            if (_dampingTimer.isRunning()) {
                switch (_dampingStep) {
                case 1:
                    value = lerp(0f, _damping, easeInOutSine(_dampingTimer.value01()));
                    break;
                case 2:
                    value = lerp(_damping, 0f, easeInOutSine(_dampingTimer.value01()));
                    break;
                case 0:
                default:
                    break;
                }
            }
            else {
                switch (_dampingStep) {
                case 1:
                    value = _damping;
                    break;
                case 0:
                case 2:
                default:
                    break;
                }
            }
            _lowpass.leftDamping = _lowpass.rightDamping = value;
        }

        int framesRead = SDL_AudioStreamGet(_stream, buffer.ptr, cast(int)(
                float.sizeof * Atelier_Audio_Channels * framesToRead));

        if (framesRead >= 0) {
            if (_hasLoopEnded && framesRead == 0) {
                remove();
            }
            framesRead >>= 2;

            const float totalVolume = volToNonLinear(_phoneme.volume * _volume);
            for (int i; i < framesToRead * Atelier_Audio_Channels; i += 2) {
                buffer[i] *= totalVolume;
                buffer[i + 1] *= totalVolume;
            }
        }
        else {
            remove();
        }

        return framesRead;
    }
}
