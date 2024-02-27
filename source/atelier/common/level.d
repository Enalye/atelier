/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.common.level;

import farfadet;
import atelier.core;
import atelier.render;
import atelier.scene;
import atelier.common.resource;
import atelier.common.stream;
import atelier.common.vec2;

private interface ImageBuilder {
    @property string type() const;
    void serialize(OutStream);
    void deserialize(InStream);
    Image build();
}

private class SpriteBuilder : ImageBuilder {
    private {
        string _name;
        Vec2f _position = Vec2f.zero;
        int _zOrder;
    }

    @property string type() const {
        return "sprite";
    }

    this() {
    }

    this(const Farfadet ffd) {
        _name = ffd.get!string(0);

        foreach (node; ffd.nodes) {
            switch (node.name) {
            case "position":
                _position = Vec2f(node.get!float(0), node.get!float(1));
                break;
            default:
                break;
            }
        }
    }

    Image build() {
        Sprite sprite = Atelier.res.get!Sprite(_name);
        sprite.position = _position;
        sprite.zOrder = _zOrder;
        return sprite;
    }

    void serialize(OutStream stream) {
        stream.write!string(_name);
        stream.write!Vec2f(_position);
    }

    void deserialize(InStream stream) {
        _name = stream.read!string();
        _position = stream.read!Vec2f();
    }
}

private class TilemapBuilder : ImageBuilder {
    private {
        string _name;
        Vec2f _position = Vec2f.zero;
        int _zOrder;
    }

    @property string type() const {
        return "tilemap";
    }

    this() {
    }

    this(const Farfadet ffd) {
        _name = ffd.get!string(0);

        foreach (node; ffd.nodes) {
            switch (node.name) {
            case "position":
                _position = Vec2f(node.get!float(0), node.get!float(1));
                break;
            default:
                break;
            }
        }
    }

    Image build() {
        Tilemap tilemap = Atelier.res.get!Tilemap(_name);
        tilemap.position = _position;
        tilemap.zOrder = _zOrder;
        return tilemap;
    }

    void serialize(OutStream stream) {
        stream.write!string(_name);
        stream.write!Vec2f(_position);
        stream.write!int(_zOrder);
    }

    void deserialize(InStream stream) {
        _name = stream.read!string();
        _position = stream.read!Vec2f();
        _zOrder = stream.read!int();
    }
}

private class EntityBuilder {
    private {
        Vec2f _position = Vec2f.zero;
        int _zOrder;
        EntityBuilder[] _entities;
        ImageBuilder[] _images;
        string _name;
        string[] _tags;
    }

    this() {
    }

    this(const Farfadet ffd) {
        foreach (node; ffd.nodes) {
            switch (node.name) {
            case "name":
                _name = node.get!string(0);
                break;
            case "tags":
                _tags ~= node.get!(string[])(0);
                break;
            case "tag":
                _tags ~= node.get!string(0);
                break;
            case "position":
                _position = Vec2f(node.get!float(0), node.get!float(1));
                break;
            case "zOrder":
                _zOrder = node.get!int(0);
                break;
            case "entity":
                _entities ~= new EntityBuilder(node);
                break;
            case "sprite":
                _images ~= new SpriteBuilder(node);
                break;
            case "tilemap":
                _images ~= new TilemapBuilder(node);
                break;
            default:
                break;
            }
        }
    }

    Entity build() {
        Entity entity = new Entity;
        entity.name = _name;
        entity.tags = _tags;
        entity.position = _position;
        entity.zOrder = _zOrder;

        foreach (EntityBuilder entityBuilder; _entities) {
            entity.addChild(entityBuilder.build());
        }

        foreach (ImageBuilder imageBuilder; _images) {
            entity.addImage(imageBuilder.build());
        }

        return entity;
    }

    void serialize(OutStream stream) {
        stream.write!string(_name);
        stream.write!(string[])(_tags);
        stream.write!Vec2f(_position);
        stream.write!int(_zOrder);

        stream.write!uint(cast(uint) _entities.length);
        foreach (EntityBuilder entity; _entities) {
            entity.serialize(stream);
        }

        stream.write!uint(cast(uint) _images.length);
        foreach (ImageBuilder image; _images) {
            stream.write!string(image.type);
            image.serialize(stream);
        }
    }

