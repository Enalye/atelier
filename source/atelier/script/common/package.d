/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.common;

import grimoire;

import atelier.script.common.color;
import atelier.script.common.spline;
import atelier.script.common.vec;

package(atelier.script) GrLibLoader[] getLibLoaders_common() {
    return [
        &loadLibCommon_color,
        &loadLibCommon_spline,
        &loadLibCommon_vec
    ];
}
