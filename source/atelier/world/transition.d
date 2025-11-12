module atelier.world.transition;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world.scene;
import atelier.world.entity;

abstract class Transition {
    @property {
        bool showTiles() const {
            return true;
        }

        bool isRunning() const {
            return false;
        }
    }

    void update() {
    }

    void onCameraMoved() {
    }

    void setupDrawStep(Scene scene, Vec2f offset, Vec2f targetPos) {
    }

    void drawLine(Vec2f offset, int y, size_t level) {
    }

    void drawEntity(Entity entity, Vec2f entityOffset) {
    }

    void renderEntity(Entity entity, Vec2f offset, float tTransition, bool drawGraphics) {
    }

    void drawAbove() {
    }
}

final class DefaultTransition : Transition {
    private {
        string _sceneRid, _tpName;
        bool _isRunning = true;

        enum State {
            fadeOut,
            black,
            fadeIn
        }

        State _state = State.fadeOut;
        Timer _timer;
        Rectangle _rect;

        enum _fadeDuration = 15;
    }

    @property {
        override bool showTiles() const {
            return true;
        }

        override bool isRunning() const {
            return _isRunning;
        }
    }

    this(string sceneRid, string tpName, Actor actor, bool skip) {
        _sceneRid = sceneRid;
        _tpName = tpName;

        _rect = Rectangle.fill(Vec2f(Atelier.renderer.size.x, Atelier.renderer.size.y));
        _rect.anchor = Vec2f.zero;
        _rect.color = Color.black;
        _rect.alpha = 1f;

        _timer.start(_fadeDuration);
    }

    override void update() {
        _timer.update();

        final switch (_state) with (State) {
        case fadeOut:
            _rect.alpha = lerp(0f, 1f, easeOutQuad(_timer.value01()));
            break;
        case black:
            _rect.alpha = 1f;
            break;
        case fadeIn:
            _rect.alpha = lerp(1f, 0f, easeInQuad(_timer.value01()));
            break;
        }

        if (!_timer.isRunning()) {
            final switch (_state) with (State) {
            case fadeOut:
                _state = State.black;
                Atelier.world.load(_sceneRid, _tpName);
                break;
            case black:
                break;
            case fadeIn:
                _isRunning = false;
                break;
            }
        }
    }

    override void onCameraMoved() {
        _state = State.fadeIn;
        _timer.start(_fadeDuration);
    }

    override void setupDrawStep(Scene scene, Vec2f offset, Vec2f targetPos) {
    }

    override void drawLine(Vec2f offset, int y, size_t level) {
    }

    override void drawEntity(Entity entity, Vec2f entityOffset) {
        entity.draw(entityOffset);
    }

    override void renderEntity(Entity entity, Vec2f offset, float tTransition, bool drawGraphics) {
    }

    override void drawAbove() {
        _rect.draw();
    }
}