    void deserialize(InStream stream) {
        _name = stream.read!string();
        _tags = stream.read!(string[])();
        _position = stream.read!Vec2f();
        _zOrder = stream.read!int();

        _entities.length = 0;
        const uint entityCount = stream.read!uint();
        for (uint i; i < entityCount; ++i) {
            EntityBuilder entity = new EntityBuilder;
            entity.deserialize(stream);
            _entities ~= entity;
        }

        _images.length = 0;
        const uint imageCount = stream.read!uint();
        for (uint i; i < imageCount; ++i) {
            ImageBuilder image;
            switch (stream.read!string()) {
            case "sprite":
                image = new SpriteBuilder;
                break;
            case "tilemap":
                image = new TilemapBuilder;
                break;
            default:
                break;
            }
            image.deserialize(stream);
            _images ~= image;
        }
    }
}

private class SceneBuilder {
    private {
        Vec2u _size = Vec2u.zero;
        Vec2f _position = Vec2f.zero;
        int _zOrder;
        EntityBuilder[] _entities;
        string _name;
        string[] _tags;
    }

    this() {
    }

    this(const Farfadet ffd) {
        _size = Vec2u(ffd.get!uint(0), ffd.get!uint(1));

        foreach (node; ffd.nodes) {
            switch (node.name) {
            case "name":
                _name = node.get!string(0);
                break;
            case "tags":
                _tags ~= node.get!(string[])(0);
                break;
            case "tag":
                _tags ~= node.get!string(0);
                break;
            case "zOrder":
                _zOrder = node.get!int(0);
                break;
            case "position":
                _position = Vec2f(node.get!float(0), node.get!float(1));
                break;
            case "entity":
                _entities ~= new EntityBuilder(node);
                break;
            default:
                break;
            }
        }
    }

    Scene build() {
        Scene scene = new Scene(_size.x, _size.y);
        scene.name = _name;
        scene.tags = _tags;
        scene.position = _position;
        scene.zOrder = _zOrder;

        foreach (EntityBuilder entityBuilder; _entities) {
            scene.addEntity(entityBuilder.build());
        }

        return scene;
    }

    void serialize(OutStream stream) {
        stream.write!string(_name);
        stream.write!(string[])(_tags);
        stream.write!Vec2u(_size);
        stream.write!Vec2f(_position);
        stream.write!int(_zOrder);

        stream.write!uint(cast(uint) _entities.length);
        foreach (EntityBuilder entity; _entities) {
            entity.serialize(stream);
        }
    }

    void deserialize(InStream stream) {
        _name = stream.read!string();
        _tags = stream.read!(string[])();
        _size = stream.read!Vec2u();
        _position = stream.read!Vec2f();
        _zOrder = stream.read!int();

        _entities.length = 0;
        const uint entityCount = stream.read!uint();
        for (uint i; i < entityCount; ++i) {
            EntityBuilder entity = new EntityBuilder;
            entity.deserialize(stream);
            _entities ~= entity;
        }
    }
}

final class Level : Resource!Level {
    private {
        SceneBuilder[] _scenes;
    }

    this() {
    }

    this(const Farfadet ffd) {
        foreach (node; ffd.nodes) {
            switch (node.name) {
            case "scene":
                _scenes ~= new SceneBuilder(node);
                break;
            default:
                break;
            }
        }
    }

    Level fetch() {
        return this;
    }

    Scene[] build() {
        Scene[] scenes;
        foreach (SceneBuilder sceneBuilder; _scenes) {
            scenes ~= sceneBuilder.build();
        }
        return scenes;
    }

    void serialize(OutStream stream) {
        stream.write!uint(cast(uint) _scenes.length);
        foreach (SceneBuilder scene; _scenes) {
            scene.serialize(stream);
        }
    }

    void deserialize(InStream stream) {
        _scenes.length = 0;
        const uint sceneCount = stream.read!uint();
        for (uint i; i < sceneCount; ++i) {
            SceneBuilder scene = new SceneBuilder;
            scene.deserialize(stream);
            _scenes ~= scene;
        }
    }
}
