/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.audio.oscillator;

import std.math;
import audioformats;
import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.audio.config;
import atelier.audio.player;

final class Oscillator : AudioPlayer {
    private {
        int _currentFrame;
        float _frequency;
    }

    this(float frequency) {
        _frequency = frequency;
    }

    override size_t process(out float[Atelier_Audio_BufferSize] buffer) {
        float v = 2f * PI * _frequency / Atelier_Audio_SampleRate;
        for (int i; i < Atelier_Audio_BufferSize; i += 2) {
            float sample = 0.4 * sin(v * _currentFrame);
            buffer[i] = sample;
            buffer[i + 1] = sample;
            ++_currentFrame;
        }

        return Atelier_Audio_BufferSize;
    }
}
