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

    GrType lightningType = mod.addNative("Lightning");

    GrType darknessType = mod.addNative("Darkness");
    GrType fadedDarknessType = mod.addNative("FadedDarkness", [], "Darkness");

    GrType lightType = mod.addNative("Light");
    GrType pointLightType = mod.addNative("PointLight", [], "Light");
    GrType fadedLightType = mod.addNative("FadedLight", [], "Light");

    GrType entityType = grGetNativeType("Entity");
    GrType splineType = grGetEnumType("Spline");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType colorType = grGetNativeType("Color");

    mod.setDescription(GrLocale.fr_FR, "Définit l’éclairage global");
    mod.setParameters(["brightness"]);
    mod.addStatic(&_setBrightness, lightningType, "setBrightness", [
            grFloat
        ]);

    /*
    mod.addProperty(&_darkness!"get", &_darkness!"set", "darkness",
        entityType, grOptional(darknessType));
    mod.addProperty(&_light!"get", &_light!"set", "light", entityType, grOptional(lightType));
*/

    /*
    mod.setParameters(["position", "size"]);
    mod.addConstructor(&_ctor_pointLight, pointLightType, [vec2fType, vec2fType]);

    mod.addProperty(&_pointLight_brightness!"get",
        &_pointLight_brightness!"set", "brightness", pointLightType, grFloat);
    mod.addProperty(&_pointLight_color!"get",
        &_pointLight_color!"set", "color", pointLightType, colorType);
    mod.addProperty(&_pointLight_size!"get",
        &_pointLight_size!"set", "size", pointLightType, vec2fType);*/
}

private void _setBrightness(GrCall call) {
    Atelier.world.lighting.setBrightness(call.getFloat(0));
}

private void _getBrightnessAt(GrCall call) {
    const float value = Atelier.world.lighting.getBrightnessAt(call.getNative!SVec2i(0));
    call.setFloat(value);
}
/*
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

private void _pointLight_brightness(string op)(GrCall call) {
    PointLight pointLight = call.getNative!PointLight(0);

    static if (op == "set") {
        pointLight.brightness = call.getFloat(1);
    }

    call.setFloat(pointLight.brightness);
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
*/
