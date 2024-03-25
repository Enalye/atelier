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

package void loadLibScene_actor(GrModule mod) {
    mod.setModule("scene.actor");
    mod.setModuleInfo(GrLocale.fr_FR, "Acteur physique d’une scène");

    GrType actorType = mod.addNative("Actor", [], "Collider");
    GrType collisionType = grGetNativeType("Collision");
    GrType solidType = grGetNativeType("Solid");

    mod.addConstructor(&_ctor, actorType);

    mod.setDescription(GrLocale.fr_FR,
        "Déplace horizontalement l’acteur et retourne des informations de collision si un solide est touché.");
    mod.setParameters(["actor", "x"]);
    mod.addFunction(&_moveX, "moveX", [actorType, grFloat], [
            grOptional(collisionType)
        ]);

    mod.setDescription(GrLocale.fr_FR,
        "Déplace verticalement l’acteur et retourne des informations de collision si un solide est touché.");
    mod.setParameters(["actor", "y"]);
    mod.addFunction(&_moveY, "moveY", [actorType, grFloat], [
            grOptional(collisionType)
        ]);

    mod.setDescription(GrLocale.fr_FR, "Attache l’acteur au solide");
    mod.setParameters(["actor", "solid"]);
    mod.addFunction(&_mount, "mount", [actorType, solidType]);

    mod.setDescription(GrLocale.fr_FR, "Détache l’acteur du solide");
    mod.setParameters(["actor"]);
    mod.addFunction(&_dismount, "dismount", [actorType]);
}

private void _ctor(GrCall call) {
    call.setNative(new Actor);
}

private void _moveX(GrCall call) {
    Actor actor = call.getNative!Actor(0);
    float movement = call.getFloat(1);
    Collision collision = actor.moveX(movement);

    if (collision) {
        call.setNative(collision);
    }
    else {
        call.setNull();
    }
}

private void _moveY(GrCall call) {
    Actor actor = call.getNative!Actor(0);
    float movement = call.getFloat(1);
    Collision collision = actor.moveY(movement);

    if (collision) {
        call.setNative(collision);
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
