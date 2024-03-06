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
    library.setModuleInfo(GrLocale.fr_FR, "Défini un calque où évolue des entités");
    library.setModuleExample(GrLocale.fr_FR, "var scene = @Scene;
addScene(scene);");

    GrType sceneType = library.addNative("Scene");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType entityType = grGetNativeType("Entity");
    GrType actorType = grGetNativeType("Actor");
    GrType solidType = grGetNativeType("Solid");
    GrType particleSourceType = grGetNativeType("ParticleSource");
    GrType canvasType = grGetNativeType("Canvas");
    GrType uiType = grGetNativeType("UIElement");

    library.setParameters(["width", "height"]);
    library.addConstructor(&_ctor, sceneType);

    library.addProperty(&_name!"get", &_name!"set", "name", sceneType, grString);
    library.addProperty(&_position!"get", &_position!"set", "position", sceneType, vec2fType);
    library.addProperty(&_zOrder!"get", &_zOrder!"set", "zOrder", entityType, grInt);
    library.addProperty(&_isVisible!"get", &_isVisible!"set", "isVisible", sceneType, grBool);
    library.addProperty(&_isAlive, null, "isAlive", sceneType, grBool);
    library.addProperty(&_canvas, null, "canvas", sceneType, canvasType);

    library.setDescription(GrLocale.fr_FR,
        "Récupère l’entité correspondant au nom donné dans la scène");
    library.setParameters(["name"]);
    library.addFunction(&_findByName!Entity, "findEntityByName", [
            sceneType, grString
        ], [grOptional(entityType)]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère les entités possédants le tag indiqué dans la scène");
    library.setParameters(["tags"]);
    library.addFunction(&_findByTag!Entity, "findEntitiesByTag", [
            sceneType, grList(grString)
        ], [grList(entityType)]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère la source correspondant au nom donné dans la scène");
    library.setParameters(["name"]);
    library.addFunction(&_findByName!ParticleSource, "findParticleSourceByName",
        [sceneType, grString], [grOptional(particleSourceType)]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère les sources possédants le tag indiqué dans la scène");
    library.setParameters(["tags"]);
    library.addFunction(&_findByTag!ParticleSource, "findParticleSourcesByTag",
        [sceneType, grList(grString)], [grList(particleSourceType)]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère l’acteur correspondant au nom donné dans la scène");
    library.setParameters(["name"]);
    library.addFunction(&_findByName!Actor, "findActorByName", [
            sceneType, grString
        ], [grOptional(actorType)]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère les acteurs possédants le tag indiqué dans la scène");
    library.setParameters(["tags"]);
    library.addFunction(&_findByTag!Actor, "findActorsByTag", [
            sceneType, grList(grString)
        ], [grList(actorType)]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère le solide correspondant au nom donné dans la scène");
    library.setParameters(["name"]);
    library.addFunction(&_findByName!Solid, "findSolidByName", [
            sceneType, grString
        ], [grOptional(solidType)]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère les solides possédants le tag indiqué dans la scène");
    library.setParameters(["tags"]);
    library.addFunction(&_findByTag!Solid, "findSolidByTag", [
            sceneType, grList(grString)
        ], [grList(solidType)]);

    library.setDescription(GrLocale.fr_FR, "Récupère les tags de la scène");
    library.setParameters(["scene"]);
    library.addFunction(&_getTags, "getTags", [sceneType], [grList(grString)]);

    library.setDescription(GrLocale.fr_FR, "Ajoute un tag à la scène");
    library.setParameters(["scene", "tag"]);
    library.addFunction(&_addTag, "addTag", [sceneType, grString]);

    library.setDescription(GrLocale.fr_FR, "Vérifie si la scène possède le tag");
    library.setParameters(["scene", "tag"]);
    library.addFunction(&_hasTag, "hasTag", [sceneType, grString], [grBool]);

    library.setDescription(GrLocale.fr_FR, "Ajoute une entité à la scène");
    library.setParameters(["scene", "entity"]);
    library.addFunction(&_addEntity, "addEntity", [sceneType, entityType]);

    library.setDescription(GrLocale.fr_FR, "Ajoute une source de particules à la scène");
    library.setParameters(["scene", "source"]);
    library.addFunction(&_addParticleSource, "addParticleSource", [
            sceneType, particleSourceType
        ]);

    library.setDescription(GrLocale.fr_FR, "Ajoute un solide à la scène");
    library.setParameters(["scene", "solid"]);
    library.addFunction(&_addSolid, "addSolid", [sceneType, solidType]);

    library.setDescription(GrLocale.fr_FR, "Ajoute un acteur à la scène");
    library.setParameters(["scene", "actor"]);
    library.addFunction(&_addActor, "addActor", [sceneType, actorType]);

    library.setDescription(GrLocale.fr_FR, "Ajoute un élément d’interface à la scène");
    library.setParameters(["scene", "ui"]);
    library.addFunction(&_addUI, "addUI", [sceneType, uiType]);

    library.setDescription(GrLocale.fr_FR, "Supprime les élements d’interface de la scène");
    library.setParameters(["scene"]);
    library.addFunction(&_clearUI, "clearUI", [sceneType]);

    library.setDescription(GrLocale.fr_FR, "Supprime la scène");
    library.setParameters(["scene"]);
    library.addFunction(&_remove, "remove", [sceneType]);
}

private void _ctor(GrCall call) {
    call.setNative(new Scene);
}

private void _name(string op)(GrCall call) {
    Scene scene = call.getNative!Scene(0);

    static if (op == "set") {
        scene.name = call.getString(1);
    }
    call.setString(scene.name);
}

private void _position(string op)(GrCall call) {
    Scene scene = call.getNative!Scene(0);

    static if (op == "set") {
        scene.position = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(scene.position));
}

private void _zOrder(string op)(GrCall call) {
    Scene scene = call.getNative!Scene(0);

    static if (op == "set") {
        scene.zOrder = call.getInt(1);
    }
    call.setInt(scene.zOrder);
}

private void _isVisible(string op)(GrCall call) {
    Scene scene = call.getNative!Scene(0);

    static if (op == "set") {
        scene.isVisible = call.getBool(1);
    }
    call.setBool(scene.isVisible);
}

private void _isAlive(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    call.setBool(scene.isAlive);
}

private void _canvas(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    call.setNative(scene.canvas);
}

private void _findByName(T)(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    T element = scene.findByName!T(call.getString(1));
    if (element) {
        call.setNative(element);
        return;
    }
    call.setNull();
}

private void _findByTag(T)(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    GrList result = new GrList;
    result.setNatives(scene.findByTag!T(call.getList(1).getStrings!string()));
    call.setList(result);
}

private void _getTags(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    GrList list = new GrList;
    list.setStrings(scene.tags);
    call.setList(list);
}

private void _addTag(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    string tag = call.getString(1);

    foreach (sceneTag; scene.tags) {
        if (sceneTag == tag) {
            return;
        }
    }

    scene.tags ~= tag;
}

private void _hasTag(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    string tag = call.getString(1);

    foreach (sceneTag; scene.tags) {
        if (sceneTag == tag) {
            call.setBool(true);
            return;
        }
    }
    call.setBool(false);
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

private void _addActor(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    Actor actor = call.getNative!Actor(1);
    scene.addActor(actor);
}

private void _addSolid(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    Solid solid = call.getNative!Solid(1);
    scene.addSolid(solid);
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

private void _remove(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    scene.remove();
}
