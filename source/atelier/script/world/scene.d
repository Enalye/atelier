/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.world.scene;

import std.algorithm;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world;
import atelier.ui;
import atelier.script.util;

package void loadLibWorld_scene(GrModule mod) {
    mod.setModule("world.scene");
    mod.setModuleInfo(GrLocale.fr_FR, "Défini un calque où évolue des entités");
    mod.setModuleExample(GrLocale.fr_FR, "var scene = @Scene;
@World.addScene(scene);");

    GrType sceneType = mod.addNative("Scene");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType imageType = grGetNativeType("Image");
    GrType entityType = grGetNativeType("Entity");
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

    mod.addProperty(&_zOrder!"get", &_zOrder!"set", "zOrder", sceneType, grInt);
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
*/
    mod.setDescription(GrLocale.fr_FR,
        "Récupère les entités possédants le tag indiqué dans la scène");
    mod.setParameters(["tags"]);
    mod.addFunction(&_findByTag, "findByTag", [sceneType, grList(grString)], [
            grList(entityType)
        ]);

    mod.setDescription(GrLocale.fr_FR, "Récupère les tags de la scène");
    mod.setParameters(["scene"]);
    mod.addFunction(&_getTags, "getTags", [sceneType], [grList(grString)]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute un tag à la scène");
    mod.setParameters(["scene", "tag"]);
    mod.addFunction(&_addTag, "addTag", [sceneType, grString]);

    mod.setDescription(GrLocale.fr_FR, "Vérifie si la scène possède le tag");
    mod.setParameters(["scene", "tag"]);
    mod.addFunction(&_hasTag, "hasTag", [sceneType, grString], [grBool]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute une étape système de calcul avant les entités");
    mod.setParameters(["scene", "name"]);
    mod.addFunction(&_addSystemUpdate!true, "addSystemUpdate", [
            sceneType, grString
        ]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute une étape système de calcul après les entités");
    mod.setParameters(["scene", "name"]);
    mod.addFunction(&_addSystemUpdate!false, "addSystemUpdateLate", [
            sceneType, grString
        ]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute une étape système de rendu avant les entités");
    mod.setParameters(["scene", "name", "isAfterEntities"]);
    mod.addFunction(&_addSystemRender!true, "addSystemRender", [
            sceneType, grString
        ]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute une étape système de rendu après les entités");
    mod.setParameters(["scene", "name", "isAfterEntities"]);
    mod.addFunction(&_addSystemRender!false, "addSystemRenderLate", [
            sceneType, grString
        ]);

    mod.setDescription(GrLocale.fr_FR, "Change le mode de calcul des entités");
    mod.setParameters(["scene", "name"]);
    mod.addFunction(&_setSystemEntityUpdate, "setSystemEntityUpdate", [
            sceneType, grString
        ]);

    mod.setDescription(GrLocale.fr_FR, "Change le mode de rendu des entités");
    mod.setParameters(["scene", "name"]);
    mod.addFunction(&_setSystemEntityRender, "setSystemEntityRender", [
            sceneType, grString
        ]);

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
*/
private void _findByTag(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    GrList result = new GrList;

    __componentLoop: foreach (id, component; scene.getComponentPool!TagComponent()) {
        foreach (GrString tag; call.getList(1).getStrings()) {
            if (!canFind(component.tags, tag.str())) {
                continue __componentLoop;
            }
            SEntity entity = new SEntity;
            entity.scene = scene;
            entity.id = id;
            result.pushBack(GrValue(entity));
        }
    }
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

private void _addSystemUpdate(bool isBefore)(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    string name = call.getString(1);
    SystemUpdater system = Atelier.world.getSystem!SystemUpdater(name);

    if (system) {
        void* context = scene.getSystemContext(name);
        scene.addSystemUpdate(system, context, isBefore);
    }
    else {
        call.raise("UndefinedSystemError");
    }
}

private void _addSystemRender(bool isBefore)(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    string name = call.getString(1);
    SystemRenderer system = Atelier.world.getSystem!SystemRenderer(name);

    if (system) {
        void* context = scene.getSystemContext(name);
        scene.addSystemRender(system, context, isBefore);
    }
    else {
        call.raise("UndefinedSystemError");
    }
}

private void _setSystemEntityUpdate(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    SystemEntityUpdater system = Atelier.world.getSystem!SystemEntityUpdater(call.getString(1));

    if (system) {
        scene.setSystemEntityUpdate(system);
    }
    else {
        call.raise("UndefinedSystemError");
    }
}

private void _setSystemEntityRender(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    SystemEntityRenderer system = Atelier.world.getSystem!SystemEntityRenderer(call.getString(1));

    if (system) {
        scene.setSystemEntityRender(system);
    }
    else {
        call.raise("UndefinedSystemError");
    }
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
    PositionComponent* position = scene.getPosition(id);
    position.localPosition.x = call.getFloat(2);
    position.localPosition.y = call.getFloat(3);
}

private void _getPosition(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    EntityID id = call.getUInt(1);
    PositionComponent* position = scene.getPosition(id);
    call.setFloat(position.localPosition.x);
    call.setFloat(position.localPosition.y);
}

private void _setImage(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    EntityID id = call.getUInt(1);
    RenderComponent* render = scene.getRender(id);
    render.image = call.isNull(2) ? null : call.getNative!Image(2);
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
