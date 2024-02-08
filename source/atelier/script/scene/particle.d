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

    GrType particleSourceType = library.addNative("ParticleSource");
    GrType circularParticleSourceType = library.addNative("CircularParticleSource",
        [], "ParticleSource");

    GrType splineType = grGetEnumType("Spline");
    GrType entityType = grGetNativeType("Entity");

    library.addConstructor(&_circular, circularParticleSourceType);

    library.addFunction(&_start, "start", [particleSourceType, grUInt]);
    library.addFunction(&_stop, "stop", [particleSourceType]);
    library.addFunction(&_emit, "emit", [particleSourceType]);
    library.addFunction(&_clear, "clear", [particleSourceType]);
    library.addFunction(&_remove, "remove", [particleSourceType]);
    library.addFunction(&_setSprite, "setSprite", [particleSourceType, grString]);
    library.addFunction(&_setRelativePosition, "setRelativePosition",
        [particleSourceType, grBool]);
    library.addFunction(&_attachTo, "attachTo", [particleSourceType, entityType]);
    library.addFunction(&_detach, "detach", [particleSourceType]);
    library.addFunction(&_setLifetime, "setLifetime", [
            particleSourceType, grUInt, grUInt
        ]);
    library.addFunction(&_setCount, "setCount", [
            particleSourceType, grUInt, grUInt
        ]);

    // Circular
    library.addFunction(&_setDistance, "setDistance",
        [circularParticleSourceType, grFloat, grFloat]);
    library.addFunction(&_setSpread, "setSpread", [
            circularParticleSourceType, grFloat, grFloat, grFloat
        ]);

    // Effets
    library.addFunction(&_setEffectOnce!"Speed", "setSpeed",
        [particleSourceType, grUInt, grFloat, grFloat]);
    library.addFunction(&_setEffectInterval!"Speed", "setSpeedInterval",
        [particleSourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    library.addFunction(&_setEffectOnce!"Angle", "setAngle",
        [particleSourceType, grUInt, grFloat, grFloat]);
    library.addFunction(&_setEffectInterval!"Angle", "setAngleInterval",
        [particleSourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    library.addFunction(&_setEffectOnce!"AngleSpeed", "setAngleSpeed",
        [particleSourceType, grUInt, grFloat, grFloat]);
    library.addFunction(&_setEffectInterval!"AngleSpeed", "setAngleSpeedInterval",
        [particleSourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    library.addFunction(&_setEffectOnce!"PivotAngle", "setPivotAngle",
        [particleSourceType, grUInt, grFloat, grFloat]);
    library.addFunction(&_setEffectInterval!"PivotAngle", "setPivotAngleInterval",
        [particleSourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    library.addFunction(&_setEffectOnce!"PivotAngleSpeed",
        "setPivotAngleSpeed", [particleSourceType, grUInt, grFloat, grFloat]);
    library.addFunction(&_setEffectInterval!"PivotAngleSpeed", "setPivotAngleSpeedInterval",
        [particleSourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    library.addFunction(&_setEffectOnce!"PivotDistance", "setPivotDistance",
        [particleSourceType, grUInt, grFloat, grFloat]);
    library.addFunction(&_setEffectInterval!"PivotDistance", "setPivotDistanceInterval",
        [particleSourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

}

private void _circular(GrCall call) {
    CircularParticleSource source = new CircularParticleSource;
    call.setNative(source);
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
    Sprite sprite = Atelier.res.get!Sprite(call.getString(1).str());
    source.setSprite(sprite);
}

private void _setRelativePosition(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrBool isRelative = call.getBool(1);
    source.setRelativePosition(isRelative);
}

private void _attachTo(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    Entity entity = call.getNative!Entity(1);
    source.attachTo(entity);
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

private void _setDistance(GrCall call) {
    CircularParticleSource source = call.getNative!CircularParticleSource(0);
    GrFloat minDistance = call.getFloat(1);
    GrFloat maxDistance = call.getFloat(2);
    source.setDistance(minDistance, maxDistance);
}

private void _setSpread(GrCall call) {
    CircularParticleSource source = call.getNative!CircularParticleSource(0);
    GrFloat minAngle = call.getFloat(1);
    GrFloat maxAngle = call.getFloat(2);
    GrFloat spreadAngle = call.getFloat(3);
    source.setSpread(minAngle, maxAngle, spreadAngle);
}

private void _setEffectOnce(string EffectName)(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrUInt frame = call.getUInt(1);
    GrFloat minValue = call.getFloat(2);
    GrFloat maxValue = call.getFloat(3);
    ParticleEffect effect;
    mixin("effect = new ", EffectName, "ParticleEffect(minValue, maxValue);");
    effect.setFrames(frame, frame);
    source.addEffect(effect);
}

private void _setEffectInterval(string EffectName)(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrUInt startFrame = call.getUInt(1);
    GrUInt endFrame = call.getUInt(2);
    GrFloat minValue = call.getFloat(3);
    GrFloat maxValue = call.getFloat(4);
    Spline spline = call.getEnum!Spline(5);
    ParticleEffect effect;
    mixin("effect = new ", EffectName,
        "IntervalParticleEffect(minValue, maxValue, getSplineFunc(spline));");
    effect.setFrames(startFrame, endFrame);
    source.addEffect(effect);
}
