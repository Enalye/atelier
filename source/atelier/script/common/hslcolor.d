/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.common.hslcolor;

import grimoire;

import atelier.common;

import atelier.script.util;

package void loadLibCommon_hslcolor(GrModule mod) {
    mod.setModule("common.hslcolor");
    mod.setModuleInfo(GrLocale.fr_FR, "Représentation d’une couleur dans l’espace TSL");

    GrType hslColorType = mod.addNative("HSLColor");

    mod.addConstructor(&_ctor, hslColorType, [grFloat, grFloat, grFloat]);

    static foreach (field; ["h", "s", "l"]) {
        mod.addProperty(&_property!(field, "get"), &_property!(field,
                "set"), field, hslColorType, grFloat);
    }

    mod.addFunction(&_lerp, "lerp", [hslColorType, hslColorType, grFloat], [hslColorType]);
}

private void _ctor(GrCall call) {
    SHSLColor color = new SHSLColor;
    static foreach (int idx, field; ["h", "s", "l"]) {
        mixin("color.", field, " = call.getFloat(", idx, ");");
    }
    call.setNative(color);
}

private void _property(string field, string op)(GrCall call) {
    SHSLColor color = call.getNative!SHSLColor(0);
    static if (op == "set") {
        mixin("color.", field, " = call.getFloat(1);");
    }
    mixin("call.setFloat(color.", field, ");");
}

private void _lerp(GrCall call) {
    SHSLColor c1 = call.getNative!SHSLColor(0);
    SHSLColor c2 = call.getNative!SHSLColor(1);
    float t = call.getFloat(2);
    call.setNative(shslcolor(lerp(c1._hslcolor, c2._hslcolor, t)));
}
