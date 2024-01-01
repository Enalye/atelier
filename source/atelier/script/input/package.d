/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.input;

import grimoire;

import atelier.script.input.input;

package(atelier.script) GrLibLoader[] getLibLoaders_input() {
    return [
        &loadLibInput_input
    ];
}
