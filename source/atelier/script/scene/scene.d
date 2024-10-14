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

package void loadLibScene_scene(GrModule mod) {
    mod.setModule("scene.scene");
    mod.setModuleInfo(GrLocale.fr_FR, "Défini un calque où évolue des entités");
    mod.setModuleExample(GrLocale.fr_FR, "var scene = @Scene;
@Level.addScene(scene);");

    GrType sceneType = mod.addNative("Scene");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType entityType = mod.addAlias("Entity", grUInt);
    GrType imageType = grGetNativeType("Image");
    GrType particleSourceType = grGetNativeType("ParticleSource");
    GrType canvasType = grGetNativeType("Canvas");
    GrType spriteType = grGetNativeType("Sprite");

    /*GrType actorType = grGetNativeType("Actor");
    GrType solidType = grGetNativeType("Solid");
    GrType particleSourceType = grGetNativeType("ParticleSource");
    GrType canvasType = grGetNativeType("Canvas");*/
    GrType uiType = grGetNativeType("UIElement");

    mod.setParameters(["width", "height"]);
    mod.addConstructor(&_ctor, sceneType);

    mod.addProperty(&_name!"get", &_name!"set", "name", sceneType, grString);
    mod.addProperty(&_position!"get", &_position!"set", "position", sceneType, vec2fType);

    mod.setDescription(GrLocale.fr_FR, "Position de la souris dans la scène");
    mod.addProperty(&_mousePosition, null, "mousePosition", sceneType, vec2fType);

    mod.addProperty(&_zOrder!"get", &_zOrder!"set", "zOrder", entityType, grInt);
    mod.addProperty(&_isVisible!"get", &_isVisible!"set", "isVisible", sceneType, grBool);
    /*mod.addProperty(&_isAlive, null, "isAlive", sceneType, grBool);
    mod.addProperty(&_showColliders!"get", &_showColliders!"set",
        "showColliders", sceneType, grBool);*/
    /*    mod.addProperty(&_canvas, null, "canvas", sceneType, canvasType);

    mod.setDescription(GrLocale.fr_FR,
        "Récupère l’entité correspondant au nom donné dans la scène");
    mod.setParameters(["name"]);
    mod.addFunction(&_findByName!Entity, "findEntityByName", [
            sceneType, grString
        ], [grOptional(entityType)]);

    mod.setDescription(GrLocale.fr_FR,
        "Récupère les entités possédants le tag indiqué dans la scène");
    mod.setParameters(["tags"]);
    mod.addFunction(&_findByTag!Entity, "findEntitiesByTag", [
            sceneType, grList(grString)
        ], [grList(entityType)]);

    mod.setDescription(GrLocale.fr_FR,
        "Récupère la source correspondant au nom donné dans la scène");
    mod.setParameters(["name"]);
    mod.addFunction(&_findByName!ParticleSource, "findParticleSourceByName",
        [sceneType, grString], [grOptional(particleSourceType)]);

    mod.setDescription(GrLocale.fr_FR,
        "Récupère les sources possédants le tag indiqué dans la scène");
    mod.setParameters(["tags"]);
    mod.addFunction(&_findByTag!ParticleSource, "findParticleSourcesByTag",
        [sceneType, grList(grString)], [grList(particleSourceType)]);

    mod.setDescription(GrLocale.fr_FR,
        "Récupère l’acteur correspondant au nom donné dans la scène");
    mod.setParameters(["name"]);
    mod.addFunction(&_findByName!Actor, "findActorByName", [sceneType,
            grString], [grOptional(actorType)]);

    mod.setDescription(GrLocale.fr_FR,
        "Récupère les acteurs possédants le tag indiqué dans la scène");
    mod.setParameters(["tags"]);
    mod.addFunction(&_findByTag!Actor, "findActorsByTag", [
            sceneType, grList(grString)
        ], [grList(actorType)]);

    mod.setDescription(GrLocale.fr_FR,
        "Récupère le solide correspondant au nom donné dans la scène");
    mod.setParameters(["name"]);
    mod.addFunction(&_findByName!Solid, "findSolidByName", [sceneType,
            grString], [grOptional(solidType)]);

    mod.setDescription(GrLocale.fr_FR,
        "Récupère les solides possédants le tag indiqué dans la scène");
    mod.setParameters(["tags"]);
    mod.addFunction(&_findByTag!Solid, "findSolidByTag", [
            sceneType, grList(grString)
        ], [grList(solidType)]);
*/
    mod.setDescription(GrLocale.fr_FR, "Récupère les tags de la scène");
    mod.setParameters(["scene"]);
    mod.addFunction(&_getTags, "getTags", [sceneType], [grList(grString)]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute un tag à la scène");
    mod.setParameters(["scene", "tag"]);
    mod.addFunction(&_addTag, "addTag", [sceneType, grString]);

    mod.setDescription(GrLocale.fr_FR, "Vérifie si la scène possède le tag");
    mod.setParameters(["scene", "tag"]);
    mod.addFunction(&_hasTag, "hasTag", [sceneType, grString], [grBool]);

    mod.setDescription(GrLocale.fr_FR, "Crée une entité dans la scène");
    mod.setParameters(["scene", "entity"]);
    mod.addFunction(&_createEntity, "createEntity", [sceneType], [entityType]);

    mod.setDescription(GrLocale.fr_FR, "Retire une entité de la scène");
    mod.setParameters(["scene", "entity"]);
    mod.addFunction(&_removeEntity, "removeEntity", [sceneType, entityType]);

    mod.setDescription(GrLocale.fr_FR, "Modifie la position de l’entité");
    mod.setParameters(["scene", "entity", "x", "y"]);
    mod.addFunction(&_setPosition, "setPosition", [
            sceneType, entityType, grFloat, grFloat
        ]);

    mod.setDescription(GrLocale.fr_FR, "Récupère la position de l’entité");
    mod.setParameters(["scene", "entity"]);
    mod.addFunction(&_getPosition, "getPosition", [sceneType, entityType], [
            grFloat, grFloat
        ]);

    mod.setDescription(GrLocale.fr_FR, "Associe une image à l’entité");
    mod.setParameters(["scene", "entity", "image"]);
    mod.addFunction(&_setImage, "setImage", [
            sceneType, entityType, grOptional(imageType)
        ]);

    mod.setDescription(GrLocale.fr_FR, "Associe une source de particules à l’entité");
    mod.setParameters(["scene", "entity", "source"]);
    mod.addFunction(&_setParticleSource, "setParticleSource", [
            sceneType, entityType, grOptional(particleSourceType)
        ]);

    /*
    mod.setDescription(GrLocale.fr_FR, "Ajoute une source de particules à la scène");
    mod.setParameters(["scene", "source"]);
    mod.addFunction(&_addParticleSource, "addParticleSource", [
            sceneType, particleSourceType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute un solide à la scène");
    mod.setParameters(["scene", "solid"]);
    mod.addFunction(&_addSolid, "addSolid", [sceneType, solidType]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute un acteur à la scène");
    mod.setParameters(["scene", "actor"]);
    mod.addFunction(&_addActor, "addActor", [sceneType, actorType]);
*/
    mod.setDescription(GrLocale.fr_FR, "Ajoute un élément d’interface à la scène");
    mod.setParameters(["scene", "ui"]);
    mod.addFunction(&_addUI, "addUI", [sceneType, uiType]);

    mod.setDescription(GrLocale.fr_FR, "Supprime les élements d’interface de la scène");
    mod.setParameters(["scene"]);
    mod.addFunction(&_clearUI, "clearUI", [sceneType]);
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

private void _mousePosition(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    call.setNative(svec2(scene.mousePosition));
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
/*
private void _isAlive(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    call.setBool(scene.isAlive);
}

private void _showColliders(string op)(GrCall call) {
    Scene scene = call.getNative!Scene(0);

    static if (op == "set") {
        scene.showColliders = call.getBool(1);
    }

    call.setBool(scene.showColliders);
}*/
/*
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
*/
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

private void _createEntity(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    EntityID id = scene.createEntity();
    call.setUInt(id);
}

private void _removeEntity(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    EntityID id = call.getUInt(1);
    scene.removeEntity(id);
}

private void _setPosition(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    EntityID id = call.getUInt(1);
    Vec2f* position = scene.getLocalPosition(id);
    position.x = call.getFloat(2);
    position.y = call.getFloat(3);
}

private void _getPosition(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    EntityID id = call.getUInt(1);
    Vec2f* position = scene.getLocalPosition(id);
    call.setFloat(position.x);
    call.setFloat(position.y);
}

private void _setImage(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    EntityID id = call.getUInt(1);
    RenderComponent* render = scene.getRender(id);
    render.image = call.isNull(2) ? null : call.getNative!Image(2);
}

private void _setParticleSource(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    EntityID id = call.getUInt(1);
    if (call.isNull(2)) {
        scene.removeComponent!ParticleComponent(id);
    }
    else {
        ParticleComponent* part = scene.addComponent!ParticleComponent(id);
        part.source = call.getNative!ParticleSource(2);
        part.id = id;
    }
}
/*
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
*/
private void _addUI(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    UIElement ui = call.getNative!UIElement(1);
    scene.addUI(ui);
}

private void _clearUI(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    scene.clearUI();
}
