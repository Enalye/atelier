/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.scrollbar.base;

import std.algorithm.comparison : clamp, max;
import atelier.ui.core;

abstract class Scrollbar : UIElement {
    private {
        float _handlePosition = 0f;
        float _handleSize = 0f;
        float _contentSize = 0f;
        bool _isGrabbed;
        float _grabPosition;
    }

    @property {
        bool isHandleGrabbed() const {
            return _isGrabbed;
        }

        bool isHandleHovered() const {
            float mousePosition = _getScrollMousePosition();
            return isHovered && mousePosition >= _handlePosition &&
                mousePosition <= _handlePosition + _handleSize;
        }
    }

    this() {
        addEventListener("mousedown", &_onMouseDown);
        addEventListener("mouserelease", &_onMouseUp);
        addEventListener("size", &_onSize);
    }

    final void setHandlePosition(float position) {
        position = clamp(position, 0f, max(0f, _getScrollLength() - _handleSize));
        if (_handlePosition == position)
            return;

        _handlePosition = position;
        dispatchEvent("handlePosition", false);
    }

    final float getHandlePosition() const {
        return _handlePosition;
    }

    final float getHandleSize() const {
        return _handleSize;
    }

    final void setContentSize(float size) {
        _contentSize = size;
        _onSize();
    }

    final void _onSize() {
        float handleSize = _getScrollLength();
        if (_contentSize < handleSize) {
            handleSize = _contentSize;
        }
        else if (_contentSize > 0f) {
            handleSize = (handleSize * handleSize) / _contentSize;
        }

        if (_handleSize != handleSize) {
            _handleSize = handleSize;
            dispatchEvent("handleSize", false);
        }
    }

    final void setContentPosition(float position) {
        setHandlePosition(position * (_getScrollLength() / _contentSize));
    }

    final float getContentPosition() const {
        return _handlePosition * (_contentSize / _getScrollLength());
    }

    private void _onMouseDown() {
        float mousePosition = _getScrollMousePosition();

        if (mousePosition >= _handlePosition && mousePosition <= _handlePosition + _handleSize) {
            _isGrabbed = true;
            _grabPosition = mousePosition - _handlePosition;
        }
        else {
            _isGrabbed = true;
            setHandlePosition(mousePosition - _handleSize / 2f);
            _grabPosition = mousePosition - _handlePosition;
        }
        addEventListener("update", &_onMouseUpdate);
    }

    private void _onMouseUp() {
        _isGrabbed = false;
        removeEventListener("update", &_onMouseUpdate);
    }

    private void _onMouseUpdate() {
        float mousePosition = _getScrollMousePosition();
        if (_isGrabbed) {
            setHandlePosition(mousePosition - _grabPosition);
        }
    }

    protected abstract float _getScrollLength() const;
    protected abstract float _getScrollMousePosition() const;
}
