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
import atelier.scene.actor;
import atelier.scene.camera;
import atelier.scene.collider;
import atelier.scene.entity;
import atelier.scene.particle;
import atelier.scene.solid;

/// Représente un contexte contenant des entités
final class Scene {
    private {
        Canvas _canvas;
        Sprite _sprite;
        UIManager _uiManager;
        Array!Actor _actors;
        Array!Solid _solids;
        Array!Entity _entities;
        Array!ParticleSource _particleSources;
        bool _isAlive = true;
        bool _isVisible = true;
        Vec2i _size;

        bool _showColliders = true;
    }

    string name;
    Vec2f position = Vec2f.zero;
    Vec2f parallax = Vec2f.one;
    string[] tags;
    int zOrder;

    @property {
        int width() const {
            return _size.x;
        }

        int height() const {
            return _size.y;
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

        Array!Solid solids() {
            return _solids;
        }

        Array!Actor actors() {
            return _actors;
        }
    }

    this() {
        _size = Atelier.renderer.size;

        _uiManager = new UIManager();
        _uiManager.isSceneUI = true;
        _entities = new Array!Entity;
        _particleSources = new Array!ParticleSource;

        _canvas = new Canvas(_size.x, _size.y);
        _sprite = new Sprite(_canvas);
        _sprite.anchor = Vec2f.half;

        _actors = new Array!Actor;
        _solids = new Array!Solid;
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

    void addActor(Actor actor) {
        actor.setScene(this);
        _actors ~= actor;
    }

    void addSolid(Solid solid) {
        solid.setScene(this);
        _solids ~= solid;
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

    Entity fetchEntityByName(string name) {
        foreach (entity; _entities) {
            if (entity.name == name)
                return entity;
        }
        return null;
    }

    Entity[] fetchEntitiesByTag(string[] tags) {
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

    ParticleSource fetchParticleSourceByName(string name) {
        foreach (source; _particleSources) {
            if (source.name == name)
                return source;
        }
        return null;
    }

    ParticleSource[] fetchParticleSourcesByTag(string[] tags) {
        ParticleSource[] result;
        __sourceLoop: foreach (source; _particleSources) {
            foreach (string tag; tags) {
                if (!canFind(source.tags, tag)) {
                    continue __sourceLoop;
                }
            }
            result ~= source;
        }
        return result;
    }

    Actor fetchActorByName(string name) {
        foreach (actor; _actors) {
            if (actor.name == name)
                return actor;
        }
        return null;
    }

    Actor[] fetchActorsByTag(string[] tags) {
        Actor[] result;
        __actorLoop: foreach (actor; _actors) {
            foreach (string tag; tags) {
                if (!canFind(actor.tags, tag)) {
                    continue __actorLoop;
                }
            }
            result ~= actor;
        }
        return result;
    }

    Solid fetchSolidByName(string name) {
        foreach (solid; _solids) {
            if (solid.name == name)
                return solid;
        }
        return null;
    }

    Solid[] fetchSolidsByTag(string[] tags) {
        Solid[] result;
        __solidLoop: foreach (solid; _solids) {
            foreach (string tag; tags) {
                if (!canFind(solid.tags, tag)) {
                    continue __solidLoop;
                }
            }
            result ~= solid;
        }
        return result;
    }

    Solid collideAt(Vec2i point, Vec2i halfSize) {
        foreach (Solid solid; _solids) {
            if (solid.collideWith(point, halfSize))
                return solid;
        }
        return null;
    }

    void update() {
        _uiManager.cameraPosition = _sprite.size / 2f - globalPosition;
        _uiManager.update();

        bool isDirty = false;
        foreach (idx, entity; _entities) {
            entity.update();
            if (!entity.isAlive) {
                _entities.mark(idx);
                isDirty = true;
            }
        }

        if (isDirty) {
            isDirty = false;
            _entities.sweep();
            _sortEntities();
        }

        foreach (idx, source; _particleSources) {
            source.update();
            if (!source.isAlive) {
                _particleSources.mark(idx);
                isDirty = true;
            }
        }

        if (isDirty) {
            isDirty = false;
            _particleSources.sweep();
        }

        foreach (idx, actor; _actors) {
            actor.update();
            if (!actor.isAlive) {
                _actors.mark(idx);
                isDirty = true;
            }
        }

        if (isDirty) {
            isDirty = false;
            _actors.sweep();
        }

        foreach (idx, solid; _solids) {
            solid.update();
            if (!solid.isAlive) {
                _solids.mark(idx);
                isDirty = true;
            }
        }

        if (isDirty) {
            isDirty = false;
            _solids.sweep();
        }
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
        Vec2f offset = _sprite.size / 2f - globalPosition;
        foreach (entity; _entities) {
            entity.draw(offset);
        }

        foreach (source; _particleSources) {
            source.draw(offset);
        }

        if (_showColliders) {
            foreach (actor; _actors) {
                Vec2f pos = offset + cast(Vec2f)(actor.position - actor.hitbox);
                Atelier.renderer.drawRect(pos, (cast(Vec2f) actor.hitbox) * 2f,
                    Color.blue, 1f, false);
            }

            foreach (solid; _solids) {
                Vec2f pos = offset + cast(Vec2f)(solid.position - solid.hitbox);
                Atelier.renderer.drawRect(pos, (cast(Vec2f) solid.hitbox) * 2f,
                    Color.red, 1f, false);
            }

        }

        _uiManager.draw();
    }

    void draw(Vec2f origin) {
        if (_isVisible) {
            _sprite.draw(origin);
        }
    }
}
