/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.scene;

import grimoire;
import atelier.script.scene.camera;
import atelier.script.scene.component;
import atelier.script.scene.entity;
import atelier.script.scene.particle;
import atelier.script.scene.scene;

package(atelier.script) GrLibLoader[] getLibLoaders_scene() {
    return [
        &loadLibScene_camera,
        &loadLibScene_component,
        &loadLibScene_entity,
        &loadLibScene_particle,
        &loadLibScene_scene
    ];
}