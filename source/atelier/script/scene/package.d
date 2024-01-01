/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.scene;

import grimoire;
import atelier.script.scene.entity;
import atelier.script.scene.scene;

package(atelier.script) GrLibLoader[] getLibLoaders_scene() {
    return [
        &loadLibScene_entity,
        &loadLibScene_scene
    ];
}