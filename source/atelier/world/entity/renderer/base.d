module atelier.world.entity.renderer.base;

import atelier.common;
import atelier.render;

abstract class EntityGraphic {
    private {
        bool _isDefault;
        int[] _isBehind;
    }

    this() {

    }

    this(EntityGraphic other) {
        _isDefault = other._isDefault;
        _isBehind = other._isBehind;
    }

    final void setDefault(bool isDefault) {
        _isDefault = isDefault;
    }

    final bool getDefault() const {
        return _isDefault;
    }

    final void setIsBehind(int[] isBehind_) {
        _isBehind = isBehind_;
    }

    final const(int[]) getIsBehind() const {
        return _isBehind;
    }

    EntityGraphic fetch();
    void setAnchor(Vec2f anchor);
    void setPivot(Vec2f pivot);
    void setOffset(Vec2f position);
    void setAngle(float angle);
    void setRotating(bool isRotating);
    void setAngleOffset(float angle);
    void setBlend(Blend blend);
    void setAlpha(float alpha);
    void setColor(Color color);
    void setScale(Vec2f scale);
    void setEffectMargin(Vec2i margin);
    void start();
    void stop();
    void pause();
    void resume();
    void update();
    bool isPlaying() const;
    void draw(Vec2f offset, float alpha = 1f);
    float getLeft(float x) const;
    float getRight(float x) const;
    float getUp(float y) const;
    float getDown(float y) const;
    uint getWidth() const;
    uint getHeight() const;
    uint getEffectWidth() const;
    uint getEffectHeight() const;
    bool isBehind() const;
}
