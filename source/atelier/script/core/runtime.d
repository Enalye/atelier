/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.core.runtime;

import grimoire;

import atelier.core;
import atelier.render;
import atelier.script.util;

package void loadLibCore_runtime(GrLibDefinition library) {
    library.setModule("core.runtime");
    library.setModuleInfo(GrLocale.fr_FR, "Informations système");

    GrType appType = library.addNative("App");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType vec2iType = grGetNativeType("Vec2", [grInt]);

    GrType scalingType = library.addEnum("Scaling", grNativeEnum!(Renderer.Scaling)());

    library.addStatic(&_width, appType, "width", [], [grInt]);
    library.addStatic(&_height, appType, "height", [], [grInt]);
    library.addStatic(&_size, appType, "size", [], [vec2iType]);
    library.addStatic(&_center, appType, "center", [], [vec2iType]);
    library.addStatic(&_setPixelSharpness, appType, "setPixelSharpness", [grUInt]);
    library.addStatic(&_setScaling, appType, "setScaling", [scalingType]);
}

private void _width(GrCall call) {
    call.setInt(Atelier.renderer.size.x);
}

private void _height(GrCall call) {
    call.setInt(Atelier.renderer.size.y);
}

private void _size(GrCall call) {
    call.setNative(svec2(Atelier.renderer.size));
}

private void _center(GrCall call) {
    call.setNative(svec2(Atelier.renderer.center));
}

private void _setPixelSharpness(GrCall call) {
    Atelier.renderer.setPixelSharpness(call.getUInt(0));
}

private void _setScaling(GrCall call) {
    Atelier.renderer.setScaling(call.getEnum!(Renderer.Scaling)(0));
}
