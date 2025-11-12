module atelier.world.lighting.light.faded;

import atelier.common;
import atelier.world.lighting.light.base;

/*
final class FadedLight : Light {
    private {
        float _maxBrightness;
        uint _fadeIn, _duration, _fadeOut;
        Timer _timer;
        enum State {
            fadeIn,
            stay,
            fadeOut
        }

        State _state;
    }

    this(Vec2i position_, float radius_, Color color_, float brightness_,
        uint fadeIn, uint duration, uint fadeOut) {
        super(position_, radius_, color_, 0f);
        _maxBrightness = brightness_;
        _fadeIn = fadeIn;
        _duration = duration;
        _fadeOut = fadeOut;
        _state = State.fadeIn;
        _timer.start(_fadeIn);
    }

    override void update() {
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
*/
