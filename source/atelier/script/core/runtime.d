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
    GrType appType = library.addNative("App");
    //GrType uiType = grGetNativeType("UI");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType vec2iType = grGetNativeType("Vec2", [grInt]);

    GrType scalingType = library.addEnum("Scaling", grNativeEnum!(Renderer.Scaling)());

    //library.addVariable("app", appType);

    //library.addProperty(&_ui, null, "ui", appType, uiType);
    library.addFunction(&_getAppWidth, "getAppWidth", [], [grInt]);
    library.addFunction(&_getAppHeight, "getAppHeight", [], [grInt]);
    library.addFunction(&_getAppSize, "getAppSize", [], [vec2iType]);
    library.addFunction(&_getAppCenter, "getAppCenter", [], [vec2iType]);
    library.addFunction(&_setPixelSharpness, "setPixelSharpness", [grUInt]);
    library.addFunction(&_setScaling, "setScaling", [scalingType]);
}
/*
private void _ui(GrCall call) {
    Atelier rt = call.getNative!Atelier(0);
    call.setNative(rt.ui);
}*/

private void _getAppWidth(GrCall call) {
    call.setInt(Atelier.renderer.size.x);
}

private void _getAppHeight(GrCall call) {
    call.setInt(Atelier.renderer.size.y);
}

private void _getAppSize(GrCall call) {
    call.setNative(svec2(Atelier.renderer.size));
}

private void _getAppCenter(GrCall call) {
    call.setNative(svec2(Atelier.renderer.center));
}

private void _setPixelSharpness(GrCall call) {
    Atelier.renderer.setPixelSharpness(call.getUInt(0));
}

private void _setScaling(GrCall call) {
    Atelier.renderer.setScaling(call.getEnum!(Renderer.Scaling)(0));
}
