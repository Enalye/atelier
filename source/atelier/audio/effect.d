/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
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
        bool _bypass = false;
    }

    @property {
        bool isAlive() const {
            return _isAlive;
        }

        bool bypass() const {
            return _bypass;
        }

        bool bypass(bool bypass_) {
            return _bypass = bypass_;
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
