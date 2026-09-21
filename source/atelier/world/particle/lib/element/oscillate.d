module atelier.world.particle.lib.element.oscillate;

import std.math;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.system;

package(atelier.world.particle.lib.element) void particle_loadElementLibrary_oscillate(
    ParticleSystem system) {
    // oscillate
    system.addElementFunc(&_oscillate, "oscillate");
    system.addElementParam("oscillate", "count", [
            ParticleParam("count", ParticleParam.Type.float_),
            ParticleParam("phase", ParticleParam.Type.float_)
        ]);
    system.addElementParam("oscillate", "angle", [
            ParticleParam("start", ParticleParam.Type.float_),
            ParticleParam("end", ParticleParam.Type.float_)
        ]);
    system.addElementParam("oscillate", "amplitude", [
            ParticleParam("startX", ParticleParam.Type.float_),
            ParticleParam("startY", ParticleParam.Type.float_),
            ParticleParam("endX", ParticleParam.Type.float_),
            ParticleParam("endY", ParticleParam.Type.float_)
        ]);
    system.addElementParam("oscillate", "duration", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addElementParam("oscillate", "spline", [
            ParticleParam("spline", ParticleParam.Type.spline)
        ]);
}

private final class Oscillator : ParticleEffect!ParticleElement {
    private {
        SplineFunc _splineFunc;
        float _count = 0f;
        float _phase = 0f;
        float _startAngle = 0f;
        float _endAngle = 0f;
        float _startAmplitudeX = 0f;
        float _startAmplitudeY = 0f;
        float _endAmplitudeX = 0f;
        float _endAmplitudeY = 0f;
        Timer _timer;
    }

    this(ParticleElement element, Farfadet ffd) {
        if (ffd.hasNode("duration")) {
            Farfadet node = ffd.getNode("duration");
            _timer.start(Atelier.rng.randVariance(node.get!uint(0), node.get!uint(1)));
        }

        Spline spline = Spline.linear;
        if (ffd.hasNode("spline")) {
            spline = ffd.getNode("spline").get!Spline(0);
        }
        _splineFunc = getSplineFunc(spline);

        if (ffd.hasNode("count")) {
            Farfadet node = ffd.getNode("count");
            _count = node.get!float(0);
            _phase = degToRad(node.get!float(1));
        }

        if (ffd.hasNode("angle")) {
            Farfadet node = ffd.getNode("angle");
            _startAngle = degToRad(node.get!float(0));
            _endAngle = degToRad(node.get!float(1));
        }

        _startAmplitudeX = 0f;
        _startAmplitudeY = 0f;
        _endAmplitudeX = 0f;
        _endAmplitudeY = 0f;
        if (ffd.hasNode("amplitude")) {
            Farfadet node = ffd.getNode("amplitude");
            _startAmplitudeX = node.get!float(0);
            _startAmplitudeY = node.get!float(1);
            _endAmplitudeX = node.get!float(2);
            _endAmplitudeY = node.get!float(3);
        }
    }

    bool process(ParticleElement element) {
        _timer.update();
        float t = _splineFunc(_timer.value01);

        float amplitudeX = lerp(_startAmplitudeX, _endAmplitudeX, t);
        float amplitudeY = lerp(_startAmplitudeY, _endAmplitudeY, t);
        float angle = lerp(_startAngle, _endAngle, t);

        float offset = (_count * t * PI * 2f) + _phase;
        Vec2f dir = Vec2f(cos(offset) * amplitudeX, sin(offset) * amplitudeY);

        element.position = Vec3f(dir.rotate(angle), 0f);
        return _timer.isRunning();
    }
}

private void _oscillate(ParticleElement element, Farfadet ffd) {
    element.addEffect(new Oscillator(element, ffd));
}
