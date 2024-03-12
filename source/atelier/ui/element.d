module atelier.ui.element;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;

/// Alignement horizontal
enum UIAlignX {
    left,
    center,
    right
}

/// Alignement vertical
enum UIAlignY {
    top,
    center,
    bottom
}

/// Élément d’interface
class UIElement {
    private {
        alias NativeEventListener = void delegate();

        UIElement _parent;
        Array!UIElement _children;
        Array!Image _images;
        Array!NativeEventListener[string] _nativeEventListeners;
        Array!GrEvent[string] _scriptEventListeners;

        UIAlignX _alignX = UIAlignX.center;
        UIAlignY _alignY = UIAlignY.center;

        Vec2f _position = Vec2f.zero;
        Vec2f _size = Vec2f.zero;
        Vec2f _pivot = Vec2f.half;
        Vec2f _mousePosition = Vec2f.zero;

        bool _isHovered, _hasFocus, _isPressed, _isSelected, _isActive, _isGrabbed;
        bool _isEnabled = true;
        bool _isAlive;
    }

    /// Ordenancement
    int zOrder = 0;

    /// Transitions
    Vec2f offset = Vec2f.zero;
    Vec2f scale = Vec2f.one;
    Color color = Color.white;
    float alpha = 1f;
    double angle = 0.0;

    static final class State {
        string name;
        Vec2f offset = Vec2f.zero;
        Vec2f scale = Vec2f.one;
        Color color = Color.white;
        float alpha = 1f;
        double angle = 0.0;
        int time = 60;
        Spline spline = Spline.linear;
    }

    State[string] states;
    string currentStateName;
    State initState, targetState;
    Timer timer;

    // Propriétés
    @property {
        package final bool isAlive() const {
            return _isAlive;
        }

        package final bool isAlive(bool isAlive_) {
            if (_isAlive != isAlive_) {
                _isAlive = isAlive_;
                dispatchEvent(_isAlive ? "register" : "unregister", false);
            }
            return _isAlive = isAlive_;
        }

        final bool isHovered() const {
            return _isHovered;
        }

        package final bool isHovered(bool isHovered_) {
            if (_isHovered != isHovered_) {
                _isHovered = isHovered_;
                dispatchEvent(_isHovered ? "mouseenter" : "mouseleave", false);
            }
            return _isHovered;
        }

        final bool hasFocus() const {
            return _hasFocus;
        }

        final bool hasFocus(bool hasFocus_) {
            if (_hasFocus != hasFocus_) {
                _hasFocus = hasFocus_;
                dispatchEvent(_hasFocus ? "focus" : "blur", false);
            }
            return _hasFocus;
        }

        final bool isPressed() const {
            return _isPressed;
        }

        package final bool isPressed(bool isPressed_) {
            if (_isPressed != isPressed_) {
                _isPressed = isPressed_;
                dispatchEvent(_isPressed ? "press" : "unpress", true);
            }
            return _isPressed;
        }

        final bool isSelected() const {
            return _isSelected;
        }

        final bool isSelected(bool isSelected_) {
            if (_isSelected != isSelected_) {
                _isSelected = isSelected_;
                dispatchEvent(_isSelected ? "select" : "deselect", false);
            }
            return _isSelected;
        }

        final bool isActive() const {
            return _isActive;
        }

        final bool isActive(bool isActive_) {
            if (_isActive != isActive_) {
                _isActive = isActive_;
                dispatchEvent(_isActive ? "active" : "inactive", false);
            }
            return _isActive;
        }

        final bool isGrabbed() const {
            return _isGrabbed;
        }

        package final bool isGrabbed(bool isGrabbed_) {
            if (_isGrabbed != isGrabbed_) {
                _isGrabbed = isGrabbed_;
                dispatchEvent(_isGrabbed ? "grab" : "ungrab", false);
            }
            return _isGrabbed;
        }

        final bool isEnabled() const {
            return _isEnabled;
        }

        final bool isEnabled(bool isEnabled_) {
            if (_isEnabled != isEnabled_) {
                _isEnabled = isEnabled_;
                dispatchEvent(_isEnabled ? "enable" : "disable", false);
            }
            return _isEnabled;
        }
    }

    bool focusable, movable;

