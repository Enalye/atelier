/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.world.camera;

import grimoire;
import atelier.common;
import atelier.core;
import atelier.world;
import atelier.script.util;

package void loadLibWorld_camera(GrModule mod) {
    mod.setModule("world.camera");
    mod.setModuleInfo(GrLocale.fr_FR, "Point de vue du joueur");
    mod.setModuleExample(GrLocale.fr_FR,
        "@Camera.follow(player, @Vec2f(1f, 0.2f), @Vec2f(0f, 100f));
@Camera.zoom(1f, 120, Spline.sineInOut);");

    GrType cameraType = mod.addNative("Camera");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType splineType = grGetEnumType("Spline");
    GrType entityType = grGetNativeType("Entity");

    mod.setDescription(GrLocale.fr_FR, "Récupère la position de la caméra");
    mod.setParameters();
    mod.addStatic(&_getPosition, cameraType, "getPosition", [], [vec2fType]);

    mod.setDescription(GrLocale.fr_FR, "Déplace instantanément la caméra");
    mod.setParameters(["position"]);
    mod.addStatic(&_setPosition, cameraType, "setPosition", [vec2fType]);

    mod.setDescription(GrLocale.fr_FR, "Déplace la caméra vers la position");
    mod.setParameters(["position", "frames", "spline"]);
    mod.addStatic(&_moveTo, cameraType, "moveTo", [
            vec2fType, grUInt, splineType
        ]);
/*
    mod.setDescription(GrLocale.fr_FR, "Déplace la caméra en suivant une cible");
    mod.setParameters(["target", "damping", "deadzone"]);
    mod.addStatic(&_follow, cameraType, "follow", [
            entityType, vec2fType, vec2fType
        ]);*/

    mod.setDescription(GrLocale.fr_FR, "Arrête la caméra");
    mod.setParameters();
    mod.addStatic(&_stop, cameraType, "stop");

    mod.setDescription(GrLocale.fr_FR, "Change le zoom de la caméra");
    mod.setParameters(["zoomLevel", "frames", "spline"]);
    mod.addStatic(&_zoom, cameraType, "zoom", [grFloat, grUInt, splineType]);

    mod.setDescription(GrLocale.fr_FR, "Secoue temporairement la caméra");
    mod.setParameters(["trauma"]);
    mod.addStatic(&_shake, cameraType, "shake", [grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Fait trembler la caméra");
    mod.setParameters(["trauma", "frames", "spline"]);
    mod.addStatic(&_rumble, cameraType, "rumble", [grFloat, grUInt, splineType]);
}

private void _getPosition(GrCall call) {
    call.setNative(svec2(Atelier.world.camera.getPosition()));
}

private void _setPosition(GrCall call) {
    Atelier.world.camera.setPosition(call.getNative!SVec2f(0));
}

private void _moveTo(GrCall call) {
    Atelier.world.camera.moveTo(call.getNative!SVec2f(0), call.getUInt(1),
        call.getEnum!Spline(2));
}
/*
private void _follow(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    Vec2f damping = call.getNative!SVec2f(1);
    Vec2f deadZone = call.getNative!SVec2f(2);
    Atelier.world.camera.follow(entity, damping, deadZone);
}*/

private void _stop(GrCall call) {
    Atelier.world.camera.stop();
}

private void _zoom(GrCall call) {
    Atelier.world.camera.zoom(call.getFloat(0), call.getUInt(1), call.getEnum!Spline(2));
}

private void _shake(GrCall call) {
    Atelier.world.camera.shake(call.getFloat(0));
}

private void _rumble(GrCall call) {
    Atelier.world.camera.rumble(call.getFloat(0), call.getUInt(1), call.getEnum!Spline(2));
}
