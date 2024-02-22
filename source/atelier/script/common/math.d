/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.common.math;

import grimoire;
import atelier.common;

package void loadLibCommon_math(GrLibDefinition library) {
    library.setModule("common.math");
    library.setModuleInfo(GrLocale.fr_FR, "Functions mathématiques");

    library.setDescription(GrLocale.fr_FR,
        "Convertit un volume en décibel vers une amplitude linéaire.");
    library.setParameters(["volume"]);
    library.addFunction(&_dbToVol, "dbToVol", [grFloat], [grFloat]);

    library.setDescription(GrLocale.fr_FR, "Convertit un volume linéaire en décibels.");
    library.setParameters(["db"]);
    library.addFunction(&_volToDb, "volToDb", [grFloat], [grFloat]);
}

private void _dbToVol(GrCall call) {
    call.setFloat(dbToVol(call.getFloat(0)));
}

private void _volToDb(GrCall call) {
    call.setFloat(volToDb(call.getFloat(0)));
}
