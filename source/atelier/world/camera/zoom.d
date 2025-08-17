module atelier.world.camera.zoom;

import atelier.common;
import atelier.core;
import atelier.render;

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

    void reset() {
        _zoomSize = _nominalSize;
        _zoomFrame = 0;
        _zoomFrames = 0;
    }

    void zoom(float zoomLevel, uint frames, Spline spline) {
        _initZoom = _currentZoom;
        _targetZoom = max(1f, zoomLevel);
        _zoomFrames = frames;
        _zoomFrame = 0;
        _zoomSplineFunc = getSplineFunc(spline);

        if (_zoomFrame < _zoomFrames) {
            float t = (cast(float) _zoomFrame) / cast(float) _zoomFrames;
            _currentZoom = lerp(_initZoom, _targetZoom, _zoomSplineFunc(t));
        }
        else {
            _currentZoom = _targetZoom;
        }

        _zoomSize = _nominalSize * _currentZoom;
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
