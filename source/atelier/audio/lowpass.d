module atelier.audio.lowpass;

import std.math : round, isFinite;

import atelier.common;
import atelier.core;
import atelier.audio.config;
import atelier.audio.effect;

final class AudioLowPassFilter : AudioEffect {
    private {
        float _leftDamping = 0f;
        float _rightDamping = 0f;
        bool _isStarting = true;
        float[6] _samples;
    }

    @property {
        float leftDamping() const {
            return _leftDamping;
        }

        float leftDamping(float leftDamping_) {
            return _leftDamping = clamp(leftDamping_, 0f, 1f);
        }

        float rightDamping() const {
            return _rightDamping;
        }

        float rightDamping(float rightDamping_) {
            return _rightDamping = clamp(rightDamping_, 0f, 1f);
        }
    }

    this() {
    }

    private float _getAmp(float value) {
        return isFinite(value) ? value : 0f;
    }

    override void process(ref float[Atelier_Audio_BufferSize] buffer) {
        float eL = 3f * _leftDamping;
        float fL = -eL * _leftDamping;
        float gL = _leftDamping * _leftDamping * _leftDamping;
        float hL = 1f - eL - fL - gL;

        float eR = 3f * _rightDamping;
        float fR = -eR * _rightDamping;
        float gR = _rightDamping * _rightDamping * _rightDamping;
        float hR = 1f - eR - fR - gR;

        uint startSample;

        if (_isStarting) {
            _isStarting = false;

            // Initialisation
            for (size_t i; i < 6; i++) {
                _samples[i] = _getAmp(buffer[i]);
            }

            startSample = 6;
        }

        for (size_t i = startSample; i < Atelier_Audio_BufferSize; i += 2) {
            // dfmt off
            float a = eL * _samples[4] + fL * _samples[2] + gL * _samples[0] + hL * _getAmp(buffer[i]);
            float b = eR * _samples[5] + fR * _samples[3] + gR * _samples[1] + hR * _getAmp(buffer[i + 1]);
            // dfmt on

            buffer[i] = a;
            buffer[i + 1] = b;

            _samples[0] = _samples[2];
            _samples[2] = _samples[4];
            _samples[4] = buffer[i];

            _samples[1] = _samples[3];
            _samples[3] = _samples[5];
            _samples[5] = buffer[i + 1];
        }
    }
}
