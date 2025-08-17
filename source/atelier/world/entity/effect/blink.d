module atelier.world.entity.effect.blink;

import atelier.common;
import atelier.render;
import atelier.world.entity.renderer;
import atelier.world.entity.effect.base;

/// Fait clignoter l’entité
final class BlinkEffect : EntityGraphicEffect {
    private {
        bool _isRunning;
        Timer _timer;
        Color _color;
        float _minAlpha, _maxAlpha;
        int _count;
        SplineFunc _easeFunc;
    }

    @property {
        /// L’effet est-il encore en cours d’exécution ?
        bool isRunning() const {
            return _isRunning;
        }
    }

    ///Ctor
    this(Color color, float maxAlpha, float minAlpha, uint duration, uint count, Spline ease) {
        _color = color;
        _maxAlpha = maxAlpha;
        _minAlpha = minAlpha;
        _count = count;
        _easeFunc = getSplineFunc(ease);
        _isRunning = true;
        _timer.start(duration);
    }

    ///Modify the effect sprite
    void update(Sprite sprite) {
        _timer.update();
        if (_timer.isRunning()) {
            if (_timer.value01 < .5f) {
                const float t = _easeFunc(_timer.value01 * 2f);
                sprite.alpha = lerp(_minAlpha, _maxAlpha, t);
                sprite.color = lerp(Color.white, _color, t);
            }
            else {
                const float t = _easeFunc((_timer.value01 - .5f) * 2f);
                sprite.alpha = lerp(_maxAlpha, _minAlpha, t);
                sprite.color = lerp(_color, Color.white, t);
            }
        }
        else {
            if (_count == 1) {
                _isRunning = false;
            }
            else {
                if (_count > 1)
                    _count--;
                _timer.start();
            }
        }
    }

    void draw(Sprite sprite, Vec2f position) {
        sprite.draw(position);
    }
}
