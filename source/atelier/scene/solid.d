/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.scene.solid;

import std.algorithm : canFind;
import std.math;
import atelier.common;
import atelier.scene.actor;
import atelier.scene.scene;
import atelier.scene.collider;

final class Solid : Collider {
    private {
        bool _isTempCollidable = true;
        bool _isCollidable = true;
    }

    void moveX(float x) {
        move(x, 0f);
    }

    void moveY(float y) {
        move(0f, y);
    }

    void move(float x, float y) {
        _moveRemaining.x += x;
        _moveRemaining.y += y;

        int moveX = cast(int) round(_moveRemaining.x);
        int moveY = cast(int) round(_moveRemaining.y);

        if (moveX || moveY) {
            const Actor[] ridingActors = getAllRidingActors();

            _isTempCollidable = false;

            if (moveX) {
                _moveRemaining.x -= moveX;
                _position.x += moveX;

                if (moveX > 0) {
                    foreach (Actor actor; _scene.actors) {
                        if (overlapWith(actor)) {
                            actor.moveX(right - actor.left, actor.onSquish);
                        }
                        else if (ridingActors.canFind(actor)) {
                            actor.moveX(moveX, null);
                        }
                    }
                }
                else {
                    foreach (Actor actor; _scene.actors) {
                        if (overlapWith(actor)) {
                            actor.moveX(left - actor.right, actor.onSquish);
                        }
                        else if (ridingActors.canFind(actor)) {
                            actor.moveX(moveX, null);
                        }
                    }
                }
            }
            if (moveY) {
                _moveRemaining.y -= moveY;
                _position.y += moveY;

                if (moveY > 0) {
                    foreach (Actor actor; _scene.actors) {
                        if (overlapWith(actor)) {
                            actor.moveY(up - actor.down, actor.onSquish);
                        }
                        else if (ridingActors.canFind(actor)) {
                            actor.moveY(moveY, null);
                        }
                    }
                }
                else {
                    foreach (Actor actor; _scene.actors) {
                        if (overlapWith(actor)) {
                            actor.moveY(down - actor.up, actor.onSquish);
                        }
                        else if (ridingActors.canFind(actor)) {
                            actor.moveY(moveY, null);
                        }
                    }
                }
            }
            _isTempCollidable = true;
        }
    }

    Actor[] getAllRidingActors() {
        Actor[] ridingActors;
        foreach (Actor actor; _scene.actors) {
            if (actor.isRiding(this))
                ridingActors ~= actor;
        }
        return ridingActors;
    }

    bool collideWith(Vec2i point, Vec2i hitbox) {
        if (!_isTempCollidable || !_isCollidable)
            return false;
        return (left < (point.x + hitbox.x)) && (down < (point.y + hitbox.y)) &&
            (right > (point.x - hitbox.x)) && (up > (point.y - hitbox.y));
    }

    bool overlapWith(Actor actor) {
        if (!_isCollidable)
            return false;
        return (left < actor.right) && (down < actor.up) && (right > actor.left) && (up > actor
                .down);
    }
}
