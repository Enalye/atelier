module atelier.script.world.graphic;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world;
import atelier.ui;
import atelier.script.util;

package void loadLibWorld_graphic(GrModule mod) {
    mod.setModule("world.graphic");
    mod.setModuleInfo(GrLocale.fr_FR, "Définit le rendu d’une entité");

    GrType graphicType = mod.addNative("EntityGraphic");
    GrType blendType = grGetEnumType("Blend");

    mod.setDescription(GrLocale.fr_FR, "Positionne l’encre");
    mod.setParameters(["graphic", "x", "y"]);
    mod.addFunction(&_setAnchor, "setAnchor", [graphicType, grFloat, grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Positionne le point de pivot");
    mod.setParameters(["graphic", "x", "y"]);
    mod.addFunction(&_setPivot, "setPivot", [graphicType, grFloat, grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Décale le rendu");
    mod.setParameters(["graphic", "x", "y"]);
    mod.addFunction(&_setOffset, "setOffset", [graphicType, grFloat, grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Tourne le rendu");
    mod.setParameters(["graphic", "angle"]);
    mod.addFunction(&_setAngle, "setAngle", [graphicType, grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Détermine si le rendu tourne avec l’angle");
    mod.setParameters(["graphic", "isRotating"]);
    mod.addFunction(&_setRotating, "setRotating", [graphicType, grBool]);

    mod.setDescription(GrLocale.fr_FR, "Angle de base du rendu");
    mod.setParameters(["graphic", "angle"]);
    mod.addFunction(&_setAngleOffset, "setAngleOffset", [graphicType, grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Mode de rendu");
    mod.setParameters(["graphic", "blend"]);
    mod.addFunction(&_setBlend, "setBlend", [graphicType, blendType]);

    mod.setDescription(GrLocale.fr_FR, "Opacité du rendu");
    mod.setParameters(["graphic", "alpha"]);
    mod.addFunction(&_setAlpha, "setAlpha", [graphicType, grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Couleur du rendu");
    mod.setParameters(["graphic", "r", "g", "b"]);
    mod.addFunction(&_setColor, "setColor", [
            graphicType, grFloat, grFloat, grFloat
        ]);

    mod.setDescription(GrLocale.fr_FR, "Échelle du rendu");
    mod.setParameters(["graphic", "x", "y"]);
    mod.addFunction(&_setScale, "setScale", [graphicType, grFloat, grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Marque le rendu comme rendu par défaut");
    mod.setParameters(["graphic", "isDefault"]);
    mod.addFunction(&_setDefault, "setDefault", [graphicType, grBool]);

    mod.setDescription(GrLocale.fr_FR, "Le rendu est-il marqué par défaut ?");
    mod.setParameters(["graphic"]);
    mod.addFunction(&_getDefault, "getDefault", [graphicType], [grBool]);

    mod.setDescription(GrLocale.fr_FR, "Démarre le rendu");
    mod.setParameters(["graphic"]);
    mod.addFunction(&_start, "start", [graphicType]);

    mod.setDescription(GrLocale.fr_FR, "Interromp et réinitialise le rendu");
    mod.setParameters(["graphic"]);
    mod.addFunction(&_stop, "stop", [graphicType]);

    mod.setDescription(GrLocale.fr_FR, "Met le rendu en pause");
    mod.setParameters(["graphic"]);
    mod.addFunction(&_pause, "pause", [graphicType]);

    mod.setDescription(GrLocale.fr_FR, "Relance le rendu");
    mod.setParameters(["graphic"]);
    mod.addFunction(&_resume, "resume", [graphicType]);

    mod.setDescription(GrLocale.fr_FR, "Largeur du rendu");
    mod.setParameters(["graphic"]);
    mod.addFunction(&_getWidth, "getWidth", [graphicType], [grUInt]);

    mod.setDescription(GrLocale.fr_FR, "Hauteur du rendu");
    mod.setParameters(["graphic"]);
    mod.addFunction(&_getHeight, "getHeight", [graphicType], [grUInt]);
}

private void _setAnchor(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    Vec2f anchor = Vec2f(call.getFloat(1), call.getFloat(2));
    graphic.setAnchor(anchor);
}

private void _setPivot(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    Vec2f pivot = Vec2f(call.getFloat(1), call.getFloat(2));
    graphic.setPivot(pivot);
}

private void _setOffset(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    Vec2f offset = Vec2f(call.getFloat(1), call.getFloat(2));
    graphic.setOffset(offset);
}

private void _setAngle(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    graphic.setAngle(call.getFloat(1));
}

private void _setRotating(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    graphic.setRotating(call.getBool(1));
}

private void _setAngleOffset(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    graphic.setAngleOffset(call.getFloat(1));
}

private void _setBlend(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    graphic.setBlend(call.getEnum!Blend(1));
}

private void _setAlpha(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    graphic.setAlpha(call.getFloat(1));
}

private void _setColor(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    Color color = Color(call.getFloat(1), call.getFloat(2), call.getFloat(3));
    graphic.setColor(color);
}

private void _setScale(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    Vec2f scale = Vec2f(call.getFloat(1), call.getFloat(2));
    graphic.setScale(scale);
}

private void _setDefault(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    graphic.setDefault(call.getBool(1));
}

private void _getDefault(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    call.setBool(graphic.getDefault());
}

private void _start(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    graphic.start();
}

private void _stop(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    graphic.stop();
}

private void _pause(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    graphic.pause();
}

private void _resume(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    graphic.resume();
}

private void _getWidth(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    call.setUInt(graphic.getWidth());
}

private void _getHeight(GrCall call) {
    EntityGraphic graphic = call.getNative!EntityGraphic(0);
    call.setUInt(graphic.getHeight());
}
