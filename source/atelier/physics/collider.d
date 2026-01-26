module atelier.physics.collider;

import farfadet;
import atelier.common;
import atelier.core;
import atelier.world;
import atelier.physics.actor;
import atelier.physics.solid;
import atelier.physics.system;

struct HitboxData {
    enum Type {
        none,
        actor,
        solid,
        shot
    }

    Type type = Type.none;
    Vec3u size;
    string shape = "box";
    float bounciness = 0f;

    void load(const Farfadet ffd) {
        type = Type.none;

        Farfadet hitboxNode;
        if (ffd.hasNode("hitbox")) {
            hitboxNode = ffd.getNode("hitbox");
            if (hitboxNode.hasNode("type")) {
                type = hitboxNode.getNode("type").get!Type(0);
            }
        }

        final switch (type) with (Type) {
        case none:
            break;
        case actor:
            if (hitboxNode.hasNode("size")) {
                size = hitboxNode.getNode("size").get!Vec3u(0);
            }
            if (hitboxNode.hasNode("bounciness")) {
                bounciness = hitboxNode.getNode("bounciness").get!float(0);
            }
            break;
        case solid:
            if (hitboxNode.hasNode("size")) {
                size = hitboxNode.getNode("size").get!Vec3u(0);
            }
            if (hitboxNode.hasNode("shape")) {
                shape = hitboxNode.getNode("shape").get!string(0);
            }
            if (hitboxNode.hasNode("bounciness")) {
                bounciness = hitboxNode.getNode("bounciness").get!float(0);
            }
            break;
        case shot:
            if (hitboxNode.hasNode("size")) {
                size = hitboxNode.getNode("size").get!Vec3u(0);
            }
            break;
        }
    }

    void save(Farfadet ffd) {
        final switch (type) with (Type) {
        case none:
            break;
        case actor:
            Farfadet node = ffd.addNode("hitbox");
            node.addNode("type").add(type);
            node.addNode("size").add(size);
            node.addNode("bounciness").add(bounciness);
            break;
        case solid:
            Farfadet node = ffd.addNode("hitbox");
            node.addNode("type").add(type);
            node.addNode("size").add(size);
            node.addNode("shape").add(shape);
            node.addNode("bounciness").add(bounciness);
            break;
        case shot:
            Farfadet node = ffd.addNode("hitbox");
            node.addNode("type").add(type);
            node.addNode("size").add(size);
            break;
        }
    }

    void serialize(OutStream stream) {
        stream.write!Type(type);

        final switch (type) with (Type) {
        case none:
            break;
        case actor:
            stream.write!Vec3u(size);
            stream.write!float(bounciness);
            break;
        case solid:
            stream.write!Vec3u(size);
            stream.write!string(shape);
            stream.write!float(bounciness);
            break;
        case shot:
            stream.write!Vec3u(size);
            break;
        }
    }

    void deserialize(InStream stream) {
        type = stream.read!Type();

        final switch (type) with (Type) {
        case none:
            break;
        case actor:
            size = stream.read!Vec3u();
            bounciness = stream.read!float();
            break;
        case solid:
            size = stream.read!Vec3u();
            shape = stream.read!string();
            bounciness = stream.read!float();
            break;
        case shot:
            size = stream.read!Vec3u();
            break;
        }
    }

    Collider fetch() {
        final switch (type) with (Type) {
        case none:
            return null;
        case actor:
            return new ActorCollider(size, bounciness);
        case solid:
            return new SolidCollider(size, shape, bounciness);
        case shot:
            return null;
        }
    }
}

/// Base des collisions
abstract class Collider {
    private {
        bool _isRegistered = true;
        bool _isTiled;
        Entity _entity;
        Vec3i _hitbox = Vec3i.zero;
        Vec2i _hitboxHalf1 = Vec2i.zero;
        Vec2i _hitboxHalf2 = Vec2i.zero;
        Vec2i _tileboxHalf1 = Vec2i.zero;
        Vec2i _tileboxHalf2 = Vec2i.zero;
        int _zTilebox;
        bool _isDisplayed;
    }

    enum Type {
        solid,
        actor,
        shot,
        trigger
    }

    protected {
        Type _type;
    }

    @property {
        bool isRegistered() const {
            return _isRegistered;
        }

        package bool isRegistered(bool value) {
            return _isRegistered = value;
        }

        bool isTiled() const {
            return _isTiled;
        }

        final Type type() {
            return _type;
        }

        final Entity entity() {
            return _entity;
        }

        final Vec3i hitbox() const {
            return _hitbox;
        }

        /// Coin gauche de la boite de collision (Axe X)
        final int left() const {
            return _entity.getPosition().x - _hitboxHalf1.x;
        }

        /// Coin droite de la boite de collision (Axe X)
        final int right() const {
            return _entity.getPosition().x + _hitboxHalf2.x;
        }

        /// Coin bas de la boite de collision (Axe Y)
        final int down() const {
            return _entity.getPosition().y + _hitboxHalf2.y;
        }

        /// Coin haut de la boite de collision (Axe Y)
        final int up() const {
            return _entity.getPosition().y - _hitboxHalf1.y;
        }

        /// Coin dessus la boite de collision (Axe Z)
        final int top() const {
            return _entity.getPosition().z + _hitbox.z;
        }

        /// Coin dessous la boite de collision (Axe Z)
        final int bottom() const {
            return _entity.getPosition().z;
        }

        final bool isDisplayed() const {
            return _isDisplayed;
        }

        final bool isDisplayed(bool isDisplayed_) {
            return _isDisplayed = isDisplayed_;
        }
    }

