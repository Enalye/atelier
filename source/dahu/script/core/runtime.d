/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.core.runtime;

import grimoire;

import dahu.core;

package void loadLibCore_runtime(GrLibDefinition lib) {
    GrType appType = lib.addNative("Runtime");
    GrType uiType = grGetNativeType("UI");

    lib.addVariable("app", appType);
    lib.addProperty(&_ui, null, "ui", appType, uiType);
}

private void _ui(GrCall call) {
    Runtime rt = call.getNative!Runtime(0);
    call.setNative(rt.ui);
}
