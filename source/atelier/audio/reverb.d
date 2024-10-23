/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.audio.reverb;

import std.math;
import std.random;

import atelier.common;
import atelier.core;
import atelier.audio.config;
import atelier.audio.effect;

final class AudioReverb : AudioEffect {
    private {
        enum ChannelsCount = 8;
        Reverb!(ChannelsCount, 4) _leftReverb, _rightReverb;
    }

    alias Channels(T) = T[ChannelsCount];

    this(float delayMs, float rt60) {
        _leftReverb.setup(delayMs, rt60);
        _rightReverb.setup(delayMs, rt60);
    }

    void setMix(float dry, float wet) {
        _leftReverb.dry = dry;
        _leftReverb.wet = wet;
        _rightReverb.dry = dry;
        _rightReverb.wet = wet;
    }

    override void process(ref float[Atelier_Audio_BufferSize] buffer) {
        Channels!(float) leftChannels, rightChannnels;
        for (size_t i; i < Atelier_Audio_BufferSize; i += Atelier_Audio_Channels) {
            static foreach (ch; 0 .. ChannelsCount) {
                leftChannels[ch] = buffer[i];
                rightChannnels[ch] = buffer[i + 1];
            }

            leftChannels = _leftReverb.process(leftChannels);
            rightChannnels = _rightReverb.process(rightChannnels);

            static foreach (ch; 0 .. ChannelsCount) {
                buffer[i] = leftChannels[ch];
                buffer[i + 1] = rightChannnels[ch];
            }
        }
    }
}

private struct Reverb(uint channels, uint steps) {
    alias Channels(T) = T[channels];

    private {
        Diffuser!(channels, steps) _diffuser;
        FeedbackLoop!(channels) _feedbackLoop;
    }

    float dry = 0.5f;
    float wet = 0.5f;

    void setup(float roomSizeMs, float rt60) {
        _diffuser.setup(roomSizeMs);
        _feedbackLoop.setup(roomSizeMs, rt60);
    }

    Channels!float process(Channels!float input) {
        Channels!float diffuse = _diffuser.process(input);
        Channels!float output = _feedbackLoop.process(diffuse);

        static foreach (uint ch; 0 .. channels) {
            output[ch] = output[ch] * wet + input[ch] * dry;
        }
        return output;
    }
}

private struct FeedbackLoop(uint channels) {
    alias Channels(T) = T[channels];

    private {
        Channels!(DelayBuffer!float) _delays;
        float _decayGain = 0.85f;
    }

    void setup(float delayMs, float rt60) {
        float typicalLoopMs = delayMs * 1.5f;
        float loopsPerRt60 = rt60 / (typicalLoopMs * 0.001f);
        float dbPerCycle = -60f / loopsPerRt60;
        _decayGain = pow(10f, dbPerCycle * 0.05f);

        float delaySamplesBase = delayMs * 0.001f * Atelier_Audio_SampleRate;
        float r;
        uint delayOffset;

        static foreach (uint ch; 0 .. channels) {
            r = ch / cast(float) channels;
            delayOffset = cast(uint)(pow(2, r) * delaySamplesBase);
            _delays[ch].resize(delayOffset + 1);
            _delays[ch].reset(0f);
        }
    }

    Channels!float process(Channels!float input) {
        Channels!float output;

        static foreach (uint ch; 0 .. channels) {
            output[ch] = _delays[ch].read();
        }

        householder(output);

        float sum;
        static foreach (uint ch; 0 .. channels) {
            sum = input[ch] + output[ch] * _decayGain;
            _delays[ch].write(sum);
            _delays[ch].advance();
        }

        return output;
    }

    void householder(ref Channels!float data) {
        float sum = 0f;
        static foreach (uint ch; 0 .. channels) {
            sum += data[ch];
        }

        sum *= -2f / channels;

        static foreach (uint ch; 0 .. channels) {
            data[ch] += sum;
        }
    }
}

private struct Diffuser(uint channels, uint steps) {
    alias Channels(T) = T[channels];
    alias Steps = DiffusionStep!(channels);

    private {
        Steps[steps] _steps;
    }

    void setup(float duration) {
        static foreach (s; 0 .. steps) {
            duration *= 0.5f;
            _steps[s].setup(duration);
        }
    }

    Channels!float process(Channels!float data) {
        static foreach (uint step; 0 .. steps) {
            data = _steps[step].process(data);
        }
        return data;
    }
}

private struct DiffusionStep(uint channels) {
    alias Channels(T) = T[channels];

    private {
        Channels!bool _flipPolarity;
        Channels!(DelayBuffer!float) _delays;
    }

    void setup(float delayMsRange = 50f) {
        float delaySamplesRange = delayMsRange * 0.001f * Atelier_Audio_SampleRate;
        uint delayOffset;

        for (uint ch; ch < channels; ++ch) {
            float rangeLow = delaySamplesRange * ch / channels;
            float rangeHigh = delaySamplesRange * (ch + 1) / channels;
            delayOffset = cast(uint) uniform(rangeLow, rangeHigh);
            _delays[ch].resize(delayOffset + 1);
            _delays[ch].reset(0f);
            _flipPolarity[ch] = choice([false, true]);
        }
    }

    Channels!float process(Channels!float input) {
        Channels!float output;
        output[] = input;
        static foreach (uint ch; 0 .. channels) {
            _delays[ch].write(input[ch]);
            output[ch] = _delays[ch].read();
            _delays[ch].advance();
        }

        hadamard(output);

        static foreach (uint ch; 0 .. channels) {
            if (_flipPolarity[ch]) {
                output[ch] = -output[ch];
            }
        }

        return output;
    }

    void recursiveHadamard(uint size)(ref float[size] data) {
        static if (size <= 1)
            return;
        else {
            enum hSize = size >> 1;

            recursiveHadamard!hSize(data[0 .. hSize]);
            recursiveHadamard!hSize(data[hSize .. $]);

            float a, b;
            static foreach (i; 0 .. hSize) {
                a = data[i];
                b = data[i + hSize];
                data[i] = a + b;
                data[i + hSize] = a - b;
            }
        }
    }

    void hadamard(ref Channels!float data) {
        recursiveHadamard(data);

        float scalingFactor = sqrt(1f / channels);
        static foreach (uint ch; 0 .. channels) {
            data[ch] *= scalingFactor;
        }
    }
}

private struct DelayBuffer(T) {
    private {
        T[] _buffer;
        size_t _position;
    }

    void resize(size_t len) {
        _buffer.length = len;
    }

    void reset(T value) {
        _buffer[] = value;
    }

    T read() {
        size_t offset = (_position + 1) % _buffer.length;
        return _buffer[offset];
    }

    void write(T value) {
        _buffer[_position] = value;
    }

    void advance() {
        _position = (_position + 1) % _buffer.length;
    }
}
