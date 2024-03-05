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

final class Actor : Collider {
    private {
        bool _hasPhysics = true;
    }

    void moveX(float x, GrEvent onCollide) {
        _moveRemaining.x += x;
        int move = cast(int) round(_moveRemaining.x);

        if (move != 0) {
            _moveRemaining.x -= move;
            if (_hasPhysics) {
                int dir = move > 0 ? 1 : -1;

                while (move) {
                    Solid solid = _scene.collideAt(_position + Vec2i(dir, 0), _hitbox);
                    if (solid) {
                        _moveRemaining.x = 0f;
                        if (onCollide) {
                            CollisionData data = new CollisionData;
                            data.solid = solid;
                            data.direction = Vec2i(dir, 0);
                            Atelier.vm.callEvent(onCollide, [GrValue(data)]);
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
    }

    void moveY(float y, GrEvent onCollide) {
        _moveRemaining.y += y;
        int move = cast(int) round(_moveRemaining.y);

        if (move != 0) {
            _moveRemaining.y -= move;
            if (_hasPhysics) {
                int dir = move > 0 ? 1 : -1;

                while (move) {
                    Solid solid = _scene.collideAt(_position + Vec2i(0, dir), _hitbox);
                    if (solid) {
                        _moveRemaining.y = 0f;
                        if (onCollide) {
                            CollisionData data = new CollisionData;
                            data.solid = solid;
                            data.direction = Vec2i(0, dir);
                            Atelier.vm.callEvent(onCollide, [GrValue(data)]);
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
    }

    bool isRiding(Solid solid) {
        return false;
        //return (solid.left < right) && (solid.down < up) && (solid.right > left) && (solid.up > down);
    }

    GrEvent onSquish;
}
