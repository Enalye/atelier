module atelier.world.entity.base;

import std.math;

import farfadet;
import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.render;
import atelier.world.lighting;
import atelier.world.world;
import atelier.world.entity.effect;
import atelier.world.entity.component;
import atelier.world.entity.controller;
import atelier.world.entity.renderer;

// Propriétés de base l’entité
struct BaseEntityData {
    string[] tags;
    string controller;
    int zOrderOffset;

    mixin Serializer;
}

// Propriétés de l’entité dans la scène
struct EntityData {
    string name;
    string[] tags;
    string layer = Entity.Layer.scene.stringof;
    Vec3i position;
    string controller;

    mixin Serializer;
}

mixin template EntityController() {
    private {
        alias T = typeof(this);

        static assert(__traits(isAbstractClass, T) == false,
            "EntityController ne doit pas être intégré dans une classe abstraite");

        Controller!T _controller;
    }

    Controller!T getController() {
        return _controller;
    }

    override bool hasController() {
        return _controller !is null;
    }

    override void removeController() {
        if (_controller) {
            _controller.unregister();
            _controller = null;
        }
    }

    override void setController(string id) {
        import atelier.core : Atelier;

        if (_controller) {
            _controller.unregister();
        }

        _controller = Atelier.world.fetchController!T(id);

        if (_controller) {
            _controller.setup(this);
            Atelier.world.registerController(_controller);
            _controller.onStart();
        }
    }

    override string sendEvent(string event) {
        if (!_controller)
            return "";

        return _controller.onEvent(event);
    }

    final private void onHit(Entity target, Vec3f normal) {
        if (!_controller)
            return;

        _controller.onHit(target, normal);
    }

    final private void onSquish(Vec3f normal) {
        if (!_controller)
            return;

        _controller.onSquish(normal);
    }

    final private void onImpact(Entity target, Vec3f normal) {
        if (!_controller)
            return;

        _controller.onImpact(target, normal);
    }
}

abstract class Entity {
    enum Layer {
        scene,
        above,
        glow
    }

    enum Type {
        actor,
        prop,
        particle,
        proxy,
        shot,
        teleporter,
        trigger
    }

    private {
        Type _type;
        bool _isRegistered = false;
        string _name;
        string[] _tags;
        Layer _layer = Layer.scene;
        string _baseControllerId;
        bool _hasCulling = true;
    }

    protected {
        EntityComponent[string] _components;
        EntityGraphic[string] _graphics;
        string _graphicId;
        EntityGraphic _graphic;

        struct AuxGraphic {
            string id;
            EntityGraphic graphic;
        }

        AuxGraphic[] _auxGraphics;

        EntityGraphicEffectWrapper _effect;
        Collider _collider;
        Hurtbox _hurtbox;
        float _angle = 180f;
        int _material = 0;
        int _baseZ = 0;
        int _baseMaterial = 0;

        Vec3i _position = Vec3i.zero;
        Vec3f _subPosition = Vec3f.zero;
        Vec3f _velocity = Vec3f.zero;
        Vec3f _acceleration = Vec3f.zero;
        bool _shadow;
        int _shadowBaseZ = 0;
        bool _isMoving;
        Vec3i _targetPosition = Vec3i.zero;
        int _zOrderOffset;

        bool _isEnabled = true;
        bool _isRendered;
        int _isInRenderList;
        Entity[] _renderEntitiesAbove;
        Entity[] _renderEntitiesBehind;
    }

