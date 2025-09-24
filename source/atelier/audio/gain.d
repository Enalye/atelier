module atelier.audio.gain;

import atelier.common;
import atelier.core;
import atelier.audio.config;
import atelier.audio.effect;

final class AudioGain : AudioEffect {
    private {
        float _volume = 1f;
        float _gain = 1f;
    }

    @property {
        float gain() const {
            return _gain;
        }

        float volume() const {
            return _volume;
        }

        float volume(float volume_) {
            _volume = volume_;
            _gain = volToNonLinear(_volume);
            return _volume;
        }
    }

    override void process(ref float[Atelier_Audio_BufferSize] buffer) {
        buffer[] *= _gain;
    }
}
