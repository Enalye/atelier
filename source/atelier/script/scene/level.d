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
    library.addStatic(&_fetchSceneByName, levelType, "fetchSceneByName",
        [grString], [grOptional(sceneType)]);

    library.setDescription(GrLocale.fr_FR, "Récupère les scènes possédants le tag indiqué");
    library.setParameters(["tags"]);
    library.addStatic(&_fetchScenesByTag, levelType, "fetchScenesByTag",
        [grList(grString)], [grList(sceneType)]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère l’entité correspondant au nom donné parmi toutes les scènes");
    library.setParameters(["name"]);
    library.addStatic(&_fetchEntityByName, levelType, "fetchEntityByName",
        [grString], [grOptional(entityType)]);

    library.setDescription(GrLocale.fr_FR, "Récupère les entités possédants le tag indiqué");
    library.setParameters(["tags"]);
    library.addStatic(&_fetchEntitiesByTag, levelType, "fetchEntitiesByTag",
        [grList(grString)], [grList(entityType)]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère l’entité correspondant au nom donné parmi toutes les scènes");
    library.setParameters(["name"]);
    library.addStatic(&_fetchParticleSourceByName, levelType,
        "fetchParticleSourceByName", [grString], [
            grOptional(particleSourceType)
        ]);

    library.setDescription(GrLocale.fr_FR, "Récupère les entités possédants le tag indiqué");
    library.setParameters(["tags"]);
    library.addStatic(&_fetchParticleSourcesByTag, levelType,
        "fetchParticleSourcesByTag", [grList(grString)], [
            grList(particleSourceType)
        ]);
}

private void _load(GrCall call) {
    Atelier.scene.load(call.getString(0));
}

private void _addScene(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    Atelier.scene.addScene(scene);
}

private void _fetchSceneByName(GrCall call) {
    Scene scene = Atelier.scene.fetchSceneByName(call.getString(0));
    if (scene) {
        call.setNative(scene);
        return;
    }
    call.setNull();
}

private void _fetchScenesByTag(GrCall call) {
    Scene[] scenes = Atelier.scene.fetchScenesByTag(call.getList(0).getStrings!string());
    GrList result = new GrList;
    result.setNatives(scenes);
    call.setList(result);
}

private void _fetchEntityByName(GrCall call) {
    Entity entity = Atelier.scene.fetchEntityByName(call.getString(0));
    if (entity) {
        call.setNative(entity);
        return;
    }
    call.setNull();
}

private void _fetchEntitiesByTag(GrCall call) {
    Entity[] entities = Atelier.scene.fetchEntitiesByTag(call.getList(0).getStrings!string());
    GrList result = new GrList;
    result.setNatives(entities);
    call.setList(result);
}

private void _fetchParticleSourceByName(GrCall call) {
    ParticleSource source = Atelier.scene.fetchParticleSourceByName(call.getString(0));
    if (source) {
        call.setNative(source);
        return;
    }
    call.setNull();
}

private void _fetchParticleSourcesByTag(GrCall call) {
    ParticleSource[] sources = Atelier.scene.fetchParticleSourcesByTag(call.getList(0)
            .getStrings!string());
    GrList result = new GrList;
    result.setNatives(sources);
    call.setList(result);
}
