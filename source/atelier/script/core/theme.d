/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.core.theme;

import grimoire;

import atelier.core;
import atelier.render;
import atelier.script.util;

package void loadLibCore_theme(GrModule mod) {
    mod.setModule("core.theme");
    mod.setModuleInfo(GrLocale.fr_FR, "Thème global");

    GrType themeType = mod.addNative("Theme");
    GrType colorType = grGetNativeType("Color");

    mod.addConstructor(&_ctor, themeType);

    mod.setDescription(GrLocale.fr_FR, "Récupère le thème actuel.");
    mod.addStatic(&_get, themeType, "get", [], [themeType]);

    mod.addProperty(&_background!"get", &_background!"set", "background", themeType, colorType);
}

private void _ctor(GrCall call) {
    call.setNative(new Theme);
}

private void _get(GrCall call) {
    call.setNative(Atelier.theme);
}

private void _background(string op)(GrCall call) {
    Theme theme = call.getNative!Theme(0);

    static if (op == "set") {
        theme.background = call.getNative!SColor(1);
    }

    call.setNative(scolor(theme.background));
}
