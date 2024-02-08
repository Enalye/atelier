/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.scene.scene;

import std.algorithm;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.render;
import atelier.scene.entity;
import atelier.scene.particle;

/// Représente un contexte contenant des entités
final class Scene {
    private {
        Canvas _canvas;
        Sprite _sprite;
        Array!Entity _entities;
        Array!ParticleSource _particleSources;
        int _zOrder;
        bool _isAlive = true;
        bool _isVisible = true;
        int _width, _height;
    }

    Vec2f position = Vec2f.zero;

    @property {
        int width() const {
            return _width;
        }

        int height() const {
            return _height;
        }

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

    this(int width_, int height_) {
        _width = width_;
        _height = height_;

        _entities = new Array!Entity;
        _particleSources = new Array!ParticleSource;

        _canvas = new Canvas(_width, _height);
        _sprite = new Sprite(_canvas);
        _sprite.anchor = Vec2f.half;
    }

    private void _sortEntities() {
        sort!((a, b) => (a.zOrder > b.zOrder), SwapStrategy.stable)(_entities.array);
    }

    void addEntity(Entity entity) {
        entity.setScene(this);
        _entities ~= entity;
        _sortEntities();
    }

    void addParticleSource(ParticleSource source) {
        _particleSources ~= source;
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

        foreach (idx, source; _particleSources) {
            source.update();
            if (!source.isAlive) {
                _particleSources.mark(idx);
                isEntitiesDirty = true;
            }
        }
        _particleSources.sweep();
    }

    void remove() {
        if (!_isAlive)
            return;
        _isAlive = false;
        foreach (entity; _entities) {
            entity.remove();
        }
        _entities.clear();
    }

    void render() {
        foreach (entity; _entities) {
            entity.draw(_sprite.size / 2f - position);
        }

        foreach (source; _particleSources) {
            source.draw(_sprite.size / 2f - position);
        }
    }

    void draw(Vec2f origin) {
        if (_isVisible) {
            _sprite.draw(origin);
        }
    }
}
