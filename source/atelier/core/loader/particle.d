/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.core.loader.particle;

import std.conv : to, ConvException;
import std.exception : enforce;
import std.format : format;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.scene;
import atelier.core.runtime;

private struct ParticleEffectInfo {
    private {
        string _name;
        Vec2u _frames;
        Vec2f _startVec2f = Vec2f.zero;
        Vec2f _endVec2f = Vec2f.zero;
        float _startFloat = 0f;
        float _endFloat = 0f;
        Color _startColor = Color.white;
        Color _endColor = Color.white;
        Spline _spline;
        int _count;
        int _type;
    }

    void _setType(bool isInterval) {
        if (_type == 0) {
            _type = isInterval ? 2 : 1;
            return;
        }
        enforce(_type == (isInterval ? 2 : 1),
            "l’effet peut soit être de type intervalle, soit instantané");
    }

    void parse(const Farfadet ffd) {
        _name = ffd.name;

        foreach (node; ffd.getNodes()) {
            switch (node.name) {
            case "frame":
                uint frame = node.get!uint(0);
                _frames = Vec2u(frame, frame);
                _setType(false);
                break;
            case "frames":
                _frames = Vec2u(node.get!uint(0), node.get!uint(1));
                _setType(true);
                break;
            case "spline":
                _setType(true);
                try {
                    _spline = to!Spline(node.get!string(0));
                }
                catch (ConvException e) {
                    enforce(false, "spline `" ~ node.get!string(0) ~ "` n’est pas valide");
                }
                break;
            case "start":
            case "min":
                _setType(node.name == "start");

                switch (_name) {
                case "scale":
                    _startVec2f = Vec2f(node.get!float(0), node.get!float(1));
                    break;
                case "color":
                    _startColor = Color(node.get!float(0), node.get!float(1), node.get!float(2));
                    break;
                default:
                    _startFloat = node.get!float(0);
                    break;
                }
                break;
            case "end":
            case "max":
                _setType(node.name == "end");

                switch (_name) {
                case "scale":
                    _endVec2f = Vec2f(node.get!float(0), node.get!float(1));
                    break;
                case "color":
                    _endColor = Color(node.get!float(0), node.get!float(1), node.get!float(2));
                    break;
                default:
                    _endFloat = node.get!float(0);
                    break;
                }
                break;
            default:
                enforce(false, "`" ~ _name ~ "` ne définit pas le nœud `" ~ node.name ~ "`");
                break;
            }
        }
    }

    void serialize(OutStream stream) {
        stream.write!string(_name);
        stream.write!int(_type);
        if (_type == 1) {
            stream.write!uint(_frames.x);
        }
        else if (_type == 2) {
            stream.write!uint(_frames.x);
            stream.write!uint(_frames.y);
            stream.write!Spline(_spline);
        }

        switch (_name) {
        case "scale":
            stream.write!Vec2f(_startVec2f);
            stream.write!Vec2f(_endVec2f);
            break;
        case "color":
            stream.write!Color(_startColor);
            stream.write!Color(_endColor);
            break;
        default:
            stream.write!float(_startFloat);
            stream.write!float(_endFloat);
            break;
        }
    }

    void deserialize(InStream stream) {
        _name = stream.read!string();
        _type = stream.read!int();
        if (_type == 1) {
            _frames.x = stream.read!uint();
        }
        else if (_type == 2) {
            _frames.x = stream.read!uint();
            _frames.y = stream.read!uint();
            _spline = stream.read!Spline();
        }

        switch (_name) {
        case "scale":
            _startVec2f = stream.read!Vec2f();
            _endVec2f = stream.read!Vec2f();
            break;
        case "color":
            _startColor = stream.read!Color();
            _endColor = stream.read!Color();
            break;
        default:
            _startFloat = stream.read!float();
            _endFloat = stream.read!float();
            break;
        }
    }
}

