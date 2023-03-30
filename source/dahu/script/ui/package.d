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
        &loadLibUI_button, &loadLibUI_element, &loadLibUI_label, &loadLibUI_state
    ];
}
