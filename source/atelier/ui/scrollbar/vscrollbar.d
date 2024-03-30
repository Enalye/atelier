/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.scrollbar.vscrollbar;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.scrollbar.base;

final class VScrollbar : Scrollbar {
    private {
        Capsule _background, _handle;
        Color _grabColor;
    }

    this() {
        setSize(Vec2f(9f, 0f));
        setSizeLock(true, false);

        _background = Capsule.fill(getSize());
        _background.anchor = Vec2f.zero;
        _background.color = Atelier.theme.foreground;
        addImage(_background);

        _handle = Capsule.fill(getSize());
        _handle.anchor = Vec2f.zero;
        _handle.color = Atelier.theme.neutral;
        addImage(_handle);

        HSLColor color = HSLColor.fromColor(Atelier.theme.accent);
        color.l = color.l * 0.8f;
        _grabColor = color.toColor();

        addEventListener("size", &_onSize);
        addEventListener("handlePosition", &_onHandlePosition);
        addEventListener("handleSize", &_onHandleSize);
        addEventListener("update", &_onUpdate);
    }

    protected override float _getScrollLength() const {
        return getHeight();
    }

    protected override float _getScrollMousePosition() const {
        return getMousePosition().y;
    }

    private void _onHandlePosition() {
        _handle.position.y = getHandlePosition();
    }

    private void _onHandleSize() {
        _handle.size = Vec2f(getWidth(), getHandleSize());
    }

    private void _onSize() {
        _background.size = getSize();
        _handle.size = Vec2f(getWidth(), getHandleSize());
    }

    private void _onUpdate() {
        if (isHandleGrabbed()) {
            _handle.color = _grabColor;
            return;
        }

        if (isHandleHovered()) {
            _handle.color = Atelier.theme.accent;
        }
        else {
            _handle.color = Atelier.theme.neutral;
        }
    }
}
