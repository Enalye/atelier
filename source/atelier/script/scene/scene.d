/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.scene.scene;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.scene;
import atelier.ui;
import atelier.script.util;

package void loadLibScene_scene(GrLibDefinition library) {
    library.setModule("scene.scene");
    library.setModuleInfo(GrLocale.fr_FR, "Défini une caméra où évolue des entités");
    library.setModuleExample(GrLocale.fr_FR, "var scene = @Scene(@App.width, @App.height);
addScene(scene);");

    GrType sceneType = library.addNative("Scene");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType entityType = grGetNativeType("Entity");
    GrType particleSourceType = grGetNativeType("ParticleSource");
    GrType canvasType = grGetNativeType("Canvas");
    GrType uiType = grGetNativeType("UIElement");

    library.setParameters(["width", "height"]);
    library.addConstructor(&_ctor, sceneType, [grInt, grInt]);

    library.addProperty(&_position!"get", &_position!"set", "position", sceneType, vec2fType);
    library.addProperty(&_isVisible!"get", &_isVisible!"set", "isVisible", sceneType, grBool);
    library.addProperty(&_canvas, null, "canvas", sceneType, canvasType);

    library.setDescription(GrLocale.fr_FR, "Charge un niveau");
    library.setParameters(["name"]);
    library.addFunction(&_loadLevel, "loadLevel", [grString]);

    library.setDescription(GrLocale.fr_FR, "Ajoute une scène à l’application");
    library.setParameters(["scene"]);
    library.addFunction(&_addScene, "addScene", [sceneType]);

    library.setDescription(GrLocale.fr_FR, "Récupère la scène correspondant au nom donné");
    library.setParameters(["name"]);
    library.addFunction(&_fetchNamedScene, "fetchNamedScene", [grString], [
            grOptional(sceneType)
        ]);

    library.setDescription(GrLocale.fr_FR, "Récupère les scènes possédants le tag indiqué");
    library.setParameters(["tags"]);
    library.addFunction(&_fetchTaggedScenes, "fetchTaggedScenes",
        [grList(grString)], [grList(sceneType)]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère l’entité correspondant au nom donné parmi toutes les scènes");
    library.setParameters(["name"]);
    library.addFunction(&_fetchNamedEntity, "fetchNamedEntity", [grString],
        [grOptional(entityType)]);

    library.setDescription(GrLocale.fr_FR, "Récupère les entités possédants le tag indiqué");
    library.setParameters(["tags"]);
    library.addFunction(&_fetchTaggedEntities, "fetchTaggedEntities",
        [grList(grString)], [grList(entityType)]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère l’entité correspondant au nom donné dans la scène");
    library.setParameters(["name"]);
    library.addFunction(&_fetchNamedEntity_scene, "fetchNamedEntity",
        [sceneType, grString], [grOptional(entityType)]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère les entités possédants le tag indiqué dans la scène");
    library.setParameters(["tags"]);
    library.addFunction(&_fetchTaggedEntities, "fetchTaggedEntities",
        [sceneType, grList(grString)], [grList(entityType)]);

    library.setDescription(GrLocale.fr_FR, "Ajoute une entité à la scène");
    library.setParameters(["scene", "entity"]);
    library.addFunction(&_addEntity, "addEntity", [sceneType, entityType]);

    library.setDescription(GrLocale.fr_FR, "Ajoute une source de particules à la scène");
    library.setParameters(["scene", "source"]);
    library.addFunction(&_addParticleSource, "addParticleSource", [
            sceneType, particleSourceType
        ]);

    library.setDescription(GrLocale.fr_FR, "Ajoute un élément d’interface à la scène");
    library.setParameters(["scene", "ui"]);
    library.addFunction(&_addUI, "addUI", [sceneType, uiType]);

    library.setDescription(GrLocale.fr_FR, "Supprime les élements d’interface de la scène");
    library.setParameters(["scene"]);
    library.addFunction(&_clearUI, "clearUI", [sceneType]);
}

private void _ctor(GrCall call) {
    call.setNative(new Scene(call.getInt(0), call.getInt(1)));
}

private void _position(string op)(GrCall call) {
    Scene scene = call.getNative!Scene(0);

    static if (op == "set") {
        scene.position = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(scene.position));
}

private void _isVisible(string op)(GrCall call) {
    Scene scene = call.getNative!Scene(0);

    static if (op == "set") {
        scene.isVisible = call.getBool(1);
    }
    call.setBool(scene.isVisible);
}

private void _canvas(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    call.setNative(scene.canvas);
}

private void _loadLevel(GrCall call) {
    Atelier.scene.load(call.getString(0));
}

private void _addScene(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    Atelier.scene.addScene(scene);
}

private void _fetchNamedScene(GrCall call) {
    Scene scene = Atelier.scene.fetchNamedScene(call.getString(0));
    if (scene) {
        call.setNative(scene);
        return;
    }
    call.setNull();
}

private void _fetchTaggedScenes(GrCall call) {
    GrString[] list = call.getList(0).getStrings();
    string[] tags;
    foreach (element; list) {
        tags ~= element;
    }
    Scene[] scenes = Atelier.scene.fetchTaggedScenes(tags);
    GrList result = new GrList;
    result.setNatives(scenes);
    call.setList(result);
}

private void _fetchNamedEntity(GrCall call) {
    Entity entity = Atelier.scene.fetchNamedEntity(call.getString(0));
    if (entity) {
        call.setNative(entity);
        return;
    }
    call.setNull();
}

private void _fetchTaggedEntities(GrCall call) {
    GrString[] list = call.getList(0).getStrings();
    string[] tags;
    foreach (element; list) {
        tags ~= element;
    }
    Entity[] entities = Atelier.scene.fetchTaggedEntities(tags);
    GrList result = new GrList;
    result.setNatives(entities);
    call.setList(result);
}

private void _fetchNamedEntity_scene(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    Entity entity = scene.fetchNamedEntity(call.getString(1));
    if (entity) {
        call.setNative(entity);
        return;
    }
    call.setNull();
}

private void _fetchTaggedEntities_scene(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    GrString[] list = call.getList(1).getStrings();
    string[] tags;
    foreach (element; list) {
        tags ~= element;
    }
    Entity[] entities = scene.fetchTaggedEntities(tags);
    GrList result = new GrList;
    result.setNatives(entities);
    call.setList(result);
}

private void _addEntity(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    Entity entity = call.getNative!Entity(1);
    scene.addEntity(entity);
}

private void _addParticleSource(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    ParticleSource source = call.getNative!ParticleSource(1);
    scene.addParticleSource(source);
}

private void _addUI(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    UIElement ui = call.getNative!UIElement(1);
    scene.addUI(ui);
}

private void _clearUI(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    scene.clearUI();
}
