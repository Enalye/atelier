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

    GrType uiType = library.addNative("UI");
    GrType elementType = grGetNativeType("UIElement");

    library.setDescription(GrLocale.fr_FR, "Montre les bordures des interfaces");
    library.setParameters(["isDebug"]);
    library.addStatic(&_setDebug, uiType, "setDebug", [grBool]);

    library.setDescription(GrLocale.fr_FR, "Ajoute une interface au sommet de la hiérarchie");
    library.setParameters(["ui"]);
    library.addStatic(&_add, uiType, "add", [elementType]);

    library.setDescription(GrLocale.fr_FR, "Supprime toutes les interfaces");
    library.setParameters();
    library.addStatic(&_clear, uiType, "clear");
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
