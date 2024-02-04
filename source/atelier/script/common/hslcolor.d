/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.common.hslcolor;

import grimoire;

import atelier.common;

import atelier.script.util;

package void loadLibCommon_hslcolor(GrLibDefinition library) {
    library.setModule("common.hslcolor");
    library.setModuleInfo(GrLocale.fr_FR, "Représentation d’une couleur dans l’espace TSL");

    GrType hslColorType = library.addNative("HSLColor");

    library.addConstructor(&_ctor, hslColorType, [grFloat, grFloat, grFloat]);

    static foreach (field; ["h", "s", "l"]) {
        library.addProperty(&_property!(field, "get"), &_property!(field,
                "set"), field, hslColorType, grFloat);
    }
}

private void _ctor(GrCall call) {
    SHSLColor color = new SHSLColor;
    static foreach (int idx, field; ["h", "s", "l"]) {
        mixin("color.", field, " = call.getFloat(", idx, ");");
    }
    call.setNative(color);
}

private void _property(string field, string op)(GrCall call) {
    SHSLColor color = call.getNative!(SHSLColor)(0);
    static if (op == "set") {
        mixin("color.", field, " = call.getFloat(1);");
    }
    mixin("call.setFloat(color.", field, ");");
}
