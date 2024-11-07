/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.world.particle;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.world;
import atelier.render;
import atelier.script.util;

package void loadLibWorld_particle(GrModule mod) {
    mod.setModule("scene.particle");
    mod.setModuleInfo(GrLocale.fr_FR, "Système de particules");
    mod.setModuleExample(GrLocale.fr_FR, "var src = @ParticleSource;
src.setSprite(\"particle\");
src.setMode(ParticleMode.spread);
src.setSpread(0f, 360f, 45f);
src.setDistance(100f, 100f);
src.setCount(50, 70);
src.setLifetime(100, 100);
src.setSpeed(0, 60, 0.3f, 0.5f, Spline.sineInOut);
src.setSpeed(60, 100, 0.5f, 0f, Spline.sineInOut);
src.setAlpha(0, 10, 0f, 1f, Spline.sineInOut);
src.setAlpha(90, 100, 1f, 0f, Spline.sineInOut);
src.setPivotSpin(0, 0.02f, 0.02f);
src.setPivotDistance(0, 60, 50f, 150f, Spline.sineInOut);
src.setPivotDistance(60, 100, 150f, 100f, Spline.sineInOut);
src.start(5);

scene.setParticleSource(entity, src, false);");

    GrType sourceType = mod.addNative("ParticleSource");
    mod.setDescription(GrLocale.fr_FR, "Mode d’émission des particules");
    GrType modeType = mod.addEnum("ParticleMode", grNativeEnum!ParticleMode());

    GrType splineType = grGetEnumType("Spline");
    GrType blendType = grGetEnumType("Blend");
    GrType entityType = grUInt;
    GrType colorType = grGetNativeType("Color");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    mod.addConstructor(&_ctor, sourceType);
    mod.addConstructor(&_ctor_str, sourceType, [grString]);

    mod.setDescription(GrLocale.fr_FR, "Associe une source de particules à l’entité");
    mod.setParameters(["entity", "source", "isInFront"]);
    mod.addFunction(&_setParticleSource, "setParticleSource", [
            entityType, grOptional(sourceType), grBool
        ]);

    mod.addProperty(&_name!"get", &_name!"set", "name", sourceType, grString);
    mod.addProperty(&_position!"get", &_position!"set", "position", sourceType, vec2fType);
    mod.addProperty(&_isVisible!"get", &_isVisible!"set", "isVisible", sourceType, grBool);

    mod.setDescription(GrLocale.fr_FR, "Récupère les tags de la source");
    mod.setParameters(["source"]);
    mod.addFunction(&_getTags, "getTags", [sourceType]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute un tag à la source");
    mod.setParameters(["source", "tag"]);
    mod.addFunction(&_addTag, "addTag", [sourceType, grString]);

    mod.setDescription(GrLocale.fr_FR, "Vérifie si la source possède le tag");
    mod.setParameters(["source", "tag"]);
    mod.addFunction(&_hasTag, "hasTag", [sourceType, grString], [grBool]);

    mod.setDescription(GrLocale.fr_FR,
        "Démarre l’émission de particules toutes les `interval` frames.");
    mod.setParameters(["source", "interval"]);
    mod.addFunction(&_start, "start", [sourceType, grUInt]);

    mod.setDescription(GrLocale.fr_FR, "Interrompt l’émission de particules.");
    mod.setParameters(["source"]);
    mod.addFunction(&_stop, "stop", [sourceType]);

    mod.setDescription(GrLocale.fr_FR, "Génère une seule fois des particules.");
    mod.setParameters(["source"]);
    mod.addFunction(&_emit, "emit", [sourceType]);

    mod.setDescription(GrLocale.fr_FR, "Efface toutes les particules.");
    mod.setParameters(["source"]);
    mod.addFunction(&_clear, "clear", [sourceType]);

    mod.setDescription(GrLocale.fr_FR, "Retire la source de la scène.");
    mod.setParameters(["source"]);
    mod.addFunction(&_remove, "remove", [sourceType]);

    mod.setDescription(GrLocale.fr_FR, "Change le sprite des particules.");
    mod.setParameters(["source", "spriteId"]);
    mod.addFunction(&_setSprite, "setSprite", [sourceType, grString]);

    mod.setDescription(GrLocale.fr_FR, "Type de blending");
    mod.setParameters(["source", "blend"]);
    mod.addFunction(&_setBlend, "setBlend", [sourceType, blendType]);

    mod.setDescription(GrLocale.fr_FR,
        "Si `true` les particules suivent la source, sinon elles sont laissées à la traine.");
    mod.setParameters(["source", "isRelative"]);
    mod.addFunction(&_setRelativePosition, "setRelativePosition", [
            sourceType, grBool
        ]);

    mod.setDescription(GrLocale.fr_FR,
        "Est-ce que l’orientation du sprite dépend de l’angle de la particule ?");
    mod.setParameters(["source", "isRelative"]);
    mod.addFunction(&_setRelativeSpriteAngle, "setRelativeSpriteAngle", [
            sourceType, grBool
        ]);
    /*
    mod.setDescription(GrLocale.fr_FR, "La source suit l’entité.");
    mod.setParameters(["source", "entity"]);
    mod.addFunction(&_attachTo, "attachTo", [sourceType, entityType]);

    mod.setDescription(GrLocale.fr_FR, "La source suit la caméra.");
    mod.setParameters(["source"]);
    mod.addFunction(&_attachToCamera, "attachToCamera", [sourceType]);

    mod.setDescription(GrLocale.fr_FR,
        "Détache la source de l’entité/scène auquel elle était attaché.");
    mod.setParameters(["source"]);
    mod.addFunction(&_detach, "detach", [sourceType]);
*/
    mod.setDescription(GrLocale.fr_FR, "Paramètre la durée de vie des particules (en frames).");
    mod.setParameters(["source", "minLifetime", "maxLifetime"]);
    mod.addFunction(&_setLifetime, "setLifetime", [sourceType, grUInt, grUInt]);

    mod.setDescription(GrLocale.fr_FR, "Le nombre de particule à émettre en même temps.");
    mod.setParameters(["source", "minCount", "maxCount"]);
    mod.addFunction(&_setCount, "setCount", [sourceType, grUInt, grUInt]);

    mod.setDescription(GrLocale.fr_FR, "Le mode d’émission:
 * ParticleMode.spread: réglé par `setDistance` et `setSpread`, projette les particules selon un arc de cercle.
 * ParticleMode.rectangle: réglé par `setArea`, défini un rectangle autour de la position.
 * ParticleMode.ellipsis: réglé par `setArea`, défini une ellipse autour de la position.");
    mod.setParameters(["source", "mode"]);
    mod.addFunction(&_setMode, "setMode", [sourceType, modeType]);

    mod.setDescription(GrLocale.fr_FR, "Change la taille de la zone à émettre.");
    mod.setParameters(["source", "width", "height"]);
    mod.addFunction(&_setArea, "setArea", [sourceType, grFloat, grFloat]);

    mod.setDescription(GrLocale.fr_FR,
        "En mode `spread`, change la distance avec laquelle les particules sont émises.");
    mod.setParameters(["source", "minDistance", "maxDistance"]);
    mod.addFunction(&_setDistance, "setDistance", [sourceType, grFloat, grFloat]);

    mod.setDescription(GrLocale.fr_FR,
        "En mode `spread`, change l’angle (en radians) où sont émises les particules.
À chaque émission, un angle entre `minAngle` et `maxAngle` est choisi, les particules sont émises dans cet angle avec un écart de `spreadAngle`.");
    mod.setParameters(["source", "minAngle", "maxAngle", "spreadAngle"]);
    mod.addFunction(&_setSpread, "setSpread", [
            sourceType, grFloat, grFloat, grFloat
        ]);

    // Effets
    mod.setDescription(GrLocale.fr_FR, "Change la vitesse des particules.");
    mod.setParameters(["source", "frame", "minSpeed", "maxSpeed"]);
    mod.addFunction(&_setEffectOnce!("Float", "Speed"), "setSpeed",
        [sourceType, grUInt, grFloat, grFloat]);
    mod.setParameters([
        "source", "startFrame", "endFrame", "startSpeed", "endSpeed", "spline"
    ]);
    mod.addFunction(&_setEffectInterval!("Float", "Speed"), "setSpeed",
        [sourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    mod.setDescription(GrLocale.fr_FR, "Change l’angle des particules.");
    mod.setParameters(["source", "frame", "minAngle", "maxAngle"]);
    mod.addFunction(&_setEffectOnce!("Float", "Angle"), "setAngle",
        [sourceType, grUInt, grFloat, grFloat]);
    mod.setParameters([
        "source", "startFrame", "endFrame", "startAngle", "endAngle", "spline"
    ]);
    mod.addFunction(&_setEffectInterval!("Float", "Angle"), "setAngle",
        [sourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    mod.setDescription(GrLocale.fr_FR, "Change la vitesse de rotation des particules.");
    mod.setParameters(["source", "frame", "minSpin", "maxSpin"]);
    mod.addFunction(&_setEffectOnce!("Float", "Spin"), "setSpin",
        [sourceType, grUInt, grFloat, grFloat]);
    mod.setParameters([
        "source", "startFrame", "endFrame", "startSpin", "endSpin", "spline"
    ]);
    mod.addFunction(&_setEffectInterval!("Float", "Spin"), "setSpin",
        [sourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    mod.setDescription(GrLocale.fr_FR, "Change l’angle des particules autour de leur pivot.");
    mod.setParameters(["source", "frame", "minAngle", "maxAngle"]);
    mod.addFunction(&_setEffectOnce!("Float", "PivotAngle"), "setPivotAngle",
        [sourceType, grUInt, grFloat, grFloat]);
    mod.setParameters([
        "source", "startFrame", "endFrame", "startAngle", "endAngle", "spline"
    ]);
    mod.addFunction(&_setEffectInterval!("Float", "PivotAngle"), "setPivotAngle",
        [sourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    mod.setDescription(GrLocale.fr_FR,
        "Change la vitesse de rotation des particules autour de leur pivot.");
    mod.setParameters(["source", "frame", "minSpin", "maxSpin"]);
    mod.addFunction(&_setEffectOnce!("Float", "PivotSpin"), "setPivotSpin",
        [sourceType, grUInt, grFloat, grFloat]);
    mod.setParameters([
        "source", "startFrame", "endFrame", "startSpin", "endSpin", "spline"
    ]);
    mod.addFunction(&_setEffectInterval!("Float", "PivotSpin"), "setPivotSpin",
        [sourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    mod.setDescription(GrLocale.fr_FR, "Change la distance des particules avec leur pivot.");
    mod.setParameters(["source", "frame", "minDistance", "maxDistance"]);
    mod.addFunction(&_setEffectOnce!("Float", "PivotDistance"),
        "setPivotDistance", [sourceType, grUInt, grFloat, grFloat]);
    mod.setParameters([
        "source", "startFrame", "endFrame", "startDistance", "endDistance",
        "spline"
    ]);
    mod.addFunction(&_setEffectInterval!("Float", "PivotDistance"),
        "setPivotDistance", [
            sourceType, grUInt, grUInt, grFloat, grFloat, splineType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Change la rotation de l’image des particules.");
    mod.setParameters(["source", "frame", "minAngle", "maxAngle"]);
    mod.addFunction(&_setEffectOnce!("Float", "SpriteAngle"),
        "setSpriteAngle", [sourceType, grUInt, grFloat, grFloat]);
    mod.setParameters([
        "source", "startFrame", "endFrame", "startAngle", "endAngle", "spline"
    ]);
    mod.addFunction(&_setEffectInterval!("Float", "SpriteAngle"),
        "setSpriteAngle", [
            sourceType, grUInt, grUInt, grFloat, grFloat, splineType
        ]);

    mod.setDescription(GrLocale.fr_FR,
        "Change la vitesse de rotation de l’image des particules.");
    mod.setParameters(["source", "frame", "minSpin", "maxSpin"]);
    mod.addFunction(&_setEffectOnce!("Float", "SpriteSpin"), "setSpriteSpin",
        [sourceType, grUInt, grFloat, grFloat]);
    mod.setParameters([
        "source", "startFrame", "endFrame", "startSpin", "endSpin", "spline"
    ]);
    mod.addFunction(&_setEffectInterval!("Float", "SpriteSpin"), "setSpriteSpin",
        [sourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    mod.setDescription(GrLocale.fr_FR, "Change la taille des particules.");
    mod.setParameters(["source", "frame", "minScale", "maxScale"]);
    mod.addFunction(&_setEffectScaleOnce, "setScale", [
            sourceType, grUInt, vec2fType, vec2fType
        ]);
    mod.setParameters([
        "source", "startFrame", "endFrame", "startScale", "endScale", "spline"
    ]);
    mod.addFunction(&_setEffectScaleInterval, "setScale", [
            sourceType, grUInt, grUInt, vec2fType, vec2fType, splineType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Change la couleur des particules.");
    mod.setParameters(["source", "frame", "minColor", "maxColor"]);
    mod.addFunction(&_setEffectColorOnce, "setColor", [
            sourceType, grUInt, colorType, colorType
        ]);
    mod.setParameters([
        "source", "startFrame", "endFrame", "startColor", "endColor", "spline"
    ]);
    mod.addFunction(&_setEffectColorInterval, "setColor", [
            sourceType, grUInt, grUInt, colorType, colorType, splineType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Change l’opacité des particules.");
    mod.setParameters(["source", "frame", "minAlpha", "maxAlpha"]);
    mod.addFunction(&_setEffectOnce!("Float", "Alpha"), "setAlpha",
        [sourceType, grUInt, grFloat, grFloat]);
    mod.setParameters([
        "source", "startFrame", "endFrame", "startAlpha", "endAlpha", "spline"
    ]);
    mod.addFunction(&_setEffectInterval!("Float", "Alpha"), "setAlpha",
        [sourceType, grUInt, grUInt, grFloat, grFloat, splineType]);
}

private void _ctor(GrCall call) {
    ParticleSource source = new ParticleSource;
    call.setNative(source);
}

private void _ctor_str(GrCall call) {
    ParticleSource source = Atelier.res.get!ParticleSource(call.getString(0));
    call.setNative(source);
}

private void _setParticleSource(GrCall call) {
    SEntity entity = call.getNative!SEntity(0);

    if (call.isNull(2)) {
        entity.scene.removeComponent!ParticleComponent(entity.id);
    }
    else {
        ParticleComponent* part = entity.scene.addComponent!ParticleComponent(entity.id);
        part.source = call.getNative!ParticleSource(1);
        part.isFront = call.getBool(2);
    }
}

private void _name(string op)(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);

    static if (op == "set") {
        source.name = call.getString(1);
    }
    call.setString(source.name);
}

private void _position(string op)(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);

    static if (op == "set") {
        source.position = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(source.position));
}

private void _isVisible(string op)(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);

    static if (op == "set") {
        source.isVisible = call.getBool(1);
    }
    call.setBool(source.isVisible);
}

private void _getTags(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrList list = new GrList;
    list.setStrings(source.tags);
    call.setList(list);
}

private void _addTag(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    string tag = call.getString(1);

    foreach (sourceTag; source.tags) {
        if (sourceTag == tag) {
            return;
        }
    }

    source.tags ~= tag;
}

private void _hasTag(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    string tag = call.getString(1);

    foreach (sourceTag; source.tags) {
        if (sourceTag == tag) {
            call.setBool(true);
            return;
        }
    }
    call.setBool(false);
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

private void _setRelativeSpriteAngle(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    GrBool isRelative = call.getBool(1);
    source.setRelativeSpriteAngle(isRelative);
}
/*
private void _attachTo(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    Entity entity = call.getNative!Entity(1);
    source.attachTo(entity);
}

private void _attachToCamera(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    source.attachToCamera();
}

private void _detach(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    source.attachTo(null);
}
*/
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
