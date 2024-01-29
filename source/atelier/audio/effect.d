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

final class AudioFader : AudioEffect {
    private {
        SplineFunc _spline;
        int _currentFrame, _startFrame, _endFrame;
        bool _fadeIn;
    }

    this(bool fadeIn, float duration, SplineFunc spline, float delay = 0f) {
        _fadeIn = fadeIn;
        _spline = spline;
        _currentFrame = 0;
        _startFrame = cast(int)(delay * Atelier_Audio_SampleRate);
        _endFrame = cast(int)(_startFrame + (duration * Atelier_Audio_SampleRate));
    }

    override void process(ref float[Atelier_Audio_BufferSize] buffer) {
        if (_currentFrame + Atelier_Audio_FrameSize < _startFrame) {
            _currentFrame += Atelier_Audio_FrameSize;
            if (_fadeIn) {
                buffer[] = 0f;
            }
            return;
        }

        for (size_t i; i < Atelier_Audio_BufferSize; i += 2) {
            if (_currentFrame > _startFrame) {
                if (_currentFrame >= _endFrame) {
                    remove();
                    triggerCallback();
                    return;
                }
                float t = rlerp(_startFrame, _endFrame, _currentFrame);
                t = _spline(t);
                t = _fadeIn ? t : 1f - t;
                buffer[i] *= t;
                buffer[i + 1] *= t;
            }
            else if (_fadeIn) {
                buffer[i] = 0f;
                buffer[i + 1] = 0f;
            }
            _currentFrame++;
        }
    }
}
