module atelier.script.world.proxy;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world;
import atelier.script.util;

package void loadLibWorld_proxy(GrModule mod) {
    mod.setModule("world.proxy");
    mod.setModuleInfo(GrLocale.fr_FR, "Définit un proxy");

    GrType proxyType = mod.addNative("Proxy", [], "Entity");
    GrType entityType = grGetNativeType("Entity");

    mod.setDescription(GrLocale.fr_FR, "Crée un proxy");
    mod.setParameters(["rid"]);
    mod.addConstructor(&_ctor, proxyType, [grString]);

    mod.setDescription(GrLocale.fr_FR, "Attache le proxy à l’entité");
    mod.setParameters(["proxy", "entity"]);
    mod.addFunction(&_attachTo, "attachTo", [proxyType, entityType]);

    mod.setDescription(GrLocale.fr_FR, "Position relative à l’entité");
    mod.setParameters(["proxy", "x", "y", "z"]);
    mod.addFunction(&_setRelativePosition, "setRelativePosition", [
            proxyType, grFloat, grFloat, grFloat
        ]);

    mod.setDescription(GrLocale.fr_FR, "Décalage de l’entité en coordonnées polaires");
    mod.setParameters(["proxy", "dist"]);
    mod.addFunction(&_setRelativeDistance, "setRelativeDistance", [
            proxyType, grFloat
        ]);

    mod.setDescription(GrLocale.fr_FR, "Décalage de l’entité en coordonnées polaires");
    mod.setParameters(["proxy", "angle"]);
    mod.addFunction(&_setRelativeAngle, "setRelativeAngle", [
            proxyType, grFloat
        ]);
}

private void _ctor(GrCall call) {
    Proxy proxy = Atelier.res.get!Proxy(call.getString(0));
    call.setNative(proxy);
}

private void _attachTo(GrCall call) {
    Proxy proxy = call.getNative!Proxy(0);
    Entity entity = call.getNative!Entity(1);
    proxy.attachTo(entity);
}

private void _setRelativePosition(GrCall call) {
    Proxy proxy = call.getNative!Proxy(0);
    proxy.setRelativePosition(Vec3f(
            call.getFloat(1),
            call.getFloat(2),
            call.getFloat(3)));
}

private void _setRelativeDistance(GrCall call) {
    Proxy proxy = call.getNative!Proxy(0);
    proxy.setRelativeDistance(call.getFloat(1));
}

private void _setRelativeAngle(GrCall call) {
    Proxy proxy = call.getNative!Proxy(0);
    proxy.setRelativeAngle(call.getFloat(1));
}
