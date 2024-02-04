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
    library.setModule("ui.manager");
    library.setModuleInfo(GrLocale.fr_FR, "Gestionnaire d’interface");

    GrType uiType = grGetNativeType("UIElement");

    library.setDescription(GrLocale.fr_FR, "Montre les bordures des interfaces");
    library.addFunction(&_setDebugUI, "setDebugUI", [grBool]);

    library.setDescription(GrLocale.fr_FR, "Ajoute une interface au sommet de la hiérarchie");
    library.addFunction(&_addElement, "addUIElement", [uiType]);

    library.setDescription(GrLocale.fr_FR, "Supprime toutes les interfaces");
    library.addFunction(&_clearElements, "clearUIElements");
}

private void _setDebugUI(GrCall call) {
    Atelier.ui.isDebug = call.getBool(0);
}

private void _addElement(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    Atelier.ui.addElement(ui);
}

private void _clearElements(GrCall call) {
    Atelier.ui.clearElements();
}