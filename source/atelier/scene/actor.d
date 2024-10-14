/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.scene.actor;

import std.math;
import grimoire;
import atelier.common;
import atelier.core;
import atelier.scene.collider;
import atelier.scene.scene;
import atelier.scene.solid;
/*
final class Actor : Collider {
    private {
        bool _hasPhysics = true;
        Solid _mountedSolid;
    }

    override void remove() {
        if (scene) {
            scene.removeActor(this);
        }
    }

    Collision moveX(float x, bool getInfo = true) {
        Collision collision;
        _moveRemaining.x += x;
        int move = cast(int) round(_moveRemaining.x);

        if (move != 0) {
            _moveRemaining.x -= move;
            if (_hasPhysics) {
                int dir = move > 0 ? 1 : -1;

                while (move) {
                    Solid solid;
                    if (scene) {
                        solid = scene.collideAt(_position + Vec2i(dir, 0), _hitbox);
                    }
                    if (solid) {
                        _moveRemaining.x = 0f;
                        if (getInfo) {
                            collision = new Collision;
                            collision.actor = this;
                            collision.solid = solid;
                            collision.direction = Vec2i(dir, 0);
                        }
                        break;
                    }
                    else {
                        _position.x += dir;
                        move -= dir;
                    }
                }
            }
            else {
                _position.x += move;
            }
        }

        return collision;
    }

    Collision moveY(float y, bool getInfo = true) {
        Collision collision;
        _moveRemaining.y += y;
        int move = cast(int) round(_moveRemaining.y);

        if (move != 0) {
            _moveRemaining.y -= move;
            if (_hasPhysics) {
                int dir = move > 0 ? 1 : -1;

                while (move) {
                    Solid solid;
                    if (scene) {
                        solid = scene.collideAt(_position + Vec2i(0, dir), _hitbox);
                    }
                    if (solid) {
                        _moveRemaining.y = 0f;
                        if (getInfo) {
                            collision = new Collision;
                            collision.actor = this;
                            collision.solid = solid;
                            collision.direction = Vec2i(0, dir);
                        }
                        break;
                    }
                    else {
                        _position.y += dir;
                        move -= dir;
                    }
                }
            }
            else {
                _position.y += move;
            }
        }

        return collision;
    }

    void mount(Solid solid) {
        _mountedSolid = solid;
    }

    void dismount() {
        _mountedSolid = null;
    }

    bool isRiding(Solid solid) {
        return _mountedSolid == solid;
    }
}
*/