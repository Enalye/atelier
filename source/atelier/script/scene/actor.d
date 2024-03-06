/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.scene.actor;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.scene;
import atelier.script.util;

package void loadLibScene_actor(GrLibDefinition library) {
    library.setModule("scene.actor");
    library.setModuleInfo(GrLocale.fr_FR, "Acteur physique d’une scène");

    GrType actorType = library.addNative("Actor", [], "Collider");
    GrType collisionDataType = grGetNativeType("CollisionData");
    GrType solidType = grGetNativeType("Solid");

    library.addConstructor(&_ctor, actorType);

    library.setDescription(GrLocale.fr_FR,
        "Déplace horizontalement l’acteur et retourne des informations de collision si un solide est touché.");
    library.setParameters(["actor", "x"]);
    library.addFunction(&_moveX, "moveX", [actorType, grFloat], [
            grOptional(collisionDataType)
        ]);

    library.setDescription(GrLocale.fr_FR,
        "Déplace verticalement l’acteur et retourne des informations de collision si un solide est touché.");
    library.setParameters(["actor", "y"]);
    library.addFunction(&_moveY, "moveY", [actorType, grFloat], [
            grOptional(collisionDataType)
        ]);

    library.setDescription(GrLocale.fr_FR, "Attache l’acteur au solide");
    library.setParameters(["actor", "solid"]);
    library.addFunction(&_mount, "mount", [actorType, solidType]);

    library.setDescription(GrLocale.fr_FR, "Détache l’acteur du solide");
    library.setParameters(["actor"]);
    library.addFunction(&_dismount, "dismount", [actorType]);
}

private void _ctor(GrCall call) {
    call.setNative(new Actor);
}

private void _moveX(GrCall call) {
    Actor actor = call.getNative!Actor(0);
    float movement = call.getFloat(1);
    CollisionData collData = actor.moveX(movement);

    if (collData) {
        call.setNative(collData);
    }
    else {
        call.setNull();
    }
}

private void _moveY(GrCall call) {
    Actor actor = call.getNative!Actor(0);
    float movement = call.getFloat(1);
    CollisionData collData = actor.moveY(movement);

    if (collData) {
        call.setNative(collData);
    }
    else {
        call.setNull();
    }
}

private void _mount(GrCall call) {
    Actor actor = call.getNative!Actor(0);
    Solid solid = call.getNative!Solid(1);
    actor.mount(solid);
}

private void _dismount(GrCall call) {
    Actor actor = call.getNative!Actor(0);
    actor.dismount();
}
