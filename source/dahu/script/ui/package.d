/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.ui;

import grimoire;

import dahu.script.ui.button;
import dahu.script.ui.element;
import dahu.script.ui.label;
import dahu.script.ui.state;

package(dahu.script) GrLibLoader[] getLibLoaders_ui() {
    return [
        &loadLibUI, &loadLibUI_button, &loadLibUI_element, &loadLibUI_label,
        &loadLibUI_state
    ];
}

import dahu.ui;

private void loadLibUI(GrLibDefinition lib) {
    GrType uiType = lib.addNative("UI");

    lib.addProperty(&_isDebug!"get", &_isDebug!"set", "isDebug", uiType, grBool);
}

private void _isDebug(string op)(GrCall call) {
    UI ui = call.getNative!UI(0);

    static if (op == "set") {
        ui.isDebug = call.getBool(1);
    }

    call.setBool(ui.isDebug);
}
