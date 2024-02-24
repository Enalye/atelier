/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.render.rectangle;

import grimoire;

import atelier.common;
import atelier.render;
import atelier.script.util;

package void loadLibRender_rectangle(GrLibDefinition library) {
    library.setModule("render.rectangle");
    library.setModuleInfo(GrLocale.fr_FR, "Rectangle");
    library.setModuleExample(GrLocale.fr_FR, "var rect = @Rectangle.fill(200f, 50f);
rect.anchor = @Vec2f.zero;
rect.position = @Vec2f.zero;
rect.color = @Color.red;
entity.addImage(rect);");

    GrType rectangleType = library.addNative("Rectangle", [], "Image");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    library.setDescription(GrLocale.fr_FR, "Construit un rectangle plein");
    library.setParameters(["x", "y"]);
    library.addStatic(&_fill, rectangleType, "fill", [
            grFloat, grFloat
        ], [rectangleType]);

    library.setDescription(GrLocale.fr_FR, "Construit le contour d’un rectangle");
    library.setParameters(["x", "y", "thickness"]);
    library.addStatic(&_outline, rectangleType, "outline", [
            grFloat, grFloat, grFloat
        ], [rectangleType]);

    library.setDescription(GrLocale.fr_FR, "Taille du rectangle");
    library.addProperty(&_size!"get", &_size!"set", "size", rectangleType, vec2fType);

    library.setDescription(GrLocale.fr_FR,
        "Si `true`, le rectangle est plein, sinon le rectangle est une bordure");
    library.addProperty(&_filled!"get", &_filled!"set", "filled", rectangleType, grBool);

    library.setDescription(GrLocale.fr_FR,
        "(Seulement si `filled` == false) Épaisseur de la bordure");
    library.addProperty(&_thickness!"get", &_thickness!"set", "thickness",
        rectangleType, grFloat);
}

private void _fill(GrCall call) {
    call.setNative(Rectangle.fill(Vec2f(call.getFloat(0), call.getFloat(1))));
}

private void _outline(GrCall call) {
    call.setNative(Rectangle.outline(Vec2f(call.getFloat(0),
            call.getFloat(1)), call.getFloat(2)));
}

private void _size(string op)(GrCall call) {
    Rectangle rectangle = call.getNative!Rectangle(0);

    static if (op == "set") {
        rectangle.size = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(rectangle.size));
}

private void _filled(string op)(GrCall call) {
    Rectangle rectangle = call.getNative!Rectangle(0);

    static if (op == "set") {
        rectangle.filled = call.getBool(1);
    }

    call.setBool(rectangle.filled);
}

private void _thickness(string op)(GrCall call) {
    Rectangle rect = call.getNative!Rectangle(0);

    static if (op == "set") {
        rect.thickness = call.getFloat(1);
    }
    call.setFloat(rect.thickness);
}
