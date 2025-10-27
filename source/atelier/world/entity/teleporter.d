module atelier.world.entity.teleporter;

import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.world.entity.base;
import atelier.world.entity.actor;

final class Teleporter : Entity {
    private {
        string _scene;
        string _target;
        uint _direction;
    }

    @property {
        uint direction() const {
            return _direction;
        }
    }

    this() {
        super(Entity.Type.teleporter);
    }

    this(Teleporter other) {
        super(other);
        _scene = other._scene;
        _target = other._target;
    }

    void setupCollider(Vec3u size_) {
        if (_collider) {
            _collider.setEntity(null);
            _collider.unregister();
        }
        TriggerCollider triggerCollider = new TriggerCollider(size_);
        triggerCollider.setEntity(this);
        triggerCollider.isActive = true;
        triggerCollider.isActiveOnce = true;
        _collider = triggerCollider;
    }

    TriggerCollider getCollider() {
        return cast(TriggerCollider) _collider;
    }

    Vec3i getExitPosition(Actor actor) {
        Vec3i result = getPosition();
        Vec3i actorSize;
        if (actor.getCollider()) {
            actorSize = (actor.getCollider().hitbox() / 2) + 1;
        }

        if (!_collider)
            return result;

        switch (_direction) {
        case 0: // Nord
            result.y = _collider.down + actorSize.y;
            break;
        case 1: // Nord-Ouest
            result.x = _collider.right + actorSize.x;
            result.y = _collider.down + actorSize.y;
            break;
        case 2: // Ouest
            result.x = _collider.right + actorSize.x;
            break;
        case 3: // Sud-Ouest
            result.x = _collider.right + actorSize.x;
            result.y = _collider.up - actorSize.y;
            break;
        case 4: // Sud
            result.y = _collider.up - actorSize.y;
            break;
        case 5: // Sud-Est
            result.x = _collider.left - actorSize.x;
            result.y = _collider.up - actorSize.y;
            break;
        case 6: // Est
            result.x = _collider.left - actorSize.x;
            break;
        case 7: // Nord-Est
            result.x = _collider.left - actorSize.x;
            result.y = _collider.down + actorSize.y;
            break;
        default:
            break;
        }
        return result;
    }

    void setTarget(string scene_, string target_, uint direction_) {
        _scene = scene_;
        _target = target_;
        _direction = direction_;
    }

    override void onTrigger() {
        Atelier.world.transitionScene(_scene, _target, _direction);
    }
}
