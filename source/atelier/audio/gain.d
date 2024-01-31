/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.audio.gain;

import atelier.common;
import atelier.core;
import atelier.audio.config;
import atelier.audio.effect;

final class AudioGain : AudioEffect {
    private {
        float _volume = 1f;
    }

    @property {
        float volume() const {
            return _volume;
        }

        float volume(float volume_) {
            return _volume = volume_;
        }
    }

    override void process(ref float[Atelier_Audio_BufferSize] buffer) {
        buffer[] *= _volume;
    }
}
