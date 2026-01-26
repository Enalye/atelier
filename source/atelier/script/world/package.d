module atelier.script.world;

import grimoire;
import atelier.script.world.audio;
import atelier.script.world.behavior;
import atelier.script.world.camera;
import atelier.script.world.controller;
import atelier.script.world.dialog;
import atelier.script.world.effect;
import atelier.script.world.entity;
import atelier.script.world.graphic;
import atelier.script.world.grid;
import atelier.script.world.lighting;
import atelier.script.world.particle;
import atelier.script.world.scene;
import atelier.script.world.system;
import atelier.script.world.trigger;

package(atelier.script) GrModuleLoader[] getLibLoaders_world() {
    return [
        &loadLibWorld_audio, //
        &loadLibWorld_behavior, //
        &loadLibWorld_camera, //
        &loadLibWorld_controller, //
        &loadLibWorld_dialog, //
        &loadLibWorld_effect, //
        &loadLibWorld_entity, //
        &loadLibWorld_graphic, //
        &loadLibWorld_grid, //
        &loadLibWorld_lighting, //
        &loadLibWorld_particle, //
        &loadLibWorld_scene, //
        &loadLibWorld_system, //
    ];
}
