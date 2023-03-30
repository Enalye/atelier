module dahu.ui.button;

import dahu.ui.element;

import dahu.common, dahu.render, dahu.core;

class Button : UIElement {
    Rectangle rect;

    this() {
        alignX = AlignX.right;
        alignY = AlignY.bottom;


        angle = 45f;

        rect = new Rectangle();
        rect.sizeX = sizeX;
        rect.sizeY = sizeY;
        rect.color = Color.blue;
        _drawables ~= rect;
    }

    override void update() {
        //pivotX = 0f;
        //angle ++;
        rect.color = focused ? Color.red : Color.blue;
    }
}