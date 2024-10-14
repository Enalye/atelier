/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.scene.camera;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.scene.scene;

interface CameraPositioner {
    void update();
}

private final class MoveCameraPosition : CameraPositioner {
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

private final class FollowCameraPosition : CameraPositioner {
    private {
        Camera _camera;
        Scene _scene;
        EntityID _id;
        Vec2f _damping;
        Vec2f _deadZone = Vec2f.zero;
    }

    this(Camera camera, Scene scene, EntityID id, Vec2f damping, Vec2f deadZone) {
        _camera = camera;
        _scene = scene;
        _id = id;
        _damping = damping.clamp(Vec2f.zero, Vec2f.one);
        _deadZone = deadZone.abs();
    }

    void update() {
        Vec2f entityPos = *_scene.getWorldPosition(_id);
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

final class CameraShaker {
    private {
        Vec2f _offset = Vec2f.zero;
        float _angle = 0f;
        float _shakeTrauma = 0f, _rumbleTrauma = 0f, _shakeIntensity = 0f, _rumbleIntensity = 0f;
        double _shakeTime = 0.0, _rumbleTime = 0.0;
        uint _rumbleFrame, _rumbleFrames;
        float _initRumble = 0f, _targetRumble = 0f;
        SplineFunc _rumbleSplineFunc;
    }

    @property {
        Vec2f offset() const {
            return _offset;
        }

        float angle() const {
            return _angle;
        }
    }

    void reset() {
        _shakeTrauma = 0f;
        _rumbleTrauma = 0f;
    }

    void shake(float trauma) {
        _shakeTrauma += trauma;
        if (_shakeTrauma > 1f)
            _shakeTrauma = 1f;
    }

    void rumble(float trauma, uint frames, Spline spline) {
        _initRumble = _rumbleTrauma;
        _targetRumble = trauma;
        _rumbleFrame = 0;
        _rumbleFrames = frames;
        _rumbleSplineFunc = getSplineFunc(spline);
    }

    void update() {
        if (_rumbleFrame < _rumbleFrames) {
            float t = (cast(float) _rumbleFrame) / cast(float) _rumbleFrames;
            _rumbleTrauma = lerp(_initRumble, _targetRumble, _rumbleSplineFunc(t));
            _rumbleFrame++;
        }

        _shakeTime += 0.1f;
        _rumbleTime += 0.01f;

        _shakeIntensity = clamp(_shakeTrauma * _shakeTrauma, 0f, 1f);
        _rumbleIntensity = clamp(_rumbleTrauma * _rumbleTrauma, 0f, 1f);

        _angle = _shakeIntensity * noise(_shakeTime, 0.0);
        _offset.x = 30f * _shakeIntensity * noise(_shakeTime, 10_000.0);
        _offset.y = 30f * _shakeIntensity * noise(_shakeTime, 20_000.0);

        _angle += 0.5f * _rumbleIntensity * noise(_rumbleTime, 30_000.0);
        _offset.x += 10f * _rumbleIntensity * noise(_rumbleTime, 40_000.0);
        _offset.y += 10f * _rumbleIntensity * noise(_rumbleTime, 50_000.0);

        _shakeTrauma = approach(_shakeTrauma, 0f, 0.05f);
    }
}

final class CameraZoomer {
    private {
        float _currentZoom = 1f, _initZoom = 1f, _targetZoom = 1f;
        uint _zoomFrame, _zoomFrames;
        SplineFunc _zoomSplineFunc;
        Vec2f _nominalSize = Vec2f.zero;
        Vec2f _zoomSize = Vec2f.zero;
    }

    this() {
        _nominalSize = cast(Vec2f) Atelier.renderer.size;
        _zoomSize = _nominalSize;
    }

    @property {
        Vec2f size() const {
            return _zoomSize;
        }
    }

    void zoom(float zoomLevel, uint frames, Spline spline) {
        _initZoom = _currentZoom;
        _targetZoom = max(1f, zoomLevel);
        _zoomFrames = frames;
        _zoomFrame = 0;
        _zoomSplineFunc = getSplineFunc(spline);
    }

    void update() {
        if (_zoomFrame < _zoomFrames) {
            float t = (cast(float) _zoomFrame) / cast(float) _zoomFrames;
            _currentZoom = lerp(_initZoom, _targetZoom, _zoomSplineFunc(t));
            _zoomSize = _nominalSize * _currentZoom;
            _zoomFrame++;
        }
    }
}

final class Camera {
    private {
        Canvas _canvas;
        Sprite _sprite;

        Vec2f _position = Vec2f.zero;
        CameraPositioner _positioner;
        CameraShaker _shaker;
        CameraZoomer _zoomer;
    }

    @property {
        Canvas canvas() {
            return _canvas;
        }
    }

    this() {
        Vec2i renderSize = Atelier.renderer.size;
        _canvas = new Canvas(renderSize.x, renderSize.y);
        _sprite = new Sprite(_canvas);
        _sprite.anchor = Vec2f.half;
        _sprite.position = (cast(Vec2f) renderSize) / 2f;

        _shaker = new CameraShaker;
        _zoomer = new CameraZoomer;
    }

    Vec2f getPosition() {
        return _position;
    }

    void setPosition(Vec2f position_) {
        _positioner = null;
        _position = position_;
    }

    void moveTo(Vec2f position_, uint frames, Spline spline) {
        _positioner = new MoveCameraPosition(this, position_, frames, spline);
    }

    void follow(Scene scene, EntityID id, Vec2f damping, Vec2f deadZone) {
        _positioner = new FollowCameraPosition(this, scene, id, damping, deadZone);
    }

    void stop() {
        _positioner = null;
    }

    void zoom(float zoomLevel, uint frames, Spline spline) {
        _zoomer.zoom(zoomLevel, frames, spline);
    }

    void shake(float trauma) {
        _shaker.shake(trauma);
    }

    void rumble(float trauma, uint frames, Spline spline) {
        _shaker.rumble(trauma, frames, spline);
    }

    void update() {
        if (_positioner) {
            _positioner.update();
        }

        _zoomer.update();
        _shaker.update();
    }

    void draw() {
        _sprite.size = _zoomer.size();
        _sprite.angle = _shaker.angle();
        _sprite.draw(_shaker.offset());
    }
}