    @property {
        final Type type() const {
            return _type;
        }

        final Vec2f cameraPosition() const {
            return Vec2f(_position.x, _position.y - _position.z);
        }

        final bool isRegistered() const {
            return _isRegistered;
        }

        /*package(atelier.world) */
        final bool isRegistered(bool value) {
            return _isRegistered = value;
        }

        final bool isRendered() const {
            return _isRendered;
        }

        final bool isRendered(bool value) {
            return _isRendered = value;
        }

        final int isInRenderList() const {
            return _isInRenderList;
        }

        final int isInRenderList(int value) {
            return _isInRenderList = value;
        }

        bool isMoving() const {
            return _isMoving;
        }

        bool isEnabled() const {
            return _isEnabled;
        }

        float angle() const {
            return _angle;
        }

        float angle(float angle_) {
            _angle = angle_;
            if (_graphic) {
                _graphic.setAngle(_angle);
            }

            foreach (ref auxGraphic; _auxGraphics) {
                if (!auxGraphic.graphic)
                    continue;

                auxGraphic.graphic.setAngle(_angle);
            }

            return _angle;
        }

        Vec3f velocity() const {
            return _velocity;
        }
    }

    this(Type type_) {
        _type = type_;
    }

    this(Entity other) {
        _type = other._type;
        _name = other._name;
        _tags = other._tags;
        _layer = other._layer;
        _position = other._position;
        _angle = other._angle;
        _material = other._material;
        _baseZ = other._baseZ;
        _baseControllerId = other._baseControllerId;
        _zOrderOffset = other._zOrderOffset;
        _baseMaterial = other._baseMaterial;
        _shadowBaseZ = other._shadowBaseZ;
        _shadow = other._shadow;
        _isEnabled = other._isEnabled;
        _hasCulling = other._hasCulling;

        foreach (id, renderer; other._graphics) {
            _graphics[id] = renderer.fetch();
        }

        if (other._collider) {
            _collider = other._collider.fetch();
            _collider.setEntity(this);
        }

        if (other._hurtbox) {
            _hurtbox = new Hurtbox(other._hurtbox);
            _hurtbox.setEntity(this);
        }

        // Graphique par défaut
        foreach (graphicId, graphic; _graphics) {
            if (graphic.getDefault()) {
                _graphic = graphic;
                _graphic.start();
                _graphic.setAngle(_angle);
                version (AtelierEtabli) {
                }
                else {
                    Atelier.world.addRenderedEntity(this);
                }
                break;
            }
        }
    }

    final void setData(const(EntityData) data) {
        _name = data.name;
        _tags ~= data.tags.dup;
        _layer = asEnum!Layer(data.layer);
        setPosition(data.position);

        if (data.controller.length) {
            setController(data.controller);
        }
    }

    final void setBaseEntityData(const(BaseEntityData) data) {
        _tags ~= data.tags.dup;
        _baseControllerId = data.controller;
        _zOrderOffset = data.zOrderOffset;
    }

    final Layer getLayer() const {
        return _layer;
    }

    final void setLayer(Layer layer) {
        _layer = layer;
    }

    T getComponent(T : EntityComponent)() {
        return cast(T) _components.require(T.stringof, {
            T component = new T;
            component.entity = this;
            component.setup();
            return component;
        }());
    }

    void addComponent(T : EntityComponent)() {
        if (T.stringof in _components)
            return;
        T component = new T;
        component.entity = this;
        component.setup();
        _components[T.stringof] = component;
    }

    void removeComponent(T : EntityComponent)() {
        _components.remove(T.stringof);
    }

    final void removeCollider() {
        if (_collider) {
            _collider.setEntity(null);
            _collider.unregister();
            _collider = null;
        }
    }

    final Collider getBaseCollider() {
        return _collider;
    }

    final void unregister() {
        _isRegistered = false;
    }

    final int getColumn() const {
        return _position.x / 16;
    }

    final int getLine() const {
        return _position.y / 16;
    }

    final int getLevel() const {
        return _position.z / 16;
    }

    final Vec3i getTilePosition() const {
        return _position >> 4;
    }

    final void setTilePosition(Vec3i pos) {
        _position = pos << 4;
        if (_collider) {
            Vec2i offset = _collider.getTileOffset();
            _position.x += offset.x;
            _position.y += offset.y;
        }
        _subPosition = Vec3f.zero;
        reloadTerrainInfo();
    }

    final int getYOrder() const {
        if (_collider) {
            return _collider.down();
        }
        else if (_graphic) {
            return cast(int) _graphic.getDown(_position.y).ceil();
        }
        return _position.y;
    }

