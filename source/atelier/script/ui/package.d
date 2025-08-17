module atelier.script.ui;

import grimoire;

import atelier.script.ui.box;
import atelier.script.ui.element;
import atelier.script.ui.label;
import atelier.script.ui.manager;
import atelier.script.ui.state;

package(atelier.script) GrModuleLoader[] getLibLoaders_ui() {
    return [
        &loadLibUI_box, &loadLibUI_element, &loadLibUI_label,
        &loadLibUI_manager, &loadLibUI_state
    ];
}
