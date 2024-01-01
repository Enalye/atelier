/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.scene;

import grimoire;
import dahu.script.scene.entity;
import dahu.script.scene.scene;

package(dahu.script) GrLibLoader[] getLibLoaders_scene() {
    return [
        &loadLibScene_entity,
        &loadLibScene_scene
    ];
}