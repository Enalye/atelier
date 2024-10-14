/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.scene.level;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.scene;
import atelier.ui;
import atelier.script.util;

package void loadLibScene_level(GrModule mod) {
    mod.setModule("scene.level");
    mod.setModuleInfo(GrLocale.fr_FR, "Niveau actuel");

    GrType levelType = mod.addNative("Level");
    GrType sceneType = grGetNativeType("Scene");
    GrType entityType = grGetNativeType("Entity");
    GrType particleSourceType = grGetNativeType("ParticleSource");
    GrType actorType = grGetNativeType("Actor");
    GrType solidType = grGetNativeType("Solid");

    mod.setDescription(GrLocale.fr_FR, "Ajoute une scène au niveau");
    mod.setParameters(["scene"]);
    mod.addStatic(&_addScene, levelType, "addScene", [sceneType]);

    mod.setDescription(GrLocale.fr_FR, "Retire une scène du niveau");
    mod.setParameters(["scene"]);
    mod.addStatic(&_removeScene, levelType, "removeScene", [sceneType]);

    mod.setDescription(GrLocale.fr_FR, "Récupère la scène correspondant au nom donné");
    mod.setParameters(["name"]);
    mod.addStatic(&_findSceneByName, levelType, "findSceneByName", [grString],
        [grOptional(sceneType)]);

    mod.setDescription(GrLocale.fr_FR, "Récupère les scènes possédants le tag indiqué");
    mod.setParameters(["tags"]);
    mod.addStatic(&_findScenesByTag, levelType, "findScenesByTag",
        [grList(grString)], [grList(sceneType)]);
/*
    mod.setDescription(GrLocale.fr_FR,
        "Récupère l’entité correspondant au nom donné parmi toutes les scènes");
    mod.setParameters(["name"]);
    mod.addStatic(&_findByName!Entity, levelType, "findEntityByName",
        [grString], [grOptional(entityType)]);
    
    mod.setDescription(GrLocale.fr_FR, "Récupère les entités possédants le tag indiqué");
    mod.setParameters(["tags"]);
    mod.addStatic(&_findByTag!Entity, levelType, "findEntitiesByTag",
        [grList(grString)], [grList(entityType)]);*/
    /*
    mod.setDescription(GrLocale.fr_FR,
        "Récupère la source correspondant au nom donné parmi toutes les scènes");
    mod.setParameters(["name"]);
    mod.addStatic(&_findByName!ParticleSource, levelType,
        "findParticleSourceByName", [grString], [grOptional(particleSourceType)]);
*/ /*
    mod.setDescription(GrLocale.fr_FR, "Récupère les sources possédants le tag indiqué");
    mod.setParameters(["tags"]);
    mod.addStatic(&_findByTag!ParticleSource, levelType,
        "findParticleSourcesByTag", [grList(grString)], [
            grList(particleSourceType)
        ]);*/
    /*
    mod.setDescription(GrLocale.fr_FR,
        "Récupère l’acteur correspondant au nom donné parmi toutes les scènes");
    mod.setParameters(["name"]);
    mod.addStatic(&_findByName!Actor, levelType, "findActorByName",
        [grString], [grOptional(actorType)]);

    mod.setDescription(GrLocale.fr_FR, "Récupère les acteurs possédants le tag indiqué");
    mod.setParameters(["tags"]);
    mod.addStatic(&_findByTag!Actor, levelType, "findActorsByTag",
        [grList(grString)], [grList(actorType)]);

    mod.setDescription(GrLocale.fr_FR,
        "Récupère le solide correspondant au nom donné parmi toutes les scènes");
    mod.setParameters(["name"]);
    mod.addStatic(&_findByName!Solid, levelType, "findSolidByName",
        [grString], [grOptional(solidType)]);

    mod.setDescription(GrLocale.fr_FR, "Récupère les solides possédants le tag indiqué");
    mod.setParameters(["tags"]);
    mod.addStatic(&_findByTag!Solid, levelType, "findSolidsByTag",
        [grList(grString)], [grList(solidType)]);*/
}

private void _addScene(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    Atelier.scene.addScene(scene);
}

private void _removeScene(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    Atelier.scene.removeScene(scene);
}

private void _findSceneByName(GrCall call) {
    Scene scene = Atelier.scene.findSceneByName(call.getString(0));
    if (scene) {
        call.setNative(scene);
        return;
    }
    call.setNull();
}

private void _findScenesByTag(GrCall call) {
    Scene[] scenes = Atelier.scene.findScenesByTag(call.getList(0).getStrings!string());
    GrList result = new GrList;
    result.setNatives(scenes);
    call.setList(result);
}
/*
private void _findByName(T)(GrCall call) {
    T element = Atelier.scene.findByName!T(call.getString(0));
    if (element) {
        call.setNative(element);
        return;
    }
    call.setNull();
}

private void _findByTag(T)(GrCall call) {
    GrList result = new GrList;
    result.setNatives(Atelier.scene.findByTag!T(call.getList(0).getStrings!string()));
    call.setList(result);
}
*/
