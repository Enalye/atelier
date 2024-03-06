/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.common.level;

import std.conv : to, ConvException;
import std.exception : enforce;

import farfadet;
import atelier.core;
import atelier.render;
import atelier.scene;
import atelier.common.color;
import atelier.common.hslcolor;
import atelier.common.resource;
import atelier.common.stream;
import atelier.common.vec2;

private abstract class ImageBuilder {
    private {
        Vec2f _position = Vec2f.zero;
        double _angle = 0.0;
        bool _flipX, _flipY;
        Vec2f _anchor = Vec2f.half;
        Vec2f _pivot = Vec2f.half;
        Blend _blend = Blend.alpha;
        Color _color = Color.white;
        float _alpha = 1f;
        int _zOrder;
    }

    @property string type() const;

    void parse(const Farfadet node) {
        switch (node.name) {
        case "position":
            _position = Vec2f(node.get!float(0), node.get!float(1));
            break;
        case "angle":
            _angle = node.get!double(0);
            break;
        case "flip":
            _flipX = node.get!bool(0);
            _flipY = node.get!bool(1);
            break;
        case "anchor":
            _anchor = Vec2f(node.get!float(0), node.get!float(1));
            break;
        case "pivot":
            _pivot = Vec2f(node.get!float(0), node.get!float(1));
            break;
        case "blend":
            try {
                _blend = to!Blend(node.get!string(0));
            }
            catch (ConvException e) {
                enforce(false,
                    "blend doit valoir `none`, `alpha`, `additive`, `modular`, `multiply` ou `mask`, et non `" ~
                    node.name ~ "`");
            }
            break;
        case "rgb":
            _color = Color(node.get!float(0), node.get!float(1), node.get!float(2));
            break;
        case "hsl":
            _color = HSLColor(node.get!float(0), node.get!float(1), node.get!float(2)).toColor();
            break;
        case "alpha":
            _alpha = node.get!float(0);
            break;
        default:
            enforce(false, "le nœud `" ~ node.name ~ "` n’est pas reconnu");
            break;
        }
    }

    void serialize(OutStream stream) {
        stream.write!Vec2f(_position);
        stream.write!double(_angle);
        stream.write!bool(_flipX);
        stream.write!bool(_flipY);
        stream.write!Vec2f(_anchor);
        stream.write!Vec2f(_pivot);
        stream.write!Blend(_blend);
        stream.write!Color(_color);
        stream.write!float(_alpha);
        stream.write!int(_zOrder);
    }

    void deserialize(InStream stream) {
        _position = stream.read!Vec2f();
        _angle = stream.read!double();
        _flipX = stream.read!bool();
        _flipY = stream.read!bool();
        _anchor = stream.read!Vec2f();
        _pivot = stream.read!Vec2f();
        _blend = stream.read!Blend();
        _color = stream.read!Color();
        _alpha = stream.read!float();
        _zOrder = stream.read!int();
    }

    final void build(Image img) {
        img.position = _position;
        img.angle = _angle;
        img.flipX = _flipX;
        img.flipY = _flipY;
        img.anchor = _anchor;
        img.pivot = _pivot;
        img.blend = _blend;
        img.color = _color;
        img.alpha = _alpha;
        img.zOrder = _zOrder;
    }

    Image build();
}

private class AnimationBuilder : ImageBuilder {
    private {
        string _rid;
    }

    @property override string type() const {
        return "animation";
    }

    this() {
    }

    this(const Farfadet ffd) {
        _rid = ffd.get!string(0);

        foreach (node; ffd.nodes) {
            switch (node.name) {
            default:
                super.parse(node);
                break;
            }
        }
    }

    override Image build() {
        Animation animation = Atelier.res.get!Animation(_rid);
        super.build(animation);
        return animation;
    }

    override void serialize(OutStream stream) {
        stream.write!string(_rid);
        super.serialize(stream);
    }

