/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.button.button;

import atelier.common;
import atelier.core;
import atelier.ui.core;
import atelier.ui.button.fx;

abstract class Button(ImageType) : UIElement {
    private {
        ButtonFx!ImageType _fx;
        Timer _clickTimer;
    }

    this() {
        focusable = true;

        _fx = new ButtonFx!ImageType(this);

        addEventListener("press", {
            _fx.onClick(getMousePosition());
            _clickTimer.start(15);
            addEventListener("update", &_onClickHeld);
        });
        addEventListener("unpress", {
            _fx.onUnclick();
            removeEventListener("update", &_onClickHeld);
        });
        addEventListener("mousemove", { _fx.onUpdate(getMousePosition()); });
        addEventListener("update", { _fx.update(); });
        addEventListener("draw", { _fx.draw(); });
        addEventListener("size", { _fx.onSize(); });
    }

    private void _onClickHeld() {
        _clickTimer.update();
        if (!_clickTimer.isRunning) {
            _clickTimer.start(2);
            dispatchEvent("echo", false);
        }
    }

    final void setFxColor(Color color) {
        _fx.setColor(color);
    }
}

abstract class TextButton(ImageType) : Button!ImageType {
    private {
        Vec2f _padding = Vec2f(24f, 8f);
        Label _label;
    }

    this(string text_) {
        _label = new Label(text_, Atelier.theme.font);
        _label.textColor = Atelier.theme.onNeutral;
        addUI(_label);

        setSize(_label.getSize() + _padding);
    }

    final Vec2f getPadding() const {
        return _padding;
    }

    final void setPadding(Vec2f padding) {
        _padding = padding;
        setSize(_label.getSize() + _padding);
    }

    void setText(string text_) {
        _label.text = text_;
        setSize(_label.getSize() + _padding);
    }

    void setTextAlign(UIAlignX alignX, float offset = 0f) {
        _label.setAlign(alignX, UIAlignY.center);
        _label.setPosition(Vec2f(offset, 0f));
    }

    void setTextColor(Color color) {
        _label.textColor = color;
    }
}
