module atelier.audio.clip;

import std.math;
import atelier.common;
import atelier.core;
import atelier.audio.config;
import atelier.audio.effect;

final class AudioClip : AudioEffect {
    private {
        float _amplitude = 1f;
    }

    @property {
        float amplitude() const {
            return _amplitude;
        }

        float amplitude(float amplitude_) {
            return _amplitude = amplitude_;
        }
    }

    override void process(ref float[Atelier_Audio_BufferSize] buffer) {
        for (size_t i; i < Atelier_Audio_BufferSize; i += 2) {
            float a = buffer[i];
            buffer[i] = a > _amplitude ? _amplitude : a;
            a = buffer[i + 1];
            buffer[i + 1] = a > _amplitude ? _amplitude : a;
        }
    }
}
