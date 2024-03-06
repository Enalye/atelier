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

    override void remove() {
        if (scene) {
            scene.removeSolid(this);
        }
    }

    Collision[] moveX(float x) {
        return move(x, 0f);
    }

    Collision[] moveY(float y) {
        return move(0f, y);
    }

    Collision[] move(float x, float y) {
        Collision[] collisions;
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
                    if (scene) {
                        foreach (Actor actor; scene.actors) {
                            if (overlapWith(actor)) {
                                collisions ~= actor.moveX(right - actor.left, true);
                            }
                            else if (ridingActors.canFind(actor)) {
                                actor.moveX(moveX, false);
                            }
                        }
                    }
                }
                else {
                    if (scene) {
                        foreach (Actor actor; scene.actors) {
                            if (overlapWith(actor)) {
                                collisions ~= actor.moveX(left - actor.right, true);
                            }
                            else if (ridingActors.canFind(actor)) {
                                actor.moveX(moveX, false);
                            }
                        }
                    }
                }
            }
            if (moveY) {
                _moveRemaining.y -= moveY;
                _position.y += moveY;

                if (moveY > 0) {
                    if (scene) {
                        foreach (Actor actor; scene.actors) {
                            if (overlapWith(actor)) {
                                collisions ~= actor.moveY(up - actor.down, true);
                            }
                            else if (ridingActors.canFind(actor)) {
                                actor.moveY(moveY, false);
                            }
                        }
                    }
                }
                else {
                    if (scene) {
                        foreach (Actor actor; scene.actors) {
                            if (overlapWith(actor)) {
                                collisions ~= actor.moveY(down - actor.up, true);
                            }
                            else if (ridingActors.canFind(actor)) {
                                actor.moveY(moveY, false);
                            }
                        }
                    }
                }
            }
            _isTempCollidable = true;
        }

        return collisions;
    }

    Actor[] getAllRidingActors() {
        Actor[] ridingActors;
        if (scene) {
            foreach (Actor actor; scene.actors) {
                if (actor.isRiding(this))
                    ridingActors ~= actor;
            }
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
