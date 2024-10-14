/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.scene.collider;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.scene;
import atelier.script.util;
/*
package void loadLibScene_collider(GrModule mod) {
    mod.setModule("scene.collider");
    mod.setModuleInfo(GrLocale.fr_FR, "Objet physique d’une scène");

    GrType colliderType = mod.addNative("Collider");
    GrType solidType = grGetNativeType("Solid");
    GrType vec2iType = grGetNativeType("Vec2", [grInt]);
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType entityType = grGetNativeType("Entity");

    GrType collisionType = mod.addNative("Collision");

    mod.addProperty(&_solid_collision, null, "solid", collisionType, solidType);
    mod.addProperty(&_direction_collision, null, "direction", collisionType, vec2iType);

    mod.addProperty(&_name!"get", &_name!"set", "name", colliderType, grString);
    mod.addProperty(&_position!"get", &_position!"set", "position", colliderType, vec2iType);
    mod.addProperty(&_hitbox!"get", &_hitbox!"set", "hitbox", colliderType, vec2iType);
    mod.addProperty(&_isAlive, null, "isAlive", colliderType, grBool);

    mod.setDescription(GrLocale.fr_FR, "Entité lié à l’objet");
    mod.addProperty(&_entity!"get", &_entity!"set", "entity", colliderType,
        grOptional(entityType));

    mod.setDescription(GrLocale.fr_FR, "Récupère les tags de l’objet");
    mod.setParameters(["collider"]);
    mod.addFunction(&_getTags, "getTags", [colliderType]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute un tag à l’objet");
    mod.setParameters(["collider", "tag"]);
    mod.addFunction(&_addTag, "addTag", [colliderType, grString]);

    mod.setDescription(GrLocale.fr_FR, "Vérifie si l’objet possède le tag");
    mod.setParameters(["collider", "tag"]);
    mod.addFunction(&_hasTag, "hasTag", [colliderType, grString], [grBool]);

    mod.setDescription(GrLocale.fr_FR, "Supprime l’objet");
    mod.setParameters(["collider"]);
    mod.addFunction(&_remove, "remove", [colliderType]);
}

private void _solid_collision(GrCall call) {
    Collision collision = call.getNative!Collision(0);
    call.setNative(collision.solid);
}

private void _direction_collision(GrCall call) {
    Collision collision = call.getNative!Collision(0);
    call.setNative(svec2(collision.direction));
}

private void _name(string op)(GrCall call) {
    Collider collider = call.getNative!Collider(0);

    static if (op == "set") {
        collider.name = call.getString(1);
    }
    call.setString(collider.name);
}

private void _position(string op)(GrCall call) {
    Collider collider = call.getNative!Collider(0);

    static if (op == "set") {
        collider.position = call.getNative!SVec2i(1);
    }
    call.setNative(svec2(collider.position));
}

private void _hitbox(string op)(GrCall call) {
    Collider collider = call.getNative!Collider(0);

    static if (op == "set") {
        collider.hitbox = call.getNative!SVec2i(1);
    }
    call.setNative(svec2(collider.hitbox));
}

private void _isAlive(GrCall call) {
    Collider collider = call.getNative!Collider(0);
    call.setBool(collider.isAlive);
}

private void _getTags(GrCall call) {
    Collider collider = call.getNative!Collider(0);
    GrList list = new GrList;
    list.setStrings(collider.tags);
    call.setList(list);
}

private void _addTag(GrCall call) {
    Collider collider = call.getNative!Collider(0);
    string tag = call.getString(1);

    foreach (colliderTag; collider.tags) {
        if (colliderTag == tag) {
            return;
        }
    }

    collider.tags ~= tag;
}

private void _hasTag(GrCall call) {
    Collider collider = call.getNative!Collider(0);
    string tag = call.getString(1);

    foreach (colliderTag; collider.tags) {
        if (colliderTag == tag) {
            call.setBool(true);
            return;
        }
    }
    call.setBool(false);
}

private void _remove(GrCall call) {
    Collider collider = call.getNative!Collider(0);
    collider.remove();
}

private void _entity(string op)(GrCall call) {
    Collider collider = call.getNative!Collider(0);

    static if (op == "set") {
        if (call.isNull(1)) {
            collider.entity = null;
        }
        else {
            collider.entity = call.getNative!Entity(1);
        }
    }

    if (collider.entity) {
        call.setNative(collider.entity);
    }
    else {
        call.setNull();
    }
}
*/