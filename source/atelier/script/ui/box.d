/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.ui.box;

import grimoire;

import atelier.common;
import atelier.ui;
import atelier.script.util;

package void loadLibUI_box(GrLibDefinition library) {
    library.setModule("ui.box");
    library.setModuleInfo(GrLocale.fr_FR, "Système d’alignement d’interfaces");

    GrType boxType = library.addNative("Box", [], "UIElement");
    GrType hboxType = library.addNative("HBox", [], "Box");
    GrType vboxType = library.addNative("VBox", [], "Box");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    library.addConstructor(&_hboxCtor, hboxType);
    library.addConstructor(&_vboxCtor, vboxType);

    library.setDescription(GrLocale.fr_FR, "Taille minimale de la boite");
    library.addProperty(&_padding!"get", &_padding!"set", "padding", boxType, vec2fType);

    library.setDescription(GrLocale.fr_FR, "Taille de la marge");
    library.addProperty(&_margin!"get", &_margin!"set", "margin", boxType, vec2fType);

    library.setDescription(GrLocale.fr_FR, "Espacement entre les enfants");
    library.addProperty(&_spacing!"get", &_spacing!"set", "spacing", boxType, grFloat);
}

private void _hboxCtor(GrCall call) {
    call.setNative(new HBox);
}

private void _vboxCtor(GrCall call) {
    call.setNative(new VBox);
}

private void _padding(string op)(GrCall call) {
    Box box = call.getNative!Box(0);

    static if (op == "set") {
        box.setPadding(call.getNative!SVec2f(1));
    }
    call.setNative(svec2(box.getPadding()));
}

private void _margin(string op)(GrCall call) {
    Box box = call.getNative!Box(0);

    static if (op == "set") {
        box.setMargin(call.getNative!SVec2f(1));
    }
    call.setNative(svec2(box.getMargin()));
}

private void _spacing(string op)(GrCall call) {
    Box box = call.getNative!Box(0);

    static if (op == "set") {
        box.setSpacing(call.getFloat(1));
    }
    call.setFloat(box.getSpacing());
}