    final Vec3i getGroundPosition() const {
        return Vec3i(_position.x, _position.y, _baseZ);
    }

    final Vec3i getPosition() const {
        return _position;
    }

    final void setPosition(Vec3i pos) {
        _position = pos;
        _subPosition = Vec3f.zero;
        reloadTerrainInfo();
    }

    final void addPosition(Vec3i pos) {
        _position += pos;
        reloadTerrainInfo();
    }

    final void setPosition(Vec3f pos) {
        _position = Vec3i.zero;
        moveRaw(pos);
    }

    final Vec3f getSubPosition() const {
        return _subPosition;
    }

    final void setSubPosition(Vec3f pos) {
        _subPosition = pos;
    }

    final void setPositionRaw(Vec3i pos, Vec3f subPos) {
        _position = pos;
        _subPosition = subPos;
        reloadTerrainInfo();
    }

    final void addGraphic(string name, EntityGraphic renderer) {
        _graphics[name] = renderer;
    }

    final void setDefaultGraphic() {
        if (_graphic && _graphic.getDefault())
            return;

        bool wasRendered;
        if (_graphic) {
            _graphic.stop();
            _graphic = null;
            wasRendered = true;
        }

        foreach (graphicId, graphic; _graphics) {
            if (graphic.getDefault()) {
                _graphic = graphic;
                _graphic.start();
                _graphic.setAngle(_angle);

                if (!wasRendered) {
                    version (AtelierEtabli) {
                    }
                    else {
                        Atelier.world.addRenderedEntity(this);
                    }
                }
                return;
            }
        }

        if (!_graphic) {
            Atelier.log("Pas d’état graphique par défaut trouvé");
        }
    }

    final void setGraphic(string id) {
        if (!id.length) {
            setDefaultGraphic();
            return;
        }
        else if (_graphicId == id) {
            return;
        }

        _graphicId = id;

        if (_graphicId !in _graphics) {
            if (_graphicId.length) {
                Atelier.log("Pas d’état `", _graphicId, "` trouvé");
            }
            _graphic = null;
            return;
        }

        if (_graphic) {
            _graphic.stop();
        }

        bool wasRendered = _graphic !is null;
        _graphic = _graphics[_graphicId];
        _graphic.start();
        _graphic.setAngle(_angle);
        if (!wasRendered) {
            version (AtelierEtabli) {
            }
            else {
                Atelier.world.addRenderedEntity(this);
            }
        }
    }

    final void setAuxGraphic(uint index, string id) {
        if (index >= _auxGraphics.length) {
            if (!id.length)
                return;

            _auxGraphics.length = index + 1;
        }

        if (!id.length) {
            _auxGraphics[index].id.length = 0;
            _auxGraphics[index].graphic = null;
            return;
        }
        else if (_auxGraphics[index].id == id) {
            return;
        }

        _auxGraphics[index].id = id;

        if (id !in _graphics) {
            if (id.length) {
                Atelier.log("Pas d’état `", id, "` trouvé");
            }
            _auxGraphics[index].graphic = null;
            return;
        }

        if (_auxGraphics[index].graphic) {
            _auxGraphics[index].graphic.stop();
        }

        _auxGraphics[index].graphic = _graphics[id];
        _auxGraphics[index].graphic.start();
        _auxGraphics[index].graphic.setAngle(_angle);
    }

    final EntityGraphic getGraphic() {
        return _graphic;
    }

    final EntityGraphic getAuxGraphic(uint index) {
        if (index >= _auxGraphics.length)
            return null;

        return _auxGraphics[index].graphic;
    }

    final void setEffect(EntityGraphicEffect effect) {
        _effect = effect.setup(this);
    }

    final void setShadow(bool shadow_) {
        _shadow = shadow_;
    }

    final void setMaterial(int mat) {
        _material = mat;
    }

    final int getMaterial() const {
        return _material;
    }

    final int getBaseMaterial() const {
        return _baseMaterial;
    }

