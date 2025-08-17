module atelier.world.lighting.light.base;

import atelier.common;

abstract class Light {
    protected {
        Vec2i _position = Vec2i.zero;
        float _radius = 0f;
        Color _color = Color.white;
        float _brightness = 1f;
        bool _isAlive = true;
    }

    @property {
        Vec2i position() const {
            return _position;
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

    this(Vec2i position_, float radius_, Color color_ = Color.white, float brightness_ = 1f) {
        _position = position_;
        _radius = radius_;
        _color = color_;
        _brightness = brightness_;
    }

    void update() {
    }
}
