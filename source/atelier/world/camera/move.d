module atelier.world.camera.move;

import atelier.common;
import atelier.world.camera.system;

final class MoveCameraPosition : CameraPositioner {
    private {
        Camera _camera;
        Vec2f _startPosition = Vec2f.zero, _endPosition = Vec2f.zero;
        SplineFunc _splineFunc;
        uint _frames;
        uint _frame;
    }

    @property {
        bool isRunning() const {
            return _frame < _frames;
        }
    }

    this(Camera camera, Vec2f position_, uint frames, Spline spline) {
        _camera = camera;
        _startPosition = _camera.getPosition(false);
        _endPosition = position_;
        _frames = frames;
        _splineFunc = getSplineFunc(spline);
    }

    void update() {
        if (_frame >= _frames) {
            _camera.updatePosition(_endPosition);
        }
        else {
            float t = (cast(float) _frame) / cast(float) _frames;
            _camera.updatePosition(lerp(_startPosition, _endPosition, _splineFunc(t)));
            _frame++;
        }
    }

    Vec2f getTargetPosition() const {
        return _endPosition;
    }
}
