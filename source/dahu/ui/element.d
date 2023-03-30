module dahu.ui.element;

import grimoire;

import dahu.common, dahu.render;

/// Abstract class representing an UI element
abstract class UIElement {
    public {
        UIElement[] _children;
        Drawable[] _drawables;
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

    AlignX alignX = AlignX.left;
    AlignY alignY = AlignY.top;

    /// Transitions
    float offsetX = 0f, offsetY = 0f;
    float scaleX = 1f, scaleY = 1f;
    float alpha = 1f;
    double angle = 0.0;

    static final class State {
        string name;
        float offsetX = 0f, offsetY = 0f;
        float scaleX = 1f, scaleY = 1f;
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
    bool focused, clicked;
    bool active = true, movable;

    GrEvent onClick;

    bool alive = true;

    void update() {}
    void draw() {}
}
