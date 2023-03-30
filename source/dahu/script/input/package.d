/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.input;

import grimoire;

import dahu.script.input.input;

package(dahu.script) GrLibLoader[] getLibLoaders_input() {
    return [
        &loadLibInput_input
    ];
}
