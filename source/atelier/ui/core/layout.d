
module atelier.ui.core.layout;

import atelier.common;
import atelier.ui.core.element;

abstract class Layout : UIElement {
    private {
        Vec2f _padding = Vec2f.zero;
        Vec2f _margin = Vec2f.zero;
    }

    final Vec2f getPadding() const {
        return _padding;
    }

    final void setPadding(Vec2f padding) {
        _padding = padding;
    }

    final Vec2f getMargin() const {
        return _margin;
    }

    final void setMargin(Vec2f margin) {
        _margin = margin;
    }
}

final class HLayout : Layout {
    private {
        UIAlignY _childAlign = UIAlignY.center;
    }

    this() {
        addEventListener("update", &_onUpdate);
    }

    void setChildAlign(UIAlignY align_) {
        _childAlign = align_;
    }

    UIAlignY getChildAlign() const {
        return _childAlign;
    }

    private void _onUpdate() {
        Vec2f innerSize = Vec2f(0f, _padding.y);
        Vec2f newSize = Vec2f(_margin.x, _padding.y);

        foreach (UIElement child; getChildren()) {
            innerSize.x += child.getWidth();
            innerSize.y = max(innerSize.y, child.getHeight());
        }

        float extraSpace = _padding.x - innerSize.x;

        float spacing = 0f;
        if (extraSpace > 0f && getChildren().length > 1) {
            spacing = extraSpace / ((cast(int) getChildren().length) - 1);
        }

        foreach (const size_t i, UIElement child; getChildren()) {
            child.setAlign(UIAlignX.left, _childAlign);
            child.setPosition(Vec2f(newSize.x, _margin.y));
            newSize.x += child.getWidth() + ((i + 1 < getChildren().length) ? spacing : 0f);
            newSize.y = max(newSize.y, child.getHeight() + _margin.y * 2f);
        }
        newSize.x = max(_padding.x, newSize.x + _margin.x);

        setSize(newSize);
    }
}

final class VLayout : Layout {
    private {
        UIAlignX _childAlign = UIAlignX.center;
    }

    this() {
        addEventListener("update", &_onUpdate);
    }

    void setChildAlign(UIAlignX align_) {
        _childAlign = align_;
    }

    UIAlignX getChildAlign() const {
        return _childAlign;
    }

    private void _onUpdate() {
        Vec2f innerSize = Vec2f(_padding.x, 0f);
        Vec2f newSize = Vec2f(_padding.x, _margin.y);

        foreach (UIElement child; getChildren()) {
            innerSize.x = max(innerSize.x, child.getWidth());
            innerSize.y += child.getHeight();
        }

        float extraSpace = _padding.y - innerSize.y;

        float spacing = 0f;
        if (extraSpace > 0f && getChildren().length > 1) {
            spacing = extraSpace / ((cast(int) getChildren().length) - 1);
        }

        foreach (const size_t i, UIElement child; getChildren()) {
            child.setAlign(_childAlign, UIAlignY.top);
            child.setPosition(Vec2f(_margin.x, newSize.y));
            newSize.y += child.getHeight() + ((i + 1 < getChildren().length) ? spacing : 0f);
            newSize.x = max(newSize.x, child.getWidth() + _margin.x * 2f);
        }
        newSize.y = max(_padding.y, newSize.y + _margin.y);

        setSize(newSize);
    }
}
