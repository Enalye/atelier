/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.scene.collider;

import std.exception : enforce;
import grimoire;

import atelier.common;
import atelier.scene.actor;
import atelier.scene.entity;
import atelier.scene.scene;
import atelier.scene.solid;

final class CollisionData {
    Actor actor;
    Solid solid;
    Vec2i direction;
}

abstract class Collider {
    protected {
        Scene _scene;
        Vec2f _moveRemaining = Vec2f.zero;
        Vec2i _position, _hitbox;
    }

    private {
        bool _isAlive = true;
        Entity _entity;
    }

    string name;
    string[] tags;

    @property {
        bool isAlive() const {
            return _isAlive;
        }

        Vec2f scenePosition() const {
            return cast(Vec2f) position;
        }

        Vec2f globalPosition() const {
            if (_scene)
                return (cast(Vec2f) position) - _scene.globalPosition;
            return cast(Vec2f) position;
        }

        final int left() const {
            return _position.x - _hitbox.x;
        }

        final int right() const {
            return _position.x + _hitbox.x;
        }

        final int down() const {
            return _position.y - _hitbox.y;
        }

        final int up() const {
            return _position.y + _hitbox.y;
        }

        final Vec2i position() const {
            return _position;
        }

        final Vec2i position(Vec2i v) {
            return _position = v;
        }

        final Vec2i hitbox() const {
            return _hitbox;
        }

        final Vec2i hitbox(Vec2i v) {
            return _hitbox = v;
        }

        final Entity entity() {
            return _entity;
        }

        final Entity entity(Entity entity_) {
            enforce(!entity_ || !entity_.parent,
                "l’entité doit être à la racine de la scène");
            return _entity = entity_;
        }
    }

    this() {
    }

    void setScene(Scene scene) {
        _scene = scene;
    }

    void remove() {
        _isAlive = false;
        _scene = null;
    }

    void update() {
        if (_entity) {
            _entity.position = scenePosition;
        }
    }
}
