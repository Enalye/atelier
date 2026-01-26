module atelier.world.entity.behavior.base;

import atelier.world.entity.base;

abstract class EntityBehavior {
    private {
        Entity _entity;
    }

    @property {
        Entity entity() {
            return _entity;
        }

        package(atelier.world.entity) Entity entity(Entity entity_) {
            return _entity = entity_;
        }
    }

    void setup() {
    }

    void update() {
    }
}
