module atelier.world.lighting.light.base;

import atelier.common;
import atelier.world.entity;

struct BaseLightData {
    string shadedtexture;
    Vec4u clip;
    Vec2f anchor = Vec2f.zero;
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
        string shadedTexture() const {
            return _data.shadedtexture;
        }

        Vec4u clip() const {
            return _data.clip;
        }

        Vec2f anchor() const {
            return _data.anchor;
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