    override void deserialize(InStream stream) {
        _rid = stream.read!string();
        super.deserialize(stream);
    }
}

private class CapsuleBuilder : ImageBuilder {
    private {
        Vec2f _size = Vec2f.zero;
        float _outline = 0f;
    }

    @property override string type() const {
        return "capsule";
    }

    this() {
    }

    this(const Farfadet ffd) {
        foreach (node; ffd.nodes) {
            switch (node.name) {
            case "size":
                _size = Vec2f(node.get!float(0), node.get!float(1));
                break;
            case "outline":
                _outline = node.get!float(0);
                break;
            default:
                super.parse(node);
                break;
            }
        }
    }

    override Image build() {
        Capsule capsule;
        if (_outline > 0f) {
            capsule = Capsule.outline(_size, _outline);
        }
        else {
            capsule = Capsule.fill(_size);
        }
        super.build(capsule);
        return capsule;
    }

    override void serialize(OutStream stream) {
        stream.write!Vec2f(_size);
        stream.write!float(_outline);
        super.serialize(stream);
    }

    override void deserialize(InStream stream) {
        _size = stream.read!Vec2f();
        _outline = stream.read!float();
        super.deserialize(stream);
    }
}

private class CircleBuilder : ImageBuilder {
    private {
        float _radius = 0f;
        float _outline = 0f;
    }

    @property override string type() const {
        return "circle";
    }

    this() {
    }

    this(const Farfadet ffd) {
        foreach (node; ffd.nodes) {
            switch (node.name) {
            case "radius":
                _radius = node.get!float(0);
                break;
            case "outline":
                _outline = node.get!float(0);
                break;
            default:
                super.parse(node);
                break;
            }
        }
    }

    override Image build() {
        Circle circle;
        if (_outline > 0f) {
            circle = Circle.outline(_radius, _outline);
        }
        else {
            circle = Circle.fill(_radius);
        }
        super.build(circle);
        return circle;
    }

    override void serialize(OutStream stream) {
        stream.write!float(_radius);
        stream.write!float(_outline);
        super.serialize(stream);
    }

    override void deserialize(InStream stream) {
        _radius = stream.read!float();
        _outline = stream.read!float();
        super.deserialize(stream);
    }
}

private class NinePatchBuilder : ImageBuilder {
    private {
        string _rid;
    }

    @property override string type() const {
        return "ninepatch";
    }

    this() {
    }

    this(const Farfadet ffd) {
        _rid = ffd.get!string(0);

        foreach (node; ffd.nodes) {
            switch (node.name) {
            default:
                super.parse(node);
                break;
            }
        }
    }

    override Image build() {
        NinePatch ninepatch = Atelier.res.get!NinePatch(_rid);
        super.build(ninepatch);
        return ninepatch;
    }

    override void serialize(OutStream stream) {
        stream.write!string(_rid);
        super.serialize(stream);
    }

    override void deserialize(InStream stream) {
        _rid = stream.read!string();
        super.deserialize(stream);
    }
}

private class RectangleBuilder : ImageBuilder {
    private {
        Vec2f _size = Vec2f.zero;
        float _outline = 0f;
    }

    @property override string type() const {
        return "rectangle";
    }

    this() {
    }

    this(const Farfadet ffd) {
        foreach (node; ffd.nodes) {
            switch (node.name) {
            case "size":
                _size = Vec2f(node.get!float(0), node.get!float(1));
                break;
            case "outline":
                _outline = node.get!float(0);
                break;
            default:
                super.parse(node);
                break;
            }
        }
    }

    override Image build() {
        Rectangle rectangle;
        if (_outline > 0f) {
            rectangle = Rectangle.outline(_size, _outline);
        }
        else {
            rectangle = Rectangle.fill(_size);
        }
        super.build(rectangle);
        return rectangle;
    }

    override void serialize(OutStream stream) {
        stream.write!Vec2f(_size);
        stream.write!float(_outline);
        super.serialize(stream);
    }

