module atelier.script.world.component;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world;
import atelier.script.util;

package void loadLibWorld_component(GrModule mod) {
    mod.setModule("world.component");
    mod.setModuleInfo(GrLocale.fr_FR, "Définit un composant");

    GrType componentType = mod.addNative("EntityComponent");
    GrType entityType = grGetNativeType("Entity");
}