    final void setupHurtbox(HurtboxData data) {
        if (_hurtbox) {
            _hurtbox.unregister();
            _hurtbox = null;
        }

        if (data.type == "none")
            return;

        _hurtbox = new Hurtbox(this, data);
    }

    void update() {
    }

    final void updateEntityGraphics() {
        if (_graphic) {
            _graphic.update();
        }

        foreach (ref auxGraphic; _auxGraphics) {
            if (!auxGraphic.graphic)
                continue;

            auxGraphic.graphic.update();
        }
    }

    final void updateEntity() {
        if (_isEnabled) {
            foreach (component; _components) {
                component.update();
            }

            if (_effect) {
                _effect.update(this);
                if (!_effect.isRunning) {
                    _effect = null;
                }
            }

            _shadowBaseZ = approach(_shadowBaseZ, _baseZ, 1);

            if (_isMoving) {
                _position.x = approach(_position.x, _targetPosition.x, 1);
                _position.y = approach(_position.y, _targetPosition.y, 1);
                _position.z = approach(_position.z, _targetPosition.z, 1);

                if (_position == _targetPosition) {
                    _isMoving = false;
                }
            }
        }
    }

    final void clearRenderInfo() {
        _isInRenderList = 0;
        _renderEntitiesAbove.length = 0;
        _renderEntitiesBehind.length = 0;
    }

    final void addRenderChild(Entity child, bool inFront) {
        if (inFront)
            _renderEntitiesAbove ~= child;
        else
            _renderEntitiesBehind ~= child;
    }

    final void setZOrderOffset(int offset) {
        _zOrderOffset = offset;
    }

    final int getZOrder() const {
        return _position.z + _zOrderOffset;
    }

    final bool isAbove(Entity entity, bool verbose = false) {
        if (_collider && entity._collider)
            return _collider.isAbove(entity._collider);
        if (_collider && entity._graphic) {
            if (verbose) {
                Atelier.log(entity._position.x, " -> ", entity._graphic.getLeft(entity._position.x), " : ", _collider
                        .right);
                Atelier.log((entity._graphic.getLeft(entity._position.x) < _collider.right), ", ",
                    (entity._graphic.getRight(entity._position.x) > _collider.left), ", ",
                    (entity._graphic.getUp(entity._position.y) < _collider.down), ", ",
                    (entity._graphic.getDown(entity._position.y) > _collider.up), ", ",
                    (entity._position.z <= _position.z));
            }
            return (entity._graphic.getLeft(entity._position.x) < _collider.right) &&
                (entity._graphic.getRight(entity._position.x) > _collider.left) &&
                (entity._graphic.getUp(entity._position.y) < _collider.down) &&
                (entity._graphic.getDown(entity._position.y) > _collider.up) &&
                (entity._position.z <= _position.z);
        }
        if (_graphic && entity._collider) {
            return (entity._collider.left < _graphic.getRight(_position.x)) &&
                (entity._collider.right > _graphic.getLeft(_position.x)) &&
                (entity._collider.up < _graphic.getDown(_position.y)) &&
                (entity._collider.down > _graphic.getUp(_position.y)) &&
                (entity._position.z <= _position.z);
        }
        if (_graphic && entity._graphic) {
            return (entity._graphic.getLeft(_position.x) < _graphic.getRight(_position.x)) &&
                (entity._graphic.getRight(_position.x) > _graphic.getLeft(_position.x)) &&
                (entity._graphic.getUp(_position.y) < _graphic.getDown(_position.y)) &&
                (entity._graphic.getDown(_position.y) > _graphic.getUp(_position.y)) &&
                (entity._position.z <= _position.z);
        }
        return false;
    }

    final bool isBehind(Entity entity) {
        if (_collider && entity._collider)
            return _collider.isBehind(entity._collider);
        if (_graphic && entity._graphic)
            return (entity._graphic.getLeft(entity._position.x) < _graphic.getRight(_position.x)) &&
                (entity._graphic.getRight(entity._position.x) > _graphic.getLeft(_position.x));
        return false;
    }

