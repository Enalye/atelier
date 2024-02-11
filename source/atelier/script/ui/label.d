/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.ui.label;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui;

package void loadLibUI_label(GrLibDefinition library) {
    library.setModule("ui.label");
    library.setModuleInfo(GrLocale.fr_FR, "Texte");

    GrType labelType = library.addNative("Label", [], "UIElement");
    GrType fontType = grGetNativeType("Font");

    library.addConstructor(&_ctor, labelType, [grString, fontType]);

    library.setDescription(GrLocale.fr_FR, "Texte du label");
    library.addFunction(&_text, "text", [labelType, grString]);
}

private void _ctor(GrCall call) {
    Font font = call.getNative!Font(1);
    Label label = new Label(call.getString(0), font);

    call.setNative(label);
}

private void _text(GrCall call) {
    Label label = call.getNative!Label(0);

    label.text = call.getString(1);
}
