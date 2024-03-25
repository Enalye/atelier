/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.scene.entity;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.scene;
import atelier.render;
import atelier.script.util;

package void loadLibScene_entity(GrModule mod) {
    mod.setModule("scene.entity");
    mod.setModuleInfo(GrLocale.fr_FR, "Élément d’une scène");
    mod.setModuleExample(GrLocale.fr_FR, "var player = @Entity;
player.addImage(@Sprite(\"player\"));
scene.addEntity(player);");

    GrType entityType = mod.addNative("Entity");
    GrType imageType = grGetNativeType("Image");
    GrType canvasType = grGetNativeType("Canvas");
    GrType spriteType = grGetNativeType("Sprite");
    GrType audioComponentType = grGetNativeType("AudioComponent");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    mod.addConstructor(&_ctor, entityType);

    mod.addProperty(&_name!"get", &_name!"set", "name", entityType, grString);
    mod.addProperty(&_position!"get", &_position!"set", "position", entityType, vec2fType);
    mod.addProperty(&_zOrder!"get", &_zOrder!"set", "zOrder", entityType, grInt);
    mod.addProperty(&_isVisible!"get", &_isVisible!"set", "isVisible", entityType, grBool);

    mod.addProperty(&_audio, null, "audio", entityType, audioComponentType);

    mod.setDescription(GrLocale.fr_FR, "Récupère les tags de l’entité");
    mod.setParameters(["entity"]);
    mod.addFunction(&_getTags, "getTags", [entityType]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute un tag à l’entité");
    mod.setParameters(["entity", "tag"]);
    mod.addFunction(&_addTag, "addTag", [entityType, grString]);

    mod.setDescription(GrLocale.fr_FR, "Vérifie si l’entité possède le tag");
    mod.setParameters(["entity", "tag"]);
    mod.addFunction(&_hasTag, "hasTag", [entityType, grString], [grBool]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute une entité en tant qu’enfant de cette entité");
    mod.setParameters(["parent", "child"]);
    mod.addFunction(&_addChild, "addChild", [entityType, entityType]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute une image à l’entité");
    mod.setParameters(["entity", "image"]);
    mod.addFunction(&_addImage, "addImage", [entityType, imageType]);

    mod.setDescription(GrLocale.fr_FR, "Crée un canvas de rendu de l’entité");
    mod.setParameters(["entity", "width", "height"]);
    mod.addFunction(&_setCanvas, "setCanvas", [entityType, grUInt, grUInt]);

    mod.setDescription(GrLocale.fr_FR, "Retourne le canvas de rendu de l’entité");
    mod.setParameters(["entity"]);
    mod.addFunction(&_getCanvas, "getCanvas", [
            entityType, grOptional(canvasType)
        ]);

    mod.setDescription(GrLocale.fr_FR, "Retourne le sprite du canvas de rendu de l’entité");
    mod.setParameters(["entity"]);
    mod.addFunction(&_getSprite, "getSprite", [
            entityType, grOptional(spriteType)
        ]);

    mod.setDescription(GrLocale.fr_FR, "Supprime le canvas de l’entité");
    mod.setParameters(["entity"]);
    mod.addFunction(&_removeCanvas, "removeCanvas", [entityType]);

    mod.setDescription(GrLocale.fr_FR, "Supprime l’entité");
    mod.setParameters(["entity"]);
    mod.addFunction(&_remove, "remove", [entityType]);
}

private void _ctor(GrCall call) {
    call.setNative(new Entity);
}

private void _name(string op)(GrCall call) {
    Entity entity = call.getNative!Entity(0);

    static if (op == "set") {
        entity.name = call.getString(1);
    }
    call.setString(entity.name);
}

private void _position(string op)(GrCall call) {
    Entity entity = call.getNative!Entity(0);

    static if (op == "set") {
        entity.position = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(entity.position));
}

private void _zOrder(string op)(GrCall call) {
    Entity entity = call.getNative!Entity(0);

    static if (op == "set") {
        entity.zOrder = call.getInt(1);
    }
    call.setInt(entity.zOrder);
}

private void _isVisible(string op)(GrCall call) {
    Entity entity = call.getNative!Entity(0);

    static if (op == "set") {
        entity.isVisible = call.getBool(1);
    }
    call.setBool(entity.isVisible);
}

private void _audio(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    AudioComponent audioComponent = entity.getComponent!AudioComponent();
    call.setNative(audioComponent);
}

private void _getTags(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    GrList list = new GrList;
    list.setStrings(entity.tags);
    call.setList(list);
}

private void _addTag(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    string tag = call.getString(1);

    foreach (entityTag; entity.tags) {
        if (entityTag == tag) {
            return;
        }
    }

    entity.tags ~= tag;
}

private void _hasTag(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    string tag = call.getString(1);

    foreach (entityTag; entity.tags) {
        if (entityTag == tag) {
            call.setBool(true);
            return;
        }
    }
    call.setBool(false);
}

private void _addChild(GrCall call) {
    Entity parent = call.getNative!Entity(0);
    Entity child = call.getNative!Entity(1);
    parent.addChild(child);
}

private void _addImage(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    Image image = call.getNative!Image(1);
    entity.addImage(image);
}

private void _setCanvas(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.setCanvas(call.getUInt(1), call.getUInt(2));
}

private void _getCanvas(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    Canvas canvas = entity.getCanvas();
    if (canvas) {
        call.setNative(canvas);
        return;
    }
    call.setNull();
}

private void _getSprite(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    Sprite sprite = entity.getSprite();
    if (sprite) {
        call.setNative(sprite);
        return;
    }
    call.setNull();
}

private void _removeCanvas(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.removeCanvas();
}

private void _remove(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.remove();
}
