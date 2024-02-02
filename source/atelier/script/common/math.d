/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.common.math;

import grimoire;
import atelier.common;

package void loadLibCommon_math(GrLibDefinition library) {
    library.setModule("common.math");
    library.setModuleInfo(GrLocale.fr_FR, "Functions mathématiques");

    library.addFunction(&_dbToVol, "dbToVol", [grFloat], [grFloat]);
    library.addFunction(&_volToDb, "volToDb", [grFloat], [grFloat]);
}

private void _dbToVol(GrCall call) {
    call.setFloat(dbToVol(call.getFloat(0)));
}

private void _volToDb(GrCall call) {
    call.setFloat(volToDb(call.getFloat(0)));
}
