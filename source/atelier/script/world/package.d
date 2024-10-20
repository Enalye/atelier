/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.world;

import grimoire;
import atelier.script.world.camera;
import atelier.script.world.world;
import atelier.script.world.particle;
import atelier.script.world.scene;
import atelier.script.world.grid;

package(atelier.script) GrModuleLoader[] getLibLoaders_world() {
    return [
        &loadLibWorld_camera, &loadLibWorld_grid, &loadLibWorld_particle,
        &loadLibWorld_scene, &loadLibWorld_world,
    ];
}
