/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.scene.entity;

import std.algorithm;
import std.exception : enforce;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.render;
import atelier.scene.component;
import atelier.scene.scene;

/// Entité présente dans une scène
final class Entity {
    private {
        Canvas _canvas;
        Sprite _sprite;
        Entity _parent;
        EntityComponent[string] _components;
        Array!Entity _children;
        Array!Image _images;
        bool _isVisible = true;
    }

    Scene scene;
    string name;
    string[] tags;
    Vec2f position = Vec2f.zero;
    int zOrder;

    @property {
        Vec2f scenePosition() const {
            if (_parent)
                return _parent.scenePosition + position;
            return position;
        }

        Vec2f globalPosition() const {
            if (_parent)
                return _parent.globalPosition + position;
            else if (scene)
                return position - scene.globalPosition;
            return position;
        }

        Entity parent() {
            return _parent;
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

    this() {
        _children = new Array!Entity;
        _images = new Array!Image;
    }

    private void _sortChildren() {
        sort!((a, b) => (a.zOrder > b.zOrder), SwapStrategy.stable)(_children.array);
    }

    private void _sortImages() {
        sort!((a, b) => (a.zOrder > b.zOrder), SwapStrategy.stable)(_images.array);
    }

    void addChild(Entity child) {
        enforce(!child.scene, "entité déjà enregistrée dans une scène");
        enforce(!child._parent, "entité déjà apparentée à une autre entité");
        child._parent = this;
        _children ~= child;
        _sortChildren();
    }

    void removeChild(Entity child) {
        if (child._parent != this)
            return;
        child._parent = null;

        foreach (idx, element; _children) {
            if (element == child) {
                _children.mark(idx);
            }
        }
        _children.sweep();
        _sortChildren();
    }

    void addImage(Image image) {
        _images ~= image;
        _sortImages();
    }

    void remove() {
        if (_parent) {
            _parent.removeChild(this);
        }
        else if (scene) {
            scene.removeEntity(this);
        }
    }

    void update() {
        foreach (entity; _children) {
            entity.update();
        }

        bool isImagesDirty;
        foreach (idx, image; _images) {
            image.update();
            if (!image.isAlive) {
                _images.mark(idx);
                isImagesDirty = true;
            }
        }

        if (isImagesDirty) {
            _images.sweep();
            _sortImages();
        }

        foreach (component; _components) {
            component.update();
        }
    }

    void setCanvas(uint width, uint height) {
        _canvas = new Canvas(width, height);
        _sprite = new Sprite(_canvas);
    }

    Canvas getCanvas() {
        return _canvas;
    }

    Sprite getSprite() {
        return _sprite;
    }

    void removeCanvas() {
        _canvas = null;
        _sprite = null;
    }

    void draw(Vec2f origin) {
        if (!_isVisible)
            return;

        if (_canvas) {
            Atelier.renderer.pushCanvas(_canvas);
            foreach (image; _images) {
                image.draw(Vec2f.zero);
            }

            foreach (entity; _children) {
                entity.draw(Vec2f.zero);
            }
            Atelier.renderer.popCanvas();
            _sprite.draw(origin + position);
        }
        else {
            Vec2f absolutePosition = origin + position;

            foreach (image; _images) {
                image.draw(absolutePosition);
            }

            foreach (entity; _children) {
                entity.draw(absolutePosition);
            }
        }
    }

    T getComponent(T : EntityComponent)() {
        return cast(T) _components.require(T.stringof, {
            T component = new T;
            component.entity = this;
            return component;
        }());
    }

    void addComponent(T : EntityComponent)() {
        if (T.stringof in _components)
            return;
        T component = new T;
        component.entity = this;
        _components[T.stringof] = component;
    }

    void removeComponent(T : EntityComponent)() {
        _components.remove(T.stringof);
    }
}
