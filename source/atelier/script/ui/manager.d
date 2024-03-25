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

package void loadLibUI_manager(GrModule mod) {
    mod.setModule("ui.manager");
    mod.setModuleInfo(GrLocale.fr_FR, "Gestionnaire d’interface");

    GrType uiType = mod.addNative("UI");
    GrType elementType = grGetNativeType("UIElement");

    mod.setDescription(GrLocale.fr_FR, "Montre les bordures des interfaces");
    mod.setParameters(["isDebug"]);
    mod.addStatic(&_setDebug, uiType, "setDebug", [grBool]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute une interface au sommet de la hiérarchie");
    mod.setParameters(["ui"]);
    mod.addStatic(&_add, uiType, "add", [elementType]);

    mod.setDescription(GrLocale.fr_FR, "Supprime toutes les interfaces");
    mod.setParameters();
    mod.addStatic(&_clear, uiType, "clear");
}

private void _setDebug(GrCall call) {
    Atelier.ui.isDebug = call.getBool(0);
}

private void _add(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    Atelier.ui.addUI(ui);
}

private void _clear(GrCall call) {
    Atelier.ui.clearUI();
}
