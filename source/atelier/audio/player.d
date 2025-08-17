module atelier.audio.player;

import std.stdio;
import audioformats;
import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.audio.effect;
import atelier.audio.config;
import atelier.audio.music;
import atelier.audio.sound;

abstract class AudioPlayer {
    private {
        Array!AudioEffect _effects;
        bool _isAlive = true;

    }

    @property {
        final bool isAlive() const {
            return _isAlive;
        }
    }

    this() {
        _effects = new Array!AudioEffect;
    }

    final void addEffect(AudioEffect effect) {
        _effects ~= effect;
    }

    final void remove() {
        _isAlive = false;
    }

    package final void processEffects(ref float[Atelier_Audio_BufferSize] buffer) {
        foreach (i, effect; _effects) {
            effect.process(buffer);

            if (!effect.isAlive)
                _effects.mark(i);
        }
        _effects.sweep();
    }

    abstract size_t process(out float[Atelier_Audio_BufferSize]);
}
