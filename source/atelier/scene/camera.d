/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.scene.camera;

import atelier.common;
import atelier.scene.entity;

interface CameraFx {
    void update();
}

interface CameraPosition {
    void update();
}

private final class MoveCameraPosition : CameraPosition {
    private {
        Camera _camera;
        Vec2f _startPosition = Vec2f.zero, _endPosition = Vec2f.zero;
        SplineFunc _splineFunc;
        uint _frames;
        uint _frame;
    }

    this(Camera camera, Vec2f position_, uint frames, Spline spline) {
        _camera = camera;
        _startPosition = _camera._position;
        _endPosition = position_;
        _frames = frames;
        _splineFunc = getSplineFunc(spline);
    }

    void update() {
        if (_frame >= _frames) {
            _camera._position = _endPosition;
        }
        else {
            float t = (cast(float) _frame) / cast(float) _frames;
            _camera._position = lerp(_startPosition, _endPosition, _splineFunc(t));
            _frame++;
        }
    }
}

private final class FollowCameraPosition : CameraPosition {
    private {
        Camera _camera;
        Entity _entity;
        Vec2f _damping;
        Vec2f _deadZone = Vec2f.zero;
    }

    this(Camera camera, Entity entity, Vec2f damping, Vec2f deadZone) {
        _camera = camera;
        _entity = entity;
        _damping = damping.clamp(Vec2f.zero, Vec2f.one);
        _deadZone = deadZone.abs();
    }

    void update() {
        Vec2f entityPos = _entity.scenePosition();
        Vec2f position = _camera._position;

        if (position.x < entityPos.x - _deadZone.x) {
            position.x = lerp(_camera._position.x, entityPos.x - _deadZone.x, _damping.x);
        }
        else if (position.x > entityPos.x + _deadZone.x) {
            position.x = lerp(_camera._position.x, entityPos.x + _deadZone.x, _damping.x);
        }
        if (position.y < entityPos.y - _deadZone.y) {
            position.y = lerp(_camera._position.y, entityPos.y - _deadZone.y, _damping.y);
        }
        else if (position.y > entityPos.y + _deadZone.y) {
            position.y = lerp(_camera._position.y, entityPos.y + _deadZone.y, _damping.y);
        }
        _camera._position = position;
    }
}

final class Camera {
    private {
        Vec2f _position = Vec2f.zero;
        CameraPosition _mover;
        CameraFx _fx;
    }

    this() {
    }

    Vec2f getPosition() {
        return _position;
    }

    void setPosition(Vec2f position_) {
        _mover = null;
        _position = position_;
    }

    void moveTo(Vec2f position_, uint frames, Spline spline) {
        _mover = new MoveCameraPosition(this, position_, frames, spline);
    }

    void follow(Entity entity, Vec2f damping, Vec2f deadZone) {
        _mover = new FollowCameraPosition(this, entity, damping, deadZone);
    }

    void stop() {
        _mover = null;
    }

    void update() {
        if (_mover) {
            _mover.update();
        }
    }
}
