module atelier.world.entity.component.trigger;

import grimoire;
import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.world.entity.base;
import atelier.world.entity.component.base;

abstract class TriggerComponent : EntityComponent {
    void onTrigger() {
    }
}

final class TriggerEventComponent : TriggerComponent {
    private {
        string _event;
    }

    void setEvent(string event_) {
        _event = event_;
    }

    override void onTrigger() {
        Atelier.script.callEvent(_event,
            [grGetNativeType("Entity")],
            [GrValue(entity)]);
    }
}
