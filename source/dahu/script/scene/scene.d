/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.scene.scene;

import grimoire;

import dahu.common;
import dahu.core;
import dahu.scene;

package void loadLibScene_scene(GrLibDefinition library) {
    GrType sceneType = library.addNative("Scene");

    GrType entityType = grGetNativeType("Entity");

    library.addConstructor(&_ctor, sceneType);

    library.addFunction(&_addScene, "addScene", [sceneType]);
    library.addFunction(&_addEntity, "addEntity", [sceneType, entityType]);
}

private void _ctor(GrCall call) {
    call.setNative(new Scene);
}

private void _addScene(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    Dahu.scene.addScene(scene);
}

private void _addEntity(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    Entity entity = call.getNative!Entity(1);
    scene.addEntity(entity);
}