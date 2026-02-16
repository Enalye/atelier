module atelier.world.particle.lib.element.distance;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.system;

package(atelier.world.particle) void particle_loadElementLibrary_distance(ParticleSystem system) {
    // distance
    system.addElementFunc(&_distance, "distance", [
            ParticleParam("distance", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);

    // addDistance
    system.addElementFunc(&_addDistance, "addDistance", [
            ParticleParam("distance", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);

    // moveDistance
    system.addElementFunc(&_moveDistance, "moveDistance");
    system.addElementParam("moveDistance", "distance", [
            ParticleParam("distance", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);
    system.addElementParam("moveDistance", "duration", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addElementParam("moveDistance", "spline", [
            ParticleParam("spline", ParticleParam.Type.spline)
        ]);

    // moveToDistance
    system.addElementFunc(&_moveToDistance, "moveToDistance");
    system.addElementParam("moveToDistance", "distance", [
            ParticleParam("distance", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);
    system.addElementParam("moveToDistance", "duration", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addElementParam("moveToDistance", "spline", [
            ParticleParam("spline", ParticleParam.Type.spline)
        ]);
}

private final class MoveDistance : ParticleEffect!ParticleElement {
    private {
        SplineFunc _splineFunc;
        float _startDistance = 0f;
        float _endDistance = 0f;
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

        _startDistance = element.distance;
        if (ffd.hasNode("distance")) {
            Farfadet node = ffd.getNode("distance");
            _endDistance = Atelier.rng.randVariance(node.get!float(0), node.get!float(1));
            if (isRelative)
                _endDistance += _startDistance;
        }
    }

    bool process(ParticleElement element) {
        _timer.update();
        element.distance = lerp(_startDistance, _endDistance, _splineFunc(_timer.value01));
        return _timer.isRunning();
    }
}

private void _distance(ParticleElement element, Farfadet ffd) {
    element.distance = Atelier.rng.randVariance(ffd.get!float(0), ffd.get!float(1));
}

private void _addDistance(ParticleElement element, Farfadet ffd) {
    element.distance += Atelier.rng.randVariance(ffd.get!float(0), ffd.get!float(1));
}

private void _moveDistance(ParticleElement element, Farfadet ffd) {
    element.addEffect(new MoveDistance(element, ffd, true));
}

private void _moveToDistance(ParticleElement element, Farfadet ffd) {
    element.addEffect(new MoveDistance(element, ffd, false));
}
