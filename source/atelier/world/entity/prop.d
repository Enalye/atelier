module atelier.world.entity.prop;

import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.world.entity.base;
import atelier.world.entity.effect;

final class Prop : Entity, Resource!Prop {
    private {
    }

    @property {
    }

    this() {
    }

    this(Prop other) {
        super(other);
    }

    Prop fetch() {
        return new Prop(this);
    }

    void setupCollider(Vec3u size_, string shape, float bounciness) {
        if (_collider) {
            _collider.setEntity(null);
            _collider.unregister();
        }
        _collider = new SolidCollider(size_, shape, bounciness);
        _collider.setEntity(this);
    }

    override void update() {
    }

    override void onCollide(Physics.CollisionHit hit) {
        final switch (hit.type) with (Physics.CollisionHit.Type) {
        case none:
        case squish:
            break;
        case impact:
            setEffect(new FlashEffect(Color.white, 1f, 0, 30, Spline.sineInOut));
            break;
        }
    }
}
