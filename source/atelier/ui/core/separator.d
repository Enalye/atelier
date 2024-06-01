/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.core.separator;

import atelier.common;
import atelier.render;
import atelier.ui.core.element;
import atelier.ui.core.label;

abstract class Separator : UIElement {
    protected {
        Color _color = Color.white;
        float _lineWidth = 1f;
    }

    final Color getColor() const {
        return _color;
    }

    final void setColor(Color color_) {
        if (_color == color_)
            return;

        _color = color_;
        reload();
    }

    final float getLineWidth() const {
        return _lineWidth;
    }

    final void setLineWidth(float lineWidth_) {
        if (_lineWidth == lineWidth_)
            return;

        _lineWidth = lineWidth_;
        reload();
    }

    this() {
        isEnabled = false;
        addEventListener("size", &reload);
    }

    protected abstract void reload();
}

final class HSeparator : Separator {
    private {
        Rectangle _line;
    }

    this() {
        _line = Rectangle.fill(Vec2f(getWidth(), _lineWidth));
        _line.color = _color;
        _line.anchor = Vec2f(0f, 0.5f);
        _line.alpha = 1f;
        addImage(_line);
    }

    override void reload() {
        _line.position = getCenter();
        _line.size = Vec2f(getWidth(), _lineWidth);
    }
}

final class VSeparator : Separator {
    private {
        Rectangle _line;
    }

    this() {
        _line = Rectangle.fill(Vec2f(_lineWidth, getHeight()));
        _line.color = _color;
        _line.anchor = Vec2f(0.5f, 0f);
        _line.alpha = 1f;
        addImage(_line);

        reload();
    }

    protected override void reload() {
        _line.position = getCenter();
        _line.size = Vec2f(_lineWidth, getHeight());
    }
}

final class LabelSeparator : Separator {
    private {
        Label _label;
        Rectangle _leftLine, _rightLine;
        Vec2f _padding = Vec2f.zero;
        float _spacing = 4f;
    }

    float getSpacing() const {
        return _spacing;
    }

    void setSpacing(float spacing_) {
        if (_spacing == spacing_)
            return;
        _spacing = spacing_;
        reload();
    }

    Vec2f getPadding() const {
        return _padding;
    }

    void setPadding(Vec2f padding_) {
        if (_padding == padding_)
            return;
        _padding = padding_;
        _onText();
    }

    this(string text, Font font) {
        _label = new Label(text, font);
        _label.textColor = _color;
        _label.setAlign(UIAlignX.center, UIAlignY.center);
        addUI(_label);

        _leftLine = Rectangle.fill(Vec2f(0f, _lineWidth));
        _leftLine.color = _color;
        _leftLine.anchor = Vec2f(0f, 0.5f);
        _leftLine.alpha = 1f;
        addImage(_leftLine);

        _rightLine = Rectangle.fill(Vec2f(0f, _lineWidth));
        _rightLine.color = _color;
        _rightLine.anchor = Vec2f(1f, 0.5f);
        _rightLine.alpha = 1f;
        addImage(_rightLine);

        _onText();
    }

    void setText(string text) {
        _label.text = text;
        _onText();
    }

    void setFont(Font font) {
        _label.font = font;
        _onText();
    }

    private void _onText() {
        setSize(_padding.max(_label.getSize()));
    }

    protected override void reload() {
        _leftLine.color = _color;
        _rightLine.color = _color;
        _label.textColor = _color;

        _leftLine.position = Vec2f(0f, getCenter().y);
        _rightLine.position = Vec2f(getWidth(), getCenter().y);

        float lineWidth = max(0f, getWidth() - _label.getWidth()) / 2f;
        _leftLine.size = Vec2f(max(0f, lineWidth - _spacing), _lineWidth);
        _rightLine.size = Vec2f(max(0f, lineWidth - _spacing), _lineWidth);
    }
}
