/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
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

    GrType sceneType = grGetNativeType("Scene");
    GrType entityType = grUInt;
    GrType splineType = grGetEnumType("Spline");

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
    mod.setParameters(["scene", "entity", "x", "y"]);
    mod.addFunction(&_setTilePosition, "setTilePosition", [
            sceneType, entityType, grInt, grInt
        ]);

    mod.setDescription(GrLocale.fr_FR, "Déplace l’entité sur une grille");
    mod.setParameters(["scene", "entity", "x", "y"]);
    mod.addFunction(&_moveTilePosition, "moveTilePosition", [
            sceneType, entityType, grInt, grInt
        ]);
}

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
    Scene scene = call.getNative!Scene(0);
    EntityID id = call.getUInt(1);
    if (scene.hasComponent!TilePositionComponent(id)) {
        TilePositionComponent* tile = scene.getComponent!TilePositionComponent(id);
        tile.tilePosition.x = call.getInt(2);
        tile.tilePosition.y = call.getInt(3);
    }
    else {
        TilePositionComponent* tile = scene.addComponent!TilePositionComponent(id);
        tile.tilePosition.x = call.getInt(2);
        tile.tilePosition.y = call.getInt(3);
    }
}

private void _moveTilePosition(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    EntityID id = call.getUInt(1);
    if (scene.hasComponent!TilePositionComponent(id)) {
        TilePositionComponent* tile = scene.getComponent!TilePositionComponent(id);

        if (tile.timer <= 0f) {
            PositionComponent* position = scene.getComponent!PositionComponent(id);
            tile.originPosition = position.localPosition;
            tile.tilePosition.x += call.getInt(2);
            tile.tilePosition.y += call.getInt(3);
            tile.timer = 1f;
        }
    }
    else {
        TilePositionComponent* tile = scene.addComponent!TilePositionComponent(id);
        tile.tilePosition.x = call.getInt(2);
        tile.tilePosition.y = call.getInt(3);
    }
}
