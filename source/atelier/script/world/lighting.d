/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.world.lighting;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world;
import atelier.ui;
import atelier.script.util;

package void loadLibWorld_lighting(GrModule mod) {
    mod.setModule("world.lighting");
    mod.setModuleInfo(GrLocale.fr_FR, "Gestion de la lumière");
    mod.setModuleExample(GrLocale.fr_FR, "");

    GrType darknessType = mod.addNative("Darkness");
    GrType fadedDarknessType = mod.addNative("FadedDarkness", [], "Darkness");

    GrType lightType = mod.addNative("Light");
    GrType pointLightType = mod.addNative("PointLight", [], "Light");
    GrType fadedLightType = mod.addNative("FadedLight", [], "Light");

    GrType sceneType = grGetNativeType("Scene");
    GrType entityType = grGetNativeType("Entity");
    GrType splineType = grGetEnumType("Spline");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType colorType = grGetNativeType("Color");

    mod.addProperty(&_darkness!"get", &_darkness!"set", "darkness",
        entityType, grOptional(darknessType));
    mod.addProperty(&_light!"get", &_light!"set", "light", entityType, grOptional(lightType));

    mod.setDescription(GrLocale.fr_FR, "Définit l’éclairage global");
    mod.setParameters(["scene", "illumination"]);
    mod.addFunction(&_setGlobalIllumination, "setGlobalIllumination", [
            sceneType, grFloat
        ]);

    mod.setParameters(["position", "size"]);
    mod.addConstructor(&_ctor_pointLight, pointLightType, [vec2fType, vec2fType]);

    mod.addProperty(&_pointLight_intensity!"get",
        &_pointLight_intensity!"set", "intensity", pointLightType, grFloat);
    mod.addProperty(&_pointLight_color!"get",
        &_pointLight_color!"set", "color", pointLightType, colorType);
    mod.addProperty(&_pointLight_size!"get",
        &_pointLight_size!"set", "size", pointLightType, vec2fType);

}

private void _setGlobalIllumination(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    LightingSystem context = cast(LightingSystem) scene.getSystemContext("lighting");
    context.globalIllumination = call.getFloat(1);
}

private void _darkness(string op)(GrCall call) {
    SEntity entity = call.getNative!SEntity(0);
    DarknessComponent* darkness = entity.scene.getComponent!DarknessComponent(entity.id);

    static if (op == "set") {
        darkness.darkness = call.isNull(1) ? null : call.getNative!Darkness(1);
    }

    if (darkness.darkness) {
        call.setNative(darkness.darkness);
    }
    else {
        call.setNull();
    }
}

private void _light(string op)(GrCall call) {
    SEntity entity = call.getNative!SEntity(0);
    LightComponent* light = entity.scene.getOrAddComponent!LightComponent(entity.id);

    static if (op == "set") {
        light.light = call.isNull(1) ? null : call.getNative!Light(1);
    }

    if (light.light) {
        call.setNative(light.light);
    }
    else {
        call.setNull();
    }
}

private void _ctor_pointLight(GrCall call) {
    call.setNative(new PointLight(call.getNative!SVec2f(0), call.getNative!SVec2f(1)));
}

private void _pointLight_intensity(string op)(GrCall call) {
    PointLight pointLight = call.getNative!PointLight(0);

    static if (op == "set") {
        pointLight.intensity = call.getFloat(1);
    }

    call.setFloat(pointLight.intensity);
}

private void _pointLight_color(string op)(GrCall call) {
    PointLight pointLight = call.getNative!PointLight(0);

    static if (op == "set") {
        pointLight.color = call.getNative!SColor(1);
    }

    call.setNative(scolor(pointLight.color));
}

private void _pointLight_size(string op)(GrCall call) {
    PointLight pointLight = call.getNative!PointLight(0);

    static if (op == "set") {
        pointLight.size = call.getNative!SVec2f(1);
    }

    call.setNative(svec2(pointLight.size));
}