    override void deserialize(InStream stream) {
        _size = stream.read!Vec2f();
        _outline = stream.read!float();
        super.deserialize(stream);
    }
}

private class RoundedRectangleBuilder : ImageBuilder {
    private {
        Vec2f _size = Vec2f.zero;
        float _radius = 0f;
        float _outline = 0f;
    }

    @property override string type() const {
        return "roundedrectangle";
    }

    this() {
    }

    this(const Farfadet ffd) {
        foreach (node; ffd.nodes) {
            switch (node.name) {
            case "size":
                _size = Vec2f(node.get!float(0), node.get!float(1));
                break;
            case "outline":
                _outline = node.get!float(0);
                break;
            case "radius":
                _radius = node.get!float(0);
                break;
            default:
                super.parse(node);
                break;
            }
        }
    }

    override Image build() {
        RoundedRectangle roundedrectangle;
        if (_outline > 0f) {
            roundedrectangle = RoundedRectangle.outline(_size, _radius, _outline);
        }
        else {
            roundedrectangle = RoundedRectangle.fill(_size, _radius);
        }
        super.build(roundedrectangle);
        return roundedrectangle;
    }

    override void serialize(OutStream stream) {
        stream.write!Vec2f(_size);
        stream.write!float(_radius);
        stream.write!float(_outline);
        super.serialize(stream);
    }

    override void deserialize(InStream stream) {
        _size = stream.read!Vec2f();
        _radius = stream.read!float();
        _outline = stream.read!float();
        super.deserialize(stream);
    }
}

private class SpriteBuilder : ImageBuilder {
    private {
        string _rid;
    }

    @property override string type() const {
        return "sprite";
    }

    this() {
    }

    this(const Farfadet ffd) {
        _rid = ffd.get!string(0);

        foreach (node; ffd.nodes) {
            switch (node.name) {
            default:
                super.parse(node);
                break;
            }
        }
    }

    override Image build() {
        Sprite sprite = Atelier.res.get!Sprite(_rid);
        super.build(sprite);
        return sprite;
    }

    override void serialize(OutStream stream) {
        stream.write!string(_rid);
        super.serialize(stream);
    }

    override void deserialize(InStream stream) {
        _rid = stream.read!string();
        super.deserialize(stream);
    }
}

private class TilemapBuilder : ImageBuilder {
    private {
        string _rid;
    }

    @property override string type() const {
        return "tilemap";
    }

    this() {
    }

    this(const Farfadet ffd) {
        _rid = ffd.get!string(0);

        foreach (node; ffd.nodes) {
            switch (node.name) {
            default:
                super.parse(node);
                break;
            }
        }
    }

    override Image build() {
        Tilemap tilemap = Atelier.res.get!Tilemap(_rid);
        super.build(tilemap);
        return tilemap;
    }

    override void serialize(OutStream stream) {
        stream.write!string(_rid);
        super.serialize(stream);
    }

    override void deserialize(InStream stream) {
        _rid = stream.read!string();
        super.deserialize(stream);
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
            case "animation":
                _images ~= new AnimationBuilder(node);
                break;
            case "capsule":
                _images ~= new CapsuleBuilder(node);
                break;
            case "circle":
                _images ~= new CircleBuilder(node);
                break;
            case "ninepatch":
                _images ~= new NinePatchBuilder(node);
                break;
            case "rectangle":
                _images ~= new RectangleBuilder(node);
                break;
            case "roundedrectangle":
                _images ~= new RoundedRectangleBuilder(node);
                break;
            case "sprite":
                _images ~= new SpriteBuilder(node);
                break;
            case "tilemap":
                _images ~= new TilemapBuilder(node);
                break;
            default:
                enforce(false, "le nœud `entity` ne définit pas le nœud `" ~ node.name ~ "`");
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
            string imageType = stream.read!string();
            switch (imageType) {
            case "animation":
                image = new AnimationBuilder;
                break;
            case "capsule":
                image = new CapsuleBuilder;
                break;
            case "circle":
                image = new CircleBuilder;
                break;
            case "ninepatch":
                image = new NinePatchBuilder;
                break;
            case "rectangle":
                image = new RectangleBuilder;
                break;
            case "roundedrectangle":
                image = new RoundedRectangleBuilder;
                break;
            case "sprite":
                image = new SpriteBuilder;
                break;
            case "tilemap":
                image = new TilemapBuilder;
                break;
            default:
                enforce(false, "`" ~ imageType ~ "` n’est pas défini");
                break;
            }
            image.deserialize(stream);
            _images ~= image;
        }
    }
}

