module atelier.world.camera.system;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world.scene;
import atelier.world.entity;
import atelier.world.camera.follow;
import atelier.world.camera.focus;
import atelier.world.camera.move;
import atelier.world.camera.shake;
import atelier.world.camera.zoom;

interface CameraPositioner {
    @property {
        bool isRunning() const;
    }
    void update();
    Vec2f getTargetPosition() const;
}

final class Camera {
    private {
        Canvas _canvas;
        Sprite _sprite;

        Vec2f _position = Vec2f.zero;
        CameraPositioner _positioner, _defaultPositioner;
        CameraShaker _shaker;
        CameraZoomer _zoomer;

        Vec2f _minBounds = Vec2f.zero;
        Vec2f _maxBounds = Vec2f.zero;
        bool _hasXBounds, _hasYBounds;
        void delegate() _onMoveFinishCallback;

        float _startBlurFactor, _endBlurFactor, _blurFactor = 0f;
        Timer _blurTimer;
        SplineFunc _blurSplineFunc;
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

    package {
        void updatePosition(Vec2f position_) {
            _position = position_;
        }
    }

    void reset() {
        _shaker.reset();
        _zoomer.reset();
        _positioner = null;
        _position = Vec2f(_canvas.width, _canvas.height) / 2f;
    }

    void setBounds(bool hasXBounds, bool hasYBounds, Vec2f minBounds, Vec2f maxBounds) {
        _hasXBounds = hasXBounds;
        _hasYBounds = hasYBounds;
        _minBounds = minBounds;
        _maxBounds = maxBounds;
    }

    Vec2f getPosition(bool boundedPosition = true) const {
        if (boundedPosition)
            return getBoundedPositionOf(_position);
        return _position;
    }

    Vec2f getBoundedPositionOf(Vec2f position_) const {
        if (_hasXBounds) {
            position_.x = clamp(position_.x, _minBounds.x,
                _maxBounds.x);
        }
        if (_hasYBounds) {
            position_.y = clamp(position_.y, _minBounds.y,
                _maxBounds.y);
        }
        return position_;
    }

    void setPosition(Vec2f position_, bool stopBehavior = true) {
        if (stopBehavior) {
            _positioner = null;
        }
        _position = position_;
    }

    Vec4f getRelativePosition(Entity entity) const {
        Vec2f entityPos = entity.cameraPosition();
        Vec2f halfRenderSize = (cast(Vec2f) Atelier.renderer.size) / 2f;
        Vec2f cameraPos = getPosition();

        Vec4f result = Vec4f.zero;
        result.x = (entityPos.x + halfRenderSize.x) - cameraPos.x;
        result.y = (entityPos.y + halfRenderSize.y) - cameraPos.y;
        result.z = (cameraPos.x + halfRenderSize.x) - entityPos.x;
        result.w = (cameraPos.y + halfRenderSize.y) - entityPos.y;
        return result;
    }

    void setOnMoveCallback(void delegate() callback) {
        _onMoveFinishCallback = callback;
    }

    void moveTo(Vec2f position_, uint frames, Spline spline) {
        _positioner = new MoveCameraPosition(this, position_, frames, spline);
        _onMoveFinishCallback = null;
    }

    void follow(Entity entity, Vec2f damping, Vec2f deadZone) {
        _positioner = new FollowCameraPosition(this, entity, damping, deadZone);
        _onMoveFinishCallback = null;
    }

    void focus(Entity entity, Vec3i center, Vec2f damping, Vec2f deadZone) {
        _positioner = new FocusCameraPosition(this, entity, center, damping, deadZone);
        _onMoveFinishCallback = null;
    }

    void stop(bool backToDefault = true) {
        if (backToDefault && _positioner != _defaultPositioner) {
            _positioner = _defaultPositioner;
        }
        else {
            _positioner = null;
        }
        _onMoveFinishCallback = null;
    }

    void setDefault() {
        _defaultPositioner = _positioner;
    }

    void zoom(float zoomLevel, uint frames, Spline spline) {
        _zoomer.zoom(zoomLevel, frames, spline);
    }

    void blurShake(float trauma) {
        _shaker.blurShake(trauma);
    }

    void shake(float trauma) {
        _shaker.shake(trauma);
    }

    void rumble(float trauma, uint frames, Spline spline) {
        _shaker.rumble(trauma, frames, spline);
    }

    void rumble(float trauma) {
        _shaker.rumble(trauma);
    }

    void blur(float factor, uint duration, Spline spline) {
        factor = clamp(factor, 0f, 1f);
        if (duration == 0) {
            _blurFactor = factor;
            _startBlurFactor = factor;
            _endBlurFactor = factor;
            _blurSplineFunc = getSplineFunc(spline);
            _blurTimer.stop();
            return;
        }
        _startBlurFactor = _blurFactor;
        _endBlurFactor = factor;
        _blurTimer.start(duration);
        _blurSplineFunc = getSplineFunc(spline);
    }

    void update() {
        if (_positioner) {
            _positioner.update();

            if (!_positioner.isRunning) {
                if (_onMoveFinishCallback) {
                    _onMoveFinishCallback();
                }
                stop();
            }
        }

        _zoomer.update();
        _shaker.update();

        _blurTimer.update();
        if (_blurTimer.isRunning) {
            _blurFactor = lerp(_startBlurFactor, _endBlurFactor,
                _blurSplineFunc(_blurTimer.value01));
        }
        else {
            _blurFactor = 0f;
        }
    }

    void draw() {
        Vec2f position = _shaker.getOffset();
        Vec2f size = _zoomer.size();

        _sprite.blend = Blend.alpha;
        _sprite.size = size;
        _sprite.angle = _shaker.getAngle();
        _sprite.alpha = 1f;
        _sprite.color = Color.white;
        _sprite.draw(position);

        if (_shaker.isBlurred()) {
            for (uint i; i < 5; ++i) {
                _sprite.blend = Blend.additive;
                _sprite.alpha = 1f * _shaker.getBlurFactor();
                _sprite.color = Color.black;
                _sprite.color.r = _shaker.getBlurColor(i).r;
                _sprite.angle = _shaker.getBlurAngle(i);
                _sprite.draw(_shaker.getBlurOffset(i));
            }
        }
        if (_blurFactor > 0f) {
            _sprite.alpha = .5f * _blurFactor;
            _sprite.size = size * lerp(1f, 1.2f, _blurFactor);
            _sprite.draw(position);
            _sprite.size = size * lerp(1f, 1.4f, _blurFactor);
            _sprite.draw(position);
            _sprite.size = size * lerp(1f, 1.6f, _blurFactor);
            _sprite.draw(position);
        }
    }

    Vec2f getTargetPosition() const {
        if (!_positioner)
            return _position;
        return _positioner.getTargetPosition();
    }
}
