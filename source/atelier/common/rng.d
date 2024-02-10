/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.common.rng;

import std.math;
import std.mathspecial;

final class RNG {
    private {
        ulong _state = 0x853c49e6748fea9bUL;
        ulong _inc = 0xda3e39cb94b95bdbUL;
        double spared;
        bool hasSpared = false;
        float sparef;
        bool hasSparef = false;
    }

    this() {
    }

    this(ulong initState, ulong initSeq) {
        _state = 0u;
        _inc = (initSeq << 1u) | 1u;
    }

    private uint _rand() {
        ulong oldState = _state;
        _state = oldState * 6_364_136_223_846_793_005UL + (_inc | 1u);
        uint xorShifted = cast(uint)(((oldState >> 18u) ^ oldState) >> 27u);
        uint rot = oldState >> 59u;
        return (xorShifted >> rot) | (xorShifted << ((-rot) & 31));
    }

    double randd() {
        return ldexp(cast(double) _rand(), -32);
    }

    float randf() {
        return ldexp(cast(float) _rand(), -32);
    }

    uint randu(uint maxValue) {
        return _rand() % maxValue;
    }

    int randi(int maxValue) {
        return (cast(int) _rand()) % maxValue;
    }

    double randd(double maxValue) {
        return randd() * maxValue;
    }

    float randf(float maxValue) {
        return randf() * maxValue;
    }

    uint randu(uint minValue, uint maxValue) {
        return minValue + (_rand() % maxValue);
    }

    int randi(int minValue, int maxValue) {
        return minValue + (cast(int) _rand()) % maxValue;
    }

    double randd(double minValue, double maxValue) {
        return minValue + randd() * maxValue;
    }

    float randf(float minValue, float maxValue) {
        return minValue + randf() * maxValue;
    }

    double randdn() {
        return generateGaussian(0.5, 0.1);
    }

    float randfn() {
        return generateGaussian(0.5f, 0.1f);
    }

    double generateGaussian(double mean, double deviation) {
        if (hasSpared) {
            hasSpared = false;
            return spared * deviation + mean;
        }
        double u, v, s;
        do {
            u = randd() * 2.0 - 1.0;
            v = randd() * 2.0 - 1.0;
            s = u * u + v * v;
        }
        while (s >= 1.0 || s == 0.0);
        s = sqrt(-2.0 * log(s) / s);
        spared = v * s;
        hasSpared = true;
        return mean + deviation * u * s;
    }

    float generateGaussian(float mean, float deviation) {
        if (hasSparef) {
            hasSparef = false;
            return sparef * deviation + mean;
        }
        float u, v, s;
        do {
            u = randf() * 2f - 1f;
            v = randf() * 2f - 1f;
            s = u * u + v * v;
        }
        while (s >= 1f || s == 0f);
        s = sqrt(-2f * log(s) / s);
        sparef = v * s;
        hasSparef = true;
        return mean + deviation * u * s;
    }
}