    this() {
        _children = new Array!UIElement;
        _images = new Array!Image;
    }

    final UIElement getParent() {
        return _parent;
    }

    final Array!UIElement getChildren() {
        return _children;
    }

    final Array!Image getImages() {
        return _images;
    }

    final Vec2f getMousePosition() const {
        return _mousePosition;
    }

    final package Vec2f setMousePosition(Vec2f mousePosition) {
        return _mousePosition = mousePosition;
    }

    final void setAlign(UIAlignX alignX, UIAlignY alignY) {
        _alignX = alignX;
        _alignY = alignY;
    }

    final UIAlignX getAlignX() {
        return _alignX;
    }

    final UIAlignY getAlignY() {
        return _alignY;
    }

    final Vec2f getPosition() const {
        return _position;
    }

    final void setPosition(Vec2f position_) {
        if (_position == position_)
            return;
        _position = position_;
        dispatchEvent("position");
    }

    final Vec2f getSize() const {
        return _size;
    }

    final float getWidth() const {
        return _size.x;
    }

    final float getHeight() const {
        return _size.y;
    }

    final void setSize(Vec2f size_) {
        if (_size == size_)
            return;
        _size = size_;
        dispatchEvent("size");
        dispatchEventChildren("parentSize");
    }

    final Vec2f getCenter() const {
        return _size / 2f;
    }

    final Vec2f getPivot() const {
        return _pivot;
    }

    final void setPivot(Vec2f pivot_) {
        if (_pivot == pivot_)
            return;
        _pivot = pivot_;
        dispatchEvent("pivot");
    }

    final void addEventListener(string type, NativeEventListener listener) {
        _nativeEventListeners.update(type, {
            Array!NativeEventListener evllist = new Array!NativeEventListener;
            evllist ~= listener;
            return evllist;
        }, (Array!NativeEventListener evllist) { evllist ~= listener; });
    }

    final void addEventListener(string type, GrEvent listener) {
        _scriptEventListeners.update(type, {
            Array!GrEvent evllist = new Array!GrEvent;
            evllist ~= listener;
            return evllist;
        }, (Array!GrEvent evllist) { evllist ~= listener; });
    }

    final void removeEventListener(string type, NativeEventListener listener) {
        _nativeEventListeners.update(type, {
            return new Array!NativeEventListener;
        }, (Array!NativeEventListener evllist) {
            foreach (i, eventListener; evllist) {
                if (eventListener == listener)
                    evllist.mark(i);
            }
            evllist.sweep();
        });
    }

    final void removeEventListener(string type, GrEvent listener) {
        _scriptEventListeners.update(type, { return new Array!GrEvent; }, (Array!GrEvent evllist) {
            foreach (i, eventListener; evllist) {
                if (eventListener == listener)
                    evllist.mark(i);
            }
            evllist.sweep();
        });
    }

    final void dispatchEvent(string type, bool bubbleUp = true) {
        { // Natifs
            auto p = type in _nativeEventListeners;
            if (p) {
                Array!NativeEventListener evllist = *p;
                foreach (listener; evllist) {
                    listener();
                }
            }
        }

        { // Scripts
            auto p = type in _scriptEventListeners;
            if (p) {
                Array!GrEvent evllist = *p;
                foreach (listener; evllist) {
                    Atelier.vm.callEvent(listener);
                }
            }
        }

        if (bubbleUp && _parent) {
            _parent.dispatchEvent(type);
        }
    }

    final void dispatchEventChildren(string type, bool bubbleDown = true) {
        if (bubbleDown) {
            foreach (UIElement child; _children) {
                child.dispatchEvent(type, false);
                child.dispatchEventChildren(type, bubbleDown);
            }
        }
        else {
            foreach (UIElement child; _children) {
                child.dispatchEvent(type, false);
            }
        }
    }

    final void addUI(UIElement element) {
        if (element.isAlive)
            return;

        element.isAlive = true;
        element._parent = this;
        _children ~= element;
    }

    final void clearUI() {
        foreach (child; _children) {
            child.remove();
        }
        _children.clear();
    }

    final void addImage(Image image) {
        _images ~= image;
    }

    final void clearImages() {
        _images.clear();
    }

    final void remove() {
        isAlive = false;
        _parent = null;
    }
}
