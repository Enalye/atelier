module atelier.script.world.entity;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.render;
import atelier.world;
import atelier.ui;
import atelier.script.util;

package void loadLibWorld_entity(GrModule mod) {
    mod.setModule("world.entity");
    mod.setModuleInfo(GrLocale.fr_FR, "Définit une entité évoluant dans la scène");
    mod.setModuleExample(GrLocale.fr_FR, "var entity = @Entity(\"entity\");");

    GrType entityType = mod.addNative("Entity");
    GrType graphicType = grGetNativeType("EntityGraphic");
    GrType graphicEffectType = grGetNativeType("EntityGraphicEffect");
    GrType layerType = mod.addEnum("EntityLayer", grNativeEnum!(Entity.Layer)());
    GrType componentType = grGetNativeType("EntityComponent");
    GrType controllerType = grGetNativeType("EntityController");
    GrType behaviorType = grGetNativeType("EntityBehavior");

    mod.setDescription(GrLocale.fr_FR, "Crée une entité");
    mod.setParameters(["rid"]);
    mod.addConstructor(&_ctor, entityType, [grString]);

    mod.setDescription(GrLocale.fr_FR, "Retire l’entité");
    mod.setParameters(["entity"]);
    mod.addFunction(&_unregister, "unregister", [entityType]);

    mod.setDescription(GrLocale.fr_FR, "L’entité est-il présent dans la scène ?");
    mod.setParameters(["entity"]);
    mod.addFunction(&_isRegistered, "isRegistered", [entityType], [grBool]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute un tag à l’entité");
    mod.setParameters(["entity", "tag"]);
    mod.addFunction(&_addTag, "addTag", [
            entityType, grString
        ]);

    mod.setDescription(GrLocale.fr_FR, "Vérifie la présence d’un tag chez l’entité");
    mod.setParameters(["entity", "tag"]);
    mod.addFunction(&_hasTag, "hasTag", [
            entityType, grString
        ], [grBool]);

    mod.setDescription(GrLocale.fr_FR, "Change le rendu de l’entité");
    mod.setParameters(["entity", "id"]);
    mod.addFunction(&_setGraphic, "setGraphic", [
            entityType, grString
        ]);

    mod.setDescription(GrLocale.fr_FR, "Récupère le rendu de l’entité");
    mod.setParameters(["entity"]);
    mod.addFunction(&_getGraphic, "getGraphic", [entityType], [
            grOptional(graphicType)
        ]);

    mod.setDescription(GrLocale.fr_FR, "Définit le calque de rendu");
    mod.setParameters(["entity", "layer"]);
    mod.addFunction(&_setLayer, "setLayer", [entityType, layerType]);

    mod.setDescription(GrLocale.fr_FR, "Positionne l’entité");
    mod.setParameters(["entity", "x", "y", "z"]);
    mod.addFunction(&_setPosition, "setPosition", [
            entityType, grInt, grInt, grInt
        ]);

    mod.setDescription(GrLocale.fr_FR, "Repositionne l’entité");
    mod.setParameters(["entity", "x", "y", "z"]);
    mod.addFunction(&_addPosition, "addPosition", [
            entityType, grInt, grInt, grInt
        ]);

    mod.setDescription(GrLocale.fr_FR, "Active/Désactive l’entité");
    mod.setParameters(["entity", "state"]);
    mod.addFunction(&_setEnabled, "setEnabled", [
            entityType, grBool
        ]);

    mod.setDescription(GrLocale.fr_FR, "Active/Désactive la collision de l’entité");
    mod.setParameters(["entity", "state"]);
    mod.addFunction(&_setCollidable, "setCollidable", [
            entityType, grBool
        ]);

    mod.setDescription(GrLocale.fr_FR, "Récupère la position de l’entité");
    mod.setParameters(["entity"]);
    mod.addFunction(&_getPosition, "getPosition", [entityType], [
            grInt, grInt, grInt
        ]);

    mod.setDescription(GrLocale.fr_FR, "Change la vitesse de l’entité");
    mod.setParameters(["entity", "xy", "z"]);
    mod.addFunction(&_setSpeed, "setSpeed", [
            entityType, grFloat, grFloat
        ]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute à la vitesse de l’entité");
    mod.setParameters(["entity", "xy", "z"]);
    mod.addFunction(&_addSpeed, "addSpeed", [
            entityType, grFloat, grFloat
        ]);

    mod.setDescription(GrLocale.fr_FR, "Change la trajectoire de l’entité");
    mod.setParameters(["entity", "x", "y", "z"]);
    mod.addFunction(&_setVelocity, "setVelocity", [
            entityType, grFloat, grFloat, grFloat
        ]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute à la trajectoire de l’entité");
    mod.setParameters(["entity", "x", "y", "z"]);
    mod.addFunction(&_addVelocity, "addVelocity", [
            entityType, grFloat, grFloat, grFloat
        ]);

    mod.setDescription(GrLocale.fr_FR, "Change l’angle de l’entité");
    mod.setParameters(["entity", "degrees"]);
    mod.addFunction(&_setAngle, "setAngle", [
            entityType, grFloat,
        ]);

    mod.setDescription(GrLocale.fr_FR, "Récupère l’angle de l’entité");
    mod.setParameters(["entity"]);
    mod.addFunction(&_getAngle, "getAngle", [entityType], [grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Récupère l'accélération de l'entité");
    mod.setParameters(["entity"]);
    mod.addFunction(&_getAccel, "getAccel", [
            entityType
        ], [grFloat, grFloat, grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Change l'accélération de l'entité");
    mod.setParameters(["entity", "x", "y", "z"]);
    mod.addFunction(&_setAccel, "setAccel", [
            entityType, grFloat, grFloat, grFloat
        ]);

    mod.setDescription(GrLocale.fr_FR, "S’oriente vers une cible");
    mod.setParameters(["entity", "x", "y"]);
    mod.addFunction(&_lookAt_xy, "lookAt", [entityType, grInt, grInt]);

    mod.setDescription(GrLocale.fr_FR, "S’oriente vers une cible");
    mod.setParameters(["entity", "target"]);
    mod.addFunction(&_lookAt_entity, "lookAt", [entityType, entityType]);

    mod.addFunction(&_isEnabled, "isEnabled", [entityType], [grBool]);
    mod.addFunction(&_isOnGround, "isOnGround", [entityType], [grBool]);
    mod.addFunction(&_hasGraphic, "hasGraphic", [entityType, grString], [grBool]);
    mod.addFunction(&_getBaseMaterial, "getBaseMaterial", [entityType], [grInt]);
    mod.addFunction(&_setShadow, "setShadow", [entityType, grString]);
    mod.addFunction(&_setEffect, "setEffect", [entityType, graphicEffectType]);

    mod.setDescription(GrLocale.fr_FR, "Récupère le controleur de l’entité");
    mod.setParameters(["entity"]);
    mod.addFunction(&_getController, "getController", [entityType], [
            controllerType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Définit le controleur de l’entité");
    mod.setParameters(["entity", "id"]);
    mod.addFunction(&_setController, "setController", [entityType, grString], [
            controllerType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Récupère le comportement de l’entité");
    mod.setParameters(["entity"]);
    mod.addFunction(&_getBehavior, "getBehavior", [entityType], [
            behaviorType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Définit le comportement de l’entité");
    mod.setParameters(["entity", "id"]);
    mod.addFunction(&_setBehavior, "setBehavior", [entityType, grString], [
            behaviorType
        ]);
}

private void _ctor(GrCall call) {
    Entity entity = Atelier.res.get!Entity(call.getString(0));
    call.setNative(entity);
}

private void _unregister(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.unregister();
}

private void _isRegistered(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    call.setBool(entity.isRegistered());
}

private void _addTag(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.addTag(call.getString(1));
}

private void _hasTag(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    call.setBool(entity.hasTag(call.getString(1)));
}

private void _setGraphic(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.setGraphic(call.getString(1));
}

private void _getGraphic(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    EntityGraphic graphic = entity.getGraphic();
    if (graphic) {
        call.setNative(graphic);
    }
    else {
        call.setNull();
    }
}

private void _setLayer(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    Entity.Layer layer = call.getEnum!(Entity.Layer)(1);
    entity.setLayer(layer);
}

private void _setPosition(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.setPosition(Vec3i(call.getInt(1), call.getInt(2), call.getInt(3)));
}

private void _addPosition(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.addPosition(Vec3i(call.getInt(1), call.getInt(2), call.getInt(3)));
}

private void _setEnabled(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.setEnabled(call.getBool(1));
}

private void _setCollidable(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    Hurtbox hurtbox = entity.getHurtbox();
    hurtbox.isCollidable(call.getBool(1));
}

private void _getPosition(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    Vec3i position = entity.getPosition();
    call.setInt(position.x);
    call.setInt(position.y);
    call.setInt(position.z);
}

private void _setSpeed(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.setSpeed(call.getFloat(1), call.getFloat(2));
}

private void _addSpeed(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.addSpeed(call.getFloat(1), call.getFloat(2));
}

private void _setVelocity(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.setVelocity(Vec3f(call.getFloat(1), call.getFloat(2), call.getFloat(3)));
}

private void _addVelocity(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.addVelocity(Vec3f(call.getFloat(1), call.getFloat(2), call.getFloat(3)));
}

private void _setAngle(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.angle = call.getFloat(1);
}

private void _getAngle(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    call.setFloat(entity.angle);
}

private void _isEnabled(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    call.setBool(entity.isEnabled());
}

private void _getAccel(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    Vec3f accel = entity.getAccel();
    call.setFloat(accel.x);
    call.setFloat(accel.y);
    call.setFloat(accel.z);
}

private void _setAccel(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.setAccel(Vec3f(call.getFloat(1), call.getFloat(2), call.getFloat(3)));
}

private void _lookAt_xy(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    Vec2i target = Vec2i(call.getInt(1), call.getInt(2));
    entity.lookAt(target);
}

private void _lookAt_entity(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    Entity target = call.getNative!Entity(1);
    entity.lookAt(target);
}

private void _isOnGround(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    call.setBool(entity.isOnGround);
}

private void _hasGraphic(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    call.setBool(entity.hasGraphic(call.getString(1)));
}

private void _getBaseMaterial(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    call.setInt(entity.getBaseMaterial);
}

private void _setShadow(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.setShadow(call.getString(1));
}

private void _setEffect(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    EntityGraphicEffect effect = call.getNative!EntityGraphicEffect(1);
    entity.setEffect(effect);
}

private void _getController(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    call.setNative(entity.getController());
}

private void _setController(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    string id = call.getString(1);
    call.setNative(entity.setController(id));
}

private void _getBehavior(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    call.setNative(entity.getBehavior());
}

private void _setBehavior(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    string id = call.getString(1);
    call.setNative(entity.setBehavior(id));
}
