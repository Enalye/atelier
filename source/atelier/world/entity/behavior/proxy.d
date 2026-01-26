module atelier.world.entity.behavior.proxy;

import atelier.common;
import atelier.world.entity.base;
import atelier.world.entity.component;
import atelier.world.entity.behavior.base;

final class ProxyBehavior : EntityBehavior {
    private {
        ProxyComponent _component;
    }

    void attachTo(Entity entity) {
        _component.base = entity;
    }

    void setRelativePosition(Vec3f position) {
        _component.relativePosition = position;
    }

    void setRelativeAngle(float angle) {
        _component.relativeAngle = angle;
    }

    void setRelativeDistance(float distance) {
        _component.relativeDistance = distance;
    }

    override void setup() {
        _component = entity.getComponent!ProxyComponent();
    }

    override void update() {
        if (!_component.base)
            return;

        Vec3f pos = cast(Vec3f) _component.base.getPosition();
        _component.relativePosition += entity.velocity();
        pos += _component.relativePosition;
        Vec2f dir = Vec2f.angled(degToRad(_component.relativeAngle));
        pos += Vec3f(dir * _component.relativeDistance, 0f).round();
        entity.setPosition(pos);
    }
}
