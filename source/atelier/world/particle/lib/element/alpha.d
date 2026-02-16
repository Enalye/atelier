module atelier.world.particle.lib.element.alpha;

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

package(atelier.world.particle) void particle_loadElementLibrary_alpha(ParticleSystem system) {
    // alpha
    system.addElementFunc(&_alpha, "alpha", [
            ParticleParam("opacité", ParticleParam.Type.float01)
        ]);

    // fadeAlpha
    system.addElementFunc(&_fadeAlpha, "fadeAlpha");
    system.addElementParam("fadeAlpha", "alpha", [
            ParticleParam("opacité", ParticleParam.Type.float01)
        ]);
    system.addElementParam("fadeAlpha", "duration", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addElementParam("fadeAlpha", "spline", [
            ParticleParam("spline", ParticleParam.Type.spline)
        ]);
}

private final class AlphaFader : ParticleEffect!ParticleElement {
    private {
        SplineFunc _splineFunc;
        float _startAlpha = 1f;
        float _endAlpha = 1f;
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

        _startAlpha = element.alpha;
        if (ffd.hasNode("alpha")) {
            _endAlpha = ffd.getNode("alpha").get!float(0);
        }
    }

    bool process(ParticleElement element) {
        _timer.update();
        element.alpha = lerp(_startAlpha, _endAlpha, _splineFunc(_timer.value01));
        return _timer.isRunning();
    }
}

private void _alpha(ParticleElement element, Farfadet ffd) {
    element.alpha = ffd.get!float(0);
}

private void _fadeAlpha(ParticleElement element, Farfadet ffd) {
    element.addEffect(new AlphaFader(element, ffd));
}
