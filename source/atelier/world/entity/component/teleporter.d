module atelier.world.entity.component.teleporter;

import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.world.entity.base;
import atelier.world.entity.component.base;
import atelier.world.entity.component.trigger;

final class TeleporterComponent : TriggerComponent {
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

    override void setup() {

    }

    override void update() {

    }
    /*
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
    }*/

    Vec3i getExitPosition(Entity other) {
        Vec3i result = entity.getPosition();
        Vec3i entitySize;
        if (other.getCollider()) {
            entitySize = (other.getCollider().hitbox() / 2) + 1;
        }

        if (!entity.getCollider())
            return result;

        switch (_direction) {
        case 0: // Nord
            result.y = entity.getCollider().down + entitySize.y;
            break;
        case 1: // Nord-Ouest
            result.x = entity.getCollider().right + entitySize.x;
            result.y = entity.getCollider().down + entitySize.y;
            break;
        case 2: // Ouest
            result.x = entity.getCollider().right + entitySize.x;
            break;
        case 3: // Sud-Ouest
            result.x = entity.getCollider().right + entitySize.x;
            result.y = entity.getCollider().up - entitySize.y;
            break;
        case 4: // Sud
            result.y = entity.getCollider().up - entitySize.y;
            break;
        case 5: // Sud-Est
            result.x = entity.getCollider().left - entitySize.x;
            result.y = entity.getCollider().up - entitySize.y;
            break;
        case 6: // Est
            result.x = entity.getCollider().left - entitySize.x;
            break;
        case 7: // Nord-Est
            result.x = entity.getCollider().left - entitySize.x;
            result.y = entity.getCollider().down + entitySize.y;
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
        Atelier.world.runScene(_scene, _target, _direction);
    }
}
