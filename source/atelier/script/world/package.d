module atelier.script.world;

import grimoire;
import atelier.script.world.actor;
import atelier.script.world.audio;
import atelier.script.world.camera;
import atelier.script.world.dialog;
import atelier.script.world.entity;
import atelier.script.world.graphic;
import atelier.script.world.grid;
import atelier.script.world.lighting;
import atelier.script.world.particle;
import atelier.script.world.prop;
import atelier.script.world.proxy;
import atelier.script.world.scene;
import atelier.script.world.shot;
import atelier.script.world.world;
import atelier.script.world.trigger;

package(atelier.script) GrModuleLoader[] getLibLoaders_world() {
    return [
        &loadLibWorld_actor, //
        &loadLibWorld_audio, //
        &loadLibWorld_camera, //
        &loadLibWorld_dialog, //
        &loadLibWorld_entity, //
        &loadLibWorld_graphic, //
        &loadLibWorld_grid, //
        &loadLibWorld_lighting, //
        &loadLibWorld_particle, //
        &loadLibWorld_prop, //
        &loadLibWorld_proxy, //
        &loadLibWorld_scene, //
        &loadLibWorld_shot, //
        &loadLibWorld_world, //
        &loadLibWorld_trigger, //
    ];
}
