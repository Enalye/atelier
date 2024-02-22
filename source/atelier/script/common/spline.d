/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.common.spline;

import grimoire;
import atelier.common;

package void loadLibCommon_spline(GrLibDefinition library) {
    library.setModule("common.spline");
    library.setModuleInfo(GrLocale.fr_FR, "Courbes d’accélération.
Des exemples de ces fonctions sont visibles sur [ce site](https://easings.net/fr).");

    library.setDescription(GrLocale.fr_FR, "Décrit une fonction d’accélération");
    GrType splineType = library.addEnum("Spline", grNativeEnum!Spline());

    library.setDescription(GrLocale.fr_FR, "Applique une courbe d’acccélération.
`value` doit être compris entre 0 et 1.
La fonction retourne une valeur entre 0 et 1.");
    library.setParameters(["value", "spline"]);
    library.addFunction(&_ease, "ease", [grFloat, splineType], [grFloat]);
}

private void _ease(GrCall call) {
    SplineFunc easeFunc = getSplineFunc(call.getEnum!Spline(1));
    call.setFloat(easeFunc(call.getFloat(0)));
}
