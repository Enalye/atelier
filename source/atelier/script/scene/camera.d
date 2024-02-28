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
    library.setModuleExample(GrLocale.fr_FR, "");

    GrType cameraType = library.addNative("Camera");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType splineType = grGetEnumType("Spline");
    GrType entityType = grGetNativeType("Entity");

    library.addStatic(&_getPosition, cameraType, "getPosition", [], [vec2fType]);
    library.addStatic(&_setPosition, cameraType, "setPosition", [vec2fType]);
    library.addStatic(&_moveTo, cameraType, "moveTo", [
            vec2fType, grUInt, splineType
        ]);
    library.addStatic(&_follow, cameraType, "follow", [
            entityType, vec2fType, vec2fType
        ]);
    library.addStatic(&_stop, cameraType, "stop");
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
