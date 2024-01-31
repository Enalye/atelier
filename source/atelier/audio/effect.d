/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.audio.effect;

import std.algorithm.mutation;

import atelier.common;
import atelier.core;
import atelier.audio.config;

abstract class AudioEffect {
    private {
        alias Callback = void function();
        Callback[] _callbacks;
        bool _isAlive = true;
    }

    @property {
        bool isAlive() const {
            return _isAlive;
        }
    }

    final void remove() {
        _isAlive = false;
    }

    final void addCallback(Callback callback) {
        _callbacks ~= callback;
    }

    final void removeCallback(Callback callback) {
        _callbacks.remove!(a => a == callback)();
    }

    final void triggerCallback() {
        foreach (callback; _callbacks) {
            callback();
        }
    }

    abstract void process(ref float[Atelier_Audio_BufferSize]);
}