/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.scene.scene;

import std.algorithm;

import dahu.common;
import dahu.scene.entity;

/// Représente un contexte contenant des entités
final class Scene {
    private {
        Array!Entity _entities;
        int _zOrder;
        bool _isAlive = true;
    }

    @property {
        int zOrder() const {
            return _zOrder;
        }

        bool isAlive() const {
            return _isAlive;
        }
    }

    this() {
        _entities = new Array!Entity;
    }

    private void _sortEntities() {
        sort!((a, b) => (a.zOrder > b.zOrder), SwapStrategy.stable)(_entities.array);
    }

    void addEntity(Entity entity) {
        _entities ~= entity;
        _sortEntities();
    }

    void update() {
        bool isEntitiesDirty;
        foreach (idx, entity; _entities) {
            entity.update();
            if (!entity.isAlive) {
                _entities.mark(idx);
                isEntitiesDirty = true;
            }
        }

        if (isEntitiesDirty) {
            _entities.sweep();
            _sortEntities();
        }
    }

    void draw() {
        foreach (entity; _entities) {
            entity.draw();
        }
    }
}
