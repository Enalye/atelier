module atelier.common.generator;

import std.math;

interface Generator {
    void update();
    float get();
}

final class SineGenerator : Generator {
    private {
        float _value;
        uint _time;
    }

    void update() {
        _time++;
        float freq = 1f;
        float amplitude = 1f;
        float phi = 0f;
        _value = sin(_time * freq + phi) * amplitude;
    }

    float get() {
        return 0f;
    }
}

//RampGenerator
