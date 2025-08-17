module atelier.world.lighting.darkness.faded;

import atelier.common;
import atelier.world.lighting.darkness.base;

final class FadedDarkness : Darkness {
    private {
        float _brightness, _maxBrightness;
        uint _fadeIn, _duration, _fadeOut;
        Timer _timer;
        enum State {
            fadeIn,
            stay,
            fadeOut
        }

        State _state;
        bool _isAlive;
    }

    @property {
        float brightness() const {
            return _brightness;
        }

        bool isAlive() const {
            return _isAlive;
        }
    }

    this(float brightness, uint fadeIn, uint duration, uint fadeOut) {
        _brightness = 0f;
        _maxBrightness = brightness;
        _fadeIn = fadeIn;
        _duration = duration;
        _fadeOut = fadeOut;
        _state = State.fadeIn;
        _timer.start(_fadeIn);
        _isAlive = true;
    }

    void update() {
        _timer.update();
        final switch (_state) with (State) {
        case fadeIn:
            if (!_timer.isRunning()) {
                _state = State.stay;
                _timer.start(_duration);
            }
            else {
                _brightness = lerp(0f, _maxBrightness, _timer.value01);
            }
            break;
        case stay:
            if (!_timer.isRunning()) {
                _state = State.fadeOut;
                _timer.start(_fadeOut);
            }
            else {
                _brightness = _maxBrightness;
            }
            break;
        case fadeOut:
            if (!_timer.isRunning()) {
                _isAlive = false;
            }
            else {
                _brightness = lerp(_maxBrightness, 0f, _timer.value01);
            }
            break;
        }
    }
}
