module atelier.world.particle.lib.element.color;

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

package(atelier.world.particle) void particle_loadElementLibrary_color(ParticleSystem system) {
    // color
    system.addElementFunc(&_color, "color", [
            ParticleParam("couleur", ParticleParam.Type.color)
        ]);

    // fadeColor
    system.addElementFunc(&_fadeColor, "fadeColor");
    system.addElementParam("fadeColor", "color", [
            ParticleParam("couleur", ParticleParam.Type.color)
        ]);
    system.addElementParam("fadeColor", "duration", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addElementParam("fadeColor", "spline", [
            ParticleParam("spline", ParticleParam.Type.spline)
        ]);
    system.addElementParam("fadeColor", "colorSpace", [
            ParticleParam("Espace de couleur", ParticleParam.Type.enum_, [
                    "rgb", "hsl"
                ])
        ]);
}

private final class ColorFader(T) : ParticleEffect!ParticleElement {
    private {
        SplineFunc _splineFunc;
        T _startColor;
        T _endColor;
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

        Color color = Color.white;
        if (ffd.hasNode("color")) {
            color = ffd.getNode("color").get!Color(0);
        }

        static if (is(T : HSLColor)) {
            _startColor = HSLColor.fromColor(element.color);
            _endColor = HSLColor.fromColor(color);
        }
        else static if (is(T : Color)) {
            _startColor = element.color;
            _endColor = color;
        }
    }

    bool process(ParticleElement element) {
        _timer.update();
        T color = lerp(_startColor, _endColor, _splineFunc(_timer.value01));

        static if (is(T : HSLColor)) {
            element.color = color.toColor();
        }
        else static if (is(T : Color)) {
            element.color = color;
        }

        return _timer.isRunning();
    }
}

private void _color(ParticleElement element, Farfadet ffd) {
    element.color = ffd.get!Color(0);
}

private void _fadeColor(ParticleElement element, Farfadet ffd) {
    string colorSpace;
    if (ffd.hasNode("colorSpace")) {
        colorSpace = ffd.getNode("colorSpace").get!string(0);
    }

    ParticleEffect!ParticleElement effect;
    switch (colorSpace) {
    case "rgb":
        effect = new ColorFader!Color(element, ffd);
        break;
    case "hsl":
        effect = new ColorFader!HSLColor(element, ffd);
        break;
    default:
        goto case "rgb";
    }

    element.addEffect(effect);
}
