module atelier.world.lighting.system;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world.scene;
import atelier.world.system;
import atelier.world.lighting.darkness;
import atelier.world.lighting.light;

final class Lighting {
    private {
        float _brightness = 1f;
        float _totalDarkness = 0f;
        float _totalBrightness = 1f;
        float _originBrightness = 1f;
        float _targetBrightness = 1f;
        Timer _brightnessTimer;
        Spline _brightnessSpline = Spline.linear;

        Sprite _rectSprite, _lightSprite;
        Canvas _canvas;
        Sprite _sprite;

        Array!Darkness _darknesses;
        Array!Light _lights;
        bool _isLoaded;
    }

    this() {
        _canvas = new Canvas(Atelier.renderer.size.x, Atelier.renderer.size.y);
        _sprite = new Sprite(_canvas);
        _sprite.blend = Blend.modular;
        _sprite.anchor = Vec2f.zero;

        _darknesses = new Array!Darkness;
        _lights = new Array!Light;
    }

    void setup() {
        _rectSprite = Atelier.res.get!Sprite("atelier:light.darkness");
        _rectSprite.blend = Blend.alpha;
        _rectSprite.anchor = Vec2f.zero;
        _rectSprite.color = Color.white;

        _lightSprite = Atelier.res.get!Sprite("atelier:light.point512");
        _lightSprite.blend = Blend.additive;
        _lightSprite.anchor = Vec2f.half;
        _isLoaded = true;
    }

    void clear() {
        _darknesses.clear();
        _lights.clear();
    }

    void setBrightness(float value) {
        _brightness = value;
    }

    void setBrightness(float value, uint frames, Spline spline) {
        _originBrightness = _brightness;
        _targetBrightness = value;
        _brightnessSpline = spline;

        if (frames == 0) {
            setBrightness(_targetBrightness);
        }
        else {
            _brightnessTimer.start(frames);
        }
    }

    void addLight(Light light) {
        _lights ~= light;
    }

    void addDarkness(Darkness darkness) {
        _darknesses ~= darkness;
    }

    float getBrightnessAt(Vec2i position) {
        float lighting = _totalBrightness;
        if (lighting >= 1f)
            return 1f;

        foreach (light; _lights) {
            float dist = light.position.distance(position);
            if (dist < light.radius) {
                float mul = 1f - (dist / light.radius);
                lighting += mul * light.brightness;

                if (lighting > 1f)
                    return 1f;
            }
        }

        return lighting;
    }

    void update() {
        if (!_isLoaded)
            return;

        if (_brightnessTimer.isRunning()) {
            _brightnessTimer.update();
            SplineFunc splineFunc = getSplineFunc(_brightnessSpline);
            _brightness = lerp(_originBrightness, _targetBrightness, splineFunc(
                    _brightnessTimer.value01()));
        }

        foreach (i, darkness; _darknesses) {
            darkness.update();

            if (!darkness.isAlive()) {
                _darknesses.mark(i);
            }
        }
        _darknesses.sweep();

        foreach (i, light; _lights) {
            light.update();

            if (!light.isAlive()) {
                _lights.mark(i);
            }
        }
        _lights.sweep();

        float tempDarkness = 0f;
        if (_darknesses.length()) {
            foreach (id, darkness; _darknesses) {
                tempDarkness += clamp(darkness.brightness, 0f, 1f);
            }
            tempDarkness /= cast(float) _darknesses.length();
        }
        _totalDarkness = tempDarkness;
        _totalBrightness = lerp(_brightness, 0f, _totalDarkness);
    }

    void draw(Vec2f offset) {
        if (!_isLoaded)
            return;

        _canvas.color = Color.black;
        Atelier.renderer.pushCanvas(_canvas);

        _rectSprite.alpha = _totalBrightness;
        _rectSprite.size = _sprite.size;
        _rectSprite.anchor = Vec2f.zero;
        _rectSprite.draw(Vec2f.zero);

        foreach (id, light; _lights) {
            light.draw(offset);
        }

        Atelier.renderer.popCanvas();
        _sprite.draw(Vec2f.zero);

        foreach (id, light; _lights) {
            //  light.draw(offset);
        }
    }
}
