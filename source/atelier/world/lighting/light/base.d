module atelier.world.lighting.light.base;

import atelier.common;
import atelier.core;
import atelier.render;

struct BaseLightData {
    string anim;
    string icon;
    string[] tags;
    string controller;

    mixin Serializer;
}

final class BaseLight : Resource!BaseLight {
    private {
        BaseLightData _data;
    }

    @property {
        string anim() const {
            return _data.anim;
        }

        string icon() const {
            return _data.icon;
        }

        const(string[]) tags() const {
            return _data.tags;
        }

        string controller() const {
            return _data.controller;
        }
    }

    this(BaseLightData data) {
        _data = data;
    }

    BaseLight fetch() {
        return this;
    }
}

struct LightData {
    string name;
    string[] tags;
    string controller;
    Vec2i position;
    Color color = Color.white;
    float brightness = 1f;
    float scale = 1f;
    float angle = 0f;

    mixin Serializer;
}

final class Light {
    private {
        Animation _anim;
        Vec2i _position = Vec2i.zero;
        float _scale = 1f;
        float _angle = 0f;
        Color _color = Color.white;
        float _brightness = 1f;
        bool _isAlive = true;
    }

    @property {
        Vec2i position() const {
            return _position;
        }

        float radius() const {
            return _scale;
        }

        Color color() const {
            return _color;
        }

        float brightness() const {
            return _brightness;
        }

        bool isAlive() const {
            return true;
        }
    }

    this(string rid, const(LightData) data) {
        BaseLight base = Atelier.res.get!BaseLight(rid);
        _anim = Atelier.res.get!Animation(base.anim);
        _anim.position = cast(Vec2f) data.position;
        _anim.color = data.color;
        _anim.alpha = data.brightness;
        _anim.anchor = Vec2f.half;
    }

    this(Light other) {
        if (other._anim) {
            _anim = other._anim.fetch();
        }
        _position = other._position;
        _scale = other._scale;
        _color = other._color;
        _brightness = other._brightness;
        _isAlive = other._isAlive;
    }

    void update() {
        if (!_anim)
            return;

        _anim.update();
    }

    void draw(Vec2f offset) {
        if (!_anim)
            return;

        _anim.draw(offset);
    }
}
