module atelier.script.world.behavior;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world;
import atelier.script.util;

package void loadLibWorld_behavior(GrModule mod) {
    mod.setModule("world.behavior");
    mod.setModuleInfo(GrLocale.fr_FR, "Définit un acteur");

    GrType behaviorType = mod.addNative("EntityBehavior");
    GrType unitType = mod.addNative("UnitBehavior", [], "EntityBehavior");
    GrType proxyType = mod.addNative("ProxyBehavior", [], "EntityBehavior");
    GrType entityType = grGetNativeType("Entity");

    mod.addFunction(&_setGravity, "setGravity", [
            unitType, grFloat
        ]);
    mod.addFunction(&_setFrictionBrake, "setFrictionBrake", [
            unitType, grFloat
        ]);

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

    mod.addCast(&_as_proxy, behaviorType, grOptional(proxyType), true);
}

private void _setFrictionBrake(GrCall call) {
    UnitBehavior unit = call.getNative!UnitBehavior(0);
    unit.setFrictionBrake(call.getFloat(1));
}

private void _setGravity(GrCall call) {
    UnitBehavior unit = call.getNative!UnitBehavior(0);
    unit.setGravity(call.getFloat(1));
}

private void _attachTo(GrCall call) {
    ProxyBehavior proxy = call.getNative!ProxyBehavior(0);
    proxy.attachTo(call.getNative!Entity(1));
}

private void _setRelativePosition(GrCall call) {
    ProxyBehavior proxy = call.getNative!ProxyBehavior(0);
    proxy.setRelativePosition(Vec3f(
            call.getFloat(1),
            call.getFloat(2),
            call.getFloat(3)));
}

private void _setRelativeDistance(GrCall call) {
    ProxyBehavior proxy = call.getNative!ProxyBehavior(0);
    proxy.setRelativeDistance(call.getFloat(1));
}

private void _setRelativeAngle(GrCall call) {
    ProxyBehavior proxy = call.getNative!ProxyBehavior(0);
    proxy.setRelativeAngle(call.getFloat(1));
}

private void _as_proxy(GrCall call) {
    EntityBehavior behavior = call.getNative!EntityBehavior(0);
    ProxyBehavior proxy = cast(ProxyBehavior) behavior;

    if (proxy)
        call.setNative(proxy);
    else
        call.setNull();
}
