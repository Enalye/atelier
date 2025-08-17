module atelier.world.camera.focus;

import atelier.common;
import atelier.world.entity;
import atelier.world.camera.system;

final class FocusCameraPosition : CameraPositioner {
    private {
        Camera _camera;
        Entity _entity;
        Vec2f _damping;
        Vec2f _deadZone = Vec2f.zero;
        Vec2f _center;
    }

    @property {
        bool isRunning() const {
            return true;
        }
    }

    this(Camera camera, Entity entity, Vec3i center, Vec2f damping, Vec2f deadZone) {
        _camera = camera;
        _entity = entity;
        _center = Vec2f(center.x, center.y - center.z);
        _damping = damping.clamp(Vec2f.zero, Vec2f.one);
        _deadZone = deadZone.abs();
    }

    void update() {
        Vec2f entityPos = _camera.getBoundedPositionOf(_entity.cameraPosition);
        Vec2f position = _camera.getPosition(false);

        Vec2f targetPos = lerp(entityPos, _center, 0.5f);

        if (position.x < targetPos.x - _deadZone.x) {
            position.x = lerp(position.x, targetPos.x - _deadZone.x, _damping.x);
        }
        else if (position.x > targetPos.x + _deadZone.x) {
            position.x = lerp(position.x, targetPos.x + _deadZone.x, _damping.x);
        }
        if (position.y < targetPos.y - _deadZone.y) {
            position.y = lerp(position.y, targetPos.y - _deadZone.y, _damping.y);
        }
        else if (position.y > targetPos.y + _deadZone.y) {
            position.y = lerp(position.y, targetPos.y + _deadZone.y, _damping.y);
        }
        _camera.updatePosition(position);
    }

    Vec2f getTargetPosition() const {
        return _entity.cameraPosition();
    }
}
