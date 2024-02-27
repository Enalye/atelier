/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.scene.entity;

import std.algorithm;

import atelier.audio;
import atelier.common;
import atelier.render;
import atelier.scene.component;
import atelier.scene.scene;

/// Entité présente dans une scène
final class Entity {
    private {
        Scene _scene;
        Entity _parent;
        EntityComponent[string] _components;
        Array!Entity _children;
        Array!Image _images;
        bool _isAlive = true;
    }

    string name;
    string[] tags;
    Vec2f position = Vec2f.zero;
    int zOrder;

    @property {
        bool isAlive() const {
            return _isAlive;
        }

        Vec2f scenePosition() const {
            if (_parent)
                return _parent.scenePosition + position;
            else if (_scene)
                return position - _scene.position;
            return position;
        }

        Scene scene() {
            return _scene;
        }

        Entity parent() {
            return _parent;
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

    package void setScene(Scene scene_) {
        _scene = scene_;
        foreach (child; _children) {
            if (child.isAlive) {
                child.setScene(_scene);
            }
        }
    }

    void addChild(Entity child) {
        child._parent = this;
        child.setScene(_scene);
        _children ~= child;
        _sortChildren();
    }

    void addImage(Image image) {
        _images ~= image;
        _sortImages();
    }

    void remove() {
        _isAlive = false;
        _parent = null;
        _scene = null;
    }

    void update() {
        bool isChildrenDirty, isImagesDirty;

        foreach (idx, entity; _children) {
            entity.update();
            if (!entity.isAlive) {
                _children.mark(idx);
                isChildrenDirty = true;
            }
        }

        if (isChildrenDirty) {
            _children.sweep();
            _sortChildren();
        }

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

    void draw(Vec2f origin) {
        Vec2f absolutePosition = origin + position;

        foreach (image; _images) {
            image.draw(absolutePosition);
        }

        foreach (entity; _children) {
            entity.draw(absolutePosition);
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
