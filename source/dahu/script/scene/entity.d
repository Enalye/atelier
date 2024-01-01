/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.scene.entity;

import grimoire;

import dahu.common;
import dahu.core;
import dahu.scene;
import dahu.render;
import dahu.script.util;

package void loadLibScene_entity(GrLibDefinition library) {
    GrType entityType = library.addNative("Entity");
    GrType imageType = grGetNativeType("Image");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    library.addConstructor(&_ctor, entityType);

    library.addProperty(&_position!"get", &_position!"set", "position", entityType, vec2fType);

    library.addFunction(&_addChild, "addChild", [entityType, entityType]);
    library.addFunction(&_addImage, "addImage", [entityType, imageType]);
}

private void _ctor(GrCall call) {
    call.setNative(new Entity);
}

private void _position(string op)(GrCall call) {
    Entity entity = call.getNative!Entity(0);

    static if (op == "set") {
        entity.position = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(entity.position));
}

private void _addChild(GrCall call) {
    Entity parent = call.getNative!Entity(0);
    Entity child = call.getNative!Entity(1);
    parent.addChild(child);
}

private void _addImage(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    Image image = call.getNative!Image(1);
    entity.addImage(image);
}