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
    GrType vec2iType = grGetNativeType("Vec2", [grInt]);
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType collisionDataType = grGetNativeType("CollisionData");

    GrType onCollisionType = grEvent([collisionDataType]);

    library.addConstructor(&_ctor, actorType);

    library.addProperty(&_onSquish!"get", &_onSquish!"set", "onSquish",
        actorType, grOptional(onCollisionType));

    library.setDescription(GrLocale.fr_FR,
        "Déplace horizontalement l’acteur et appelle `onCollision` si un solide est touché.");
    library.setParameters(["actor", "x", "onCollision"]);
    library.addFunction(&_moveX, "moveX", [
            actorType, grFloat, grOptional(grEvent([collisionDataType]))
        ]);

    library.setDescription(GrLocale.fr_FR,
        "Déplace verticalement l’acteur et appelle `onCollision` si un solide est touché.");
    library.setParameters(["actor", "y", "onCollision"]);
    library.addFunction(&_moveY, "moveY", [
            actorType, grFloat, grOptional(grEvent([collisionDataType]))
        ]);
}

private void _ctor(GrCall call) {
    call.setNative(new Actor);
}

private void _onSquish(string op)(GrCall call) {
    Actor actor = call.getNative!Actor(0);

    static if (op == "set") {
        if (call.isNull(1)) {
            actor.onSquish = null;
        }
        else {
            actor.onSquish = call.getEvent(1);
        }
    }

    if (actor.onSquish) {
        call.setEvent(actor.onSquish);
    }
    else {
        call.setNull();
    }
}

private void _moveX(GrCall call) {
    Actor actor = call.getNative!Actor(0);
    float movement = call.getFloat(1);

    if (call.isNull(2)) {
        actor.moveX(movement, null);
    }
    else {
        GrEvent event = call.getEvent(2);
        actor.moveX(movement, event);
    }
}

private void _moveY(GrCall call) {
    Actor actor = call.getNative!Actor(0);
    float movement = call.getFloat(1);

    if (call.isNull(2)) {
        actor.moveY(movement, null);
    }
    else {
        GrEvent event = call.getEvent(2);
        actor.moveY(movement, event);
    }
}