private class ParticleSourceBuilder {
    private {
        Vec2f _position = Vec2f.zero;
        string _rid;
        string _name;
        string[] _tags;
    }

    this() {
    }

    this(const Farfadet ffd) {
        _rid = ffd.get!string(0);

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
            default:
                enforce(false, "le nœud `particle` ne définit pas le nœud `" ~ node.name ~ "`");
                break;
            }
        }
    }

    ParticleSource build() {
        ParticleSource source = Atelier.res.get!ParticleSource(_rid);
        source.name = _name;
        source.tags = _tags;
        source.position = _position;
        return source;
    }

    void serialize(OutStream stream) {
        stream.write!string(_rid);
        stream.write!string(_name);
        stream.write!(string[])(_tags);
        stream.write!Vec2f(_position);
    }

    void deserialize(InStream stream) {
        _rid = stream.read!string();
        _name = stream.read!string();
        _tags = stream.read!(string[])();
        _position = stream.read!Vec2f();
    }
}

private abstract class ColliderBuilder {
    private {
        Vec2i _position = Vec2i.zero;
        Vec2i _hitbox = Vec2i.zero;
        string _name;
        string[] _tags;
        bool _hasEntity;
        EntityBuilder _entity;
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
                _position = Vec2i(node.get!int(0), node.get!int(1));
                break;
            case "hitbox":
                _hitbox = Vec2i(node.get!int(0), node.get!int(1));
                break;
            case "entity":
                _hasEntity = true;
                _entity = new EntityBuilder(node);
                break;
            default:
                break;
            }
        }
    }

    final void build(Collider collider) {
        collider.name = _name;
        collider.tags = _tags;
        collider.position = _position;
        collider.hitbox = _hitbox;

        if (_hasEntity) {
            collider.entity = _entity.build();
        }
    }

    void serialize(OutStream stream) {
        stream.write!string(_name);
        stream.write!(string[])(_tags);
        stream.write!Vec2i(_position);
        stream.write!Vec2i(_hitbox);
        stream.write!bool(_hasEntity);

        if (_hasEntity) {
            _entity.serialize(stream);
        }
    }

    void deserialize(InStream stream) {
        _name = stream.read!string();
        _tags = stream.read!(string[])();
        _position = stream.read!Vec2i();
        _hitbox = stream.read!Vec2i();
        _hasEntity = stream.read!bool();

        if (_hasEntity) {
            _entity = new EntityBuilder;
            _entity.deserialize(stream);
        }
    }
}

private class ActorBuilder : ColliderBuilder {
    this() {
    }

    this(const Farfadet ffd) {
        super(ffd);
    }

    Actor build() {
        Actor actor = new Actor;
        super.build(actor);
        return actor;
    }
}

private class SolidBuilder : ColliderBuilder {
    this() {
    }

    this(const Farfadet ffd) {
        super(ffd);
    }

    Solid build() {
        Solid solid = new Solid;
        super.build(solid);
        return solid;
    }
}

