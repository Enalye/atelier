module atelier.world.entity.renderer.base;

import atelier.common;
import atelier.render;

abstract class EntityGraphic {
    private {
        bool _isDefault;
        int[] _isBehind;
        uint _slot;
        int _order;
        string[] _auxGraphics;
    }

    this() {

    }

    this(EntityGraphic other) {
        _isDefault = other._isDefault;
        _isBehind = other._isBehind;
        _slot = other._slot;
        _order = other._order;
        _auxGraphics = other._auxGraphics;
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

    final void setSlot(uint slot_) {
        _slot = slot_;
    }

    final uint getSlot() const {
        return _slot;
    }

    final void setOrder(int order_) {
        _order = order_;
    }

    final int getOrder() const {
        return _order;
    }

    final void setAuxGraphics(string[] graphics) {
        _auxGraphics = graphics;
    }

    final const(string[]) getAuxGraphics() const {
        return _auxGraphics;
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
