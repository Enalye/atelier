module atelier.world.grid;

import atelier.common;
import atelier.world.scene;

/*
package(atelier.world) void registerSystems_grid(World world) {
    world.registerSystem!SystemUpdater("grid", &_updateSystem);
    world.registerSystem!SystemInitializer("grid", &_initSystem);
}

final class GridSystem {
    Vec2f tileSize = Vec2f(32f, 32f);
    uint duration = 30;
    SplineFunc splineFunc = getSplineFunc(Spline.linear);
}

struct TilePositionComponent {
    Vec2f originPosition;
    Vec2i tilePosition;
    float timer;

    void onInit() {
        originPosition = Vec2f.zero;
        tilePosition = Vec2i.zero;
        timer = 0f;
    }

    void onDestroy() {

    }
}

private void* _initSystem(Scene scene) {
    return cast(void*) new GridSystem;
}

private void _updateSystem(Scene scene, void* context) {
    EntityComponentPool!TilePositionComponent pool = scene
        .getComponentPool!TilePositionComponent();

    GridSystem sys = cast(GridSystem) context;
    Vec2f tileSize = sys.tileSize;
    float duration = sys.duration;

    foreach (id, tile; pool) {
        PositionComponent* position = scene.getComponent!PositionComponent(id);
        if (tile.timer > 0) {
            float t = 1f - tile.timer;
            position.localPosition = lerp(tile.originPosition,
                tileSize * cast(Vec2f) tile.tilePosition, sys.splineFunc(t));
            tile.timer -= 1f / duration;
        }
        else {
            position.localPosition = tileSize * cast(Vec2f) tile.tilePosition;
        }
    }
}
*/
