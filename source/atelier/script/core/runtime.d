module atelier.script.core.runtime;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.script.util;

package void loadLibCore_runtime(GrModule library) {
    library.setModule("core.runtime");
    library.setModuleInfo(GrLocale.fr_FR, "Informations système");

    GrType appType = library.addNative("Atelier");

    GrType colorType = grGetNativeType("Color");
    GrType splineType = grGetEnumType("Spline");

    library.setDescription(GrLocale.fr_FR, "Algorithme de mise à l’échelle (voir: setScaling)");
    GrType scalingType = library.addEnum("Scaling", grNativeEnum!(Renderer.Scaling)());

    library.setDescription(GrLocale.fr_FR, "La largeur en pixel de l’écran.");
    library.addStatic(&_width, appType, "width", [], [grInt]);

    library.setDescription(GrLocale.fr_FR, "La hauteur en pixel de l’écran.");
    library.addStatic(&_height, appType, "height", [], [grInt]);

    library.setDescription(GrLocale.fr_FR, "La taille en pixel de l’écran.");
    library.addStatic(&_size, appType, "size", [], [grInt, grInt]);

    library.setDescription(GrLocale.fr_FR, "Les coordonnées du centre de l’écran.
Égal à `@Atelier.size() / 2`.");
    library.addStatic(&_center, appType, "center", [], [grInt, grInt]);

    library.setDescription(GrLocale.fr_FR,
        "Renvoie `true` si l’application est en mode exporté, `false` en mode développement.");
    library.addStatic(&_isRedist, appType, "isRedist", [], [grBool]);

    library.setDescription(GrLocale.fr_FR, "Facteur de netteté des pixels.
Plus cette valeur est grande, plus la qualité est grande mais plus le jeu sera gourmand en ressources graphiques.
Le canvas du jeu de base est d’abord multiplié par ce facteur, avant de passer à l’algorithme de mise à l’échelle.
Exemple:
    Un jeu qui a un canvas de 640×360 et un facteur de netteté de 2 sera rendu avec une résolution de 1280×720
    avant d’être mise à l’échelle de la fenêtre grace à la méthode de `setScaling`.");
    library.setParameters(["sharpness"]);
    library.addStatic(&_setPixelSharpness, appType, "setPixelSharpness", [
            grUInt
        ]);

    library.setDescription(GrLocale.fr_FR, "Applique un algorithme de mise à l’échelle.
- **Scaling.none**: aucun redimensionnement
- **Scaling.integer**: seul le facteur de `setPixelSharpness` est appliqué
- **Scaling.fit**: comme `integer`, puis mise à l’échelle de la fenêtre en respectant le ratio largeur/hauteur de l’écran. Peut induire des bandes noires sur les côtés.
- **Scaling.contain**: comme `fit`, mais en dépassant de la fenêtre afin d’éviter les bandes noires.
- **Scaling.stretch**: comme `integer`, puis redimensionnement à la taille de la fenêtre sans respecter le ratio");
    library.setParameters(["scaling"]);
    library.addStatic(&_setScaling, appType, "setScaling", [scalingType]);

    library.setDescription(GrLocale.fr_FR,
        "(En mode développement seulement) Relance l’application.
- `reloadResources` recharge les dossiers de ressources.
- `reloadScript` recompile le programme.");
    library.setParameters(["reloadResources", "reloadScript"]);
    library.addStatic(&_reload, appType, "reload", [grBool, grBool]);

    library.setDescription(GrLocale.fr_FR, "Ferme l’application.");
    library.setParameters();
    library.addStatic(&_close, appType, "close");

    library.setDescription(GrLocale.fr_FR, "Affiche les bordures cinématiques en haut et en bas de l’écran.");
    library.setParameters(["enable", "color", "duration"]);
    library.addStatic(&_setVignette, appType, "setVignette", [
            grBool, colorType, grUInt
        ]);

    library.setDescription(GrLocale.fr_FR, "Permet les transitions en fondu.");
    library.setParameters(["color", "alpha", "duration", "spline"]);
    library.addStatic(&_setOverlay, appType, "setOverlay", [
            colorType, grFloat, grUInt, splineType
        ]);

    library.setDescription(GrLocale.fr_FR, "Interromp la logique pendant quelques frames.");
    library.setParameters(["duration"]);
    library.addStatic(&_freeze, appType, "freeze", [grUInt]);

    library.setDescription(GrLocale.fr_FR, "Change la vitesse de la logique en pourcentage de 60fps.");
    library.setParameters(["timeScale"]);
    library.addStatic(&_setTimeScale, appType, "setTimeScale", [grFloat]);

    library.setDescription(GrLocale.fr_FR, "Applique un ralentissement temporaire de la logique.");
    library.setParameters([
        "factor", "inDuration", "outDuration", "inSpline", "outSpline"
    ]);
    library.addStatic(&_slowDown, appType, "slowDown", [
            grFloat, grUInt, grUInt, splineType, splineType
        ]);
}

private void _width(GrCall call) {
    call.setInt(Atelier.renderer.size.x);
}

private void _height(GrCall call) {
    call.setInt(Atelier.renderer.size.y);
}

private void _size(GrCall call) {
    const Vec2i size = Atelier.renderer.size;
    call.setInt(size.x);
    call.setInt(size.y);
}

private void _center(GrCall call) {
    const Vec2i center = Atelier.renderer.center;
    call.setInt(center.x);
    call.setInt(center.y);
}

private void _setPixelSharpness(GrCall call) {
    Atelier.renderer.setPixelSharpness(call.getUInt(0));
}

private void _setScaling(GrCall call) {
    Atelier.renderer.setScaling(call.getEnum!(Renderer.Scaling)(0));
}

private void _isRedist(GrCall call) {
    call.setBool(Atelier.isRedist());
}

private void _reload(GrCall call) {
    Atelier.reload(call.getBool(0), call.getBool(1));
}

private void _close(GrCall call) {
    Atelier.close();
}

private void _setVignette(GrCall call) {
    Atelier.setVignette(call.getBool(0), call.getNative!SColor(1), call.getUInt(2));
}

private void _setOverlay(GrCall call) {
    Atelier.setOverlay(call.getNative!SColor(0), call.getFloat(1), call.getUInt(2),
        call.getEnum!Spline(3));
}

private void _freeze(GrCall call) {
    Atelier.freeze(call.getUInt(0));
}

private void _setTimeScale(GrCall call) {
    Atelier.setTimeScale(call.getFloat(0));
}

private void _slowDown(GrCall call) {
    Atelier.slowDown(call.getFloat(0), call.getUInt(1), call.getUInt(2),
        call.getEnum!Spline(3), call.getEnum!Spline(4));
}