package void compileParticle(string path, const Farfadet ffd, OutStream stream) {
    const string rid = ffd.get!string(0);
    string sprite;
    Blend blend = Blend.alpha;
    bool isRelativePosition, isRelativeSpriteAngle;
    Vec2u lifetime, count;
    ParticleMode mode;
    Vec2f area = Vec2f.zero, distance = Vec2f.zero;
    Vec2f angle = Vec2f.zero;
    float spreadAngle = 0f;
    ParticleEffectInfo[] effects;

    ffd.accept([
        "sprite", "blend", "isRelativePosition", "isRelativeSpriteAngle",
        "lifetime", "count", "mode", "area", "distance", "spread", "speed",
        "angle", "spin", "pivotAngle", "pivotSpin", "pivotDistance",
        "spriteAngle", "spriteSpin", "scale", "color", "alpha"
    ]);

    if (ffd.hasNode("sprite")) {
        Farfadet node = ffd.getNode("sprite", 1);
        sprite = node.get!string(0);
    }

    if (ffd.hasNode("blend")) {
        Farfadet node = ffd.getNode("blend");
        blend = to!Blend(node.get!string(0));
    }

    if (ffd.hasNode("isRelativePosition")) {
        Farfadet node = ffd.getNode("isRelativePosition", 1);
        isRelativePosition = node.get!bool(0);
    }

    if (ffd.hasNode("isRelativeSpriteAngle")) {
        Farfadet node = ffd.getNode("isRelativeSpriteAngle", 1);
        isRelativeSpriteAngle = node.get!bool(0);
    }

    if (ffd.hasNode("lifetime")) {
        Farfadet node = ffd.getNode("lifetime", 2);
        lifetime = Vec2u(node.get!uint(0), node.get!uint(1));
    }

    if (ffd.hasNode("count")) {
        Farfadet node = ffd.getNode("count", 2);
        count = Vec2u(node.get!uint(0), node.get!uint(1));
    }

    if (ffd.hasNode("mode")) {
        Farfadet node = ffd.getNode("mode", 1);
        mode = to!ParticleMode(node.get!string(0));
    }

    if (ffd.hasNode("area")) {
        Farfadet node = ffd.getNode("area", 2);
        area = Vec2f(node.get!float(0), node.get!float(1));
    }

    if (ffd.hasNode("distance")) {
        Farfadet node = ffd.getNode("distance", 2);
        distance = Vec2f(node.get!float(0), node.get!float(1));
    }

    if (ffd.hasNode("spread")) {
        Farfadet node = ffd.getNode("spread", 3);
        angle = Vec2f(node.get!float(0), node.get!float(1));
        spreadAngle = node.get!float(2);
    }

    foreach (node; ffd.getNodes()) {
        switch (node.name) {
        case "speed":
        case "angle":
        case "spin":
        case "pivotAngle":
        case "pivotSpin":
        case "pivotDistance":
        case "spriteAngle":
        case "spriteSpin":
        case "scale":
        case "color":
        case "alpha":
            ParticleEffectInfo effect;
            effect.parse(node);
            effects ~= effect;
            break;
        default:
            break;
        }
    }

    stream.write!string(rid);
    stream.write!string(sprite);
    stream.write!Blend(blend);
    stream.write!bool(isRelativePosition);
    stream.write!bool(isRelativeSpriteAngle);
    stream.write!Vec2u(lifetime);
    stream.write!Vec2u(count);
    stream.write!ParticleMode(mode);
    stream.write!Vec2f(area);
    stream.write!Vec2f(distance);
    stream.write!Vec2f(angle);
    stream.write!float(spreadAngle);

    stream.write!uint(cast(uint) effects.length);
    foreach (ref ParticleEffectInfo effect; effects) {
        effect.serialize(stream);
    }
}

