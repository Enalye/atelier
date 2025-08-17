module atelier.core.overlay;

import atelier.common;
import atelier.render;
import atelier.core.runtime;

/// Permet les transitions en fondu
final class Overlay {
    private {
        Timer _timer;

        Color _startColor = Color.white;
        Color _color = Color.white;
        float _startAlpha = 0f;
        float _alpha = 0f;
        SplineFunc _spline;
    }

    /// Démarre la transition
    void set(Color color, float alpha, uint duration, Spline spline) {
        _startColor = _color;
        _startAlpha = _alpha;
        _color = color;
        _alpha = alpha;
        _spline = getSplineFunc(spline);

        if (_startAlpha == 0f) {
            _startColor = _color;
        }

        if (duration > 0) {
            _timer.start(duration);
        }
        else {
            _timer.stop();
        }
    }

    void clear() {
        _timer.stop();
        _startAlpha = 0f;
        _alpha = 0f;
        _startColor = Color.white;
        _color = Color.white;
    }

    void update() {
        _timer.update();
    }

    void draw() {
        Color color;
        float alpha;
        if (_timer.isRunning) {
            const float t = _spline(_timer.value01);
            color = lerp(_startColor, _color, t);
            alpha = lerp(_startAlpha, _alpha, t);
        }
        else {
            color = _color;
            alpha = _alpha;
        }
        if (alpha > 0f) {
            Atelier.renderer.drawRect(Vec2f.zero, cast(Vec2f) Atelier.renderer.size, color, alpha, true);
        }
    }
}
