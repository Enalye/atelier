module atelier.world.particle.lib.element.angle;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.system;

package(atelier.world.particle) void particle_loadElementLibrary_angle(ParticleSystem system) {
    // angle
    system.addElementFunc(&_angle, "angle", [
            ParticleParam("angle", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);

    // addAngle
    system.addElementFunc(&_addAngle, "addAngle", [
            ParticleParam("angle", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);

    // moveAngle
    system.addElementFunc(&_moveAngle, "moveAngle");
    system.addElementParam("moveAngle", "angle", [
            ParticleParam("angle", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);
    system.addElementParam("moveAngle", "duration", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addElementParam("moveAngle", "spline", [
            ParticleParam("spline", ParticleParam.Type.spline)
        ]);

    // moveToAngle
    system.addElementFunc(&_moveToAngle, "moveToAngle");
    system.addElementParam("moveToAngle", "angle", [
            ParticleParam("angle", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);
    system.addElementParam("moveToAngle", "duration", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addElementParam("moveToAngle", "spline", [
            ParticleParam("spline", ParticleParam.Type.spline)
        ]);
}

private final class MoveAngle : ParticleEffect!ParticleElement {
    private {
        SplineFunc _splineFunc;
        float _startAngle = 0f;
        float _endAngle = 0f;
        Timer _timer;
    }

    this(ParticleElement element, Farfadet ffd, bool isRelative) {
        if (ffd.hasNode("duration")) {
            Farfadet node = ffd.getNode("duration");
            _timer.start(Atelier.rng.randVariance(node.get!uint(0), node.get!uint(1)));
        }

        Spline spline = Spline.linear;
        if (ffd.hasNode("spline")) {
            spline = ffd.getNode("spline").get!Spline(0);
        }
        _splineFunc = getSplineFunc(spline);

        _startAngle = element.angle;
        if (ffd.hasNode("angle")) {
            Farfadet node = ffd.getNode("angle");
            _endAngle = Atelier.rng.randVariance(node.get!float(0), node.get!float(1));
            if (isRelative)
                _endAngle += _startAngle;
        }
    }

    bool process(ParticleElement element) {
        _timer.update();
        element.angle = lerp(_startAngle, _endAngle, _splineFunc(_timer.value01));
        return _timer.isRunning();
    }
}

private void _angle(ParticleElement element, Farfadet ffd) {
    element.angle = Atelier.rng.randVariance(ffd.get!float(0), ffd.get!float(1));
}

private void _addAngle(ParticleElement element, Farfadet ffd) {
    element.angle += Atelier.rng.randVariance(ffd.get!float(0), ffd.get!float(1));
}

private void _moveAngle(ParticleElement element, Farfadet ffd) {
    element.addEffect(new MoveAngle(element, ffd, true));
}

private void _moveToAngle(ParticleElement element, Farfadet ffd) {
    element.addEffect(new MoveAngle(element, ffd, false));
}
