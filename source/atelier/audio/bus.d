/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.audio.bus;

import std.stdio;
import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.audio.config;
import atelier.audio.effect;
import atelier.audio.voice;

final class AudioBus {
    private {
        bool _isMaster;
        AudioBus _parentBus;
        Array!AudioBus _busses;
        Array!AudioEffect _effects;
        Array!Voice _voices;

        static bool _hasMaster;
        __gshared AudioBus _masterBus;
    }

    static AudioBus getMaster() {
        if (!_hasMaster) {
            synchronized (AudioBus.classinfo) {
                if (!_masterBus) {
                    _masterBus = new AudioBus;
                    _masterBus._isMaster = true;
                }
                _hasMaster = true;
            }
        }
        return _masterBus;
    }

    this() {
        _busses = new Array!AudioBus;
        _effects = new Array!AudioEffect;
        _voices = new Array!Voice;
    }

    void play(Voice voice) {
        _voices ~= voice;
    }

    void addEffect(AudioEffect effect) {
        _effects ~= effect;
    }

    void connectToMaster() {
        if (_isMaster)
            return;

        connectTo(getMaster());
    }

    void connectTo(AudioBus bus) {
        if (_isMaster)
            return;

        disconnect();
        _parentBus = bus;
        _parentBus._busses ~= this; // TODO: Mutexer tout ça
    }

    void disconnect() {
        if (_isMaster)
            return;

        if (_parentBus) {
            foreach (i, childBus; _parentBus._busses) {
                if (childBus == this) {
                    _parentBus._busses.mark(i);
                    break;
                }
            }
            _parentBus._busses.sweep();
        }
    }

    void process(out float[Atelier_Audio_BufferSize] buffer) {
        float[Atelier_Audio_BufferSize] mixBuffer;
        float[Atelier_Audio_BufferSize] samples;

        mixBuffer[] = 0f;

        foreach (bus; _busses) {
            bus.process(samples);
            mixBuffer[] += samples[];
        }

        foreach (i, voice; _voices) {
            size_t count = voice.process(samples);
            mixBuffer[0 .. count] += samples[0 .. count];

            if (!voice.isAlive)
                _voices.mark(i);
        }
        _voices.sweep();

        foreach (i, effect; _effects) {
            effect.process(mixBuffer);

            if (!effect.isAlive)
                _effects.mark(i);
        }
        _effects.sweep();

        buffer[] = mixBuffer[];
    }
}
