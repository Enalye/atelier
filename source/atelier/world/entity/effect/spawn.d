module atelier.world.entity.effect.spawn;

import atelier.common;
import atelier.render;
import atelier.world.entity.renderer;
import atelier.world.entity.effect.base;

/// Ghost effect for the tank when spawning
final class SpawnEffect : EntityGraphicEffect {
    private {
        Timer _timer;
        uint _duration = 60;
        Color _color = Color.white;
        float _minAlpha = 0.4f, _maxAlpha = 0.8f;
        SplineFunc _splineFunc;
    }

    @property {
        ///Is the effect still running ?
        bool isRunning() const {
            return true;
        }

        /// Color
        Color color() const {
            return _color;
        }
        /// Ditto
        Color color(Color color_) {
            return _color = color_;
        }
    }

    ///Ctor
    this() {
        _splineFunc = getSplineFunc(Spline.sineInOut);
        _timer.start(_duration);
    }

    ///Modify the effect sprite
    void update(Sprite sprite) {
        _timer.update();
        sprite.color = _color;
        if (_timer.isRunning()) {
            if (_timer.value01 < .5f) {
                const float t = _splineFunc(_timer.value01 * 2f);
                sprite.alpha = lerp(_minAlpha, _maxAlpha, t);
            }
            else {
                const float t = _splineFunc((_timer.value01 - .5f) * 2f);
                sprite.alpha = lerp(_maxAlpha, _minAlpha, t);
            }
        }
        else {
            _timer.start(_duration);
        }
    }

    void draw(Sprite sprite, Vec2f position) {
        sprite.draw(position);
    }
}
