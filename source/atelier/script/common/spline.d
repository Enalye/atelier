/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.common.spline;

import grimoire;

package void loadLibCommon_spline(GrLibDefinition library) {
    library.addEnum("Spline", [
            "linear", "sineIn", "sineOut", "sineInOut", "quadIn", "quadOut",
            "quadInOut", "cubicIn", "cubicOut", "cubicInOut", "quartIn",
            "quartOut", "quartInOut", "quintIn", "quintOut", "quintInOut",
            "expIn", "expOut", "expInOut", "circIn", "circOut",
            "circInOut", "backIn", "backOut", "backInOut", "elasticIn",
            "elasticOut", "elasticInOut", "bounceIn", "bounceOut", "bounceInOut"
        ]);
}
