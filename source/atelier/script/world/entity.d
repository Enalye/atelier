module atelier.script.world.entity;

import grimoire;

import atelier.common;
import atelier.core;
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
    GrType layerType = mod.addEnum("EntityLayer", grNativeEnum!(Entity.Layer)());

    mod.setDescription(GrLocale.fr_FR, "Retire l’entité");
    mod.setParameters(["entity"]);
    mod.addFunction(&_unregister, "unregister", [entityType]);

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

    mod.setDescription(GrLocale.fr_FR, "S’oriente vers une cible");
    mod.setParameters(["entity", "x", "y"]);
    mod.addFunction(&_lookAt_xy, "lookAt", [entityType, grInt, grInt]);

    mod.setDescription(GrLocale.fr_FR, "S’oriente vers une cible");
    mod.setParameters(["entity", "target"]);
    mod.addFunction(&_lookAt_entity, "lookAt", [entityType, entityType]);
}

private void _unregister(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.unregister();
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
