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

package void loadLibScene_entity(GrLibDefinition library) {
    library.setModule("scene.entity");
    library.setModuleInfo(GrLocale.fr_FR, "Élément d’une scène");
    library.setModuleExample(GrLocale.fr_FR, "var player = @Entity;
player.addImage(@Sprite(\"player\"));
scene.addEntity(player);");

    GrType entityType = library.addNative("Entity");
    GrType imageType = grGetNativeType("Image");
    GrType audioComponentType = grGetNativeType("AudioComponent");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    library.addConstructor(&_ctor, entityType);

    library.addProperty(&_name!"get", &_name!"set", "name", entityType, grString);
    library.addProperty(&_position!"get", &_position!"set", "position", entityType, vec2fType);

    library.addProperty(&_audio, null, "audio", entityType, audioComponentType);

    library.setDescription(GrLocale.fr_FR, "Récupère les tags de l’entité");
    library.setParameters(["scene"]);
    library.addFunction(&_getTags, "getTags", [entityType]);

    library.setDescription(GrLocale.fr_FR, "Ajoute un tag à l’entité");
    library.setParameters(["scene", "tag"]);
    library.addFunction(&_addTag, "addTag", [entityType, grString]);

    library.setDescription(GrLocale.fr_FR, "Vérifie si l’entité possède le tag");
    library.setParameters(["scene", "tag"]);
    library.addFunction(&_hasTag, "hasTag", [entityType, grString], [grBool]);

    library.setDescription(GrLocale.fr_FR,
        "Ajoute une entité en tant qu’enfant de cette entité");
    library.setParameters(["parent", "child"]);
    library.addFunction(&_addChild, "addChild", [entityType, entityType]);

    library.setDescription(GrLocale.fr_FR, "Ajoute une image à l’entité");
    library.setParameters(["entity", "image"]);
    library.addFunction(&_addImage, "addImage", [entityType, imageType]);
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
