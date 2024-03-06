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

package void loadLibScene_collider(GrLibDefinition library) {
    library.setModule("scene.collider");
    library.setModuleInfo(GrLocale.fr_FR, "Objet physique d’une scène");

    GrType colliderType = library.addNative("Collider");
    GrType solidType = grGetNativeType("Solid");
    GrType vec2iType = grGetNativeType("Vec2", [grInt]);
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType entityType = grGetNativeType("Entity");

    GrType collisionType = library.addNative("Collision");

    library.addProperty(&_solid_collision, null, "solid", collisionType, solidType);
    library.addProperty(&_direction_collision, null, "direction", collisionType, vec2iType);

    library.addProperty(&_name!"get", &_name!"set", "name", colliderType, grString);
    library.addProperty(&_position!"get", &_position!"set", "position",
        colliderType, vec2iType);
    library.addProperty(&_hitbox!"get", &_hitbox!"set", "hitbox", colliderType, vec2iType);
    library.addProperty(&_isAlive, null, "isAlive", colliderType, grBool);

    library.setDescription(GrLocale.fr_FR, "Entité lié à l’objet");
    library.addProperty(&_entity!"get", &_entity!"set", "entity",
        colliderType, grOptional(entityType));

    library.setDescription(GrLocale.fr_FR, "Récupère les tags de l’objet");
    library.setParameters(["collider"]);
    library.addFunction(&_getTags, "getTags", [colliderType]);

    library.setDescription(GrLocale.fr_FR, "Ajoute un tag à l’objet");
    library.setParameters(["collider", "tag"]);
    library.addFunction(&_addTag, "addTag", [colliderType, grString]);

    library.setDescription(GrLocale.fr_FR, "Vérifie si l’objet possède le tag");
    library.setParameters(["collider", "tag"]);
    library.addFunction(&_hasTag, "hasTag", [colliderType, grString], [grBool]);

    library.setDescription(GrLocale.fr_FR, "Supprime l’objet");
    library.setParameters(["collider"]);
    library.addFunction(&_remove, "remove", [colliderType]);
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
