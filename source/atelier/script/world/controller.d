module atelier.script.world.controller;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world;
import atelier.script.util;

package void loadLibWorld_controller(GrModule mod) {
    mod.setModule("world.controller");
    mod.setModuleInfo(GrLocale.fr_FR, "Définit un acteur");

    GrType controllerType = mod.addNative("EntityController");
}
