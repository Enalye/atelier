module atelier.audio.soundplayer;

import std.math : round;
import audioformats;
import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.audio.config;
import atelier.audio.effect;
import atelier.audio.player;
import atelier.audio.sound;

final class SoundPlayer : AudioPlayer {
    private {
        Sound _sound;
        SDL_AudioStream* _stream;
    }

    this(Sound sound, float speed = 1f) {
        if (speed <= 0f)
            speed = 1f;

        _sound = sound;
        _stream = SDL_NewAudioStream(AUDIO_F32, _sound.channels, _sound.sampleRate,
            AUDIO_F32, Atelier_Audio_Channels, cast(int)(
                round(Atelier_Audio_SampleRate * (1f / speed))));
        const int rc = SDL_AudioStreamPut(_stream, _sound.buffer.ptr,
            cast(int)(_sound.buffer.length * float.sizeof));
        if (rc < 0) {
            remove();
        }
    }

    override size_t process(out float[Atelier_Audio_BufferSize] buffer) {
        int framesRead = SDL_AudioStreamGet(_stream, buffer.ptr,
            cast(int)(float.sizeof * Atelier_Audio_BufferSize));
        framesRead >>= 2;

        const float volume = _sound.gain;
        for (int i; i < Atelier_Audio_BufferSize; i += 2) {
            buffer[i] *= volume;
            buffer[i + 1] *= volume;
        }

        if (framesRead <= 0) {
            remove();
        }
        return framesRead;
    }
}