    final void setCulling(bool culling) {
        _hasCulling = culling;
    }

    final bool isCulled(Vec4f bounds) const {
        if (!_graphic)
            return true;
        if (!_hasCulling)
            return false;
        return (_graphic.getRight(_position.x) < bounds.x) ||
            (_graphic.getLeft(_position.x) > bounds.z) ||
            (_graphic.getDown(_position.y) < bounds.y) ||
            (_graphic.getUp(_position.y) > bounds.w);
    }

    final void moveRaw(Vec3f dir) {
        _subPosition += dir;
        Vec3i delta = cast(Vec3i) _subPosition.round();
        _subPosition -= cast(Vec3f) delta;
        _position += delta;
        reloadTerrainInfo();
    }

    final void moveTileRaw(Vec3i dir) {
        _targetPosition = (getTilePosition() << 4) + dir * 16;
        if (_collider) {
            Vec2i offset = _collider.getTileOffset();
            _targetPosition.x += offset.x;
            _targetPosition.y += offset.y;
        }
        _isMoving = true;
        _subPosition = Vec3f.zero;
        reloadTerrainInfo();
    }

    final void moveRaw(Vec3i dir, int baseZ_, int material_) {
        _position += dir;
        _baseZ = baseZ_;
        _baseMaterial = material_;
    }

    final void moveTile(Vec3i dir) {
        if (_collider) {
            _collider.moveTile(dir);
        }
        else {
            moveTileRaw(dir);
        }
    }

    final void move(Vec3f dir) {
        version (AtelierEtabli) {
            moveRaw(dir);
        }
        else {
            if (_collider) {
                if (!_collider.move(dir)) {
                    _velocity.set(0f, 0f, 0f);
                    _acceleration.set(0f, 0f, 0f);
                }
            }
            else {
                moveRaw(dir);
            }
        }
    }

    void reloadTerrainInfo() {
        version (AtelierEtabli) {
            _baseZ = 0;
        }
        else {
            if (_collider) {
                Physics.TerrainHit hit = _collider.hitTerrain();
                _baseZ = hit.height;
            }
            else {
                _baseZ = Atelier.world.scene.getBaseZ(_position.xy);
            }
        }
    }

    int getBaseZ() const {
        return _baseZ;
    }

    bool isOnGround() const {
        return _position.z <= _baseZ;
    }

    int getAltitude() const {
        return _position.z - _baseZ;
    }

    Hurtbox getHurtbox() {
        return _hurtbox;
    }

    final void setName(string name_) {
        _name = name_;
    }

    final string getName() const {
        return _name;
    }

    final void addTag(string tag_) {
        if (hasTag(tag_))
            return;
        _tags ~= tag_;
    }

    final bool hasTag(string tag_) const {
        foreach (tag; _tags) {
            if (tag == tag_)
                return true;
        }
        return false;
    }

    /// À changer plus tard
    final bool hasGraphic(string graphic_) const {
        return _graphic == _graphics[graphic_];
    }

    bool hasController() {
        return false;
    }

    void removeController() {
    }

    void setController(string id) {
    }

    string sendEvent(string event) {
        return "";
    }

    void updateMovement() {
    }

    final void setSpeed(float xySpeed, float zSpeed) {
        _velocity = Vec3f(Vec2f.angled(degToRad(_angle)) * xySpeed, zSpeed);
    }

    final void addSpeed(float xySpeed, float zSpeed) {
        _velocity += Vec3f(Vec2f.angled(degToRad(_angle)) * xySpeed, zSpeed);
    }

    final void setVelocity(Vec3f dir) {
        _velocity = dir;
    }

    final void addVelocity(Vec3f dir) {
        _velocity += dir;
    }

    final void accelerate(Vec3f dir) {
        _acceleration = dir;
    }

    final void lookAt(Vec2i target) {
        Vec2i origin = getPosition().xy;

        if (target == origin)
            return;

        const float angle_ = (cast(Vec2f)(target - origin)).angle();

        angle(clampDeg(radToDeg(angle_) + 90f));
    }

