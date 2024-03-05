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

final class CollideAction {
    private {
        GrEngine _engine;
        GrEvent _event;
    }

    this(GrEngine engine, GrEvent event) {
        enforce(engine && event, "CollideAction invalide");
        _engine = engine;
        _event = event;
    }

    void opCall(CollisionData data) {
        _engine.callEvent(_event, [GrValue(data)]);
    }
}

final class CollisionData {
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

    }
}
