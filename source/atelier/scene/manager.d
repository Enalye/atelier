/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.scene.manager;

import std.algorithm;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.ui;
import atelier.scene.entity;
import atelier.scene.scene;

/// Gère les différentes scènes
final class SceneManager {
    private {
        Array!Scene _scenes;
        Vec4f _cameraClip;
        bool _isOnScene;
    }

    @property {
        bool isOnScene() const {
            return _isOnScene;
        }

        Vec4f cameraClip() const {
            return _cameraClip;
        }
    }

    this() {
        _scenes = new Array!Scene;
    }

    private void _sortScenes() {
        sort!((a, b) => (a.zOrder > b.zOrder), SwapStrategy.stable)(_scenes.array);
    }

    void clear() {
        _scenes.clear();
    }

    void load(string name) {
        clear();
        Level level = Atelier.res.get!Level(name);
        _scenes.array = level.build();
        _sortScenes();
    }

    void addScene(Scene scene) {
        _scenes ~= scene;
        _sortScenes();
    }

    Scene fetchNamedScene(string name) {
        foreach (scene; _scenes) {
            if (scene.name == name)
                return scene;
        }
        return null;
    }

    Scene[] fetchTaggedScenes(string[] tags) {
        Scene[] result;
        __sceneLoop: foreach (scene; _scenes) {
            foreach (string tag; tags) {
                if (!canFind(scene.tags, tag)) {
                    continue __sceneLoop;
                }
            }
            result ~= scene;
        }
        return result;
    }

    Entity fetchNamedEntity(string name) {
        foreach (scene; _scenes) {
            Entity entity = scene.fetchNamedEntity(name);
            if (entity)
                return entity;
        }
        return null;
    }

    Entity[] fetchTaggedEntities(string[] tags) {
        Entity[] result;
        foreach (scene; _scenes) {
            result ~= scene.fetchTaggedEntities(tags);
        }
        return result;
    }

    void update(InputEvent[] inputEvents) {
        bool isScenesDirty;
        foreach (idx, scene; _scenes) {
            foreach (InputEvent event; inputEvents) {
                scene.dispatch(event);
            }
            scene.update();
            if (!scene.isAlive) {
                _scenes.mark(idx);
                isScenesDirty = true;
            }
        }

        if (isScenesDirty) {
            _scenes.sweep();
            _sortScenes();
        }
    }

    void draw(Vec2f origin) {
        foreach (scene; _scenes) {
            Canvas canvas = scene.canvas;
            Vec2f cameraOffset = -scene.position;

            _cameraClip = Vec4f(cameraOffset.x, cameraOffset.y,
                cameraOffset.x + canvas.width, cameraOffset.y + canvas.height);

            _isOnScene = true;

            Atelier.renderer.pushCanvas(canvas);
            scene.render();
            Atelier.renderer.popCanvas();

            _isOnScene = false;

            if (scene.isVisible)
                scene.draw(origin);
        }
    }
}
