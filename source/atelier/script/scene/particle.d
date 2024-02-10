/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.scene.particle;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.scene;
import atelier.render;
import atelier.script.util;

package void loadLibScene_particle(GrLibDefinition library) {
    library.setModule("scene.particle");
    library.setModuleInfo(GrLocale.fr_FR, "Système de particules");

    GrType sourceType = library.addNative("ParticleSource");
    GrType modeType = library.addEnum("ParticleMode", grNativeEnum!ParticleMode());

    GrType splineType = grGetEnumType("Spline");
    GrType blendType = grGetEnumType("Blend");
    GrType entityType = grGetNativeType("Entity");
    GrType colorType = grGetNativeType("Color");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    library.addConstructor(&_circular, sourceType);

    library.addProperty(&_position!"get", &_position!"set", "position", sourceType, vec2fType);

    library.addFunction(&_start, "start", [sourceType, grUInt]);
    library.addFunction(&_stop, "stop", [sourceType]);
    library.addFunction(&_emit, "emit", [sourceType]);
    library.addFunction(&_clear, "clear", [sourceType]);
    library.addFunction(&_remove, "remove", [sourceType]);
    library.addFunction(&_setSprite, "setSprite", [sourceType, grString]);
    library.addFunction(&_setBlend, "setBlend", [sourceType, blendType]);
    library.addFunction(&_setRelativePosition, "setRelativePosition", [
            sourceType, grBool
        ]);
    library.addFunction(&_setRelativeRotation, "setRelativeRotation", [
            sourceType, grBool
        ]);
    library.addFunction(&_attachTo, "attachTo", [sourceType, entityType]);
    library.addFunction(&_attachToScene, "attachToScene", [sourceType]);
    library.addFunction(&_detach, "detach", [sourceType]);
    library.addFunction(&_setLifetime, "setLifetime", [
            sourceType, grUInt, grUInt
        ]);
    library.addFunction(&_setCount, "setCount", [sourceType, grUInt, grUInt]);

    library.addFunction(&_setMode, "setMode", [sourceType, modeType]);
    library.addFunction(&_setArea, "setArea", [sourceType, grFloat, grFloat]);
    library.addFunction(&_setDistance, "setDistance", [
            sourceType, grFloat, grFloat
        ]);
    library.addFunction(&_setSpread, "setSpread", [
            sourceType, grFloat, grFloat, grFloat
        ]);

    // Effets
    library.addFunction(&_setEffectOnce!("Float", "Speed"), "setSpeed",
        [sourceType, grUInt, grFloat, grFloat]);
    library.addFunction(&_setEffectInterval!("Float", "Speed"), "setSpeedInterval",
        [sourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    library.addFunction(&_setEffectOnce!("Float", "Angle"), "setAngle",
        [sourceType, grUInt, grFloat, grFloat]);
    library.addFunction(&_setEffectInterval!("Float", "Angle"), "setAngleInterval",
        [sourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    library.addFunction(&_setEffectOnce!("Float", "Spin"), "setSpin",
        [sourceType, grUInt, grFloat, grFloat]);
    library.addFunction(&_setEffectInterval!("Float", "Spin"), "setSpinInterval",
        [sourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    library.addFunction(&_setEffectOnce!("Float", "PivotAngle"),
        "setPivotAngle", [sourceType, grUInt, grFloat, grFloat]);
    library.addFunction(&_setEffectInterval!("Float", "PivotAngle"),
        "setPivotAngleInterval", [
            sourceType, grUInt, grUInt, grFloat, grFloat, splineType
        ]);

    library.addFunction(&_setEffectOnce!("Float", "PivotSpin"),
        "setPivotSpin", [sourceType, grUInt, grFloat, grFloat]);
    library.addFunction(&_setEffectInterval!("Float", "PivotSpin"),
        "setPivotSpinInterval", [
            sourceType, grUInt, grUInt, grFloat, grFloat, splineType
        ]);

    library.addFunction(&_setEffectOnce!("Float", "PivotDistance"),
        "setPivotDistance", [sourceType, grUInt, grFloat, grFloat]);
    library.addFunction(&_setEffectInterval!("Float", "PivotDistance"),
        "setPivotDistanceInterval", [
            sourceType, grUInt, grUInt, grFloat, grFloat, splineType
        ]);

    library.addFunction(&_setEffectOnce!("Float", "Rotation"), "setRotation",
        [sourceType, grUInt, grFloat, grFloat]);
    library.addFunction(&_setEffectInterval!("Float", "Rotation"),
        "setRotationInterval", [
            sourceType, grUInt, grUInt, grFloat, grFloat, splineType
        ]);

    library.addFunction(&_setEffectOnce!("Float", "RotationSpin"),
        "setRotationSpin", [sourceType, grUInt, grFloat, grFloat]);
    library.addFunction(&_setEffectInterval!("Float", "RotationSpin"),
        "setRotationSpinInterval", [
            sourceType, grUInt, grUInt, grFloat, grFloat, splineType
        ]);

    library.addFunction(&_setEffectScaleOnce, "setScale", [
            sourceType, grUInt, vec2fType, vec2fType
        ]);
    library.addFunction(&_setEffectScaleInterval, "setScaleInterval",
        [sourceType, grUInt, grUInt, vec2fType, vec2fType, splineType]);

    library.addFunction(&_setEffectColorOnce, "setColor", [
            sourceType, grUInt, colorType, colorType
        ]);
    library.addFunction(&_setEffectColorInterval, "setColorInterval",
        [sourceType, grUInt, grUInt, colorType, colorType, splineType]);

    library.addFunction(&_setEffectOnce!("Float", "Alpha"), "setAlpha",
        [sourceType, grUInt, grFloat, grFloat]);
    library.addFunction(&_setEffectInterval!("Float", "Alpha"), "setAlphaInterval",
        [sourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

}

private void _circular(GrCall call) {
    ParticleSource source = new ParticleSource;
    call.setNative(source);
}

private void _position(string op)(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);

    static if (op == "set") {
        source.position = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(source.position));
}

private void _start(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrUInt interval = call.getUInt(1);
    source.start(interval);
}

private void _stop(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    source.stop();
}

private void _emit(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    source.emit();
}

private void _clear(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    source.clear();
}

private void _remove(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    source.remove();
}

private void _setSprite(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    source.setSprite(call.getString(1).str());
}

private void _setBlend(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    Blend blend = call.getEnum!Blend(1);
    source.setBlend(blend);
}

private void _setRelativePosition(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrBool isRelative = call.getBool(1);
    source.setRelativePosition(isRelative);
}

private void _setRelativeRotation(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrBool isRelative = call.getBool(1);
    source.setRelativeRotation(isRelative);
}

private void _attachTo(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    Entity entity = call.getNative!Entity(1);
    source.attachTo(entity);
}

private void _attachToScene(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    source.attachToScene();
}

private void _detach(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    source.attachTo(null);
}

private void _setLifetime(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrUInt minTtl = call.getUInt(1);
    GrUInt maxTtl = call.getUInt(2);
    source.setLifetime(minTtl, maxTtl);
}

private void _setCount(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrUInt minCount = call.getUInt(1);
    GrUInt maxCount = call.getUInt(2);
    source.setCount(minCount, maxCount);
}

private void _setMode(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    ParticleMode mode = call.getEnum!ParticleMode(1);
    source.setMode(mode);
}

private void _setArea(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrFloat x = call.getFloat(1);
    GrFloat y = call.getFloat(2);
    source.setArea(x, y);
}

private void _setDistance(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrFloat minDistance = call.getFloat(1);
    GrFloat maxDistance = call.getFloat(2);
    source.setDistance(minDistance, maxDistance);
}

private void _setSpread(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrFloat minAngle = call.getFloat(1);
    GrFloat maxAngle = call.getFloat(2);
    GrFloat spreadAngle = call.getFloat(3);
    source.setSpread(minAngle, maxAngle, spreadAngle);
}

private void _setEffectOnce(string Type, string EffectName)(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrUInt frame = call.getUInt(1);
    mixin("Gr", Type, " minValue = call.get", Type, "(2);");
    mixin("Gr", Type, " maxValue = call.get", Type, "(3);");
    ParticleEffect effect;
    mixin("effect = new ", EffectName, "ParticleEffect(minValue, maxValue);");
    effect.setFrames(frame, frame);
    source.addEffect(effect);
}

private void _setEffectInterval(string Type, string EffectName)(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrUInt startFrame = call.getUInt(1);
    GrUInt endFrame = call.getUInt(2);
    mixin("Gr", Type, " startValue = call.get", Type, "(3);");
    mixin("Gr", Type, " endValue = call.get", Type, "(4);");
    Spline spline = call.getEnum!Spline(5);
    ParticleEffect effect;
    mixin("effect = new ", EffectName,
        "IntervalParticleEffect(startValue, endValue, getSplineFunc(spline));");
    effect.setFrames(startFrame, endFrame);
    source.addEffect(effect);
}

private void _setEffectScaleOnce(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrUInt frame = call.getUInt(1);
    Vec2f minValue = call.getNative!SVec2f(2);
    Vec2f maxValue = call.getNative!SVec2f(3);
    ParticleEffect effect = new ScaleParticleEffect(minValue, maxValue);
    effect.setFrames(frame, frame);
    source.addEffect(effect);
}

private void _setEffectScaleInterval(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrUInt startFrame = call.getUInt(1);
    GrUInt endFrame = call.getUInt(2);
    Vec2f startValue = call.getNative!SVec2f(3);
    Vec2f endValue = call.getNative!SVec2f(4);
    Spline spline = call.getEnum!Spline(5);
    ParticleEffect effect = new ScaleIntervalParticleEffect(startValue,
        endValue, getSplineFunc(spline));
    effect.setFrames(startFrame, endFrame);
    source.addEffect(effect);
}

private void _setEffectColorOnce(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrUInt frame = call.getUInt(1);
    Color minValue = call.getNative!SColor(2);
    Color maxValue = call.getNative!SColor(3);
    ParticleEffect effect = new ColorParticleEffect(minValue, maxValue);
    effect.setFrames(frame, frame);
    source.addEffect(effect);
}

private void _setEffectColorInterval(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrUInt startFrame = call.getUInt(1);
    GrUInt endFrame = call.getUInt(2);
    Color startValue = call.getNative!SColor(3);
    Color endValue = call.getNative!SColor(4);
    Spline spline = call.getEnum!Spline(5);
    ParticleEffect effect = new ColorIntervalParticleEffect(startValue,
        endValue, getSplineFunc(spline));
    effect.setFrames(startFrame, endFrame);
    source.addEffect(effect);
}