package void loadParticle(InStream stream) {
    const string rid = stream.read!string();
    const string sprite = stream.read!string();
    const Blend blend = stream.read!Blend();
    const bool isRelativePosition = stream.read!bool();
    const bool isRelativeSpriteAngle = stream.read!bool();
    const Vec2u lifetime = stream.read!Vec2u();
    const Vec2u count = stream.read!Vec2u();
    const ParticleMode mode = stream.read!ParticleMode();
    const Vec2f area = stream.read!Vec2f();
    const Vec2f distance = stream.read!Vec2f();
    const Vec2f angle = stream.read!Vec2f();
    const float spreadAngle = stream.read!float();

    const uint effectCount = stream.read!uint();
    ParticleEffectInfo[] effects = new ParticleEffectInfo[effectCount];
    for (uint i; i < effectCount; ++i) {
        effects[i].deserialize(stream);
    }

    Atelier.res.store(rid, {
        ParticleSource source = new ParticleSource;
        source.setSprite(sprite);
        source.setBlend(blend);
        source.setRelativePosition(isRelativePosition);
        source.setRelativeSpriteAngle(isRelativeSpriteAngle);
        source.setLifetime(lifetime.x, lifetime.y);
        source.setCount(count.x, count.y);
        source.setMode(mode);
        source.setArea(area.x, area.y);
        source.setDistance(distance.x, distance.y);
        source.setSpread(angle.x, angle.y, spreadAngle);

        foreach (ref ParticleEffectInfo info; effects) {
            ParticleEffect effect;

            if (info._type == 1) {
                switch (info._name) {
                case "speed":
                    effect = new SpeedParticleEffect(info._startFloat, info._endFloat);
                    break;
                case "angle":
                    effect = new AngleParticleEffect(info._startFloat, info._endFloat);
                    break;
                case "spin":
                    effect = new SpinParticleEffect(info._startFloat, info._endFloat);
                    break;
                case "pivotAngle":
                    effect = new PivotAngleParticleEffect(info._startFloat, info._endFloat);
                    break;
                case "pivotSpin":
                    effect = new PivotSpinParticleEffect(info._startFloat, info._endFloat);
                    break;
                case "pivotDistance":
                    effect = new PivotDistanceParticleEffect(info._startFloat, info._endFloat);
                    break;
                case "spriteAngle":
                    effect = new SpriteAngleParticleEffect(info._startFloat, info._endFloat);
                    break;
                case "spriteSpin":
                    effect = new SpriteSpinParticleEffect(info._startFloat, info._endFloat);
                    break;
                case "scale":
                    effect = new ScaleParticleEffect(info._startVec2f, info._endVec2f);
                    break;
                case "color":
                    effect = new ColorParticleEffect(info._startColor, info._endColor);
                    break;
                case "alpha":
                    effect = new AlphaParticleEffect(info._startFloat, info._endFloat);
                    break;
                default:
                    break;
                }
            }
            else if (info._type == 2) {
                SplineFunc splineFunc = getSplineFunc(info._spline);

                switch (info._name) {
                case "speed":
                    effect = new SpeedIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                case "angle":
                    effect = new AngleIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                case "spin":
                    effect = new SpinIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                case "pivotAngle":
                    effect = new PivotAngleIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                case "pivotSpin":
                    effect = new PivotSpinIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                case "pivotDistance":
                    effect = new PivotDistanceIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                case "spriteAngle":
                    effect = new SpriteAngleIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                case "spriteSpin":
                    effect = new SpriteSpinIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                case "scale":
                    effect = new ScaleIntervalParticleEffect(info._startVec2f,
                        info._endVec2f, splineFunc);
                    break;
                case "color":
                    effect = new ColorIntervalParticleEffect(info._startColor,
                        info._endColor, splineFunc);
                    break;
                case "alpha":
                    effect = new AlphaIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                default:
                    break;
                }
            }

            if (effect) {
                effect.setFrames(info._frames.x, info._frames.y);
                source.addEffect(effect);
            }
        }

        return source;
    });
}
