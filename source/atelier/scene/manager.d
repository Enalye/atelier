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
import atelier.scene.camera;
import atelier.scene.entity;
import atelier.scene.scene;

/// Gère les différentes scènes
final class SceneManager {
    private {
        Array!Scene _scenes;
        Vec4f _cameraClip;
        bool _isOnScene;
        Camera _camera;
    }

    @property {
        bool isOnScene() const {
            return _isOnScene;
        }

        Vec4f cameraClip() const {
            return _cameraClip;
        }

        Camera camera() {
            return _camera;
        }
    }

    this() {
        _scenes = new Array!Scene;
        _camera = new Camera;
    }

    private void _sortScenes() {
        sort!((a, b) => (a.zOrder > b.zOrder), SwapStrategy.stable)(_scenes.array);
    }

    void clear() {
        _scenes.clear();
        _camera.setPosition(Vec2f.zero);
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
        _camera.update();

        if (isScenesDirty) {
            _scenes.sweep();
            _sortScenes();
        }
    }

    void draw(Vec2f origin) {
        Atelier.renderer.pushCanvas(_camera.canvas);
        foreach (scene; _scenes) {
            Canvas canvas = scene.canvas;
            Vec2f delta = _camera.getPosition() * scene.parallax;
            Vec2f cameraOffset = -(scene.position + delta);

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
        Atelier.renderer.popCanvas();
        _camera.draw();
    }
}
