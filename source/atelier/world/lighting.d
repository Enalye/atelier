/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.world.lighting;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world.scene;
import atelier.world.world;

package(atelier.world) void registerSystems_lighting(World world) {
    world.registerSystem!SystemUpdater("lighting", &_updateSystem);
    world.registerSystem!SystemRenderer("lighting", &_renderSystem);
    world.registerSystem!SystemInitializer("lighting", &_initSystem);
}

final class LightingSystem {
    float globalIllumination = 1f;
    Sprite rectSprite, lightSprite;
    Canvas canvas;
    Sprite sprite;

    this() {
        canvas = new Canvas(Atelier.renderer.size.x, Atelier.renderer.size.y);
        sprite = new Sprite(canvas);
        sprite.blend = Blend.modular;
        sprite.anchor = Vec2f.zero;

        rectSprite = Atelier.res.get!Sprite("atelier:light.darkness");
        rectSprite.blend = Blend.alpha;
        rectSprite.anchor = Vec2f.zero;
        rectSprite.color = Color.white;

        lightSprite = Atelier.res.get!Sprite("atelier:light.point512");
        lightSprite.blend = Blend.additive;
        lightSprite.anchor = Vec2f.half;
    }
}

struct LightComponent {
    Light light;

    void onInit() {
        light = null;
    }

    void onDestroy() {

    }
}

struct DarknessComponent {
    Darkness darkness;

    void onInit() {
        darkness = null;
    }

    void onDestroy() {

    }
}

private void* _initSystem(Scene scene) {
    return cast(void*) new LightingSystem;
}

private void _updateSystem(Scene scene, void* context) {
    EntityComponentPool!DarknessComponent darknesses = scene.getComponentPool!DarknessComponent();
    EntityComponentPool!LightComponent lights = scene.getComponentPool!LightComponent();

    EntityID[] removeTable;
    foreach (id, darkness; darknesses) {
        darkness.darkness.update();

        if (!darkness.darkness.isAlive()) {
            removeTable ~= id;
        }
    }
    foreach (EntityID id; removeTable) {
        scene.removeComponent!DarknessComponent(id);
    }

    removeTable.length = 0;
    foreach (id, light; lights) {
        light.light.update();

        if (!light.light.isAlive()) {
            removeTable ~= id;
        }
    }
    foreach (EntityID id; removeTable) {
        scene.removeComponent!LightComponent(id);
    }
}

private void _renderSystem(Scene scene, void* context, Vec2f offset, bool isFront) {
    if (!isFront) {
        return;
    }

    EntityComponentPool!DarknessComponent darknesses = scene.getComponentPool!DarknessComponent();
    EntityComponentPool!LightComponent lights = scene.getComponentPool!LightComponent();
    LightingSystem sys = cast(LightingSystem) context;

    sys.canvas.color = Color.black;
    Atelier.renderer.pushCanvas(sys.canvas);

    float tempDarkness = 0f;
    if (darknesses.getCount()) {
        foreach (id, darkness; darknesses) {
            tempDarkness += clamp(darkness.darkness.intensity, 0f, 1f);
        }
        tempDarkness /= cast(float) darknesses.getCount();
    }
    sys.rectSprite.alpha = lerp(sys.globalIllumination, 0f, tempDarkness);
    sys.rectSprite.size = sys.sprite.size;
    sys.rectSprite.anchor = Vec2f.zero;
    sys.rectSprite.draw(Vec2f.zero);

    foreach (id, light; lights) {
        PositionComponent* position = scene.getPosition(id);

        sys.lightSprite.size = light.light.size;
        sys.lightSprite.color = light.light.color;
        sys.lightSprite.alpha = light.light.intensity;
        sys.lightSprite.draw(offset + position.worldPosition + light.light.position);

        import std.stdio;

        //writeln(id, ": loc: ", position.localPosition, ", global: ", position.worldPosition);
    }

    Atelier.renderer.popCanvas();
    sys.sprite.draw(Vec2f.zero);
}

interface Darkness {
    @property {
        float intensity() const;
        bool isAlive() const;
    }

