/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.ui.label;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.ui;

package void loadLibUI_label(GrLibDefinition lib) {
    GrType labelType = lib.addNative("Label", [], "UIElement");

    lib.addConstructor(&_ctor, labelType, [grString]);
    lib.addFunction(&_text, "text", [labelType, grString]);
}

private void _ctor(GrCall call) {
    Label label = new Label(call.getString(0));

    call.setNative(label);
}

private void _text(GrCall call) {
    Label label = call.getNative!Label(0);

    label.text = call.getString(1);
}
