module atelier.script.ui.label;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui;

package void loadLibUI_label(GrModule mod) {
    mod.setModule("ui.label");
    mod.setModuleInfo(GrLocale.fr_FR, "Texte");

    GrType labelType = mod.addNative("Label", [], "UIElement");
    GrType fontType = grGetNativeType("Font");

    mod.addConstructor(&_ctor, labelType, [grString, fontType]);

    mod.setDescription(GrLocale.fr_FR, "Texte du label");
    mod.addProperty(&_text!"get", &_text!"set", "text", labelType, grString);

    mod.setDescription(GrLocale.fr_FR, "Police du label");
    mod.addProperty(&_font!"get", &_font!"set", "font", labelType, fontType);

    mod.setDescription(GrLocale.fr_FR, "Espacement entre chaque caractère");
    mod.addProperty(&_charSpacing!"get", &_charSpacing!"set",
        "charSpacing", labelType, grFloat);
}

private void _ctor(GrCall call) {
    Font font = call.getNative!Font(1);
    Label label = new Label(call.getString(0), font);

    call.setNative(label);
}

private void _text(string op)(GrCall call) {
    Label label = call.getNative!Label(0);

    static if (op == "set") {
        label.text = call.getString(1);
    }

    call.setString(label.text);
}

private void _font(string op)(GrCall call) {
    Label label = call.getNative!Label(0);

    static if (op == "set") {
        label.font = call.getNative!Font(1);
    }

    call.setNative(label.font);
}

private void _charSpacing(string op)(GrCall call) {
    Label label = call.getNative!Label(0);

    static if (op == "set") {
        label.charSpacing = call.getFloat(1);
    }

    call.setFloat(label.charSpacing);
}
