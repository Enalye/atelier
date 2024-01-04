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
import atelier.script.util;

package void loadLibScene_scene(GrLibDefinition library) {
    GrType sceneType = library.addNative("Scene");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType entityType = grGetNativeType("Entity");
    GrType canvasType = grGetNativeType("Canvas");

    library.addConstructor(&_ctor, sceneType, [grInt, grInt]);

    library.addProperty(&_position!"get", &_position!"set", "position", sceneType, vec2fType);
    library.addProperty(&_isVisible!"get", &_isVisible!"set", "isVisible", entityType, grBool);
    library.addProperty(&_canvas, null, "isVisible", entityType, canvasType);

    library.addFunction(&_addScene, "addScene", [sceneType]);
    library.addFunction(&_addEntity, "addEntity", [sceneType, entityType]);
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
