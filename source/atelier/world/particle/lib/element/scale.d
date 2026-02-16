module atelier.world.particle.lib.element.scale;

import std.conv : to, ConvException;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.system;

package(atelier.world.particle) void particle_loadElementLibrary_scale(ParticleSystem system) {
    // scale
    system.addElementFunc(&_scale, "scale", [
            ParticleParam("x", ParticleParam.Type.float_),
            ParticleParam("y", ParticleParam.Type.float_),
            ParticleParam("variance X", ParticleParam.Type.float_),
            ParticleParam("variance Y", ParticleParam.Type.float_)
        ]);

    // fadeScale
    system.addElementFunc(&_fadeScale, "fadeScale");
    system.addElementParam("fadeScale", "scale", [
            ParticleParam("x", ParticleParam.Type.float_),
            ParticleParam("y", ParticleParam.Type.float_),
            ParticleParam("variance X", ParticleParam.Type.float_),
            ParticleParam("variance Y", ParticleParam.Type.float_)
        ]);
    system.addElementParam("fadeScale", "duration", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addElementParam("fadeScale", "spline", [
            ParticleParam("spline", ParticleParam.Type.spline)
        ]);
}

private final class ScaleFader : ParticleEffect!ParticleElement {
    private {
        SplineFunc _splineFunc;
        Vec2f _startScale = Vec2f.one;
        Vec2f _endScale = Vec2f.one;
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

        _startScale = element.scale;
        if (ffd.hasNode("scale")) {
            Farfadet node = ffd.getNode("scale");
            Vec2f scale;
            scale.x = Atelier.rng.rand(node.get!float(0), node.get!float(2));
            scale.y = Atelier.rng.rand(node.get!float(1), node.get!float(3));
            _endScale = scale;
        }
    }

    bool process(ParticleElement element) {
        _timer.update();
        element.scale = lerp(_startScale, _endScale, _splineFunc(_timer.value01));
        return _timer.isRunning();
    }
}

private void _scale(ParticleElement element, Farfadet ffd) {
    Vec2f scale;
    scale.x = Atelier.rng.rand(ffd.get!float(0), ffd.get!float(2));
    scale.y = Atelier.rng.rand(ffd.get!float(1), ffd.get!float(3));
    element.scale = scale;
}

private void _fadeScale(ParticleElement element, Farfadet ffd) {
    element.addEffect(new ScaleFader(element, ffd));
}
