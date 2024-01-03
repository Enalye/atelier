/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.scene.entity;

import std.algorithm;

import atelier.common;
import atelier.render;

/// Entité présente dans une scène
final class Entity {
    private {
        Array!Entity _children;
        Array!Image _images;
        int _zOrder;
        bool _isAlive = true;
    }

    Vec2f position = Vec2f.zero;

    @property {
        int zOrder() const {
            return _zOrder;
        }

        bool isAlive() const {
            return _isAlive;
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
        _children ~= child;
        _sortChildren();
    }

    void addImage(Image image) {
        _images ~= image;
        _sortImages();
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
}
