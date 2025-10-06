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
        bool _isBlurred;
    }

    void reset() {
        _shakeTrauma = 0f;
        _rumbleTrauma = 0f;
    }

    void blurShake(float trauma) {
        _shakeTrauma += trauma;
        if (_shakeTrauma > 1f)
            _shakeTrauma = 1f;
        _isBlurred = true;
    }

    void shake(float trauma) {
        _shakeTrauma += trauma;
        if (_shakeTrauma > 1f)
            _shakeTrauma = 1f;
        _isBlurred = false;
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

    Vec2f getOffset() const {
        Vec2f offset = Vec2f.zero;
        if (_shakeBrightness > 0f) {
            offset.x = 30f * _shakeBrightness * noise(_shakeTime, 10_000.0);
            offset.y = 30f * _shakeBrightness * noise(_shakeTime, 20_000.0);
        }
        if (_rumbleBrightness > 0f) {
            offset.x += 10f * _rumbleBrightness * noise(_rumbleTime, 40_000.0);
            offset.y += 10f * _rumbleBrightness * noise(_rumbleTime, 50_000.0);
        }
        return offset;
    }

    float getAngle() const {
        float angle = 0f;
        if (_shakeBrightness > 0f)
            angle += _shakeBrightness * noise(_shakeTime, 0.0);
        if (_rumbleBrightness > 0f)
            angle += 0.5f * _rumbleBrightness * noise(_rumbleTime, 30_000.0);
        return angle;
    }

    bool isBlurred() const {
        return _isBlurred;
    }

    float getBlurFactor() const {
        return _shakeTrauma;
    }

    Vec2f getBlurOffset(uint index) const {
        Vec2f offset = Vec2f.zero;
        float pos = (index + 1) * 10_000.0;
        if (_shakeBrightness > 0f) {
            offset.x = 30f * _shakeBrightness * noise(_shakeTime, pos + 60_000.0);
            offset.y = 30f * _shakeBrightness * noise(_shakeTime, pos + 70_000.0);
        }
        if (_rumbleBrightness > 0f) {
            offset.x += 10f * _rumbleBrightness * noise(_rumbleTime, pos + 80_000.0);
            offset.y += 10f * _rumbleBrightness * noise(_rumbleTime, pos + 90_000.0);
        }
        return offset;
    }

    Color getBlurColor(uint index) const {
        Color color;
        float pos = (index + 1) * 10_000.0;
        if (_shakeBrightness > 0f) {
            color.r = _shakeBrightness * noise(_shakeTime, pos + 100_000.0);
            color.g = _shakeBrightness * noise(_shakeTime, pos + 110_000.0);
            color.b = _shakeBrightness * noise(_shakeTime, pos + 120_000.0);
        }
        return color;
    }

    float getBlurAngle(uint index) const {
        float angle = 0f;
        float pos = (index + 1) * 10_000.0;
        if (_shakeBrightness > 0f) {
            angle += _shakeBrightness * noise(_shakeTime, pos + 130_000.0);
        }
        if (_rumbleBrightness > 0f) {
            angle += 0.5f * _rumbleBrightness * noise(_rumbleTime, pos + 140_000.0);
        }
        return angle;
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

        _shakeTrauma = approach(_shakeTrauma, 0f, 0.05f);

        if (_shakeTrauma <= 0f)
            _isBlurred = false;
    }
}
