/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.ui.button;

import grimoire;

import dahu.common;
import dahu.core;
import dahu.ui;

package void loadLibUI_button(GrLibDefinition lib) {
    GrType buttonType = lib.addNative("Button", [], "UIElement");

    lib.addConstructor(&_ctor, buttonType);
}

private void _ctor(GrCall call) {
    Button button = new Button;

    call.setNative(button);
}

private void _text(GrCall call) {
    Label label = call.getNative!Label(0);

    label.text = call.getString(1);
}
