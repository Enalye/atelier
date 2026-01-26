module atelier.world.entity.component.base;

import atelier.world.entity.base;

abstract class EntityComponent {
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
