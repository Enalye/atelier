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

package void loadLibScene_solid(GrLibDefinition library) {
    library.setModule("scene.solid");
    library.setModuleInfo(GrLocale.fr_FR, "Obstacle physique aux acteurs d’une scène.");

    GrType solidType = library.addNative("Solid", [], "Collider");

    library.addConstructor(&_ctor, solidType);

    library.setDescription(GrLocale.fr_FR, "Déplace le solide.");
    library.setParameters(["solid", "x", "y"]);
    library.addFunction(&_move, "move", [solidType, grFloat, grFloat]);
}

private void _ctor(GrCall call) {
    call.setNative(new Solid);
}

private void _move(GrCall call) {
    Solid solid = call.getNative!Solid(0);
    float x = call.getFloat(1);
    float y = call.getFloat(2);
    solid.move(x, y);
}
