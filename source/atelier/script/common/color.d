/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.common.color;

import grimoire;

import atelier.common;

import atelier.script.util;

package void loadLibCommon_color(GrModule mod) {
    mod.setModule("common.color");
    mod.setModuleInfo(GrLocale.fr_FR, "Représentation d’une couleur dans l’espace RVB");

    GrType colorType = mod.addNative("Color");
    GrType hslColorType = grGetNativeType("HSLColor");

    mod.addConstructor(&_ctor, colorType, [grFloat, grFloat, grFloat]);
    mod.addConstructor(&_ctor_hsl, colorType, [hslColorType]);

    static foreach (field; ["r", "g", "b"]) {
        mod.addProperty(&_property!(field, "get"), &_property!(field,
                "set"), field, colorType, grFloat);
    }

    static foreach (c; [
            "red", "lime", "blue", "white", "black", "yellow", "cyan", "magenta",
            "silver", "gray", "grey", "maroon", "olive", "green", "purple",
            "teal", "pink", "orange"
        ]) {
        mod.addStatic(&_color!c, colorType, c, [], [colorType]);
    }

    mod.addFunction(&_lerp, "lerp", [colorType, colorType, grFloat], [colorType]);
}

private void _ctor(GrCall call) {
    SColor color = new SColor;
    static foreach (int idx, field; ["r", "g", "b"]) {
        mixin("color.", field, " = call.getFloat(", idx, ");");
    }
    call.setNative(color);
}

private void _ctor_hsl(GrCall call) {
    SColor color = new SColor;
    SHSLColor hsl = call.getNative!SHSLColor(0);
    color._color = hsl._hslcolor.toColor();
    call.setNative(color);
}

private void _property(string field, string op)(GrCall call) {
    SColor color = call.getNative!(SColor)(0);
    static if (op == "set") {
        mixin("color.", field, " = call.getFloat(1);");
    }
    mixin("call.setFloat(color.", field, ");");
}

private void _color(string c)(GrCall call) {
    SColor color = new SColor;
    mixin("color = Color.", c, ";");
    call.setNative(color);
}

private void _lerp(GrCall call) {
    SColor c1 = call.getNative!SColor(0);
    SColor c2 = call.getNative!SColor(1);
    float t = call.getFloat(2);
    call.setNative(scolor(lerp(c1._color, c2._color, t)));
}
