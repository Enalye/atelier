/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.render.capsule;

import grimoire;

import atelier.common;
import atelier.render;
import atelier.script.util;

package void loadLibRender_capsule(GrLibDefinition library) {
    library.setModule("render.capsule");
    library.setModuleInfo(GrLocale.fr_FR, "Capsule");
    library.setModuleExample(GrLocale.fr_FR, "var capsule = @Capsule.outline(200f, 50f, 5f);
capsule.anchor = @Vec2f.half;
capsule.position = @Vec2f.zero;
capsule.color = @Color.red;
entity.addImage(capsule);");

    GrType capsuleType = library.addNative("Capsule", [], "Image");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    library.setDescription(GrLocale.fr_FR, "Construit une capsule pleine");
    library.setParameters(["x", "y"]);
    library.addStatic(&_fill, capsuleType, "fill", [grFloat, grFloat], [
            capsuleType
        ]);

    library.setDescription(GrLocale.fr_FR, "Construit le contour d’une capsule");
    library.setParameters(["x", "y", "thickness"]);
    library.addStatic(&_outline, capsuleType, "outline", [
            grFloat, grFloat, grFloat
        ], [capsuleType]);

    library.setDescription(GrLocale.fr_FR, "Taille de la capsule");
    library.addProperty(&_size!"get", &_size!"set", "size", capsuleType, vec2fType);

    library.setDescription(GrLocale.fr_FR,
        "Si `true`, la capsule est pleine, sinon la capsule est une bordure");
    library.addProperty(&_filled!"get", &_filled!"set", "filled", capsuleType, grBool);

    library.setDescription(GrLocale.fr_FR,
        "(Seulement si `filled` == false) Épaisseur de la bordure");
    library.addProperty(&_thickness!"get", &_thickness!"set", "thickness",
        capsuleType, grFloat);
}

private void _fill(GrCall call) {
    call.setNative(Capsule.fill(Vec2f(call.getFloat(0), call.getFloat(1))));
}

private void _outline(GrCall call) {
    call.setNative(Capsule.outline(Vec2f(call.getFloat(0), call.getFloat(1)), call.getFloat(2)));
}

private void _size(string op)(GrCall call) {
    Capsule capsule = call.getNative!Capsule(0);

    static if (op == "set") {
        capsule.size = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(capsule.size));
}

private void _filled(string op)(GrCall call) {
    Capsule capsule = call.getNative!Capsule(0);

    static if (op == "set") {
        capsule.filled = call.getBool(1);
    }

    call.setBool(capsule.filled);
}

private void _thickness(string op)(GrCall call) {
    Capsule capsule = call.getNative!Capsule(0);

    static if (op == "set") {
        capsule.thickness = call.getFloat(1);
    }
    call.setFloat(capsule.thickness);
}
