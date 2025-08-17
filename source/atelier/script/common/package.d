module atelier.script.common;

import grimoire;

import atelier.script.common.color;
import atelier.script.common.hslcolor;
import atelier.script.common.math;
import atelier.script.common.spline;
import atelier.script.common.vec;

package(atelier.script) GrModuleLoader[] getLibLoaders_common() {
    return [
        &loadLibCommon_color,
        &loadLibCommon_hslcolor,
        &loadLibCommon_math,
        &loadLibCommon_spline,
        &loadLibCommon_vec
    ];
}
