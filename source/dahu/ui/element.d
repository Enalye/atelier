module dahu.ui.element;

import grimoire;

import dahu.common;
import dahu.core;
import dahu.render;

/// Abstract class representing an UI element
abstract class UIElement {
    public {
        UIElement[] _children;
        Image[] _images;
    }

    private {
        bool _hovered, _focused, _pressed, _selected, _activated, _grabbed;
        bool _enabled;
    }

    float posX = 0f, posY = 0f;
    float sizeX = 0f, sizeY = 0f;
    float pivotX = .5f, pivotY = .5f;

    /// X alignment
    enum AlignX {
        left,
        center,
        right
    }

    /// Y alignment
    enum AlignY {
        top,
        center,
        bottom
    }

    AlignX alignX = AlignX.center;
    AlignY alignY = AlignY.center;

    /// Transitions
    float offsetX = 0f, offsetY = 0f;
    float scaleX = 1f, scaleY = 1f;
    Color color = Color.white;
    float alpha = 1f;
    double angle = 0.0;

    static final class State {
        string name;
        float offsetX = 0f, offsetY = 0f;
        float scaleX = 1f, scaleY = 1f;
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
        bool hovered() const {
            return _hovered;
        }

        bool hovered(bool hovered_) {
            if (_hovered != hovered_) {
                _hovered = hovered_;
                onHover();
            }
            return _hovered;
        }

        bool focused() const {
            return _focused;
        }

        bool focused(bool focused_) {
            if (_focused != focused_) {
                _focused = focused_;
                onFocus();
            }
            return _focused;
        }

        bool pressed() const {
            return _pressed;
        }

        bool pressed(bool pressed_) {
            if (_pressed != pressed_) {
                _pressed = pressed_;
                onPress();
            }
            return _pressed;
        }

        bool selected() const {
            return _selected;
        }

        bool selected(bool selected_) {
            if (_selected != selected_) {
                _selected = selected_;
                onSelect();
            }
            return _selected;
        }

        bool activated() const {
            return _activated;
        }

        bool activated(bool activated_) {
            if (_activated != activated_) {
                _activated = activated_;
                onActive();
            }
            return _activated;
        }

        bool grabbed() const {
            return _grabbed;
        }

        bool grabbed(bool grabbed_) {
            if (_grabbed != grabbed_) {
                _grabbed = grabbed_;
                onGrab();
            }
            return _grabbed;
        }

        bool enabled() const {
            return _enabled;
        }

        bool enabled(bool enabled_) {
            if (_enabled != enabled_) {
                _enabled = enabled_;
                onEnable();
            }
            return _enabled;
        }
    }

    bool focusable, movable;

    GrEvent onSubmitEvent;

    bool alive = true;

    void update() {
    }

    void draw() {
    }

    void onHover() {
    }

    void onFocus() {
    }

    void onPress() {
    }

    void onSelect() {
    }

    void onActive() {
    }

    void onGrab() {
    }

    void onSubmit() {
        if (onSubmitEvent) {
            Dahu.vm.callEvent(onSubmitEvent);
        }
    }

    void onEnable() {
    }
}
