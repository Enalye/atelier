/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.scene.solid;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.scene;
import atelier.script.util;

package void loadLibScene_solid(GrModule mod) {
    mod.setModule("scene.solid");
    mod.setModuleInfo(GrLocale.fr_FR, "Obstacle physique aux acteurs d’une scène.");

    GrType solidType = mod.addNative("Solid", [], "Collider");
    GrType collisionType = grGetNativeType("Collision");

    mod.addConstructor(&_ctor, solidType);

    mod.setDescription(GrLocale.fr_FR, "Déplace le solide.");
    mod.setParameters(["solid", "x", "y"]);
    mod.addFunction(&_move, "move", [solidType, grFloat, grFloat], [
            grList(collisionType)
        ]);
}

private void _ctor(GrCall call) {
    call.setNative(new Solid);
}

private void _move(GrCall call) {
    Solid solid = call.getNative!Solid(0);
    float x = call.getFloat(1);
    float y = call.getFloat(2);

    GrList list = new GrList;
    list.setNatives(solid.move(x, y));
    call.setList(list);
}
