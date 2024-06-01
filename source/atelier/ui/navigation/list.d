/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.navigation.list;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.ui.core;
import atelier.ui.scrollbar;

abstract class List : UIElement {
    protected {
        Scrollbar _scrollbar;
        ContentView _contentView;
        Rectangle _background;
    }

    this() {
        _background = Rectangle.fill(getSize());
        _background.color = Atelier.theme.background;
        _background.anchor = Vec2f.zero;
        addImage(_background);

        addEventListener("size", &_onSize);
    }

    final void setColor(Color color_) {
        _background.color = color_;
    }

    final void addList(UIElement element) {
        _contentView.addUI(element);
    }

    final UIElement[] getList() {
        return _contentView.getChildren().array;
    }

    final void clearList() {
        _contentView.clearUI();
        _contentView.setContentPosition(0f);
    }

    private void _onSize() {
        _background.size = getSize();
    }

    final float getContentPosition() {
        return _contentView.getContentPosition();
    }

    final void setContentPosition(float position) {
        _contentView.setContentPosition(position);
        _scrollbar.setContentPosition(_contentView.getContentPosition());
    }

    final float getSpacing() const {
        return _contentView.getSpacing();
    }

    final void setSpacing(float spacing_) {
        _contentView.setSpacing(spacing_);
    }
}

final class HList : List {
    this(float scrollbarSize = 9f) {
        HContentView contentView = new HContentView;
        contentView.setAlign(UIAlignX.left, UIAlignY.top);
        contentView.setChildAlign(UIAlignY.top);
        addUI(contentView);

        _contentView = contentView;

        _scrollbar = new HScrollbar;
        _scrollbar.setAlign(UIAlignX.left, UIAlignY.bottom);
        _scrollbar.setHeight(scrollbarSize);
        addUI(_scrollbar);

        addEventListener("size", &_onSize);
        addEventListener("wheel", &_onWheel);
        _contentView.addEventListener("contentSize", &_onUpdateContent);
        _scrollbar.addEventListener("handlePosition", &_onHandlePosition);
    }

    UIAlignY getChildAlign() const {
        return (cast(HContentView) _contentView).getChildAlign();
    }

    void setChildAlign(UIAlignY align_) {
        (cast(HContentView) _contentView).setChildAlign(align_);
    }

    private void _onSize() {
        _scrollbar.setWidth(getWidth());
        _contentView.setSize(getSize() - Vec2f(0f, _scrollbar.getHeight()));
        _scrollbar.isVisible = _contentView.getContentWidth() > getWidth();
    }

    private void _onUpdateContent() {
        _scrollbar.setContentSize(_contentView.getContentWidth());
        _scrollbar.isVisible = _contentView.getContentWidth() > getWidth();
    }

    private void _onHandlePosition() {
        _contentView.setContentPosition(_scrollbar.getContentPosition());
    }

    private void _onWheel() {
        _scrollbar.removeEventListener("handlePosition", &_onHandlePosition);

        UIManager manager = getManager();
        InputEvent.MouseWheel ev = manager.input.asMouseWheel();
        _contentView.setContentPosition(_contentView.getContentPosition() - ev.wheel.sum() * 32f);
        _scrollbar.setContentPosition(_contentView.getContentPosition());

        _scrollbar.addEventListener("handlePosition", &_onHandlePosition);
    }
}

final class VList : List {
    this(float scrollbarSize = 9f) {
        VContentView contentView = new VContentView;
        contentView.setAlign(UIAlignX.left, UIAlignY.top);
        contentView.setChildAlign(UIAlignX.left);
        addUI(contentView);

        _contentView = contentView;

        _scrollbar = new VScrollbar;
        _scrollbar.setAlign(UIAlignX.right, UIAlignY.top);
        _scrollbar.setWidth(scrollbarSize);
        addUI(_scrollbar);

        addEventListener("size", &_onSize);
        addEventListener("wheel", &_onWheel);
        _contentView.addEventListener("contentSize", &_onUpdateContent);
        _scrollbar.addEventListener("handlePosition", &_onHandlePosition);
    }

    UIAlignX getChildAlign() const {
        return (cast(VContentView) _contentView).getChildAlign();
    }

    void setChildAlign(UIAlignX align_) {
        (cast(VContentView) _contentView).setChildAlign(align_);
    }

    private void _onSize() {
        _scrollbar.setHeight(getHeight());
        _contentView.setSize(getSize() - Vec2f(_scrollbar.getWidth(), 0f));
        _scrollbar.isVisible = _contentView.getContentHeight() > getHeight();
    }

    private void _onUpdateContent() {
        _scrollbar.setContentSize(_contentView.getContentHeight());
        _scrollbar.isVisible = _contentView.getContentHeight() > getHeight();
    }

    private void _onHandlePosition() {
        _contentView.setContentPosition(_scrollbar.getContentPosition());
    }

    private void _onWheel() {
        _scrollbar.removeEventListener("handlePosition", &_onHandlePosition);

        UIManager manager = getManager();
        InputEvent.MouseWheel ev = manager.input.asMouseWheel();
        _contentView.setContentPosition(_contentView.getContentPosition() - ev.wheel.sum() * 32f);
        _scrollbar.setContentPosition(_contentView.getContentPosition());

        _scrollbar.addEventListener("handlePosition", &_onHandlePosition);
    }
}
