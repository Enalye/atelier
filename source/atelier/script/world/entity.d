/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.world.entity;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world;
import atelier.ui;
import atelier.script.util;

package void loadLibWorld_entity(GrModule mod) {
    mod.setModule("world.entity");
    mod.setModuleInfo(GrLocale.fr_FR, "Défini une entité évoluant dans une scène");
    mod.setModuleExample(GrLocale.fr_FR, "var scene = @Scene;
var entity = @Entity(scene);");

    GrType entityType = mod.addNative("Entity");

    GrType sceneType = grGetNativeType("Scene");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType imageType = grGetNativeType("Image");
    GrType particleSourceType = grGetNativeType("ParticleSource");
    GrType canvasType = grGetNativeType("Canvas");
    GrType spriteType = grGetNativeType("Sprite");

    mod.addProperty(&_scene, null, "scene", entityType, sceneType);
    mod.addProperty(&_position!"get", &_position!"set", "position", entityType, vec2fType);
    mod.addProperty(&_worldPosition, null, "worldPosition", entityType, vec2fType);
    mod.addProperty(&_image!"get", &_image!"set", "image", entityType, grOptional(imageType));
    mod.addProperty(&_isValid, null, "isValid", entityType, grBool);
    mod.addProperty(&_isVisible!"get", &_isVisible!"set", "isVisible", entityType, grBool);
    mod.addProperty(&_tags!"get", &_tags!"set", "tags", entityType, grList(grString));

    mod.setDescription(GrLocale.fr_FR, "Crée une entité dans la scène");
    mod.setParameters(["scene"]);
    mod.addConstructor(&_ctor, entityType, [sceneType]);

    mod.setDescription(GrLocale.fr_FR, "Retire une entité de la scène");
    mod.setParameters(["entity"]);
    mod.addFunction(&_remove, "remove", [entityType]);
}

private void _ctor(GrCall call) {
    SEntity entity = new SEntity;
    Scene scene = call.getNative!Scene(0);
    entity.scene = scene;
    entity.id = scene.createEntity();
    call.setNative(entity);
}

private void _scene(GrCall call) {
    SEntity entity = call.getNative!SEntity(0);
    call.setNative(entity.scene);
}

private void _position(string op)(GrCall call) {
    SEntity entity = call.getNative!SEntity(0);
    PositionComponent* position = entity.scene.getPosition(entity.id);

    static if (op == "set") {
        position.localPosition = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(position.localPosition));
}

private void _worldPosition(GrCall call) {
    SEntity entity = call.getNative!SEntity(0);
    PositionComponent* position = entity.scene.getPosition(entity.id);
    call.setNative(svec2(position.worldPosition));
}

private void _isVisible(string op)(GrCall call) {
    SEntity entity = call.getNative!SEntity(0);
    RenderComponent* render = entity.scene.getRender(entity.id);

    static if (op == "set") {
        render.isVisible = call.getBool(1);
    }
    call.setBool(render.isVisible);
}

private void _isValid(GrCall call) {
    SEntity entity = call.getNative!SEntity(0);
    call.setBool(entity.scene.hasEntity(entity.id));
}

private void _tags(string op)(GrCall call) {
    SEntity entity = call.getNative!SEntity(0);
    TagComponent* tag = entity.scene.getOrAddComponent!TagComponent(entity.id);

    static if (op == "set") {
        tag.tags = call.getList(1).getStrings!string();
    }

    GrList result = new GrList;
    result.setStrings!string(tag.tags);
    call.setList(result);
}

private void _remove(GrCall call) {
    SEntity entity = call.getNative!SEntity(0);
    entity.scene.removeEntity(entity.id);
}

private void _image(string op)(GrCall call) {
    SEntity entity = call.getNative!SEntity(0);
    RenderComponent* render = entity.scene.getRender(entity.id);

    static if (op == "set") {
        render.image = call.isNull(1) ? null : call.getNative!Image(1);
    }

    if (render.image) {
        call.setNative(render.image);
    }
    else {
        call.setNull();
    }
}
