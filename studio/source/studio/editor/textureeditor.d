/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editor.textureeditor;

import atelier;
import studio.editor.base;

final class TextureEditor : ContentEditor {
    private {
        Texture _texture;
        Sprite _sprite;
        float _zoom = 1f;
    }

    this(string path_, Vec2f windowSize) {
        super(path_, windowSize);

        _texture = Texture.fromFile(path);
        _sprite = new Sprite(_texture);
        _sprite.position = getCenter();
        addImage(_sprite);

        addEventListener("draw", &_onDraw);
        addEventListener("wheel", &_onWheel);
        addEventListener("mousedown", &_onMouseDown);
        addEventListener("mouseup", &_onMouseUp);
    }

    private void _onMouseDown() {
        addEventListener("mousemove", &_onDrag);
    }

    private void _onMouseUp() {
        removeEventListener("mousemove", &_onDrag);
    }

    private void _onDrag() {
        UIManager manager = getManager();
        InputEvent.MouseMotion ev = manager.input.asMouseMotion();
        _sprite.position += ev.deltaPosition;
    }

    private void _onDraw() {
        Atelier.renderer.drawRect(_sprite.position - _sprite.size / 2f,
            _sprite.size, Atelier.theme.onNeutral, 1f, false);
    }

    private void _onWheel() {
        UIManager manager = getManager();
        InputEvent.MouseWheel ev = manager.input.asMouseWheel();
        float zoomDelta = 1f + (ev.wheel.sum() * 0.25f);
        _zoom *= zoomDelta;
        _sprite.size = (cast(Vec2f) _sprite.clip.zw) * _zoom;
        Vec2f delta = _sprite.position - getMousePosition();
        _sprite.position = delta * zoomDelta + getMousePosition();
    }
}
