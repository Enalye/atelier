module atelier.etabli.media.res.shadow.toolbox;

import std.conv : to;
import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui;
import atelier.etabli.ui;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.shadow.editor;

package class Toolbox : Modal {
    private {
        Sprite _sprite;
        ToolGroup _toolGroup;
        int _tool;
    }

    this() {
        setSize(Vec2f(200f, 300f));
        setAlign(UIAlignX.left, UIAlignY.top);
        setPosition(Vec2f(258f, 75f));

        {
            Label title = new Label("Outils", Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 8f));
            addUI(title);
        }

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.center, UIAlignY.top);
            hbox.setPosition(Vec2f(0f, 32f));
            hbox.setSpacing(4f);
            addUI(hbox);

            _toolGroup = new ToolGroup;
            foreach (key; ["selection", "move", "corner", "side", "anchor"]) {
                ToolButton btn = new ToolButton(_toolGroup,
                    "editor:" ~ key ~ "-button", key == "selection");
                btn.setSize(Vec2f(32f, 32f));
                hbox.addUI(btn);
            }
        }

        {
            Rectangle rect = Rectangle.outline(Vec2f.one * (getWidth() - 16f), 1f);
            rect.color = Atelier.theme.onNeutral;
            rect.anchor = Vec2f(0.5f, 1f);
            rect.position = Vec2f(getCenter().x, getHeight() - 8f);
            addImage(rect);
        }

        addEventListener("update", {
            if (_toolGroup.value != _tool) {
                _tool = _toolGroup.value;
                dispatchEvent("tool", false);
            }
        });
    }

    int getTool() const {
        return _toolGroup.value();
    }

    void setTexture(ShadedTexture texture, Vec4u clip) {
        if (_sprite)
            _sprite.remove();
        _sprite = null;
        if (!texture)
            return;
        _sprite = new Sprite(texture.data, clip);
        _sprite.anchor = Vec2f(0.5f, 1f);
        _sprite.position = Vec2f(getCenter().x, getHeight() - 8f);
        _sprite.fit(Vec2f.one * (getWidth() - 16f));
        addImage(_sprite);
    }

    void setClip(Vec4u clip) {
        if (_sprite)
            _sprite.clip = clip;
    }

    void saveView(ref EditorView view) {
        view.tool = _toolGroup.value;
    }

    void loadView(ref EditorView view) {
        _toolGroup.value = view.tool;
    }
}
