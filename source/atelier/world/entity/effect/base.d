module atelier.world.entity.effect.base;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world.entity.base;
import atelier.world.entity.renderer;

interface EntityGraphicEffect {
    @property {
        /// L’effet est-il encore en cours d’exécution ?
        bool isRunning() const;
    }

    /// Modifie le rendu
    void update(Sprite sprite);

    /// Rendu
    void draw(Sprite sprite, Vec2f position);

    final EntityGraphicEffectWrapper setup(Entity entity) {
        EntityGraphicEffectWrapper wrapper = new EntityGraphicEffectWrapper(this);
        wrapper.update(entity);
        return wrapper;
    }
}

final class EntityGraphicEffectWrapper {
    private {
        Entity _entity;
        EntityGraphic _graphic;
        EntityGraphicEffect _effect;
        Canvas _canvas;
        Sprite _renderSprite, _fxSprite;
    }

    @property {
        /// L’effet est-il encore en cours d’exécution ?
        bool isRunning() const {
            return _effect.isRunning();
        }
    }

    private this(EntityGraphicEffect effect) {
        _effect = effect;
    }

    private void _reload() {
        if (!_graphic)
            return;

        const uint width = _graphic.getWidth();
        const uint height = _graphic.getHeight();

        if (_canvas && _canvas.width == width && _canvas.height == height)
            return;

        _canvas = new Canvas(width, height);
        _renderSprite = new Sprite(_canvas);
        WritableTexture tex = new WritableTexture(1, 1);
        tex.update(Vec4u(0, 0, 1, 1), [0xffffffff]);
        _fxSprite = new Sprite(tex);
        _fxSprite.size = Vec2f(width, height);
        _fxSprite.blend = Blend.additive;
    }

    /// Modifie le rendu
    void update(Entity entity) {
        _entity = entity;
        EntityGraphic graphic = _entity ? _entity.getGraphic() : null;

        if (_graphic != graphic) {
            _graphic = graphic;
            _reload();
        }
        if (_graphic) {
            _effect.update(_fxSprite);
        }
    }

    /// Rendu
    void draw(Vec2f position, float alpha = 1f) {
        if (_graphic) {
            Atelier.renderer.pushCanvas(_canvas);
            Vec2f center = Vec2f(_canvas.width, _canvas.height) / 2f;
            _entity.renderGraphic(center);
            _effect.draw(_fxSprite, center);
            Atelier.renderer.popCanvas();

            _renderSprite.alpha = alpha;
            _renderSprite.draw(position);
        }
    }
}
