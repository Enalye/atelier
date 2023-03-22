module dahu.ui;

import std.stdio;
import std.string;

import bindbc.sdl;

import dahu.common, dahu.render, dahu.core;

public {
    import dahu.ui.element;
    import dahu.ui.label;
}

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
        foreach (UIElement element; _roots) {
            draw(element);
        }
    }

    private void draw(UIElement element, UIElement parent = null) {
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

        getRenderer.pushCanvas(cast(uint) element.sizeX, cast(uint) element.sizeY);

        element.draw();
        foreach (UIElement child; element._children) {
            draw(child, element);
        }

        float sizeX = element.scaleX * element.sizeX;
        float sizeY = element.scaleY * element.sizeY;
        getRenderer.popCanvas(x, y, sizeX, sizeY, element.pivotX * sizeX,
            element.pivotY * sizeY, element.angle);
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
