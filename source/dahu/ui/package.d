module dahu.ui;

import std.stdio;
import std.string;

import bindbc.sdl;

import grimoire;

import dahu.common;
import dahu.core;
import dahu.input;
import dahu.render;

public {
    import dahu.ui.button;
    import dahu.ui.element;
    import dahu.ui.label;
}

/// UI elements manager
class UI {
    private {
        UIElement[] _roots;

        bool _hasClicked;
        UIElement _clickedUI;
        float _clickedUIPosX = 0f, _clickedUIPosY = 0f;

        UIElement _tempGrabbedUI, _grabbedUI;
        float _grabbedUIPosX = 0f, _grabbedUIPosY = 0f;

        UIElement _focusedUI;

        bool _wasHoveredGuiElementAlreadyHovered;
        UIElement _hoveredGuiElement;
        float _hoveredUIPosX = 0f, _hoveredUIPosY = 0f;
    }

    /// Update
    void update() {
        foreach (UIElement element; _roots) {
            update(element);
        }
    }

    void dispatch(InputEvent[] events) {
        foreach (InputEvent event; events) {
            switch (event.type) with (InputEvent.Type) {
            case mouseButton:
                auto mouseButtonEvent = event.asMouseButton();
                if (mouseButtonEvent.pressed) {
                    foreach (UIElement element; _roots) {
                        dispatchMouseDownEvent(mouseButtonEvent.x, mouseButtonEvent.y, element);
                    }
                }
                else {
                    foreach (UIElement element; _roots) {
                        dispatchMouseUpEvent(mouseButtonEvent.x, mouseButtonEvent.y, element);
                    }
                }
                break;
            case mouseMotion:
                auto mouseMotionEvent = event.asMouseMotion();
                foreach (UIElement element; _roots) {
                    dispatchMouseUpdateEvent(mouseMotionEvent.x, mouseMotionEvent.y, element);
                }
                break;
            default:
                break;
            }
        }
    }

    /// Process a mouse down event down the tree.
    private void dispatchMouseDownEvent(float x, float y, UIElement element, UIElement parent = null) {
        Vec2f mousePos = _getPointInElement(x, y, element, parent);
        Vec2f elementSize = Vec2f(element.sizeX * element.scaleX, element.sizeY * element.scaleY);

        bool isInside = mousePos.isBetween(Vec2f.zero, elementSize);
        if (!element.active || !isInside) {
            return;
        }

        _clickedUI = element;
        _tempGrabbedUI = null;

        _clickedUIPosX = mousePos.x;
        _clickedUIPosY = mousePos.y;
        _hasClicked = true;

        if (element.movable && !_grabbedUI) {
            _tempGrabbedUI = element;
            _grabbedUIPosX = _clickedUIPosX;
            _grabbedUIPosY = _clickedUIPosY;
        }

        foreach (child; element._children)
            dispatchMouseDownEvent(mousePos.x, mousePos.y, child, element);
    }

    /// Process a mouse up event down the tree.
    private void dispatchMouseUpEvent(float x, float y, UIElement element, UIElement parent = null) {
        Vec2f mousePos = _getPointInElement(x, y, element, parent);
        Vec2f elementSize = Vec2f(element.sizeX * element.scaleX, element.sizeY * element.scaleY);

        bool isInside = mousePos.isBetween(Vec2f.zero, elementSize);
        if (!element.active || !isInside) {
            return;
        }

        foreach (child; element._children)
            dispatchMouseUpEvent(mousePos.x, mousePos.y, child, element);

        if (_clickedUI == element) {
            //The previous widget is now unfocused.
            if (_focusedUI) {
                _focusedUI.hasFocus = false;
            }

            //The widget is now focused and receive the onSubmit event.
            _focusedUI = _clickedUI;
            _hasClicked = true;
            element.hasFocus = true;

            if(element.onSubmit) {
                app.callEvent(element.onSubmit, [GrValue(element)]);
            }
        }

        if (_clickedUI)
            _clickedUI.isClicked = false;
    }

