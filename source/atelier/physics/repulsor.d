module atelier.physics.repulsor;

import std.conv : to;
import std.math;
import farfadet;
import atelier.common;
import atelier.core;
import atelier.world.entity;
import atelier.physics.system;

struct RepulsorData {
    string type = "none";
    uint radius;
    uint height;

    void load(Farfadet ffd) {
        if (ffd.hasNode("type")) {
            type = ffd.getNode("type").get!string(0);
        }
        else {
            type = "none";
        }

        if (ffd.hasNode("radius")) {
            radius = ffd.getNode("radius").get!uint(0);
        }

        if (ffd.hasNode("height")) {
            height = ffd.getNode("height").get!uint(0);
        }
    }

    void save(Farfadet ffd) {
        Farfadet node = ffd.addNode("repulsor");
        if (type != "none") {
            node.addNode("type").add(type);
            node.addNode("radius").add(radius);
            node.addNode("height").add(height);
        }
    }

    void serialize(OutStream stream) {
        bool hasValue = type != "none";
        stream.write!bool(hasValue);
        if (hasValue) {
            stream.write!string(type);
            stream.write!uint(radius);
            stream.write!uint(height);
        }
    }

    void deserialize(InStream stream) {
        if (stream.read!bool()) {
            type = stream.read!string();
            radius = stream.read!uint();
            height = stream.read!uint();
        }
    }
}

final class Repulsor {
    enum Type {
        weak,
        strong
    }

    private {
        bool _isRegistered = true;
        Entity _entity;
        uint _radius;
        uint _height;
        Type _type;
        bool _isDisplayed;
        bool _isCollidable = true;
        Vec2f _forces = Vec2f.zero;
    }

    @property {
        bool isRegistered() const {
            return _isRegistered;
        }

        package bool isRegistered(bool value) {
            return _isRegistered = value;
        }

        Entity entity() {
            return _entity;
        }

        uint radius() const {
            return _radius;
        }

        uint height() const {
            return _height;
        }

        Type type() const {
            return _type;
        }

        bool isDisplayed() const {
            return _isDisplayed;
        }

        bool isDisplayed(bool isDisplayed_) {
            return _isDisplayed = isDisplayed_;
        }

        bool isCollidable() const {
            return _isCollidable;
        }

        bool isCollidable(bool isCollidable_) {
            return _isCollidable = isCollidable_;
        }
    }

    this(Entity entity_, RepulsorData data) {
        _entity = entity_;
        _radius = data.radius;
        _height = data.height;

        try {
            _type = to!Type(data.type);
        }
        catch (Exception e) {
            Atelier.log(data.type, " n’est pas un type de Repulsor valide");
        }
    }

    this(Repulsor other) {
        _entity = other._entity;
        _type = other._type;
        _radius = other._radius;
        _height = other._height;
    }

    void setEntity(Entity entity_) {
        _entity = entity_;
    }

    void register() {
        Atelier.physics.addRepulsor(this);
    }

    void unregister() {
        Atelier.physics.removeRepulsor(this);
    }

    Vec2f getCameraCenter() const {
        return cast(Vec2f) getPosition().proj2D();
    }

    Vec3i getPosition() const {
        return _entity.getPosition();
    }

    void update(Repulsor other) {
        Vec3i posA = getPosition();
        Vec3i posB = other.getPosition();

        // On exclut les désalignements en Z
        if ((posA.z > (posB.z + other._height)) ||
            (posB.z > (posA.z + _height)))
            return;

        int distSq = getPosition().distanceSquared(other.getPosition());
        int delta = (_radius * other._radius) - distSq;

        if (delta > 0) {
            Vec2f dir = (cast(Vec2f)(posB.xy - posA.xy)).normalized();
            Vec2f force = dir * delta;
            force += (other._entity.velocity.xy - _entity.velocity.xy).lengthSquared();

            if (_type == other._type) {
                _forces -= force * 0.02f;
                other._forces += force * 0.02f;
            }
            else if (_type == Type.strong) {
                other._forces += force * 0.04f;
            }
            else {
                _forces -= force * 0.04f;
            }
        }
    }

    void apply() {
        _entity.addVelocity(Vec3f(_forces, 0f));
        _forces.set(0f, 0f);
    }

    void draw(Vec2f origin) {

    }
}
