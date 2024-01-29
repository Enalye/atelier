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
import atelier.audio.effect;
import atelier.audio.sound;
import atelier.audio.voice;

final class SoundVoice : Voice {
    private {
        Sound _sound;
        Array!AudioEffect _effects;
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
        _effects = new Array!AudioEffect;
        _stream = SDL_NewAudioStream(AUDIO_F32, _sound.channels, _sound.sampleRate,
            AUDIO_F32, Atelier_Audio_Channels, Atelier_Audio_SampleRate);
        const int rc = SDL_AudioStreamPut(_stream, _sound.buffer.ptr,
            cast(int)(_sound.buffer.length * float.sizeof));
        if (rc < 0) {
            _isAlive = false;
        }
    }

    void addEffect(AudioEffect effect) {
        _effects ~= effect;
    }

    size_t process(out float[Atelier_Audio_BufferSize] buffer) {
        int gotten = SDL_AudioStreamGet(_stream, buffer.ptr,
            cast(int)(float.sizeof * Atelier_Audio_BufferSize));
        gotten >>= 2;

        const float volume = _sound.volume;
        for (int i; i < Atelier_Audio_BufferSize; i += 2) {
            buffer[i] *= volume;
            buffer[i + 1] *= volume;
        }

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
