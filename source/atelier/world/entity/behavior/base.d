module atelier.world.entity.behavior.base;

import atelier.common;
import atelier.world.entity.base;

abstract class EntityBehavior {
    private {
        Entity _entity;
        string _id;
    }

    @property {
        Entity entity() {
            return _entity;
        }

        package(atelier.world.entity) Entity entity(Entity entity_) {
            return _entity = entity_;
        }

        string id() const {
            return _id;
        }

        package(atelier.world.entity) string id(string id_) {
            return _id = id_;
        }
    }

    void setup() {
    }

    void update() {
    }

    void onCollide(Entity other, Vec3f normal) {
    }
}
