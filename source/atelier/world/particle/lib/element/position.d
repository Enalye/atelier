module atelier.world.particle.lib.element.position;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.system;

package(atelier.world.particle.lib.element) void particle_loadElementLibrary_position(
    ParticleSystem system) {
    // position
    system.addElementFunc(&_position, "position", [
            ParticleParam("x", ParticleParam.Type.float_),
            ParticleParam("y", ParticleParam.Type.float_),
            ParticleParam("z", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);

    // addPosition
    system.addElementFunc(&_addPosition, "addPosition", [
            ParticleParam("x", ParticleParam.Type.float_),
            ParticleParam("y", ParticleParam.Type.float_),
            ParticleParam("z", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);

    // movePosition
    system.addElementFunc(&_movePosition, "movePosition");
    system.addElementParam("movePosition", "position", [
            ParticleParam("x", ParticleParam.Type.float_),
            ParticleParam("y", ParticleParam.Type.float_),
            ParticleParam("z", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);
    system.addElementParam("movePosition", "duration", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addElementParam("movePosition", "spline", [
            ParticleParam("spline", ParticleParam.Type.spline)
        ]);

    // moveToPosition
    system.addElementFunc(&_moveToPosition, "moveToPosition");
    system.addElementParam("moveToPosition", "position", [
            ParticleParam("x", ParticleParam.Type.float_),
            ParticleParam("y", ParticleParam.Type.float_),
            ParticleParam("z", ParticleParam.Type.float_)
        ]);
    system.addElementParam("moveToPosition", "duration", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addElementParam("moveToPosition", "spline", [
            ParticleParam("spline", ParticleParam.Type.spline)
        ]);
}

private final class MovePosition : ParticleEffect!ParticleElement {
    private {
        SplineFunc _splineFunc;
        Vec3f _startPosition = Vec3f.zero;
        Vec3f _endPosition = Vec3f.zero;
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

        _startPosition = element.position;
        if (ffd.hasNode("position")) {
            Farfadet node = ffd.getNode("position");
            Vec3f delta = node.get!Vec3f(0);
            Vec3f dir = delta.normalized();
            delta = dir * Atelier.rng.randVariance(delta.length, node.get!float(3));
            _endPosition = delta;

            if (isRelative)
                _endPosition += _startPosition;
        }
    }

    bool process(ParticleElement element) {
        _timer.update();
        element.position = lerp(_startPosition, _endPosition, _splineFunc(_timer.value01));
        return _timer.isRunning();
    }
}

private void _position(ParticleElement element, Farfadet ffd) {
    Vec3f delta = ffd.get!Vec3f(0);
    Vec3f dir = delta.normalized();
    delta = dir * Atelier.rng.randVariance(delta.length, ffd.get!float(3));
    element.position = delta;
}

private void _addPosition(ParticleElement element, Farfadet ffd) {
    Vec3f delta = ffd.get!Vec3f(0);
    Vec3f dir = delta.normalized();
    delta = dir * Atelier.rng.randVariance(delta.length, ffd.get!float(3));
    element.position += delta;
}

private void _movePosition(ParticleElement element, Farfadet ffd) {
    element.addEffect(new MovePosition(element, ffd, true));
}

private void _moveToPosition(ParticleElement element, Farfadet ffd) {
    element.addEffect(new MovePosition(element, ffd, false));
}
