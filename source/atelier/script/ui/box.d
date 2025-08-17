module atelier.script.ui.box;

import grimoire;

import atelier.common;
import atelier.ui;
import atelier.script.util;

package void loadLibUI_box(GrModule mod) {
    mod.setModule("ui.box");
    mod.setModuleInfo(GrLocale.fr_FR, "Système d’alignement d’interfaces");

    GrType boxType = mod.addNative("Box", [], "UIElement");
    GrType hboxType = mod.addNative("HBox", [], "Box");
    GrType vboxType = mod.addNative("VBox", [], "Box");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Aligne horizontalement les interfaces");
    mod.addConstructor(&_hboxCtor, hboxType);

    mod.setDescription(GrLocale.fr_FR, "Aligne verticalement les interfaces");
    mod.addConstructor(&_vboxCtor, vboxType);

    mod.setDescription(GrLocale.fr_FR, "Taille minimale de la boite");
    mod.addProperty(&_padding!"get", &_padding!"set", "padding", boxType, vec2fType);

    mod.setDescription(GrLocale.fr_FR, "Taille de la marge");
    mod.addProperty(&_margin!"get", &_margin!"set", "margin", boxType, vec2fType);

    mod.setDescription(GrLocale.fr_FR, "Espacement entre les enfants");
    mod.addProperty(&_spacing!"get", &_spacing!"set", "spacing", boxType, grFloat);
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
