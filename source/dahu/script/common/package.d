/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.common;

import grimoire;

import dahu.script.common.color;
import dahu.script.common.spline;
import dahu.script.common.vec;

package(dahu.script) GrLibLoader[] getLibLoaders_common() {
    return [
        &loadLibCommon_color,
        &loadLibCommon_spline,
        &loadLibCommon_vec
    ];
}
