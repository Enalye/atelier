/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.select.list;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.ui.core;
import atelier.ui.scrollbar;
import atelier.ui.select.button;
import atelier.ui.select.item;

package final class SelectList : UIElement {
    private {
        RoundedRectangle _background, _outline;
        string _name;
        uint _id;
        SelectButton _button;
        SelectItem[] _items;
        VContentView _contentView;
        VScrollbar _scrollbar;
    }

    this(SelectButton button) {
        _button = button;
        setAlign(UIAlignX.left, UIAlignY.top);

        _contentView = new VContentView;
        _contentView.setAlign(UIAlignX.left, UIAlignY.top);
        _contentView.setChildAlign(UIAlignX.left);
        _contentView.setSpacing(2f);
        _contentView.setPosition(Vec2f(4f, 4f));
        addUI(_contentView);

        _background = RoundedRectangle.fill(getSize(), Atelier.theme.corner);
        _background.color = Atelier.theme.foreground;
        _background.anchor = Vec2f.zero;
        addImage(_background);

        _outline = RoundedRectangle.outline(getSize(), Atelier.theme.corner, 1f);
        _outline.color = Atelier.theme.neutral;
        _outline.anchor = Vec2f.zero;
        addImage(_outline);

        addEventListener("size", &_onSizeChange);
        addEventListener("clickoutside", { _button.removeMenu(); });
        addEventListener("register", &_onRegister);
        addEventListener("unregister", &_onUnregister);

        State hiddenState = new State("hidden");
        hiddenState.scale = Vec2f(1f, 0.5f);
        hiddenState.time = 5;
        hiddenState.spline = Spline.sineInOut;
        addState(hiddenState);

        State visibleState = new State("visible");
        visibleState.time = 5;
        visibleState.spline = Spline.sineInOut;
        addState(visibleState);

        setState("hidden");
        runState("visible");
    }

    private void _onRegister() {
        addEventListener("update", &_updatePosition);
    }

    private void _onUnregister() {
        addEventListener("update", &_updatePosition);
    }

    private void _updatePosition() {
        Vec2f pos = _button.getAbsolutePosition();

        final switch (_button.getListAlignX()) with (UIAlignX) {
        case left:
            break;
        case center:
            pos.x += (_button.getWidth() - getWidth()) / 2f;
            break;
        case right:
            pos.x += _button.getWidth() - getWidth();
            break;
        }

        final switch (_button.getListAlignY()) with (UIAlignY) {
        case top:
        case center:
            pos.y += _button.getHeight() + 4f;
            break;
        case bottom:
            pos.y -= getHeight() + 4f;
            break;
        }

        setPosition(pos);
    }

    private void _onSizeChange() {
        _background.size = getSize();
        _outline.size = getSize();
    }

    private void _updateSize() {
        Vec2f padding = Vec2f(32f, 16f);
        Vec2f margin = Vec2f(4f, 4f);

        Vec2f newSize = Vec2f(padding.x, margin.y);
        float itemWidth = padding.x;

        foreach (SelectItem item; _items) {
            newSize.x = max(newSize.x, item.getWidth() + margin.x * 2f);
            itemWidth = max(itemWidth, item.getWidth());
        }

        foreach (SelectItem item; _items) {
            item.setSize(Vec2f(itemWidth, item.getHeight()));
        }

        const float maxHeight = 196f;

        if (_contentView.getContentHeight() > maxHeight) {
            _contentView.setSize(Vec2f(_contentView.getContentWidth(), maxHeight));

            if (!_scrollbar) {
                _scrollbar = new VScrollbar;
                _scrollbar.setAlign(UIAlignX.right, UIAlignY.top);
                _scrollbar.setWidth(9f);
                _scrollbar.setPosition(Vec2f(1f, 6f));
                addUI(_scrollbar);

                addEventListener("wheel", &_onWheel);
                _scrollbar.addEventListener("handlePosition", &_onHandlePosition);
                _contentView.addEventListener("contentSize", &_onUpdateContent);
            }
        }
        else {
            _contentView.setSize(_contentView.getContentSize());
        }

        newSize.y = max(padding.y, _contentView.getHeight() + margin.y * 2f);

        if (_scrollbar) {
            newSize.x += _scrollbar.getWidth() + margin.x;
            _scrollbar.setHeight(newSize.y - 12f);
        }

        setSize(newSize);
    }

    private void _onHandlePosition() {
        _contentView.setContentPosition(_scrollbar.getContentPosition());
    }

    private void _onUpdateContent() {
        _scrollbar.setContentSize(_contentView.getContentHeight());
    }

    private void _onWheel() {
        _scrollbar.removeEventListener("handlePosition", &_onHandlePosition);

        UIManager manager = getManager();
        InputEvent.MouseWheel ev = manager.input.asMouseWheel();
        _contentView.setContentPosition(_contentView.getContentPosition() - ev.wheel.sum() * 32f);
        _scrollbar.setContentPosition(_contentView.getContentPosition());

        _scrollbar.addEventListener("handlePosition", &_onHandlePosition);
    }

    package void startRemove() {
        runState("hidden");
        removeEventListener("state", &_onRemove);
        addEventListener("state", &_onRemove);
    }

    private void _onRemove() {
        removeEventListener("state", &_onRemove);
        if (getState() == "hidden") {
            removeUI();
        }
    }

    package SelectItem add(string itemName) {
        SelectItem item = new SelectItem(_button, itemName);
        item.setPosition(Vec2f(4f, 0f));
        _items ~= item;
        _contentView.addUI(item);
        _updateSize();
        return item;
    }
}