    this(Vec3u size_) {
        _hitbox = cast(Vec3i) size_;
        _hitboxHalf2 = (_hitbox.xy >> 1);
        _hitboxHalf1 = _hitbox.xy - _hitboxHalf2;
        _zTilebox = (_hitbox.z >> 4) + ((_hitbox.z & 0x10) > 0 ? 1 : 0);
        _tileboxHalf1.x = (_tileboxHalf1.x >> 4) + ((_tileboxHalf1.x & 0x10) > 0 ? 1 : 0);
        _tileboxHalf1.y = (_tileboxHalf1.y >> 4) + ((_tileboxHalf1.y & 0x10) > 0 ? 1 : 0);
        _tileboxHalf2.x = (_tileboxHalf2.x >> 4) + ((_tileboxHalf2.x & 0x10) > 0 ? 1 : 0);
        _tileboxHalf2.y = (_tileboxHalf2.y >> 4) + ((_tileboxHalf2.y & 0x10) > 0 ? 1 : 0);
    }

    this(Collider other) {
        _type = other._type;
        _hitbox = other._hitbox;
        _hitboxHalf1 = other._hitboxHalf1;
        _hitboxHalf2 = other._hitboxHalf2;
        _zTilebox = other._zTilebox;
        _tileboxHalf1 = other._tileboxHalf1;
        _tileboxHalf2 = other._tileboxHalf2;
    }

    abstract Collider fetch();

    final void register() {
        Atelier.physics.addCollider(this);
    }

    final void unregister() {
        Atelier.physics.removeCollider(this);
    }

    final void setEntity(Entity entity_) {
        _entity = entity_;
    }

    final Vec2i getTileOffset() const {
        return (_tileboxHalf1 + _tileboxHalf2) << 3;
    }

    Physics.TerrainHit hitTerrain() {
        return Atelier.physics.hitTerrain(_entity.getPosition(), hitbox);
    }

    final bool isAbove(Collider other) {
        return (other.left < right) && (other.right > left) && (other.up < down) &&
            (other.down > up) && (other._entity.getPosition().z <= _entity.getPosition().z);
    }

    final bool isBehind(Collider other) {
        return (other.up >= down) && (bottom < other.top) && (left < other.right) && (
            right > other.left);
    }

    abstract void moveTile(Vec3i dir, Physics.CollisionHit.Type type = Physics
            .CollisionHit.Type.none);
    abstract bool move(Vec3f dir, Physics.CollisionHit.Type type = Physics.CollisionHit.Type.none);

    final void drawBox(Vec2f origin, float alpha) {
        Vec2f offset = cast(Vec2f)(_hitbox.xy - (_hitbox.xy >> 1));

        Atelier.renderer.drawRect(origin - (offset + Vec2f(0f, _hitbox.z)),
            cast(Vec2f) _hitbox.xy, Color.white, alpha, true);

        Atelier.renderer.drawRect(origin + Vec2f(0f,
                _hitbox.y) - (offset + Vec2f(0f, _hitbox.z)),
            cast(Vec2f) _hitbox.xz, Color.grey, alpha, true);
    }

    final void drawBack(Vec2f origin) {
        Vec2f offset = cast(Vec2f)(_hitbox.xy - (_hitbox.xy >> 1));

        Atelier.renderer.drawRect(origin - offset, cast(Vec2f) _hitbox.xy,
            Atelier.theme.onNeutral, 0.2f, false);
    }

    final void drawFront(Vec2f origin) {
        if (_isTiled) {
            Vec2f tileBox = cast(Vec2f)((_tileboxHalf1 + _tileboxHalf2) << 4);
            Vec2f offset = cast(Vec2f)(_tileboxHalf1 << 4);
            float zHeight = _zTilebox << 4;

            Atelier.renderer.drawRect(origin - (offset + Vec2f(0f, zHeight)),
                tileBox, Color.yellow, 0.2f, true);

            Atelier.renderer.drawRect(origin + Vec2f(0f,
                    tileBox.y) - (offset + Vec2f(0f, zHeight)), Vec2f(tileBox.x,
                    zHeight), Color.orange, 0.2f, true);

            Atelier.renderer.drawRect(origin - (offset + Vec2f(0f, zHeight)),
                tileBox, Atelier.theme.onNeutral, 1f, false);

            Atelier.renderer.drawRect(origin - (offset + Vec2f(0f, zHeight)),
                tileBox + Vec2f(0f, zHeight), Atelier.theme.onNeutral, 1f, false);
        }
        else {
            Vec2f offset = cast(Vec2f)(_hitbox.xy - (_hitbox.xy >> 1));

            Atelier.renderer.drawRect(origin - (offset + Vec2f(0f, _hitbox.z)),
                cast(Vec2f) _hitbox.xy, Color.yellow, 0.2f, true);

            Atelier.renderer.drawRect(origin + Vec2f(0f,
                    _hitbox.y) - (offset + Vec2f(0f, _hitbox.z)),
                cast(Vec2f) _hitbox.xz, Color.orange, 0.2f, true);

            Atelier.renderer.drawRect(origin - (offset + Vec2f(0f, _hitbox.z)),
                cast(Vec2f) _hitbox.xy, Atelier.theme.onNeutral, 1f, false);

            Atelier.renderer.drawRect(origin - (offset + Vec2f(0f, _hitbox.z)),
                cast(Vec2f) _hitbox.xy + Vec2f(0f, _hitbox.z), Atelier.theme.onNeutral, 1f, false);
        }
    }
}
