/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.core.contentview;

import atelier.common;
import atelier.ui.core.element;

abstract class ContentView : UIElement {
    private {
        Vec2f _contentSize = Vec2f.zero;
        float _contentPosition = 0f;
        float _offset = 0f;
        float _spacing = 0f;
    }

    final Vec2f getContentSize() const {
        return _contentSize;
    }

    protected final void setContentSize(Vec2f contentSize) {
        if (_contentSize != contentSize) {
            _contentSize = contentSize;
            dispatchEvent("contentSize", false);
        }
    }

    final float getContentWidth() const {
        return _contentSize.x;
    }

    final float getContentHeight() const {
        return _contentSize.y;
    }

    final float getContentPosition() const {
        return _contentPosition;
    }

    final void setContentPosition(float position) {
        _contentPosition = clamp(position, 0f, _getContentLength());
    }

    final float getChildOffset() const {
        return _offset;
    }

    final void setChildOffset(float offset) {
        _offset = offset;
    }

    final float getSpacing() const {
        return _spacing;
    }

    final void setSpacing(float spacing) {
        _spacing = spacing;
    }

    protected abstract float _getContentLength() const;
}

final class HContentView : ContentView {
    private {
        UIAlignY _childAlign = UIAlignY.center;
    }

    this() {
        addEventListener("update", &_onUpdate);
        addEventListener("addchild", &_onUpdate);
        addEventListener("removechild", &_onUpdate);
    }

    void setChildAlign(UIAlignY align_) {
        _childAlign = align_;
    }

    UIAlignY getChildAlign() const {
        return _childAlign;
    }

    private void _onUpdate() {
        Vec2f contentSize = Vec2f.zero;

        foreach (UIElement child; getChildren()) {
            child.setAlign(UIAlignX.left, _childAlign);
            child.setPosition(Vec2f(contentSize.x - _contentPosition, _offset));
            contentSize.x += child.getWidth() + _spacing;
            contentSize.y = max(contentSize.y, child.getHeight());
        }

        setContentSize(contentSize);
    }

    protected override float _getContentLength() const {
        return max(0f, _contentSize.x - getWidth());
    }
}

final class VContentView : ContentView {
    private {
        UIAlignX _childAlign = UIAlignX.center;
    }

    this() {
        addEventListener("update", &_onUpdate);
        addEventListener("addchild", &_onUpdate);
        addEventListener("removechild", &_onUpdate);
    }

    void setChildAlign(UIAlignX align_) {
        _childAlign = align_;
    }

    UIAlignX getChildAlign() const {
        return _childAlign;
    }

    private void _onUpdate() {
        Vec2f contentSize = Vec2f.zero;

        foreach (UIElement child; getChildren()) {
            child.setAlign(_childAlign, UIAlignY.top);
            child.setPosition(Vec2f(_offset, contentSize.y - _contentPosition));
            contentSize.y += child.getHeight() + _spacing;
            contentSize.x = max(contentSize.x, child.getWidth());
        }

        setContentSize(contentSize);
    }

    protected override float _getContentLength() const {
        return max(0f, _contentSize.y - getHeight());
    }
}
