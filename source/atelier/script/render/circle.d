/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.render.circle;

import grimoire;

import atelier.common;
import atelier.render;

package void loadLibRender_circle(GrLibDefinition library) {
    library.setModule("render.circle");
    library.setModuleInfo(GrLocale.fr_FR, "Cercle");
    library.setModuleExample(GrLocale.fr_FR, "var circle = @Circle.fill(20f);
circle.anchor = @Vec2f.half;
circle.position = @Vec2f(32f, -48f);
circle.color = @Color.blue;
entity.addImage(circle);");

    GrType circleType = library.addNative("Circle", [], "Image");

    library.setDescription(GrLocale.fr_FR, "Construit un cercle plein");
    library.setParameters(["radius"]);
    library.addStatic(&_fill, circleType, "fill", [grFloat], [circleType]);

    library.setDescription(GrLocale.fr_FR, "Construit le contour d’un cercle");
    library.setParameters(["radius", "thickness"]);
    library.addStatic(&_outline, circleType, "outline", [grFloat, grFloat], [
            circleType
        ]);

    library.setDescription(GrLocale.fr_FR, "Rayon du cercle");
    library.addProperty(&_radius!"get", &_radius!"set", "radius", circleType, grFloat);

    library.setDescription(GrLocale.fr_FR,
        "Si `true`, le cercle est plein, sinon le cercle est une bordure");
    library.addProperty(&_filled!"get", &_filled!"set", "filled", circleType, grBool);

    library.setDescription(GrLocale.fr_FR,
        "(Seulement si `filled` == false) Épaisseur de la bordure");
    library.addProperty(&_thickness!"get", &_thickness!"set", "thickness", circleType, grFloat);
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
