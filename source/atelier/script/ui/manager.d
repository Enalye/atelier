/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.ui.manager;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.ui;

package void loadLibUI_manager(GrLibDefinition library) {
    GrType uiType = grGetNativeType("UIElement");

    library.addFunction(&_setDebugUI, "setDebugUI", [grBool]);
    library.addFunction(&_addUI, "addUI", [uiType]);
    library.addFunction(&_clearUI, "clearUI");
}

private void _setDebugUI(GrCall call) {
    Atelier.ui.isDebug = call.getBool(0);
}

private void _addUI(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    Atelier.ui.appendRoot(ui);
}

private void _clearUI(GrCall call) {
    Atelier.ui.removeRoots();
}