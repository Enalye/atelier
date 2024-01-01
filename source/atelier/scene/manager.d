/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.scene.manager;

import std.algorithm;

import atelier.common;
import atelier.scene.scene;

/// Gère les différentes scènes
final class SceneManager {
    private {
        Array!Scene _scenes;
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
            scene.draw();
        }
    }
}