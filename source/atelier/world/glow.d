module atelier.world.glow;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world.entity;
import atelier.world.transition;

final class Glow {
    private {
        Canvas _canvas;
        Sprite _sprite;
    }

    this() {
        _canvas = new Canvas(Atelier.renderer.size.x, Atelier.renderer.size.y);
        _sprite = new Sprite(_canvas);
        _sprite.blend = Blend.additive;
        _sprite.anchor = Vec2f.zero;
    }

    void draw(Entity[] entities, Vec2f offset, Sprite shadowSprite) {
        _canvas.color = Color.black;
        Atelier.renderer.pushCanvas(_canvas);

        foreach (Entity entity; entities) {
            if (!entity.isRendered) {
                entity.isRendered = true;
                entity.draw(offset, shadowSprite);
            }
        }

        Atelier.renderer.popCanvas();
        _sprite.draw(Vec2f.zero);
    }

    void drawTransition(Transition transition, Entity[] entities, Vec2f offset, Sprite shadowSprite) {
        _canvas.color = Color.black;
        Atelier.renderer.pushCanvas(_canvas);

        foreach (Entity entity; entities) {
            if (!entity.isRendered) {
                entity.isRendered = true;
                transition.drawEntity(entity, offset, shadowSprite);
            }
        }

        Atelier.renderer.popCanvas();
        _sprite.draw(Vec2f.zero);
    }
}