    void update();
}

final class FadedDarkness : Darkness {
    private {
        float _intensity, _maxIntensity;
        uint _fadeIn, _duration, _fadeOut;
        Timer _timer;
        enum State {
            fadeIn,
            stay,
            fadeOut
        }

        State _state;
        bool _isAlive;
    }

    @property {
        float intensity() const {
            return _intensity;
        }

        bool isAlive() const {
            return _isAlive;
        }
    }

    this(float intensity, uint fadeIn, uint duration, uint fadeOut) {
        _intensity = 0f;
        _maxIntensity = intensity;
        _fadeIn = fadeIn;
        _duration = duration;
        _fadeOut = fadeOut;
        _state = State.fadeIn;
        _timer.start(_fadeIn);
        _isAlive = true;
    }

    void update() {
        _timer.update();
        final switch (_state) with (State) {
        case fadeIn:
            if (!_timer.isRunning()) {
                _state = State.stay;
                _timer.start(_duration);
            }
            else {
                _intensity = lerp(0f, _maxIntensity, _timer.value01);
            }
            break;
        case stay:
            if (!_timer.isRunning()) {
                _state = State.fadeOut;
                _timer.start(_fadeOut);
            }
            else {
                _intensity = _maxIntensity;
            }
            break;
        case fadeOut:
            if (!_timer.isRunning()) {
                _isAlive = false;
            }
            else {
                _intensity = lerp(_maxIntensity, 0f, _timer.value01);
            }
            break;
        }
    }
}

abstract class Light {
    private {
        Vec2f _position = Vec2f.zero;
        Vec2f _size = Vec2f.zero;
        Color _color = Color.white;
        float _intensity = 1f;
        bool _isAlive = true;
    }

    @property {
        Vec2f position() const {
            return _position;
        }

        Vec2f size() const {
            return _size;
        }

        Color color() const {
            return _color;
        }

        float intensity() const {
            return _intensity;
        }

        bool isAlive() const {
            return true;
        }
    }

    void update() {
    }
}

final class PointLight : Light {
    this(Vec2f position_, Vec2f size_) {
        _position = position_;
        _size = size_;
        _color = Color.white;
        _intensity = 1f;
    }

    @property {
        override float intensity() const {
            return _intensity;
        }

        float intensity(float intensity_) {
            return _intensity = intensity_;
        }

        override Vec2f size() const {
            return _size;
        }

        Vec2f size(Vec2f size_) {
            return _size = size_;
        }

        override Color color() const {
            return _color;
        }

        Color color(Color color_) {
            return _color = color_;
        }
    }

    override void update() {
    }
}

final class FadedLight : Light {
    private {
        float _maxIntensity;
        uint _fadeIn, _duration, _fadeOut;
        Timer _timer;
        enum State {
            fadeIn,
            stay,
            fadeOut
        }

        State _state;
    }

    this(Vec2f position_, float size_, Color color, float intensity, uint fadeIn,
        uint duration, uint fadeOut) {
        _position = position_;
        _size = Vec2f(size_, size_);
        _color = color;
        _intensity = 0f;
        _maxIntensity = intensity;
        _fadeIn = fadeIn;
        _duration = duration;
        _fadeOut = fadeOut;
        _state = State.fadeIn;
        _timer.start(_fadeIn);
        _isAlive = true;
    }

    override void update() {
        _timer.update();
        final switch (_state) with (State) {
        case fadeIn:
            if (!_timer.isRunning()) {
                _state = State.stay;
                _timer.start(_duration);
            }
            else {
                _intensity = lerp(0f, _maxIntensity, _timer.value01);
            }
            break;
        case stay:
            if (!_timer.isRunning()) {
                _state = State.fadeOut;
                _timer.start(_fadeOut);
            }
            else {
                _intensity = _maxIntensity;
            }
            break;
        case fadeOut:
            if (!_timer.isRunning()) {
                _isAlive = false;
            }
            else {
                _intensity = lerp(_maxIntensity, 0f, _timer.value01);
            }
            break;
        }
    }
}
