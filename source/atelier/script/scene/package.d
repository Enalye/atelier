/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.scene;

import grimoire;
import atelier.script.scene.actor;
import atelier.script.scene.camera;
import atelier.script.scene.collider;
import atelier.script.scene.component;
import atelier.script.scene.entity;
import atelier.script.scene.level;
import atelier.script.scene.particle;
import atelier.script.scene.scene;
import atelier.script.scene.solid;

package(atelier.script) GrModuleLoader[] getLibLoaders_scene() {
    return [
        &loadLibScene_level, &loadLibScene_scene, &loadLibScene_entity,
        &loadLibScene_particle,
        /*&loadLibScene_actor,
        &loadLibScene_camera,
        &loadLibScene_collider,
        &loadLibScene_component,
        &loadLibScene_solid*/
    ];
}
