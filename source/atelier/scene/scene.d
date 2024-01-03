/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.scene.scene;

import std.algorithm;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.scene.entity;

/// Représente un contexte contenant des entités
final class Scene {
    private {
        Canvas _canvas;
        Sprite _sprite;
        Array!Entity _entities;
        int _zOrder;
        bool _isAlive = true;
        bool _isVisible = true;
    }

    @property {
        int zOrder() const {
            return _zOrder;
        }

        bool isAlive() const {
            return _isAlive;
        }

        Canvas canvas() {
            return _canvas;
        }

        bool isVisible() const {
            return _isVisible;
        }

        bool isVisible(bool isVisible_) {
            return _isVisible = isVisible_;
        }
    }

    Vec2f position = Vec2f.zero;

    this() {
        _entities = new Array!Entity;
        _canvas = new Canvas(800, 600);
        _sprite = new Sprite(_canvas);
        _sprite.anchor = Vec2f.half;
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

    void render() {
        foreach (entity; _entities) {
            entity.draw(_sprite.size / 2f - position);
        }
    }

    void draw(Vec2f origin) {
        if (_isVisible) {
            _sprite.draw(origin);
        }
    }
}
