module atelier.world.entity.trigger;

import grimoire;
import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.world.entity.base;
import atelier.world.entity.actor;

final class Trigger : Entity {
    private {
        string _event;
    }

    @property {
        bool isActive() const {
            return (cast(TriggerCollider) _collider).isActive;
        }

        bool isActive(bool value) {
            return (cast(TriggerCollider) _collider).isActive = value;
        }

        bool isActiveOnce() const {
            return (cast(TriggerCollider) _collider).isActiveOnce;
        }

        bool isActiveOnce(bool value) {
            return (cast(TriggerCollider) _collider).isActiveOnce = value;
        }
    }

    this() {
        super(Entity.Type.trigger);
    }

    this(Trigger other) {
        super(other);
        _event = other._event;
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

    void setEvent(string event_) {
        _event = event_;
    }

    override void onTrigger() {
        Atelier.script.callEvent(_event,
            [grGetNativeType("Trigger")],
            [GrValue(this)]);
    }
}
