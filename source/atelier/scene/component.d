/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.scene.component;

import atelier.common;
import atelier.scene.entity;

abstract class EntityComponent {
    private {
        Entity _entity;
    }

    @property {
        Entity entity() {
            return _entity;
        }

        package Entity entity(Entity entity_) {
            return _entity = entity_;
        }
    }

    void update();
}