    final void lookAt(Entity target) {
        lookAt(target.getPosition().xy);
    }

    final void draw(Vec2f offset, Sprite shadowSprite) {
        Vec2f drawPos = offset + cameraPosition();

        foreach (child; _renderEntitiesBehind) {
            child.draw(offset, shadowSprite);
        }

        if (_isEnabled) {
            renderShadow(drawPos, shadowSprite);

            if (_collider && _collider.isDisplayed) {
                _collider.drawBack(drawPos);
                render(drawPos);
                _collider.drawFront(drawPos);
            }
            else {
                render(drawPos);
            }

            if (_hurtbox && _hurtbox.isDisplayed) {
                _hurtbox.draw(drawPos);
            }
        }

        foreach (child; _renderEntitiesAbove) {
            child.draw(offset, shadowSprite);
        }
    }

    final void drawTransition(Vec2f offset, Sprite shadowSprite, float tTransition, bool drawGraphics) {
        Vec2f drawPos = offset + cameraPosition();

        foreach (child; _renderEntitiesBehind) {
            child.drawTransition(offset, shadowSprite, tTransition, drawGraphics);
        }

        if (_isEnabled) {
            Atelier.world.renderEntityTransition(this, drawPos, shadowSprite, tTransition, drawGraphics);
        }

        foreach (child; _renderEntitiesAbove) {
            child.drawTransition(offset, shadowSprite, tTransition, drawGraphics);
        }
    }

    final void render(Vec2f offset, float alpha = 1f) {
        if (_effect) {
            _effect.draw(offset, alpha);
        }
        else {
            renderGraphic(offset, alpha);
        }
    }

    final void renderShadow(Vec2f offset, Sprite shadowSprite, float alpha = 1f) {
        if (!_shadow)
            return;

        int alt = getAltitude();
        float t = easeInOutSine(clamp(alt, 0, 16) / 16f);
        shadowSprite.alpha = lerp(0.6f, 0.2f,
            t) * Atelier.world.lighting.getBrightnessAt(
            _position.xy) * alpha;
        shadowSprite.size = Vec2f.one * lerp(15f, 10f, t);
        shadowSprite.draw(offset + Vec2f(0f, alt));
    }

    final void renderGraphic(Vec2f offset, float alpha = 1f) {
        if (_auxGraphics.length) {
            for (size_t i; i < _auxGraphics.length; ++i) {
                if (_auxGraphics[i].graphic && _auxGraphics[i].graphic.isBehind()) {
                    _auxGraphics[i].graphic.draw(offset, alpha);
                }
            }

            _graphic.draw(offset, alpha);

            for (size_t i; i < _auxGraphics.length; ++i) {
                if (_auxGraphics[i].graphic && !_auxGraphics[i].graphic.isBehind()) {
                    _auxGraphics[i].graphic.draw(offset, alpha);
                }
            }
        }
        else {
            _graphic.draw(offset, alpha);
        }
    }

    final void setEnabled(bool enabled) {
        if (enabled) {
            _isEnabled = true;
            if (_collider)
                _collider.register();
            if (_hurtbox)
                _hurtbox.register();
        }
        else {
            _isEnabled = false;
            if (_collider)
                _collider.unregister();
            if (_hurtbox)
                _hurtbox.unregister();
        }
    }

    final void onRegister() {
        if (_collider) {
            _collider.register();
        }
        if (_hurtbox) {
            _hurtbox.register();
        }
        if (!hasController()) {
            if (_baseControllerId.length) {
                setController(_baseControllerId);
            }
        }

        onRegisterEntity();
    }

    final void onUnregister() {
        if (_collider) {
            _collider.unregister();
        }
        if (_hurtbox) {
            _hurtbox.unregister();
        }
        removeController();

        onUnregisterEntity();
    }

    void onRegisterEntity() {
    }

    void onUnregisterEntity() {
    }

    void onCollide(Physics.CollisionHit hit) {
    }

    void onTrigger() {
    }
}
