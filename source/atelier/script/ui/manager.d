/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
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
    library.setParameters(["isDebug"]);
    library.addFunction(&_setDebugUI, "setDebugUI", [grBool]);

    library.setDescription(GrLocale.fr_FR, "Ajoute une interface au sommet de la hiérarchie");
    library.setParameters(["ui"]);
    library.addFunction(&_addUI, "addUI", [uiType]);

    library.setDescription(GrLocale.fr_FR, "Supprime toutes les interfaces");
    library.setParameters();
    library.addFunction(&_clearUI, "clearUI");
}

private void _setDebugUI(GrCall call) {
    Atelier.ui.isDebug = call.getBool(0);
}

private void _addUI(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    Atelier.ui.addUI(ui);
}

private void _clearUI(GrCall call) {
    Atelier.ui.clearUI();
}
