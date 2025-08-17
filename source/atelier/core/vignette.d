module atelier.core.vignette;

import atelier.common;
import atelier.render;
import atelier.core.runtime;

/// Affiche les bordures cinématiques en haut et en bas de l’écran
final class Vignette {
    private {
        Timer _timer;

        enum State {
            hidden,
            fadeIn,
            visible,
            fadeOut
        }

        Color _color = Color.black;
        State _state = State.hidden;
        float _borderSize = 50f;
    }

    /// Enable or disable the vignette
    void set(bool enable, Color color, uint duration) {
        _state = enable ? State.fadeIn : State.fadeOut;
        _color = color;
        _timer.start(duration);
    }

    void clear() {
        _timer.stop();
        _state = State.hidden;
        _color = Color.black;
    }

    void update() {
        final switch (_state) with (State) {
        case hidden:
        case visible:
            break;
        case fadeIn:
            _timer.update();
            if (!_timer.isRunning) {
                _state = State.visible;
            }
            break;
        case fadeOut:
            _timer.update();
            if (!_timer.isRunning) {
                _state = State.hidden;
            }
            break;
        }
    }

    void draw() {
        final switch (_state) with (State) {
        case hidden:
            break;
        case visible:
            Atelier.renderer.drawRect(Vec2f.zero,
                Vec2f(Atelier.renderer.size.x, _borderSize),
                _color, 1f, true);
            Atelier.renderer.drawRect(Vec2f(0f, Atelier.renderer.size.y - _borderSize),
                Vec2f(Atelier.renderer.size.x, _borderSize),
                _color, 1f, true);
            break;
        case fadeIn:
            const float sz = easeOutSine(_timer.value01) * _borderSize;
            Atelier.renderer.drawRect(Vec2f.zero,
                Vec2f(Atelier.renderer.size.x, sz),
                _color, 1f, true);
            Atelier.renderer.drawRect(Vec2f(0f, Atelier.renderer.size.y - sz),
                Vec2f(Atelier.renderer.size.x, sz + 1f),
                _color, 1f, true);
            break;
        case fadeOut:
            const float sz = easeInSine(1f - _timer.value01) * _borderSize;
            Atelier.renderer.drawRect(Vec2f.zero,
                Vec2f(Atelier.renderer.size.x, sz),
                _color, 1f, true);
            Atelier.renderer.drawRect(Vec2f(0f, Atelier.renderer.size.y - sz),
                Vec2f(Atelier.renderer.size.x, sz + 1f),
                _color, 1f, true);
            break;
        }
    }
}
