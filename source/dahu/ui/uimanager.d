module dahu.ui.uimanager;

import std.stdio;
import std.string;

import bindbc.sdl;

import dahu.common, dahu.render, dahu.window;

import dahu.ui.element;

/// UI elements manager
class UI {
    private {
        UIElement[] _roots;
    }

    /// Update
    void update(float deltaTime) {
        foreach (UIElement element; _roots) {
            update(deltaTime, element);
        }
    }

    private void update(float deltaTime, UIElement element) {
        // Compute transitions
        if (element.timer.isRunning) {
            element.timer.update(deltaTime);

            SplineFunc splineFunc = getSplineFunc(element.targetState.spline);
            const float t = splineFunc(element.timer.value01);

            element.offsetX = lerp(element.initState.offsetX, element.targetState.offsetX, t);
            element.offsetY = lerp(element.initState.offsetY, element.targetState.offsetY, t);

            element.scaleX = lerp(element.initState.scaleX, element.targetState.scaleX, t);
            element.scaleY = lerp(element.initState.scaleY, element.targetState.scaleY, t);

            element.angle = lerp(element.initState.angle, element.targetState.angle, t);
            element.alpha = lerp(element.initState.alpha, element.targetState.alpha, t);
        }

        // Update children
        foreach (UIElement child; element._children) {
            update(deltaTime, child);
        }
    }

    /// Draw
    void draw() {
        Mat3f position = Mat3f.identity;
        Mat3f size = Mat3f.identity;

        Mat3f transform = position * size;
        foreach (UIElement element; _roots) {
            draw(transform, element);
        }
    }

    private void draw(Mat3f transform, UIElement element, UIElement parent = null) {
        Mat3f local = Mat3f.identity;

        // Scale
        local.scale(Vec2f(element.scaleX, element.scaleY));

        // Rotation: translate the element back to 0,0 temporarily
        local.translate(Vec2f(-element.sizeX * element.scaleX * element.pivotX * 2f,
                -element.sizeY * element.scaleY * element.pivotY * 2f));

        // Rotation
        if (element.angle) {
            local.rotate(element.angle);
        }

        // Rotation: translate the element back to its pivot
        local.translate(Vec2f(element.sizeX * element.scaleX * element.pivotX * 2f,
                element.sizeY * element.scaleY * element.pivotY * 2f));

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
        case bottom:
            break;
        case top:
            y = parentH - (y + (element.sizeY * element.scaleY));
            break;
        case center:
            y = parentH / 2f + y;
            break;
        }

        // Position
        local.translate(Vec2f(x * 2f, y * 2f));
        transform = transform * local;

        element.draw(transform);
        foreach (UIElement child; element._children) {
            draw(transform, child, element);
        }
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
