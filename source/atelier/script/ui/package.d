/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.ui;

import grimoire;

import atelier.script.ui.element;
import atelier.script.ui.label;
import atelier.script.ui.manager;
import atelier.script.ui.state;

package(atelier.script) GrLibLoader[] getLibLoaders_ui() {
    return [
        &loadLibUI_element, &loadLibUI_label,
        &loadLibUI_manager, &loadLibUI_state
    ];
}
