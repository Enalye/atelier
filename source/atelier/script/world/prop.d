module atelier.script.world.prop;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world;
import atelier.script.util;

package void loadLibWorld_prop(GrModule mod) {
    mod.setModule("world.prop");
    mod.setModuleInfo(GrLocale.fr_FR, "Définit un élément du décors");

    GrType propType = mod.addNative("Prop", [], "Entity");

    mod.setDescription(GrLocale.fr_FR, "Crée un objet");
    mod.setParameters(["rid"]);
    mod.addConstructor(&_ctor, propType, [grString]);
}

private void _ctor(GrCall call) {
    Prop prop = Atelier.res.get!Prop(call.getString(0));
    call.setNative(prop);
}
