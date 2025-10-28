module atelier.world.entity.renderer.anim;

import atelier.common;
import atelier.render;
import atelier.world.entity.renderer.base;

final class EntityAnimRenderer : EntityGraphic {
    private {
        Animation _anim;
        bool _isRotating;
        float _alpha = 1f;
        float _angle = 0f;
        float _angleOffset = 0f;
        Vec2i _effectMargin;
    }

    this(Animation anim) {
        _anim = anim;
    }

    this(EntityAnimRenderer other) {
        super(other);
        _anim = new Animation(other._anim);
        _isRotating = other._isRotating;
        _alpha = other._alpha;
        _angle = other._angle;
        _angleOffset = other._angleOffset;
        _effectMargin = other._effectMargin;
    }

    override EntityGraphic fetch() {
        return new EntityAnimRenderer(this);
    }

    override void setAnchor(Vec2f anchor) {
        _anim.anchor = anchor;
    }

    override void setPivot(Vec2f pivot) {
        _anim.pivot = pivot;
    }

    override void setOffset(Vec2f position) {
        _anim.position = position;
    }

    override void setAngle(float angle) {
        _angle = angle;
        if (_isRotating) {
            _anim.angle = _angle + _angleOffset;
        }
    }

    override void setRotating(bool isRotating) {
        _isRotating = isRotating;
    }

    override void setAngleOffset(float angle) {
        _angleOffset = angle;
        if (_isRotating) {
            _anim.angle = _angle + _angleOffset;
        }
    }

    override void setBlend(Blend blend) {
        _anim.blend = blend;
    }

    override void setAlpha(float alpha) {
        _alpha = alpha;
    }

    override void setColor(Color color) {
        _anim.color = color;
    }

    override void setScale(Vec2f scale) {
        _anim.size = (cast(Vec2f) _anim.clip.zw) * scale;
    }

    override void setEffectMargin(Vec2i margin) {
        _effectMargin = margin;
    }

    override void start() {
        _anim.start();
    }

    override void stop() {
        _anim.stop();
    }

    override void pause() {
        _anim.pause();
    }

    override void resume() {
        _anim.resume();
    }

    override void update() {
        _anim.update();
    }

    override bool isPlaying() const {
        return _anim.isPlaying();
    }

    override void draw(Vec2f offset, float alpha = 1f) {
        _anim.alpha = _alpha * alpha;
        _anim.draw(offset);
    }

    override float getLeft(float x) const {
        return x + _anim.position.x - (_anim.anchor.x * _anim.size.x);
    }

    override float getRight(float x) const {
        return x + _anim.position.x + _anim.size.x - (_anim.anchor.x * _anim.size.x);
    }

    override float getUp(float y) const {
        return y + _anim.position.y - (_anim.anchor.y * _anim.size.y);
    }

    override float getDown(float y) const {
        return y + _anim.position.y + _anim.size.y - (_anim.anchor.y * _anim.size.y);
    }

    override uint getWidth() const {
        return _anim.width;
    }

    override uint getHeight() const {
        return _anim.height;
    }

    override uint getEffectWidth() const {
        return _anim.width + _effectMargin.x;
    }

    override uint getEffectHeight() const {
        return _anim.height + _effectMargin.y;
    }

    override bool isBehind() const {
        const(int[]) rules = getIsBehind();

        if (rules.length > 0)
            return rules[0] != 0;
        return false;
    }
}
