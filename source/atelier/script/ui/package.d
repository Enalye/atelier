/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.ui;

import grimoire;

import atelier.script.ui.button;
import atelier.script.ui.element;
import atelier.script.ui.label;
import atelier.script.ui.state;

package(atelier.script) GrLibLoader[] getLibLoaders_ui() {
    return [
        &loadLibUI, &loadLibUI_button, &loadLibUI_element, &loadLibUI_label,
        &loadLibUI_state
    ];
}

import atelier.ui;

private void loadLibUI(GrLibDefinition library) {
    GrType uiType = library.addNative("UIManager");

    library.addProperty(&_isDebug!"get", &_isDebug!"set", "isDebug", uiType, grBool);
}

private void _isDebug(string op)(GrCall call) {
    UIManager ui = call.getNative!UIManager(0);

    static if (op == "set") {
        ui.isDebug = call.getBool(1);
    }

    call.setBool(ui.isDebug);
}
