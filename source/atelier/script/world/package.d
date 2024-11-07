/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.world;

import grimoire;
import atelier.script.world.audio;
import atelier.script.world.camera;
import atelier.script.world.entity;
import atelier.script.world.grid;
import atelier.script.world.lighting;
import atelier.script.world.particle;
import atelier.script.world.scene;
import atelier.script.world.world;

package(atelier.script) GrModuleLoader[] getLibLoaders_world() {
    return [
        &loadLibWorld_audio,
        &loadLibWorld_camera,
        &loadLibWorld_entity,
        &loadLibWorld_grid,
        &loadLibWorld_lighting,
        &loadLibWorld_particle,
        &loadLibWorld_scene,
        &loadLibWorld_world,
    ];
}
