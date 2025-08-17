module atelier.audio.delay;

import std.math : round;

import atelier.common;
import atelier.core;
import atelier.audio.config;
import atelier.audio.effect;

final class AudioDelay : AudioEffect {
    private {
        uint _leftPos, _rightPos;
        float _leftDelay = 0f, _rightDelay = 0f;
        enum Buffer_Size = Atelier_Audio_SampleRate;
        float[Buffer_Size] _leftBuffer, _rightBuffer;
    }

    @property {
        float leftDelay() const {
            return _leftDelay;
        }

        float leftDelay(float leftDelay_) {
            return _leftDelay = clamp(leftDelay_, 0f, 1f);
        }

        float rightDelay() const {
            return _rightDelay;
        }

        float rightDelay(float rightDelay_) {
            return _rightDelay = clamp(rightDelay_, 0f, 1f);
        }
    }

    this() {
        for (uint i; i < Buffer_Size; ++i) {
            _leftBuffer[i] = 0f;
        }

        for (uint i; i < Buffer_Size; ++i) {
            _rightBuffer[i] = 0f;
        }
    }

    override void process(ref float[Atelier_Audio_BufferSize] buffer) {
        uint leftOffset = clamp(cast(uint) round(_leftDelay * Atelier_Audio_SampleRate),
            0, Atelier_Audio_SampleRate);
        uint rightOffset = clamp(cast(uint) round(_rightDelay * Atelier_Audio_SampleRate),
            0, Atelier_Audio_SampleRate);

        for (size_t i; i < Atelier_Audio_BufferSize; i += 2) {
            _leftBuffer[(_leftPos + leftOffset) % Buffer_Size] = buffer[i];
            _rightBuffer[(_rightPos + rightOffset) % Buffer_Size] = buffer[i + 1];

            buffer[i] = _leftBuffer[_leftPos];
            buffer[i + 1] = _rightBuffer[_rightPos];

            _leftBuffer[_leftPos] = 0f;
            _rightBuffer[_rightPos] = 0f;

            _leftPos = (_leftPos + 1) % Buffer_Size;
            _rightPos = (_rightPos + 1) % Buffer_Size;
        }
    }
}
