/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.core;

import grimoire;

import dahu.script.core.runtime;

package(dahu.script) GrLibLoader[] getLibLoaders_core() {
    return [
        &loadLibCore_runtime
    ];
}