module atelier.script.world.effect;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world;
import atelier.ui;
import atelier.script.util;

package void loadLibWorld_effect(GrModule mod) {
    mod.setModule("world.effect");
    mod.setModuleInfo(GrLocale.fr_FR, "Définit les effets d’une entité");

    GrType graphicType = mod.addNative("EntityGraphicEffect");
    GrType blinkEffectType = mod.addNative("BlinkEffect", [], "EntityGraphicEffect");
    GrType flashEffectType = mod.addNative("FlashEffect", [], "EntityGraphicEffect");
    GrType blendType = grGetEnumType("Blend");
    GrType splineType = grGetEnumType("Spline");
    GrType colorType = grGetNativeType("Color");

    mod.setDescription(GrLocale.fr_FR, "Effet de clignotement");
    mod.setParameters([
        "color", "maxAlpha", "minAlpha", "duration", "count", "ease"
    ]);
    mod.addConstructor(&_blinkCtr, blinkEffectType, [
            colorType, grFloat, grFloat, grUInt, grUInt, splineType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Effet de flash");
    mod.setParameters([
        "color", "alpha", "stayDuration", "fadeDuration", "spline"
    ]);
    mod.addConstructor(&_flashCtr, flashEffectType, [
            colorType, grFloat, grUInt, grUInt, splineType
        ]);
}

private void _blinkCtr(GrCall call) {
    Color color = call.getNative!SColor(0);
    float maxAlpha = call.getFloat(1);
    float minAlpha = call.getFloat(2);
    uint duration = call.getUInt(3);
    uint count = call.getUInt(4);
    Spline spline = call.getEnum!Spline(5);

    BlinkEffect blink = new BlinkEffect(color, maxAlpha, minAlpha, duration, count, spline);
    call.setNative(blink);
}

private void _flashCtr(GrCall call) {
    Color color = call.getNative!SColor(0);
    float alpha = call.getFloat(1);
    uint stayDuration = call.getUInt(2);
    uint fadeDuration = call.getUInt(3);
    Spline spline = call.getEnum!Spline(4);

    FlashEffect flash = new FlashEffect(color, alpha, stayDuration, fadeDuration, spline);
    call.setNative(flash);
}
