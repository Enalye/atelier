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

package void loadLibScene_level(GrLibDefinition library) {
    library.setModule("scene.level");
    library.setModuleInfo(GrLocale.fr_FR, "Niveau actuel");

    GrType levelType = library.addNative("Level");
    GrType sceneType = grGetNativeType("Scene");
    GrType entityType = grGetNativeType("Entity");
    GrType particleSourceType = grGetNativeType("ParticleSource");
    GrType actorType = grGetNativeType("Actor");
    GrType solidType = grGetNativeType("Solid");

    library.setDescription(GrLocale.fr_FR, "Charge un niveau");
    library.setParameters(["rid"]);
    library.addStatic(&_load, levelType, "load", [grString]);

    library.setDescription(GrLocale.fr_FR, "Ajoute une scène au niveau");
    library.setParameters(["scene"]);
    library.addStatic(&_addScene, levelType, "addScene", [sceneType]);

    library.setDescription(GrLocale.fr_FR, "Récupère la scène correspondant au nom donné");
    library.setParameters(["name"]);
    library.addStatic(&_findSceneByName, levelType, "findSceneByName",
        [grString], [grOptional(sceneType)]);

    library.setDescription(GrLocale.fr_FR, "Récupère les scènes possédants le tag indiqué");
    library.setParameters(["tags"]);
    library.addStatic(&_findScenesByTag, levelType, "findScenesByTag",
        [grList(grString)], [grList(sceneType)]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère l’entité correspondant au nom donné parmi toutes les scènes");
    library.setParameters(["name"]);
    library.addStatic(&_findByName!Entity, levelType, "findEntityByName",
        [grString], [grOptional(entityType)]);

    library.setDescription(GrLocale.fr_FR, "Récupère les entités possédants le tag indiqué");
    library.setParameters(["tags"]);
    library.addStatic(&_findByTag!Entity, levelType, "findEntitiesByTag",
        [grList(grString)], [grList(entityType)]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère la source correspondant au nom donné parmi toutes les scènes");
    library.setParameters(["name"]);
    library.addStatic(&_findByName!ParticleSource, levelType,
        "findParticleSourceByName", [grString], [grOptional(particleSourceType)]);

    library.setDescription(GrLocale.fr_FR, "Récupère les sources possédants le tag indiqué");
    library.setParameters(["tags"]);
    library.addStatic(&_findByTag!ParticleSource, levelType,
        "findParticleSourcesByTag", [grList(grString)], [
            grList(particleSourceType)
        ]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère l’acteur correspondant au nom donné parmi toutes les scènes");
    library.setParameters(["name"]);
    library.addStatic(&_findByName!Actor, levelType, "findActorByName",
        [grString], [grOptional(actorType)]);

    library.setDescription(GrLocale.fr_FR, "Récupère les acteurs possédants le tag indiqué");
    library.setParameters(["tags"]);
    library.addStatic(&_findByTag!Actor, levelType, "findActorsByTag",
        [grList(grString)], [grList(actorType)]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère le solide correspondant au nom donné parmi toutes les scènes");
    library.setParameters(["name"]);
    library.addStatic(&_findByName!Solid, levelType, "findSolidByName",
        [grString], [grOptional(solidType)]);

    library.setDescription(GrLocale.fr_FR, "Récupère les solides possédants le tag indiqué");
    library.setParameters(["tags"]);
    library.addStatic(&_findByTag!Solid, levelType, "findSolidsByTag",
        [grList(grString)], [grList(solidType)]);
}

private void _load(GrCall call) {
    Atelier.scene.load(call.getString(0));
}

private void _addScene(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    Atelier.scene.addScene(scene);
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
