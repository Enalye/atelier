module atelier.world.camera.shake;

import atelier.common;

final class CameraShaker {
    private {
        Vec2f _offset = Vec2f.zero;
        float _angle = 0f;
        float _shakeTrauma = 0f, _rumbleTrauma = 0f, _shakeBrightness = 0f, _rumbleBrightness = 0f;
        double _shakeTime = 0.0, _rumbleTime = 0.0;
        uint _rumbleFrame, _rumbleFrames;
        float _initRumble = 0f, _targetRumble = 0f;
        SplineFunc _rumbleSplineFunc;
    }

    @property {
        Vec2f offset() const {
            return _offset;
        }

        float angle() const {
            return _angle;
        }
    }

    void reset() {
        _shakeTrauma = 0f;
        _rumbleTrauma = 0f;
    }

    void shake(float trauma) {
        _shakeTrauma += trauma;
        if (_shakeTrauma > 1f)
            _shakeTrauma = 1f;
    }

    void rumble(float trauma, uint frames, Spline spline) {
        _initRumble = _rumbleTrauma;
        _targetRumble = trauma;
        _rumbleFrame = 0;
        _rumbleFrames = frames;
        _rumbleSplineFunc = getSplineFunc(spline);
    }

    void rumble(float trauma) {
        _initRumble = trauma;
        _targetRumble = trauma;
        _rumbleTrauma = trauma;
        _rumbleFrame = 0;
        _rumbleFrames = 0;
    }

    void update() {
        if (_rumbleFrame < _rumbleFrames) {
            float t = (cast(float) _rumbleFrame) / cast(float) _rumbleFrames;
            _rumbleTrauma = lerp(_initRumble, _targetRumble, _rumbleSplineFunc(t));
            _rumbleFrame++;
        }

        _shakeTime += 0.1f;
        _rumbleTime += 0.01f;

        _shakeBrightness = clamp(_shakeTrauma * _shakeTrauma, 0f, 1f);
        _rumbleBrightness = clamp(_rumbleTrauma * _rumbleTrauma, 0f, 1f);

        _angle = _shakeBrightness * noise(_shakeTime, 0.0);
        _offset.x = 30f * _shakeBrightness * noise(_shakeTime, 10_000.0);
        _offset.y = 30f * _shakeBrightness * noise(_shakeTime, 20_000.0);

        _angle += 0.5f * _rumbleBrightness * noise(_rumbleTime, 30_000.0);
        _offset.x += 10f * _rumbleBrightness * noise(_rumbleTime, 40_000.0);
        _offset.y += 10f * _rumbleBrightness * noise(_rumbleTime, 50_000.0);

        _shakeTrauma = approach(_shakeTrauma, 0f, 0.05f);
    }
}
