module atelier.world.particle.lib.element.sprite_angle;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.system;

package(atelier.world.particle) void particle_loadElementLibrary_spriteAngle(ParticleSystem system) {
    // spriteAngle
    system.addElementFunc(&_spriteAngle, "spriteAngle", [
            ParticleParam("angle", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);

    // addSpriteAngle
    system.addElementFunc(&_addSpriteAngle, "addSpriteAngle", [
            ParticleParam("angle", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);

    // moveSpriteAngle
    system.addElementFunc(&_moveSpriteAngle, "moveSpriteAngle");
    system.addElementParam("moveSpriteAngle", "angle", [
            ParticleParam("angle", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);
    system.addElementParam("moveSpriteAngle", "duration", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addElementParam("moveSpriteAngle", "spline", [
            ParticleParam("spline", ParticleParam.Type.spline)
        ]);

    // moveToSpriteAngle
    system.addElementFunc(&_moveToSpriteAngle, "moveToSpriteAngle");
    system.addElementParam("moveToSpriteAngle", "angle", [
            ParticleParam("angle", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);
    system.addElementParam("moveToSpriteAngle", "duration", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addElementParam("moveToSpriteAngle", "spline", [
            ParticleParam("spline", ParticleParam.Type.spline)
        ]);
}

private final class MoveSpriteAngle : ParticleEffect!ParticleElement {
    private {
        SplineFunc _splineFunc;
        float _startSpriteAngle = 0f;
        float _endSpriteAngle = 0f;
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

        _startSpriteAngle = element.spriteAngle;
        if (ffd.hasNode("angle")) {
            Farfadet node = ffd.getNode("angle");
            _endSpriteAngle = Atelier.rng.randVariance(node.get!float(0), node.get!float(1));
            if (isRelative)
                _endSpriteAngle += _startSpriteAngle;
        }
    }

    bool process(ParticleElement element) {
        _timer.update();
        element.spriteAngle = lerp(_startSpriteAngle, _endSpriteAngle, _splineFunc(_timer.value01));
        return _timer.isRunning();
    }
}

private void _spriteAngle(ParticleElement element, Farfadet ffd) {
    element.spriteAngle = Atelier.rng.randVariance(ffd.get!float(0), ffd.get!float(1));
}

private void _addSpriteAngle(ParticleElement element, Farfadet ffd) {
    element.spriteAngle += Atelier.rng.randVariance(ffd.get!float(0), ffd.get!float(1));
}

private void _moveSpriteAngle(ParticleElement element, Farfadet ffd) {
    element.addEffect(new MoveSpriteAngle(element, ffd, true));
}

private void _moveToSpriteAngle(ParticleElement element, Farfadet ffd) {
    element.addEffect(new MoveSpriteAngle(element, ffd, false));
}
