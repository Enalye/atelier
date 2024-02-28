/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.scene.camera;

import grimoire;
import atelier.common;
import atelier.core;
import atelier.scene;
import atelier.script.util;

package void loadLibScene_camera(GrLibDefinition library) {
    library.setModule("scene.camera");
    library.setModuleInfo(GrLocale.fr_FR, "Point de vue du joueur");
    library.setModuleExample(GrLocale.fr_FR, "@Camera.follow(player, @Vec2f(1f, 0.2f), @Vec2f(0f, 100f));
@Camera.zoom(1f, 120, Spline.sineInOut);");

    GrType cameraType = library.addNative("Camera");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType splineType = grGetEnumType("Spline");
    GrType entityType = grGetNativeType("Entity");

    library.setDescription(GrLocale.fr_FR, "Récupère la position de la caméra");
    library.setParameters();
    library.addStatic(&_getPosition, cameraType, "getPosition", [], [vec2fType]);

    library.setDescription(GrLocale.fr_FR, "Déplace instantanément la caméra");
    library.setParameters(["position"]);
    library.addStatic(&_setPosition, cameraType, "setPosition", [vec2fType]);

    library.setDescription(GrLocale.fr_FR, "Déplace la caméra vers la position");
    library.setParameters(["position", "frames", "spline"]);
    library.addStatic(&_moveTo, cameraType, "moveTo", [
            vec2fType, grUInt, splineType
        ]);

    library.setDescription(GrLocale.fr_FR, "Déplace la caméra en suivant une cible");
    library.setParameters(["target", "damping", "deadzone"]);
    library.addStatic(&_follow, cameraType, "follow", [
            entityType, vec2fType, vec2fType
        ]);

    library.setDescription(GrLocale.fr_FR, "Arrête la caméra");
    library.setParameters();
    library.addStatic(&_stop, cameraType, "stop");

    library.setDescription(GrLocale.fr_FR, "Change le zoom de la caméra");
    library.setParameters(["zoomLevel", "frames", "spline"]);
    library.addStatic(&_zoom, cameraType, "zoom", [grFloat, grUInt, splineType]);

    library.setDescription(GrLocale.fr_FR, "Secoue temporairement la caméra");
    library.setParameters(["trauma"]);
    library.addStatic(&_shake, cameraType, "shake", [grFloat]);

    library.setDescription(GrLocale.fr_FR, "Fait trembler la caméra");
    library.setParameters(["trauma", "frames", "spline"]);
    library.addStatic(&_rumble, cameraType, "rumble", [
            grFloat, grUInt, splineType
        ]);
}

private void _getPosition(GrCall call) {
    call.setNative(svec2(Atelier.scene.camera.getPosition()));
}

private void _setPosition(GrCall call) {
    Atelier.scene.camera.setPosition(call.getNative!SVec2f(0));
}

private void _moveTo(GrCall call) {
    Atelier.scene.camera.moveTo(call.getNative!SVec2f(0), call.getUInt(1),
        call.getEnum!Spline(2));
}

private void _follow(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    Vec2f damping = call.getNative!SVec2f(1);
    Vec2f deadZone = call.getNative!SVec2f(2);
    Atelier.scene.camera.follow(entity, damping, deadZone);
}

private void _stop(GrCall call) {
    Atelier.scene.camera.stop();
}

private void _zoom(GrCall call) {
    Atelier.scene.camera.zoom(call.getFloat(0), call.getUInt(1), call.getEnum!Spline(2));
}

private void _shake(GrCall call) {
    Atelier.scene.camera.shake(call.getFloat(0));
}

private void _rumble(GrCall call) {
    Atelier.scene.camera.rumble(call.getFloat(0), call.getUInt(1), call.getEnum!Spline(2));
}
