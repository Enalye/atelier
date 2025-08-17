module atelier.world.entity.renderer.sprite;

import atelier.common;
import atelier.render;
import atelier.world.entity.renderer.base;

final class EntitySpriteRenderer : EntityGraphic {
    private {
        Sprite _sprite;
        bool _isRotating;
        float _alpha = 1f;
        float _angle = 0f;
        float _angleOffset = 0f;
    }

    this(Sprite sprite) {
        _sprite = sprite;
    }

    this(EntitySpriteRenderer other) {
        super(other);
        _sprite = new Sprite(other._sprite);
        _isRotating = other._isRotating;
        _alpha = other._alpha;
        _angle = other._angle;
        _angleOffset = other._angleOffset;
    }

    override EntityGraphic fetch() {
        return new EntitySpriteRenderer(this);
    }

    override void setAnchor(Vec2f anchor) {
        _sprite.anchor = anchor;
    }

    override void setPivot(Vec2f pivot) {
        _sprite.pivot = pivot;
    }

    override void setOffset(Vec2f position) {
        _sprite.position = position;
    }

    override void setAngle(float angle) {
        _angle = angle;
        if (_isRotating) {
            _sprite.angle = _angle + _angleOffset;
        }
    }

    override void setRotating(bool isRotating) {
        _isRotating = isRotating;
    }

    override void setAngleOffset(float angle) {
        _angleOffset = angle;
        if (_isRotating) {
            _sprite.angle = _angle + _angleOffset;
        }
    }

    override void setBlend(Blend blend) {
        _sprite.blend = blend;
    }

    override void setAlpha(float alpha) {
        _alpha = alpha;
    }

    override void setColor(Color color) {
        _sprite.color = color;
    }

    override void setScale(Vec2f scale) {
        _sprite.size = (cast(Vec2f) _sprite.clip.zw) * scale;
    }

    override void start() {
    }

    override void stop() {
    }

    override void pause() {
    }

    override void resume() {
    }

    override void update() {
    }

    override bool isPlaying() const {
        return false;
    }

    override void draw(Vec2f offset, float alpha = 1f) {
        _sprite.alpha = _alpha * alpha;
        _sprite.draw(offset);
    }

    override float getLeft(float x) const {
        return x + _sprite.position.x - (_sprite.anchor.x * _sprite.size.x);
    }

    override float getRight(float x) const {
        return x + _sprite.position.x + _sprite.size.x - (_sprite.anchor.x * _sprite.size.x);
    }

    override float getUp(float y) const {
        return y + _sprite.position.y - (_sprite.anchor.y * _sprite.size.y);
    }

    override float getDown(float y) const {
        return y + _sprite.position.y + _sprite.size.y - (_sprite.anchor.y * _sprite.size.y);
    }

    override uint getWidth() const {
        return _sprite.width;
    }

    override uint getHeight() const {
        return _sprite.height;
    }

    override bool isBehind() const {
        const(int[]) rules = getIsBehind();

        if (rules.length > 0)
            return rules[0] != 0;
        return false;
    }
}
