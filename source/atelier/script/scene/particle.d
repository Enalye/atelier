/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
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
    library.setModuleExample(GrLocale.fr_FR, "var src = @ParticleSource;
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

scene.addParticleSource(src);");

    GrType sourceType = library.addNative("ParticleSource");
    library.setDescription(GrLocale.fr_FR, "Mode d’émission des particules");
    GrType modeType = library.addEnum("ParticleMode", grNativeEnum!ParticleMode());

    GrType splineType = grGetEnumType("Spline");
    GrType blendType = grGetEnumType("Blend");
    GrType entityType = grGetNativeType("Entity");
    GrType colorType = grGetNativeType("Color");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    library.addConstructor(&_ctor, sourceType);
    library.addConstructor(&_ctor_str, sourceType, [grString]);

    library.addProperty(&_name!"get", &_name!"set", "name", sourceType, grString);
    library.addProperty(&_position!"get", &_position!"set", "position", sourceType, vec2fType);
    library.addProperty(&_isVisible!"get", &_isVisible!"set", "isVisible", sourceType, grBool);
    library.addProperty(&_isAlive, null, "isAlive", sourceType, grBool);

    library.setDescription(GrLocale.fr_FR, "Récupère les tags de la source");
    library.setParameters(["source"]);
    library.addFunction(&_getTags, "getTags", [sourceType]);

    library.setDescription(GrLocale.fr_FR, "Ajoute un tag à la source");
    library.setParameters(["source", "tag"]);
    library.addFunction(&_addTag, "addTag", [sourceType, grString]);

    library.setDescription(GrLocale.fr_FR, "Vérifie si la source possède le tag");
    library.setParameters(["source", "tag"]);
    library.addFunction(&_hasTag, "hasTag", [sourceType, grString], [grBool]);

    library.setDescription(GrLocale.fr_FR,
        "Démarre l’émission de particules toutes les `interval` frames.");
    library.setParameters(["source", "interval"]);
    library.addFunction(&_start, "start", [sourceType, grUInt]);

    library.setDescription(GrLocale.fr_FR, "Interrompt l’émission de particules.");
    library.setParameters(["source"]);
    library.addFunction(&_stop, "stop", [sourceType]);

    library.setDescription(GrLocale.fr_FR, "Génère une seule fois des particules.");
    library.setParameters(["source"]);
    library.addFunction(&_emit, "emit", [sourceType]);

    library.setDescription(GrLocale.fr_FR, "Efface toutes les particules.");
    library.setParameters(["source"]);
    library.addFunction(&_clear, "clear", [sourceType]);

    library.setDescription(GrLocale.fr_FR, "Retire la source de la scène.");
    library.setParameters(["source"]);
    library.addFunction(&_remove, "remove", [sourceType]);

    library.setDescription(GrLocale.fr_FR, "Change le sprite des particules.");
    library.setParameters(["source", "spriteId"]);
    library.addFunction(&_setSprite, "setSprite", [sourceType, grString]);

    library.setDescription(GrLocale.fr_FR, "Type de blending");
    library.setParameters(["source", "blend"]);
    library.addFunction(&_setBlend, "setBlend", [sourceType, blendType]);

    library.setDescription(GrLocale.fr_FR,
        "Si `true` les particules suivent la source, sinon elles sont laissées à la traine.");
    library.setParameters(["source", "isRelative"]);
    library.addFunction(&_setRelativePosition, "setRelativePosition", [
            sourceType, grBool
        ]);

    library.setDescription(GrLocale.fr_FR,
        "Est-ce que l’orientation du sprite dépend de l’angle de la particule ?");
    library.setParameters(["source", "isRelative"]);
    library.addFunction(&_setRelativeSpriteAngle, "setRelativeSpriteAngle", [
            sourceType, grBool
        ]);

    library.setDescription(GrLocale.fr_FR, "La source suit l’entité.");
    library.setParameters(["source", "entity"]);
    library.addFunction(&_attachTo, "attachTo", [sourceType, entityType]);

    library.setDescription(GrLocale.fr_FR, "La source suit la caméra.");
    library.setParameters(["source"]);
    library.addFunction(&_attachToCamera, "attachToCamera", [sourceType]);

    library.setDescription(GrLocale.fr_FR,
        "Détache la source de l’entité/scène auquel elle était attaché.");
    library.setParameters(["source"]);
    library.addFunction(&_detach, "detach", [sourceType]);

    library.setDescription(GrLocale.fr_FR,
        "Paramètre la durée de vie des particules (en frames).");
    library.setParameters(["source", "minLifetime", "maxLifetime"]);
    library.addFunction(&_setLifetime, "setLifetime", [
            sourceType, grUInt, grUInt
        ]);

    library.setDescription(GrLocale.fr_FR, "Le nombre de particule à émettre en même temps.");
    library.setParameters(["source", "minCount", "maxCount"]);
    library.addFunction(&_setCount, "setCount", [sourceType, grUInt, grUInt]);

    library.setDescription(GrLocale.fr_FR, "Le mode d’émission:
 * ParticleMode.spread: réglé par `setDistance` et `setSpread`, projette les particules selon un arc de cercle.
 * ParticleMode.rectangle: réglé par `setArea`, défini un rectangle autour de la position.
 * ParticleMode.ellipsis: réglé par `setArea`, défini une ellipse autour de la position.");
    library.setParameters(["source", "mode"]);
    library.addFunction(&_setMode, "setMode", [sourceType, modeType]);

    library.setDescription(GrLocale.fr_FR, "Change la taille de la zone à émettre.");
    library.setParameters(["source", "width", "height"]);
    library.addFunction(&_setArea, "setArea", [sourceType, grFloat, grFloat]);

    library.setDescription(GrLocale.fr_FR,
        "En mode `spread`, change la distance avec laquelle les particules sont émises.");
    library.setParameters(["source", "minDistance", "maxDistance"]);
    library.addFunction(&_setDistance, "setDistance", [
            sourceType, grFloat, grFloat
        ]);

    library.setDescription(GrLocale.fr_FR,
        "En mode `spread`, change l’angle (en radians) où sont émises les particules.
À chaque émission, un angle entre `minAngle` et `maxAngle` est choisi, les particules sont émises dans cet angle avec un écart de `spreadAngle`.");
    library.setParameters(["source", "minAngle", "maxAngle", "spreadAngle"]);
    library.addFunction(&_setSpread, "setSpread", [
            sourceType, grFloat, grFloat, grFloat
        ]);

    // Effets
    library.setDescription(GrLocale.fr_FR, "Change la vitesse des particules.");
    library.setParameters(["source", "frame", "minSpeed", "maxSpeed"]);
    library.addFunction(&_setEffectOnce!("Float", "Speed"), "setSpeed",
        [sourceType, grUInt, grFloat, grFloat]);
    library.setParameters([
        "source", "startFrame", "endFrame", "startSpeed", "endSpeed", "spline"
    ]);
    library.addFunction(&_setEffectInterval!("Float", "Speed"), "setSpeed",
        [sourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    library.setDescription(GrLocale.fr_FR, "Change l’angle des particules.");
    library.setParameters(["source", "frame", "minAngle", "maxAngle"]);
    library.addFunction(&_setEffectOnce!("Float", "Angle"), "setAngle",
        [sourceType, grUInt, grFloat, grFloat]);
    library.setParameters([
        "source", "startFrame", "endFrame", "startAngle", "endAngle", "spline"
    ]);
    library.addFunction(&_setEffectInterval!("Float", "Angle"), "setAngle",
        [sourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    library.setDescription(GrLocale.fr_FR, "Change la vitesse de rotation des particules.");
    library.setParameters(["source", "frame", "minSpin", "maxSpin"]);
    library.addFunction(&_setEffectOnce!("Float", "Spin"), "setSpin",
        [sourceType, grUInt, grFloat, grFloat]);
    library.setParameters([
        "source", "startFrame", "endFrame", "startSpin", "endSpin", "spline"
    ]);
    library.addFunction(&_setEffectInterval!("Float", "Spin"), "setSpin",
        [sourceType, grUInt, grUInt, grFloat, grFloat, splineType]);

    library.setDescription(GrLocale.fr_FR, "Change l’angle des particules autour de leur pivot.");
    library.setParameters(["source", "frame", "minAngle", "maxAngle"]);
    library.addFunction(&_setEffectOnce!("Float", "PivotAngle"),
        "setPivotAngle", [sourceType, grUInt, grFloat, grFloat]);
    library.setParameters([
        "source", "startFrame", "endFrame", "startAngle", "endAngle", "spline"
    ]);
    library.addFunction(&_setEffectInterval!("Float", "PivotAngle"),
        "setPivotAngle", [
            sourceType, grUInt, grUInt, grFloat, grFloat, splineType
        ]);

    library.setDescription(GrLocale.fr_FR,
        "Change la vitesse de rotation des particules autour de leur pivot.");
    library.setParameters(["source", "frame", "minSpin", "maxSpin"]);
    library.addFunction(&_setEffectOnce!("Float", "PivotSpin"),
        "setPivotSpin", [sourceType, grUInt, grFloat, grFloat]);
    library.setParameters([
        "source", "startFrame", "endFrame", "startSpin", "endSpin", "spline"
    ]);
    library.addFunction(&_setEffectInterval!("Float", "PivotSpin"),
        "setPivotSpin", [
            sourceType, grUInt, grUInt, grFloat, grFloat, splineType
        ]);

    library.setDescription(GrLocale.fr_FR, "Change la distance des particules avec leur pivot.");
    library.setParameters(["source", "frame", "minDistance", "maxDistance"]);
    library.addFunction(&_setEffectOnce!("Float", "PivotDistance"),
        "setPivotDistance", [sourceType, grUInt, grFloat, grFloat]);
    library.setParameters([
        "source", "startFrame", "endFrame", "startDistance", "endDistance",
        "spline"
    ]);
    library.addFunction(&_setEffectInterval!("Float", "PivotDistance"),
        "setPivotDistance", [
            sourceType, grUInt, grUInt, grFloat, grFloat, splineType
        ]);

    library.setDescription(GrLocale.fr_FR, "Change la rotation de l’image des particules.");
    library.setParameters(["source", "frame", "minAngle", "maxAngle"]);
    library.addFunction(&_setEffectOnce!("Float", "SpriteAngle"),
        "setSpriteAngle", [sourceType, grUInt, grFloat, grFloat]);
    library.setParameters([
        "source", "startFrame", "endFrame", "startAngle", "endAngle", "spline"
    ]);
    library.addFunction(&_setEffectInterval!("Float", "SpriteAngle"),
        "setSpriteAngle", [
            sourceType, grUInt, grUInt, grFloat, grFloat, splineType
        ]);

    library.setDescription(GrLocale.fr_FR,
        "Change la vitesse de rotation de l’image des particules.");
    library.setParameters(["source", "frame", "minSpin", "maxSpin"]);
    library.addFunction(&_setEffectOnce!("Float", "SpriteSpin"),
        "setSpriteSpin", [sourceType, grUInt, grFloat, grFloat]);
    library.setParameters([
        "source", "startFrame", "endFrame", "startSpin", "endSpin", "spline"
    ]);
    library.addFunction(&_setEffectInterval!("Float", "SpriteSpin"),
        "setSpriteSpin", [
            sourceType, grUInt, grUInt, grFloat, grFloat, splineType
        ]);

    library.setDescription(GrLocale.fr_FR, "Change la taille des particules.");
    library.setParameters(["source", "frame", "minScale", "maxScale"]);
    library.addFunction(&_setEffectScaleOnce, "setScale", [
            sourceType, grUInt, vec2fType, vec2fType
        ]);
    library.setParameters([
        "source", "startFrame", "endFrame", "startScale", "endScale", "spline"
    ]);
    library.addFunction(&_setEffectScaleInterval, "setScale", [
            sourceType, grUInt, grUInt, vec2fType, vec2fType, splineType
        ]);

    library.setDescription(GrLocale.fr_FR, "Change la couleur des particules.");
    library.setParameters(["source", "frame", "minColor", "maxColor"]);
    library.addFunction(&_setEffectColorOnce, "setColor", [
            sourceType, grUInt, colorType, colorType
        ]);
    library.setParameters([
        "source", "startFrame", "endFrame", "startColor", "endColor", "spline"
    ]);
    library.addFunction(&_setEffectColorInterval, "setColor", [
            sourceType, grUInt, grUInt, colorType, colorType, splineType
        ]);

    library.setDescription(GrLocale.fr_FR, "Change l’opacité des particules.");
    library.setParameters(["source", "frame", "minAlpha", "maxAlpha"]);
    library.addFunction(&_setEffectOnce!("Float", "Alpha"), "setAlpha",
        [sourceType, grUInt, grFloat, grFloat]);
    library.setParameters([
        "source", "startFrame", "endFrame", "startAlpha", "endAlpha", "spline"
    ]);
    library.addFunction(&_setEffectInterval!("Float", "Alpha"), "setAlpha",
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

private void _isAlive(GrCall call) {
    ParticleSource source = call.getNative!ParticleSource(0);
    call.setBool(source.isAlive);
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
