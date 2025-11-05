module atelier.world.entity.proxy;

import atelier.common;
import atelier.physics;
import atelier.world.entity.base;
import atelier.world.entity.controller;

/// Entité positionnée relativement à une autre entité.
/// N’utilise pas de collision
final class Proxy : Entity, Resource!Proxy {
    mixin EntityController;

    private {
        Entity _base;
        Vec3f _relativePosition = Vec3f.zero;
        float _relativeAngle = 0f;
        float _relativeDistance = 0f;
    }

    this() {
        super(Entity.Type.proxy);
    }

    this(Proxy other) {
        super(other);
        _base = other._base;
        _relativePosition = other._relativePosition;
        _relativeAngle = other._relativeAngle;
        _relativeDistance = other._relativeDistance;
    }

    Proxy fetch() {
        return new Proxy(this);
    }

    void attachTo(Entity entity) {
        _base = entity;
    }

    void setRelativePosition(Vec3f position) {
        _relativePosition = position;
    }

    void setRelativeAngle(float angle) {
        _relativeAngle = angle;
    }

    void setRelativeDistance(float distance) {
        _relativeDistance = distance;
    }

    override void updateMovement() {
        Vec3f pos = cast(Vec3f) _base.getPosition();
        _relativePosition += _velocity;
        pos += _relativePosition;
        pos += Vec3f(Vec2f.angled(degToRad(_relativeAngle)) * _relativeDistance, 0f).round();
        setPosition(pos);
    }

    override void onCollide(Physics.CollisionHit hit) {
        final switch (hit.type) with (Physics.CollisionHit.Type) {
        case none:
        case squish:
            break;
        case impact:
            onImpact(hit.entity, hit.normal);
            break;
        }
    }
}
