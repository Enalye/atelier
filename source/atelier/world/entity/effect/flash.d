module atelier.world.entity.effect.flash;

import atelier.common;
import atelier.render;
import atelier.world.entity.renderer;
import atelier.world.entity.effect.base;

/// Fait clignoter l’entité
final class FlashEffect : EntityGraphicEffect {
    private {
        bool _isRunning;
        Timer _timer;
        uint _stayDuration, _fadeDuration;
        Color _color;
        float _alpha;
        SplineFunc _splineFunc;
        bool _stayPhase;
    }

    @property {
        /// L’effet est-il encore en cours d’exécution ?
        bool isRunning() const {
            return _isRunning;
        }
    }

    ///Ctor
    this(Color color, float alpha, uint stayDuration, uint fadeDuration, Spline spline) {
        _color = color;
        _alpha = alpha;
        _stayDuration = stayDuration;
        _fadeDuration = fadeDuration;
        _splineFunc = getSplineFunc(spline);
        _isRunning = true;
        _stayPhase = true;
        _timer.start(_stayDuration);
    }

    ///Modify the effect sprite
    void update(Sprite sprite) {
        _timer.update();
        if (_stayPhase) {
            sprite.alpha = _alpha;
            sprite.color = _color;
            if (!_timer.isRunning()) {
                _stayPhase = false;
                _timer.start(_fadeDuration);
            }
        }
        else {
            const float t = _splineFunc(_timer.value01);
            sprite.alpha = lerp(_alpha, 0f, t);
            sprite.color = lerp(_color, Color.white, t);
            if (!_timer.isRunning()) {
                _isRunning = false;
            }
        }
    }

    void draw(Sprite sprite, Vec2f position) {
        sprite.draw(position);
    }
}
