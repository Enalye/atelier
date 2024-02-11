/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.scene.scene;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.scene;
import atelier.ui;
import atelier.script.util;

package void loadLibScene_scene(GrLibDefinition library) {
    library.setModule("scene.scene");
    library.setModuleInfo(GrLocale.fr_FR, "Défini une caméra où évolue des entités");

    GrType sceneType = library.addNative("Scene");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType entityType = grGetNativeType("Entity");
    GrType particleSourceType = grGetNativeType("ParticleSource");
    GrType canvasType = grGetNativeType("Canvas");
    GrType uiType = grGetNativeType("UIElement");

    library.addConstructor(&_ctor, sceneType, [grInt, grInt]);

    library.addProperty(&_position!"get", &_position!"set", "position", sceneType, vec2fType);
    library.addProperty(&_isVisible!"get", &_isVisible!"set", "isVisible", entityType, grBool);
    library.addProperty(&_canvas, null, "canvas", entityType, canvasType);

    library.setDescription(GrLocale.fr_FR, "Ajoute une scène à l’application");
    library.setParameters(["scene"]);
    library.addFunction(&_addScene, "addScene", [sceneType]);

    library.setDescription(GrLocale.fr_FR, "Ajoute une entité à la scène");
    library.setParameters(["scene", "entity"]);
    library.addFunction(&_addEntity, "addEntity", [sceneType, entityType]);

    library.setDescription(GrLocale.fr_FR, "Ajoute une source de particules à la scène");
    library.setParameters(["scene", "source"]);
    library.addFunction(&_addParticleSource, "addParticleSource", [
            sceneType, particleSourceType
        ]);

    library.setDescription(GrLocale.fr_FR, "Ajoute un élément d’interface à la scène");
    library.setParameters(["scene", "ui"]);
    library.addFunction(&_addUI, "addUI", [sceneType, uiType]);

    library.setDescription(GrLocale.fr_FR, "Supprime les élements d’interface de la scène");
    library.setParameters(["scene"]);
    library.addFunction(&_clearUI, "clearUI", [sceneType]);
}

private void _ctor(GrCall call) {
    call.setNative(new Scene(call.getInt(0), call.getInt(1)));
}

private void _position(string op)(GrCall call) {
    Scene scene = call.getNative!Scene(0);

    static if (op == "set") {
        scene.position = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(scene.position));
}

private void _isVisible(string op)(GrCall call) {
    Scene scene = call.getNative!Scene(0);

    static if (op == "set") {
        scene.isVisible = call.getBool(1);
    }
    call.setBool(scene.isVisible);
}

private void _canvas(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    call.setNative(scene.canvas);
}

private void _addScene(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    Atelier.scene.addScene(scene);
}

private void _addEntity(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    Entity entity = call.getNative!Entity(1);
    scene.addEntity(entity);
}

private void _addParticleSource(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    ParticleSource source = call.getNative!ParticleSource(1);
    scene.addParticleSource(source);
}

private void _addUI(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    UIElement ui = call.getNative!UIElement(1);
    scene.addUI(ui);
}

private void _clearUI(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    scene.clearUI();
}
