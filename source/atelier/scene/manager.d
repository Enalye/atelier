/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.scene.manager;

import std.algorithm;

import atelier.common;
import atelier.core;
import atelier.render;
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

    void addScene(Scene scene) {
        _scenes ~= scene;
        _sortScenes();
    }

    void update() {
        bool isScenesDirty;
        foreach (idx, scene; _scenes) {
            scene.update();
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

    void draw() {
        foreach (scene; _scenes) {
            Canvas canvas = scene.canvas;
            Vec2f position = scene.position;

            _cameraClip = Vec4f(position.x, position.y,
                position.x + canvas.width, position.y + canvas.height);

            _isOnScene = true;

            Atelier.renderer.pushCanvas(canvas);
            scene.render();
            Atelier.renderer.popCanvas();

            _isOnScene = false;

            if (scene.isVisible)
                scene.draw(Vec2f(400, 300));
        }
    }
}