    /// Process a mouse update event down the tree.
    private void dispatchMouseUpdateEvent(float x, float y, UIElement element,
        UIElement parent = null) {
        Vec2f mousePos = _getPointInElement(x, y, element, parent);
        Vec2f elementSize = Vec2f(element.sizeX * element.scaleX, element.sizeY * element.scaleY);

        bool isInside = mousePos.isBetween(Vec2f.zero, elementSize);

        bool wasHovered = element.isHovered;

        if (element.active && element == _grabbedUI) {
            if (!element.movable) {
                _grabbedUI = null;
            }
            else {
                float deltaX = mousePos.x - _grabbedUIPosX;
                float deltaY = mousePos.y - _grabbedUIPosY;

                if (element.alignX == UIElement.AlignX.right)
                    deltaX = -deltaX;

                if (element.alignY == UIElement.AlignY.bottom)
                    deltaY = -deltaY;

                element.posX += deltaX;
                element.posY += deltaY;

                _grabbedUIPosX = mousePos.x;
                _grabbedUIPosY = mousePos.y;
            }
        }

        if (element.active && isInside) {
            //Register element
            _wasHoveredGuiElementAlreadyHovered = wasHovered;
            _hoveredGuiElement = element;
            _hoveredUIPosX = mousePos.x;
            _hoveredUIPosY = mousePos.y;
            _hasClicked = true;
        }
        else {
            void unHoverRoots(UIElement element) {
                element.isHovered = false;
                foreach (child; element._children)
                    unHoverRoots(child);
            }

            unHoverRoots(element);
            return;
        }

        foreach (child; element._children)
            dispatchMouseUpdateEvent(mousePos.x, mousePos.y, child, element);
    }

    private void update(UIElement element) {
        // Compute transitions
        if (element.timer.isRunning) {
            element.timer.update();

            SplineFunc splineFunc = getSplineFunc(element.targetState.spline);
            const float t = splineFunc(element.timer.value01);

            element.offsetX = lerp(element.initState.offsetX, element.targetState.offsetX, t);
            element.offsetY = lerp(element.initState.offsetY, element.targetState.offsetY, t);

            element.scaleX = lerp(element.initState.scaleX, element.targetState.scaleX, t);
            element.scaleY = lerp(element.initState.scaleY, element.targetState.scaleY, t);

            element.angle = lerp(element.initState.angle, element.targetState.angle, t);
            element.alpha = lerp(element.initState.alpha, element.targetState.alpha, t);
        }

        element.update();

        // Update children
        foreach (UIElement child; element._children) {
            update(child);
        }
    }

    pragma(inline) private Vec2f _getPointInElement(float x, float y,
        UIElement element, UIElement parent = null) {
        Vec2f mousePos = Vec2f(x, y);
        Vec2f elementPos = _getElementOrigin(element, parent);
        Vec2f elementSize = Vec2f(element.sizeX * element.scaleX, element.sizeY * element.scaleY);
        Vec2f pivot = elementPos + elementSize * Vec2f(element.pivotX, element.pivotY);

        if (element.angle != 0.0) {
            Vec2f mouseDelta = mousePos - pivot;
            mouseDelta.rotate(degToRad * -element.angle);
            mousePos = mouseDelta + pivot;
        }
        mousePos -= elementPos;
        return mousePos;
    }

    pragma(inline) private Vec2f _getElementOrigin(UIElement element, UIElement parent = null) {
        float x = element.posX + element.offsetX;
        float y = element.posY + element.offsetY;

        const float parentW = parent ? parent.sizeX : cast(float) getWindow().width();
        const float parentH = parent ? parent.sizeY : cast(float) getWindow().height();

        final switch (element.alignX) with (UIElement.AlignX) {
        case left:
            break;
        case right:
            x = parentW - (x + (element.sizeX * element.scaleX));
            break;
        case center:
            x = parentW / 2f + x;
            break;
        }

        final switch (element.alignY) with (UIElement.AlignY) {
        case top:
            break;
        case bottom:
            y = parentH - (y + (element.sizeY * element.scaleY));
            break;
        case center:
            y = parentH / 2f + y;
            break;
        }

        return Vec2f(x, y);
    }

    /// Draw
    void draw() {
        foreach (UIElement element; _roots) {
            draw(element);
        }
    }

    private void draw(UIElement element, UIElement parent = null) {
        Vec2f pos = _getElementOrigin(element, parent);

        app.renderer.pushCanvas(cast(uint) element.sizeX, cast(uint) element.sizeY);

        foreach (Drawable drawable; element._drawables) {
            drawable.draw(0f, 0f);
        }

        element.draw();

        foreach (UIElement child; element._children) {
            draw(child, element);
        }

        float sizeX = element.scaleX * element.sizeX;
        float sizeY = element.scaleY * element.sizeY;
        app.renderer.popCanvas(pos.x, pos.y, sizeX, sizeY,
            element.pivotX * sizeX, element.pivotY * sizeY, element.angle,
            Color.white, element.alpha);
    }

    /// Add an UIElement to the manager at root level
    void appendRoot(UIElement element) {
        _roots ~= element;
    }

    /// Remove all root UIElements from the manager
    void removeRoots() {
        _roots.length = 0;
    }
}
