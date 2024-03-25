/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.render.circle;

import grimoire;

import atelier.common;
import atelier.render;

package void loadLibRender_circle(GrModule mod) {
    mod.setModule("render.circle");
    mod.setModuleInfo(GrLocale.fr_FR, "Cercle");
    mod.setModuleExample(GrLocale.fr_FR, "var circle = @Circle.fill(20f);
circle.anchor = @Vec2f.half;
circle.position = @Vec2f(32f, -48f);
circle.color = @Color.blue;
entity.addImage(circle);");

    GrType circleType = mod.addNative("Circle", [], "Image");

    mod.setDescription(GrLocale.fr_FR, "Construit un cercle plein");
    mod.setParameters(["radius"]);
    mod.addStatic(&_fill, circleType, "fill", [grFloat], [circleType]);

    mod.setDescription(GrLocale.fr_FR, "Construit le contour d’un cercle");
    mod.setParameters(["radius", "thickness"]);
    mod.addStatic(&_outline, circleType, "outline", [grFloat, grFloat], [
            circleType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Rayon du cercle");
    mod.addProperty(&_radius!"get", &_radius!"set", "radius", circleType, grFloat);

    mod.setDescription(GrLocale.fr_FR,
        "Si `true`, le cercle est plein, sinon le cercle est une bordure");
    mod.addProperty(&_filled!"get", &_filled!"set", "filled", circleType, grBool);

    mod.setDescription(GrLocale.fr_FR, "(Seulement si `filled` == false) Épaisseur de la bordure");
    mod.addProperty(&_thickness!"get", &_thickness!"set", "thickness", circleType, grFloat);
}

private void _fill(GrCall call) {
    call.setNative(Circle.fill(call.getFloat(0)));
}

private void _outline(GrCall call) {
    call.setNative(Circle.outline(call.getFloat(0), call.getFloat(1)));
}

private void _radius(string op)(GrCall call) {
    Circle circle = call.getNative!Circle(0);

    static if (op == "set") {
        circle.radius = call.getFloat(1);
    }
    call.setFloat(circle.radius);
}

private void _filled(string op)(GrCall call) {
    Circle circle = call.getNative!Circle(0);

    static if (op == "set") {
        circle.filled = call.getBool(1);
    }

    call.setBool(circle.filled);
}

private void _thickness(string op)(GrCall call) {
    Circle circle = call.getNative!Circle(0);

    static if (op == "set") {
        circle.thickness = call.getFloat(1);
    }
    call.setFloat(circle.thickness);
}
