module atelier.world.entity.renderer.base;

import atelier.common;
import atelier.render;

abstract class EntityGraphic {
    final class AuxOffsetData {
        struct Offset {
            int[] xOffsets;
            int[] yOffsets;
            float[] angleOffsets;
            bool overrideIsBehind;
            int[] isBehind;
        }

        private {
            Offset _defaultOffset;
            Offset[uint] _dirOffsets;
        }

        void addDir(uint dir, Offset offset) {
            _dirOffsets[dir] = offset;
        }

        void setDefault(Offset offset) {
            _defaultOffset = offset;
        }

        Offset getOffset(uint frameDir) {
            auto p = frameDir in _dirOffsets;
            if (!p)
                return _defaultOffset;
            return *p;
        }
    }

    private {
        bool _isDefault;
        int[] _isBehind;
        uint _slot;
        int _order;
        AuxOffsetData[string] _auxGraphics;
        AuxOffsetData _auxOffsetData;
        Vec2f _auxOffset = Vec2f.zero;
        float _auxAngle = 0f;
        bool _overrideIsBehind;
        int[] _overridenIsBehind;
    }

    @property {
        Vec2f auxOffset() const {
            return _auxOffset;
        }

        float auxAngle() const {
            return _auxAngle;
        }
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
        if (_overrideIsBehind)
            return _overridenIsBehind;
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

    final void addAuxGraphics(string id, uint[] dirs, int[] xOffsets, int[] yOffsets, float[] angleOffsets, bool overrideIsBehind, int[] isBehind) {
        AuxOffsetData data = _auxGraphics.require(id, { return new AuxOffsetData; }());

        if (dirs.length) {
            foreach (dir; dirs) {
                data.addDir(dir, AuxOffsetData.Offset(xOffsets, yOffsets, angleOffsets, overrideIsBehind, isBehind));
            }
        }
        else {
            data.setDefault(AuxOffsetData.Offset(xOffsets, yOffsets, angleOffsets, overrideIsBehind, isBehind));
        }
    }

    final const(string[]) getAuxGraphics() const {
        return _auxGraphics.keys;
    }

    final AuxOffsetData getAuxOffsetData(string id) {
        auto p = id in _auxGraphics;
        if (p)
            return *p;
        return null;
    }

    final void setAuxOffsetData(AuxOffsetData data) {
        _auxOffsetData = data;
    }

    final void updateAuxOffset(uint frameId, uint frameDir) {
        if (!_auxOffsetData) {
            _auxOffset.set(0f, 0f);
            _auxAngle = 0f;
            return;
        }

        AuxOffsetData.Offset offset = _auxOffsetData.getOffset(frameDir);

        if (frameId >= offset.xOffsets.length) {
            if (offset.xOffsets.length)
                _auxOffset.x = offset.xOffsets[$ - 1];
            else
                _auxOffset.x = 0f;
        }
        else {
            _auxOffset.x = offset.xOffsets[frameId];
        }

        if (frameId >= offset.yOffsets.length) {
            if (offset.yOffsets.length)
                _auxOffset.y = offset.yOffsets[$ - 1];
            else
                _auxOffset.y = 0f;
        }
        else {
            _auxOffset.y = offset.yOffsets[frameId];
        }

        if (frameId >= offset.angleOffsets.length) {
            if (offset.angleOffsets.length)
                _auxAngle = offset.angleOffsets[$ - 1];
            else
                _auxAngle = 0f;
        }
        else {
            _auxAngle = offset.angleOffsets[frameId];
        }

        _overrideIsBehind = offset.overrideIsBehind;
        _overridenIsBehind = offset.isBehind;
        onUpdateAuxOffset();
    }

    void onUpdateAuxOffset() {
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
    bool isRepeating() const;
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

    uint getFrameTime() const {
        return 0;
    }

    uint getFrame() const {
        return 0;
    }

    uint getFrameId() const {
        return 0;
    }

    uint getDir() const {
        return 0;
    }

    uint getTick() const {
        return 0;
    }

    void setTick(uint tick) {
    }
}
