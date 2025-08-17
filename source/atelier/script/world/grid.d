module atelier.script.world.grid;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world;
import atelier.ui;
import atelier.script.util;

package void loadLibWorld_grid(GrModule mod) {
    mod.setModule("world.grid");
    mod.setModuleInfo(GrLocale.fr_FR, "Gestion des entités sur une grille");
    mod.setModuleExample(GrLocale.fr_FR, "scene.setTilePosition(entity, 0, 0);");
/*
    GrType sceneType = grGetNativeType("Scene");
    GrType entityType = grGetNativeType("Entity");
    GrType splineType = grGetEnumType("Spline");
    GrType vec2iType = grGetNativeType("Vec2", [grInt]);

    mod.setDescription(GrLocale.fr_FR, "Définit la taille de chaque tuile");
    mod.setParameters(["scene", "width", "height"]);
    mod.addFunction(&_setGridTileSize, "setGridTileSize", [
            sceneType, grFloat, grFloat
        ]);

    mod.setDescription(GrLocale.fr_FR, "Définit les paramètres de déplacement intertuile");
    mod.setParameters(["scene", "duration", "spline"]);
    mod.addFunction(&_setGridMovement, "setGridMovement", [
            sceneType, grUInt, splineType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Positionne l’entité sur une grille");
    mod.setParameters(["entity", "position"]);
    mod.addFunction(&_setTilePosition, "setTilePosition", [
            entityType, vec2iType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Déplace l’entité sur une grille");
    mod.setParameters(["entity", "position"]);
    mod.addFunction(&_moveTilePosition, "moveTilePosition", [
            entityType, vec2iType
        ]);*/
}
/*
private void _setGridTileSize(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    GridSystem context = cast(GridSystem) scene.getSystemContext("grid");
    context.tileSize.x = call.getFloat(1);
    context.tileSize.y = call.getFloat(2);
}

private void _setGridMovement(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    GridSystem context = cast(GridSystem) scene.getSystemContext("grid");
    context.duration = call.getUInt(1);
    context.splineFunc = getSplineFunc(call.getEnum!Spline(2));
}

private void _setTilePosition(GrCall call) {
    SEntity entity = call.getNative!SEntity(0);

    if (entity.scene.hasComponent!TilePositionComponent(entity.id)) {
        TilePositionComponent* tile = entity.scene.getComponent!TilePositionComponent(entity.id);
        tile.tilePosition.x = call.getInt(1);
        tile.tilePosition.y = call.getInt(2);
    }
    else {
        TilePositionComponent* tile = entity.scene.addComponent!TilePositionComponent(entity.id);
        tile.tilePosition.x = call.getInt(1);
        tile.tilePosition.y = call.getInt(2);
    }
}

private void _moveTilePosition(GrCall call) {
    SEntity entity = call.getNative!SEntity(0);

    if (entity.scene.hasComponent!TilePositionComponent(entity.id)) {
        TilePositionComponent* tile = entity.scene.getComponent!TilePositionComponent(entity.id);

        if (tile.timer <= 0f) {
            PositionComponent* position = entity.scene.getComponent!PositionComponent(entity.id);
            tile.originPosition = position.localPosition;
            tile.tilePosition += call.getNative!SVec2i(1);
            tile.timer = 1f;
        }
    }
    else {
        TilePositionComponent* tile = entity.scene.addComponent!TilePositionComponent(entity.id);
        tile.tilePosition = call.getNative!SVec2i(1);
    }
}*/
