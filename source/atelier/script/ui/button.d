/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.ui.button;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.ui;

package void loadLibUI_button(GrLibDefinition library) {
    GrType buttonType = library.addNative("Button", [], "UIElement");
    GrType filledButtonType = library.addNative("FilledButton", [], "UIElement");
    GrType outlinedButtonType = library.addNative("OutlinedButton", [], "Button");
    GrType textButtonType = library.addNative("TextButton", [], "Button");

    //GrType buttonStyleType = library.addEnum("ButtonStyle", grNativeEnum!(Button.Style));

    library.addConstructor(&_filledBtn_ctor, filledButtonType, [grString]);
    library.addConstructor(&_outlinedBtn_ctor, outlinedButtonType, [grString]);
    library.addConstructor(&_textBtn_ctor, textButtonType, [grString]);
}

private void _filledBtn_ctor(GrCall call) {
    call.setNative(new FilledButton(call.getString(0)));
}

private void _outlinedBtn_ctor(GrCall call) {
    call.setNative(new OutlinedButton(call.getString(0)));
}

private void _textBtn_ctor(GrCall call) {
    call.setNative(new TextButton(call.getString(0)));
}

private void _text(GrCall call) {
    Label label = call.getNative!Label(0);

    label.text = call.getString(1);
}
