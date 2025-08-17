module atelier.script.world.shot;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world;
import atelier.script.util;

package void loadLibWorld_shot(GrModule mod) {
    mod.setModule("world.shot");
    mod.setModuleInfo(GrLocale.fr_FR, "Définit un tir");

    GrType shotType = mod.addNative("Shot", [], "Entity");

    mod.setDescription(GrLocale.fr_FR, "Crée un tir");
    mod.setParameters(["rid"]);
    mod.addConstructor(&_ctor, shotType, [grString]);
}

private void _ctor(GrCall call) {
    Shot shot = Atelier.res.get!Shot(call.getString(0));
    call.setNative(shot);
}
