/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.common.math;

import grimoire;
import atelier.common;

package void loadLibCommon_math(GrModule mod) {
    mod.setModule("common.math");
    mod.setModuleInfo(GrLocale.fr_FR, "Functions mathématiques");

    mod.setDescription(GrLocale.fr_FR,
        "Convertit un volume en décibel vers une amplitude linéaire.");
    mod.setParameters(["volume"]);
    mod.addFunction(&_dbToVol, "dbToVol", [grFloat], [grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Convertit un volume linéaire en décibels.");
    mod.setParameters(["db"]);
    mod.addFunction(&_volToDb, "volToDb", [grFloat], [grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Retourne un bruit simplex en 1D.");
    mod.setParameters(["x"]);
    mod.addFunction(&_noise1, "noise", [grFloat], [grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Retourne un bruit simplex en 2D.");
    mod.setParameters(["x", "y"]);
    mod.addFunction(&_noise2, "noise", [grFloat, grFloat], [grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Retourne un bruit simplex en 3D.");
    mod.setParameters(["x", "y", "z"]);
    mod.addFunction(&_noise3, "noise", [grFloat, grFloat, grFloat], [grFloat]);
}

private void _dbToVol(GrCall call) {
    call.setFloat(dbToVol(call.getFloat(0)));
}

private void _volToDb(GrCall call) {
    call.setFloat(volToDb(call.getFloat(0)));
}

private void _noise1(GrCall call) {
    call.setFloat(noise(call.getFloat(0)));
}

private void _noise2(GrCall call) {
    call.setFloat(noise(call.getFloat(0), call.getFloat(1)));
}

private void _noise3(GrCall call) {
    call.setFloat(noise(call.getFloat(0), call.getFloat(1), call.getFloat(2)));
}
