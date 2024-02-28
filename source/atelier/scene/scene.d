/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.scene.scene;

import std.algorithm;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.ui;
import atelier.scene.camera;
import atelier.scene.entity;
import atelier.scene.particle;

/// Représente un contexte contenant des entités
final class Scene {
    private {
        Canvas _canvas;
        Sprite _sprite;
        UIManager _uiManager;
        Array!Entity _entities;
        Array!ParticleSource _particleSources;
        bool _isAlive = true;
        bool _isVisible = true;
        int _width, _height;
    }

    string name;
    Vec2f position = Vec2f.zero;
    Vec2f parallax = Vec2f.one;
    string[] tags;
    int zOrder;

    @property {
        int width() const {
            return _width;
        }

        int height() const {
            return _height;
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

        Vec2f globalPosition() const {
            return position + Atelier.scene.camera.getPosition() * parallax;
        }
    }

    this(int width_, int height_) {
        _width = width_;
        _height = height_;

        _uiManager = new UIManager();
        _uiManager.isSceneUI = true;
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
        source.setScene(this);
        _particleSources ~= source;
    }

    void addUI(UIElement ui) {
        _uiManager.addUI(ui);
    }

    void clearUI() {
        _uiManager.clearUI();
    }

    void dispatch(InputEvent event) {
        _uiManager.dispatch(event);
    }

    Entity fetchNamedEntity(string name) {
        foreach (entity; _entities) {
            if (entity.name == name)
                return entity;
        }
        return null;
    }

    Entity[] fetchTaggedEntities(string[] tags) {
        Entity[] result;
        __entityLoop: foreach (entity; _entities) {
            foreach (string tag; tags) {
                if (!canFind(entity.tags, tag)) {
                    continue __entityLoop;
                }
            }
            result ~= entity;
        }
        return result;
    }

    void update() {
        _uiManager.cameraPosition = _sprite.size / 2f - globalPosition;
        _uiManager.update();

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
            entity.draw(_sprite.size / 2f - globalPosition);
        }

        foreach (source; _particleSources) {
            source.draw(_sprite.size / 2f - globalPosition);
        }

        _uiManager.draw();
    }

    void draw(Vec2f origin) {
        if (_isVisible) {
            _sprite.draw(origin);
        }
    }
}
