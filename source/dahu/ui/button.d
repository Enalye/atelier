module dahu.ui.button;

import dahu.ui.element;

import dahu.common, dahu.render, dahu.core;

class Button : UIElement {
    Rectangle rect;

    this() {
        alignX = AlignX.right;
        alignY = AlignY.bottom;
    }

    override void update() {
    }
}