private class SceneBuilder {
    private {
        Vec2f _position = Vec2f.zero;
        Vec2f _parallax = Vec2f.one;
        int _zOrder;
        EntityBuilder[] _entities;
        ParticleSourceBuilder[] _particleSources;
        ActorBuilder[] _actors;
        SolidBuilder[] _solids;
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
            case "zOrder":
                _zOrder = node.get!int(0);
                break;
            case "position":
                _position = Vec2f(node.get!float(0), node.get!float(1));
                break;
            case "parallax":
                _parallax = Vec2f(node.get!float(0), node.get!float(1));
                break;
            case "entity":
                _entities ~= new EntityBuilder(node);
                break;
            case "particle":
                _particleSources ~= new ParticleSourceBuilder(node);
                break;
            case "actor":
                _actors ~= new ActorBuilder(node);
                break;
            case "solid":
                _solids ~= new SolidBuilder(node);
                break;
            default:
                break;
            }
        }
    }

    Scene build() {
        Scene scene = new Scene;
        scene.name = _name;
        scene.tags = _tags;
        scene.position = _position;
        scene.parallax = _parallax;
        scene.zOrder = _zOrder;

        foreach (EntityBuilder entityBuilder; _entities) {
            scene.addEntity(entityBuilder.build());
        }

        foreach (ParticleSourceBuilder sourceBuilder; _particleSources) {
            scene.addParticleSource(sourceBuilder.build());
        }

        foreach (ActorBuilder actorBuilder; _actors) {
            Actor actor = actorBuilder.build();
            scene.addActor(actor);
        }

        foreach (SolidBuilder solidBuilder; _solids) {
            Solid solid = solidBuilder.build();
            scene.addSolid(solid);
        }

        return scene;
    }

    void serialize(OutStream stream) {
        stream.write!string(_name);
        stream.write!(string[])(_tags);
        stream.write!Vec2f(_position);
        stream.write!Vec2f(_parallax);
        stream.write!int(_zOrder);

        stream.write!uint(cast(uint) _entities.length);
        foreach (EntityBuilder entity; _entities) {
            entity.serialize(stream);
        }

        stream.write!uint(cast(uint) _particleSources.length);
        foreach (ParticleSourceBuilder source; _particleSources) {
            source.serialize(stream);
        }

        stream.write!uint(cast(uint) _actors.length);
        foreach (ActorBuilder actor; _actors) {
            actor.serialize(stream);
        }

        stream.write!uint(cast(uint) _solids.length);
        foreach (SolidBuilder solid; _solids) {
            solid.serialize(stream);
        }
    }

    void deserialize(InStream stream) {
        _name = stream.read!string();
        _tags = stream.read!(string[])();
        _position = stream.read!Vec2f();
        _parallax = stream.read!Vec2f();
        _zOrder = stream.read!int();

        const uint entityCount = stream.read!uint();
        _entities = new EntityBuilder[entityCount];
        for (uint i; i < entityCount; ++i) {
            EntityBuilder entity = new EntityBuilder;
            entity.deserialize(stream);
            _entities[i] = entity;
        }

        const uint sourceCount = stream.read!uint();
        _particleSources = new ParticleSourceBuilder[sourceCount];
        for (uint i; i < sourceCount; ++i) {
            ParticleSourceBuilder particle = new ParticleSourceBuilder;
            particle.deserialize(stream);
            _particleSources[i] = particle;
        }

        const uint actorCount = stream.read!uint();
        _actors = new ActorBuilder[actorCount];
        for (uint i; i < actorCount; ++i) {
            ActorBuilder actor = new ActorBuilder;
            actor.deserialize(stream);
            _actors[i] = actor;
        }

        const uint solidCount = stream.read!uint();
        _solids = new SolidBuilder[solidCount];
        for (uint i; i < solidCount; ++i) {
            SolidBuilder solid = new SolidBuilder;
            solid.deserialize(stream);
            _solids[i] = solid;
        }
    }
}

final class LevelBuilder : Resource!LevelBuilder {
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

    LevelBuilder fetch() {
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
