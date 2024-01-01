module atelier.audio.voice;

import std.algorithm.comparison: clamp;
import bindbc.openal;

import atelier.core;
import atelier.core;

import atelier.audio.context;
import atelier.audio.sound;
import atelier.audio.source;

/// Instance d’un son
abstract class VoiceBase {
    private {
        ALuint _id;
        float _volume = 1f;
    }

    @property {
        protected ALuint id() const {
            return _id;
        }

        /// Le son est-il en train de se jouer ?
        bool isPlaying() const {
            int value = void;
            alGetSourcei(_id, AL_SOURCE_STATE, &value);
            return value != AL_STOPPED;
        }

        /// Volume entre 0 et 1
        float volume() const {
            return _volume;
        }

        /// Ditto
        float volume(float volume_) {
            _volume = clamp(volume_, 0f, 1f);
            alSourcef(_id, AL_GAIN, _volume);
            return _volume;
        }
    }

    /// Init
    this() {
        alGenSources(cast(ALuint) 1, &_id);

        alSourcef(_id, AL_PITCH, 1f);
        alSourcef(_id, AL_GAIN, 1f);
        alSource3f(_id, AL_POSITION, 0f, 0f, 0f);
        alSource3f(_id, AL_VELOCITY, 0f, 0f, 0f);
        alSourcei(_id, AL_LOOPING, AL_FALSE);
    }

    /// Màj
    void update(AudioContext);
}

/// Instance d’un son
final class Voice : VoiceBase {
    /// Init
    this(Sound sound) {
        alSourcei(_id, AL_BUFFER, sound.id);
        volume = sound.volume;

        alSourcePlay(_id);
    }

    /// Màj
    override void update(AudioContext context) {

    }
}