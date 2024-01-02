/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.render.sprite;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.script.util;

void loadLibRender_sprite(GrLibDefinition library) {
    GrType spriteType = library.addNative("Sprite", [], "Image");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    library.addConstructor(&_sprite, spriteType, [grString]);

    library.addProperty(&_size!"get", &_size!"set", "size", spriteType, vec2fType);
}

private void _sprite(GrCall call) {
    call.setNative(Atelier.res.get!Sprite(call.getString(0)));
}

private void _size(string op)(GrCall call) {
    Sprite sprite = call.getNative!Sprite(0);

    static if (op == "set") {
        sprite.size = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(sprite.size));
}
