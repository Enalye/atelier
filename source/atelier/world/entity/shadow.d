module atelier.world.entity.shadow;

import std.math;

import atelier.common;
import atelier.core;
import atelier.render;

struct ShadowData {
    string sprite;
    int maxAltitude = 16;
    float groundAlpha = 0.6f;
    float highAlpha = 0.2f;
    float groundScale = 1.5f;
    float highScale = 1f;
    bool isTurning;

    mixin Serializer;
}

final class Shadow : Resource!Shadow {
    private {
        Sprite _sprite;
        int _maxAltitude;
        float _groundAlpha;
        float _highAlpha;
        float _groundScale;
        float _highScale;
        bool _isTurning;
    }

    this(ShadowData data) {
        _sprite = Atelier.res.get!Sprite(data.sprite);
        _sprite.anchor = Vec2f.half;
        _maxAltitude = data.maxAltitude;
        _groundAlpha = data.groundAlpha;
        _highAlpha = data.highAlpha;
        _groundScale = data.groundScale;
        _highScale = data.highScale;
        _isTurning = data.isTurning;
    }

    Shadow fetch() {
        return this;
    }

    void setMaxAltitude(int altitude) {
        _maxAltitude = max(0, altitude);
    }

    void setAlpha(float groundAlpha, float highAlpha) {
        _groundAlpha = groundAlpha;
        _highAlpha = highAlpha;
    }

    void draw(Vec2f offset, Vec2i position, int altitude, float angle, float alpha) {
        float t = easeInOutSine(clamp(altitude, 0, _maxAltitude) / (cast(float) _maxAltitude));
        float brightness = Atelier.world.lighting.getBrightnessAt(position) * alpha;
        _sprite.alpha = lerp(_groundAlpha, _highAlpha, t) * brightness;
        _sprite.size = (cast(Vec2f) _sprite.clip.zw) * lerp(_groundScale, _highScale, t);
        _sprite.angle = _isTurning ? angle : 0f;
        _sprite.draw(offset + Vec2f(0f, altitude));
    }
}
