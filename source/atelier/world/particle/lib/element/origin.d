module atelier.world.particle.lib.element.origin;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.system;

package(atelier.world.particle.lib.element) void particle_loadElementLibrary_origin(
    ParticleSystem system) {
    // origin
    system.addElementFunc(&_origin, "origin", [
            ParticleParam("x", ParticleParam.Type.float_),
            ParticleParam("y", ParticleParam.Type.float_),
            ParticleParam("z", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);

    // addOrigin
    system.addElementFunc(&_addOrigin, "addOrigin", [
            ParticleParam("x", ParticleParam.Type.float_),
            ParticleParam("y", ParticleParam.Type.float_),
            ParticleParam("z", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);

    // moveOrigin
    system.addElementFunc(&_moveOrigin, "moveOrigin");
    system.addElementParam("moveOrigin", "origin", [
            ParticleParam("x", ParticleParam.Type.float_),
            ParticleParam("y", ParticleParam.Type.float_),
            ParticleParam("z", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);
    system.addElementParam("moveOrigin", "duration", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addElementParam("moveOrigin", "spline", [
            ParticleParam("spline", ParticleParam.Type.spline)
        ]);

    // moveToOrigin
    system.addElementFunc(&_moveToOrigin, "moveToOrigin");
    system.addElementParam("moveToOrigin", "origin", [
            ParticleParam("x", ParticleParam.Type.float_),
            ParticleParam("y", ParticleParam.Type.float_),
            ParticleParam("z", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);
    system.addElementParam("moveToOrigin", "duration", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addElementParam("moveToOrigin", "spline", [
            ParticleParam("spline", ParticleParam.Type.spline)
        ]);
}

private final class MoveOrigin : ParticleEffect!ParticleElement {
    private {
        SplineFunc _splineFunc;
        Vec3f _startOrigin = Vec3f.zero;
        Vec3f _endOrigin = Vec3f.zero;
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

        _startOrigin = element.origin;
        if (ffd.hasNode("origin")) {
            Farfadet node = ffd.getNode("origin");
            Vec3f delta = node.get!Vec3f(0);
            Vec3f dir = delta.normalized();
            delta = dir * Atelier.rng.randVariance(delta.length, node.get!float(3));
            _endOrigin = delta;

            if (isRelative)
                _endOrigin += _startOrigin;
        }
    }

    bool process(ParticleElement element) {
        _timer.update();
        element.origin = lerp(_startOrigin, _endOrigin, _splineFunc(_timer.value01));
        return _timer.isRunning();
    }
}

private void _origin(ParticleElement element, Farfadet ffd) {
    Vec3f delta = ffd.get!Vec3f(0);
    Vec3f dir = delta.normalized();
    delta = dir * Atelier.rng.randVariance(delta.length, ffd.get!float(3));
    element.origin = delta;
}

private void _addOrigin(ParticleElement element, Farfadet ffd) {
    Vec3f delta = ffd.get!Vec3f(0);
    Vec3f dir = delta.normalized();
    delta = dir * Atelier.rng.randVariance(delta.length, ffd.get!float(3));
    element.origin += delta;
}

private void _moveOrigin(ParticleElement element, Farfadet ffd) {
    element.addEffect(new MoveOrigin(element, ffd, true));
}

private void _moveToOrigin(ParticleElement element, Farfadet ffd) {
    element.addEffect(new MoveOrigin(element, ffd, false));
}
