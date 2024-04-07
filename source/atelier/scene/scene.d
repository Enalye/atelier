/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.scene.scene;

import std.algorithm;
import std.exception : enforce;

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
    }

    string name;
    Vec2f position = Vec2f.zero;
    Vec2f parallax = Vec2f.one;
    string[] tags;
    int zOrder;
    bool showColliders;
    Vec2f mousePosition = Vec2f.zero;

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
        enforce(!entity.scene, "entité déjà enregistrée dans une scène");
        entity.scene = this;
        _entities ~= entity;
        _sortEntities();
    }

    void removeEntity(Entity entity) {
        if (entity.scene != this)
            return;
        entity.scene = null;

        foreach (idx, element; _entities) {
            if (element == entity) {
                _entities.mark(idx);
            }
        }
        _entities.sweep();
        _sortEntities();
    }

    void addParticleSource(ParticleSource source) {
        enforce(!source.scene, "source déjà enregistrée dans une scène");
        source.scene = this;
        _particleSources ~= source;
    }

    void removeParticleSource(ParticleSource source) {
        if (source.scene != this)
            return;
        source.scene = null;

        foreach (idx, element; _particleSources) {
            if (element == source) {
                _particleSources.mark(idx);
            }
        }
        _particleSources.sweep();
    }

    void addActor(Actor actor) {
        enforce(!actor.scene, "acteur déjà enregistré dans une scène");
        actor.scene = this;
        _actors ~= actor;

        if (actor.entity) {
            if (actor.entity.scene || actor.entity.parent)
                actor.entity.remove();
            addEntity(actor.entity);
        }
    }

    void removeActor(Actor actor) {
        if (actor.scene != this)
            return;
        actor.scene = null;

        foreach (idx, element; _actors) {
            if (element == actor) {
                _actors.mark(idx);
            }
        }
        _actors.sweep();

        if (actor.entity) {
            removeEntity(actor.entity);
        }
    }

    void addSolid(Solid solid) {
        enforce(!solid.scene, "solide déjà enregistré dans une scène");
        solid.scene = this;
        _solids ~= solid;

        if (solid.entity) {
            if (solid.entity.scene || solid.entity.parent)
                solid.entity.remove();
            addEntity(solid.entity);
        }
    }

    void removeSolid(Solid solid) {
        if (solid.scene != this)
            return;
        solid.scene = null;

        foreach (idx, element; _solids) {
            if (element == solid) {
                _solids.mark(idx);
            }
        }
        _solids.sweep();

        if (solid.entity) {
            removeEntity(solid.entity);
        }
    }

    void addUI(UIElement ui) {
        _uiManager.addUI(ui);
    }

    void clearUI() {
        _uiManager.clearUI();
    }

    void dispatch(InputEvent event) {
        switch (event.type) with (InputEvent.Type) {
        case mouseButton:
            Vec2f pos = event.asMouseButton().position;
            mousePosition = pos - (_sprite.size / 2f - globalPosition);
            break;
        case mouseMotion:
            Vec2f pos = event.asMouseMotion().position;
            mousePosition = pos - (_sprite.size / 2f - globalPosition);
            break;
        default:
            break;
        }
        _uiManager.dispatch(event);
    }

    private Array!T _getArray(T)() {
        static if (is(T == Entity)) {
            return _entities;
        }
        else static if (is(T == ParticleSource)) {
            return _particleSources;
        }
        else static if (is(T == Actor)) {
            return _actors;
        }
        else static if (is(T == Solid)) {
            return _solids;
        }
        else {
            static assert(false, "type non-supporté");
        }
    }

    T findByName(T)(string name) {
        foreach (element; _getArray!T()) {
            if (element.name == name)
                return element;
        }
        return null;
    }

    T[] findByTag(T)(string[] tags) {
        T[] result;
        __elementLoop: foreach (element; _getArray!T()) {
            foreach (string tag; tags) {
                if (!canFind(element.tags, tag)) {
                    continue __elementLoop;
                }
            }
            result ~= element;
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

        foreach (entity; _entities) {
            entity.update();
        }

        foreach (source; _particleSources) {
            source.update();
        }

        foreach (actor; _actors) {
            actor.update();
        }

        foreach (solid; _solids) {
            solid.update();
        }
    }

    void remove() {
        if (!_isAlive)
            return;
        _isAlive = false;

        foreach (entity; _entities) {
            entity.scene = null;
        }
        _entities.clear();

        foreach (source; _particleSources) {
            source.scene = null;
        }
        _particleSources.clear();

        foreach (actor; _actors) {
            actor.scene = null;
        }
        _actors.clear();

        foreach (solid; _solids) {
            solid.scene = null;
        }
        _solids.clear();
    }

    void render() {
        Vec2f offset = _sprite.size / 2f - globalPosition;
        foreach (entity; _entities) {
            entity.draw(offset);
        }

        foreach (source; _particleSources) {
            source.draw(offset);
        }

        if (showColliders) {
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
