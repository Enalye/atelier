/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.scene.world;

import std.algorithm;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.ui;
import atelier.scene.camera;
import atelier.scene.entity;
import atelier.scene.particle;
import atelier.scene.scene;

alias SystemEntityUpdater = void function(Scene scene);
alias SystemEntityRenderer = void function(Scene scene, Vec2f offset);
alias SystemUpdater = void function(Scene scene);
alias SystemRenderer = void function(Scene scene, Vec2f offset, bool isFront);

/// Gère les différentes scènes
final class World {
    private {
        Array!Scene _scenes;
        Camera _camera;
        SystemUpdater[string] _systemUpdaters;
        SystemRenderer[string] _systemRenderers;
        SystemEntityUpdater[string] _systemEntityUpdaters;
        SystemEntityRenderer[string] _systemEntityRenderers;
    }

    @property {
        Camera camera() {
            return _camera;
        }
    }

    this() {
        _scenes = new Array!Scene;
        _camera = new Camera;
    }

    void registerSystem(T)(string name, T system) {
        static if (is(T == SystemUpdater)) {
            _systemUpdaters[name] = system;
        }
        else static if (is(T == SystemRenderer)) {
            _systemRenderers[name] = system;
        }
        else static if (is(T == SystemEntityUpdater)) {
            _systemEntityUpdaters[name] = system;
        }
        else static if (is(T == SystemEntityRenderer)) {
            _systemEntityRenderers[name] = system;
        }
        else
            static assert(false, "undefined system type `" ~ T.stringof ~ "`");
    }

    T getSystem(T)(string name) {
        T* p;
        static if (is(T == SystemUpdater)) {
            p = name in _systemUpdaters;
        }
        else static if (is(T == SystemRenderer)) {
            p = name in _systemRenderers;
        }
        else static if (is(T == SystemEntityUpdater)) {
            p = name in _systemEntityUpdaters;
        }
        else static if (is(T == SystemEntityRenderer)) {
            p = name in _systemEntityRenderers;
        }
        else
            static assert(false, "undefined system type `" ~ T.stringof ~ "`");
        return *p;
    }
    /*
    void registerSystemUpdater(string name, SystemUpdater system) {
        _systemUpdaters[name] = system;
    }

    void registerSystemRenderer(string name, SystemRenderer system) {
        _systemRenderers[name] = system;
    }

    void registerEntitySystemUpdater(string name, SystemEntityUpdater system) {
        _systemEntityUpdaters[name] = system;
    }

    void registerEntitySystemRenderer(string name, SystemEntityRenderer system) {
        _systemEntityRenderers[name] = system;
    }*/

    private void _sortScenes() {
        sort!((a, b) => (a.zOrder > b.zOrder), SwapStrategy.stable)(_scenes.array);
    }

    void clear() {
        _scenes.clear();
        _camera.setPosition(Vec2f.zero);
    }

    void load(string rid) {
        //clear();
        //LevelBuilder level = Atelier.res.get!LevelBuilder(rid);
        //_scenes.array = level.build();
        //_sortScenes();
    }

    void addScene(Scene scene) {
        _scenes ~= scene;
        _sortScenes();
    }

    void removeScene(Scene scene) {
        scene.remove(); // Temporaire
    }

    Scene findSceneByName(string name) {
        foreach (scene; _scenes) {
            if (scene.name == name)
                return scene;
        }
        return null;
    }

    Scene[] findScenesByTag(string[] tags) {
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

    T findByName(T)(string name) {
        foreach (scene; _scenes) {
            T element = scene.findByName!T(name);
            if (element)
                return element;
        }
        return null;
    }

    T[] findByTag(T)(string[] tags) {
        T[] result;
        foreach (scene; _scenes) {
            result ~= scene.findByTag!T(tags);
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

        _camera.update();
    }

    void draw(Vec2f origin) {
        Atelier.renderer.pushCanvas(_camera.canvas);
        foreach (scene; _scenes) {
            /* if (scene.isVisible) {
                Atelier.renderer.pushCanvas(Atelier.renderer.size.x,
                    Atelier.renderer.size.y, Blend.alpha);*/
            //    scene.render();
            /*    Atelier.renderer.popCanvasAndDraw(origin,
                    Atelier.renderer.size, 0f, Vec2f.half, Color.white, 1f);
            }*/

            if (scene.isVisible) {
                Atelier.renderer.pushCanvas(scene.canvas);
                scene.render();
                Atelier.renderer.popCanvas();
                scene.draw(origin);
            }
        }
        Atelier.renderer.popCanvas();
        _camera.draw();
    }
}
