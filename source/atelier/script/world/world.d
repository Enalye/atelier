/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.world.world;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world;
import atelier.ui;
import atelier.script.util;

package void loadLibWorld_world(GrModule mod) {
    mod.setModule("world.world");
    mod.setModuleInfo(GrLocale.fr_FR, "Niveau actuel");

    GrType worldType = mod.addNative("World");
    GrType sceneType = grGetNativeType("Scene");
    GrType entityType = grGetNativeType("Entity");
    GrType particleSourceType = grGetNativeType("ParticleSource");
    GrType actorType = grGetNativeType("Actor");
    GrType solidType = grGetNativeType("Solid");

    mod.setDescription(GrLocale.fr_FR, "Ajoute une scène au niveau");
    mod.setParameters(["scene"]);
    mod.addStatic(&_addScene, worldType, "addScene", [sceneType]);

    mod.setDescription(GrLocale.fr_FR, "Nettoie le niveau");
    mod.setParameters([]);
    mod.addStatic(&_clear, worldType, "clear");

    mod.setDescription(GrLocale.fr_FR, "Retire une scène du niveau");
    mod.setParameters(["scene"]);
    mod.addStatic(&_removeScene, worldType, "removeScene", [sceneType]);

    mod.setDescription(GrLocale.fr_FR, "Récupère la scène correspondant au nom donné");
    mod.setParameters(["name"]);
    mod.addStatic(&_findSceneByName, worldType, "findSceneByName", [grString],
        [grOptional(sceneType)]);

    mod.setDescription(GrLocale.fr_FR, "Récupère les scènes possédants le tag indiqué");
    mod.setParameters(["tags"]);
    mod.addStatic(&_findScenesByTag, worldType, "findScenesByTag",
        [grList(grString)], [grList(sceneType)]);
/*
    mod.setDescription(GrLocale.fr_FR,
        "Récupère l’entité correspondant au nom donné parmi toutes les scènes");
    mod.setParameters(["name"]);
    mod.addStatic(&_findByName!Entity, worldType, "findEntityByName",
        [grString], [grOptional(entityType)]);
    
    mod.setDescription(GrLocale.fr_FR, "Récupère les entités possédants le tag indiqué");
    mod.setParameters(["tags"]);
    mod.addStatic(&_findByTag!Entity, worldType, "findEntitiesByTag",
        [grList(grString)], [grList(entityType)]);*/
    /*
    mod.setDescription(GrLocale.fr_FR,
        "Récupère la source correspondant au nom donné parmi toutes les scènes");
    mod.setParameters(["name"]);
    mod.addStatic(&_findByName!ParticleSource, worldType,
        "findParticleSourceByName", [grString], [grOptional(particleSourceType)]);
*/ /*
    mod.setDescription(GrLocale.fr_FR, "Récupère les sources possédants le tag indiqué");
    mod.setParameters(["tags"]);
    mod.addStatic(&_findByTag!ParticleSource, worldType,
        "findParticleSourcesByTag", [grList(grString)], [
            grList(particleSourceType)
        ]);*/
    /*
    mod.setDescription(GrLocale.fr_FR,
        "Récupère l’acteur correspondant au nom donné parmi toutes les scènes");
    mod.setParameters(["name"]);
    mod.addStatic(&_findByName!Actor, worldType, "findActorByName",
        [grString], [grOptional(actorType)]);

    mod.setDescription(GrLocale.fr_FR, "Récupère les acteurs possédants le tag indiqué");
    mod.setParameters(["tags"]);
    mod.addStatic(&_findByTag!Actor, worldType, "findActorsByTag",
        [grList(grString)], [grList(actorType)]);

    mod.setDescription(GrLocale.fr_FR,
        "Récupère le solide correspondant au nom donné parmi toutes les scènes");
    mod.setParameters(["name"]);
    mod.addStatic(&_findByName!Solid, worldType, "findSolidByName",
        [grString], [grOptional(solidType)]);

    mod.setDescription(GrLocale.fr_FR, "Récupère les solides possédants le tag indiqué");
    mod.setParameters(["tags"]);
    mod.addStatic(&_findByTag!Solid, worldType, "findSolidsByTag",
        [grList(grString)], [grList(solidType)]);*/
}

private void _addScene(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    Atelier.world.addScene(scene);
}

private void _clear(GrCall call) {
    Atelier.world.clear();
}

private void _removeScene(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    Atelier.world.removeScene(scene);
}

private void _findSceneByName(GrCall call) {
    Scene scene = Atelier.world.findSceneByName(call.getString(0));
    if (scene) {
        call.setNative(scene);
        return;
    }
    call.setNull();
}

private void _findScenesByTag(GrCall call) {
    Scene[] scenes = Atelier.world.findScenesByTag(call.getList(0).getStrings!string());
    GrList result = new GrList;
    result.setNatives(scenes);
    call.setList(result);
}
/*
private void _findByName(T)(GrCall call) {
    T element = Atelier.world.findByName!T(call.getString(0));
    if (element) {
        call.setNative(element);
        return;
    }
    call.setNull();
}

private void _findByTag(T)(GrCall call) {
    GrList result = new GrList;
    result.setNatives(Atelier.world.findByTag!T(call.getList(0).getStrings!string()));
    call.setList(result);
}
*/
