module atelier.script.world.actor;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world;
import atelier.script.util;

package void loadLibWorld_actor(GrModule mod) {
    mod.setModule("world.actor");
    mod.setModuleInfo(GrLocale.fr_FR, "Définit un acteur");

    GrType actorType = mod.addNative("Actor", [], "Entity");

    mod.setDescription(GrLocale.fr_FR, "Crée un acteur");
    mod.setParameters(["rid"]);
    mod.addConstructor(&_ctor, actorType, [grString]);

    mod.addFunction(&_setGravity, "setGravity", [
            actorType, grFloat
        ]);
}

private void _ctor(GrCall call) {
    Actor actor = Atelier.res.get!Actor(call.getString(0));
    call.setNative(actor);
}

private void _setGravity(GrCall call) {
    Actor actor = call.getNative!Actor(0);
    actor.setGravity(call.getFloat(1));
}