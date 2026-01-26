module atelier.world.entity.component.proxy;

import atelier.common;
import atelier.world.entity.base;
import atelier.world.entity.component.base;

final class ProxyComponent : EntityComponent {
    Vec3f relativePosition = Vec3f.zero;
    float relativeAngle = 0f;
    float relativeDistance = 0f;
    Entity base;

    override void setup() {
    }

    override void update() {
    }
}
