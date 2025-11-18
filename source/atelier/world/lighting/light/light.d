module atelier.world.lighting.light.light;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world.lighting.light.base;
import atelier.world.lighting.light.controller;

struct LightData {
    string name;
    string[] tags;
    string controller;
    Vec2i position;
    Color color = Color.white;
    float brightness = 1f;
    float radius = 64f;
    float angle = 0f;

    mixin Serializer;
}

final class Light {
    private {
        string _name;
        string[] _tags;
        Sprite _sprite;
        Vec2i _position = Vec2i.zero;
        float _scale = 1f;
        float _radius = 0f;
        float _angle = 0f;
        Color _color = Color.white;
        float _brightness = 1f;
        bool _isAlive = true;
        LightController _controller;
    }

    @property {
        Vec2i position() const {
            return _position;
        }

        float scale() const {
            return _scale;
        }

        float radius() const {
            return _radius;
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
        ShadedTexture texture = Atelier.res.get!ShadedTexture(base.shadedTexture);
        _sprite = new Sprite(texture.data, base.clip);
        _radius = (_sprite.clip.z + _sprite.clip.w) / 4f;

        _sprite.position = cast(Vec2f) data.position;
        _sprite.color = data.color;
        _sprite.alpha = data.brightness;
        _sprite.anchor = base.anchor;
        _sprite.pivot = base.anchor;

        _name = data.name;
        _tags ~= base.tags.dup;
        _tags ~= data.tags.dup;

        if (data.controller.length) {
            setController(data.controller);
        }
        else if (base.controller.length) {
            setController(base.controller);
        }
    }

    void update() {
    }

    void draw(Vec2f offset) {
        _sprite.draw(offset);
    }

    LightController getController() {
        return _controller;
    }

    bool hasController() {
        return _controller !is null;
    }

    void removeController() {
        if (_controller) {
            _controller.unregister();
            _controller = null;
        }
    }

    void setController(string id) {
        if (_controller) {
            _controller.unregister();
        }

        _controller = Atelier.world.fetchController!Light(id);

        if (_controller) {
            _controller.setup(this);
            Atelier.world.registerController(_controller);
            _controller.onStart();
        }
    }
}
