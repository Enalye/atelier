module atelier.world.entity.base;

import std.algorithm.sorting : sort;
import std.math;

import farfadet;
import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.render;
import atelier.world.lighting;
import atelier.world.system;
import atelier.world.entity.component;
import atelier.world.entity.controller;
import atelier.world.entity.effect;
import atelier.world.entity.behavior;
import atelier.world.entity.renderer;
import atelier.world.entity.shadow;

// Propriétés de base l’entité
struct BaseEntityData {
    string[] tags;
    string controller;
    string behavior;
    string shadow;
    int zOrderOffset;
    int material;

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

final class Entity : Resource!Entity {
    mixin ControllerMixin;

    enum Layer {
        scene,
        above,
        glow
    }

    private {
        bool _isRegistered = false;
        string _name;
        string[] _tags;
        Layer _layer = Layer.scene;
        string _baseControllerId;
        string _baseBehaviorId;
        bool _hasCulling = true;
        uint _sectorID;
    }

    protected {
        EntityComponent[string] _components;
        EntityGraphic[string] _graphics, _auxGraphics;
        string _graphicId;
        EntityGraphic _graphic;

        struct AuxGraphicSlot {
            string id;
            bool isUpdated;
            EntityGraphic graphic;
        }

        AuxGraphicSlot[] _auxGraphicSlots;
        EntityGraphic[] _auxGraphicStack;

        EntityGraphicEffectWrapper _effect;
        Collider _collider;
        Hurtbox _hurtbox;
        Repulsor _repulsor;
        EntityBehavior _behavior;
        float _angle = 180f;
        int _material = 0;
        int _baseZ = 0;
        int _baseMaterial = 0;

        Vec3i _position = Vec3i.zero;
        Vec3f _subPosition = Vec3f.zero;
        Vec3f _velocity = Vec3f.zero;
        Vec3f _accel = Vec3f.zero;
        Shadow _shadow;
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
        Vec2f cameraPosition() const {
            return Vec2f(_position.x, _position.y - _position.z);
        }

        bool isRegistered() const {
            return _isRegistered;
        }

        /*package(atelier.world) */
        bool isRegistered(bool value) {
            return _isRegistered = value;
        }

        bool isRendered() const {
            return _isRendered;
        }

        bool isRendered(bool value) {
            return _isRendered = value;
        }

        int isInRenderList() const {
            return _isInRenderList;
        }

        int isInRenderList(int value) {
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

            foreach (ref auxGraphic; _auxGraphicSlots) {
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

    this() {
    }

    this(Entity other) {
        _name = other._name;
        _tags = other._tags;
        _layer = other._layer;
        _position = other._position;
        _angle = other._angle;
        _material = other._material;
        _baseZ = other._baseZ;
        _baseControllerId = other._baseControllerId;
        _baseBehaviorId = other._baseBehaviorId;
        _zOrderOffset = other._zOrderOffset;
        _baseMaterial = other._baseMaterial;
        _shadowBaseZ = other._shadowBaseZ;
        _shadow = other._shadow;
        _isEnabled = other._isEnabled;
        _hasCulling = other._hasCulling;
        _sectorID = other._sectorID;

        foreach (id, renderer; other._graphics) {
            _graphics[id] = renderer.fetch();
        }

        foreach (id, renderer; other._auxGraphics) {
            _auxGraphics[id] = renderer.fetch();
        }

        if (other._collider) {
            _collider = other._collider.fetch();
            _collider.setEntity(this);
        }

        if (other._repulsor) {
            _repulsor = new Repulsor(other._repulsor);
            _repulsor.setEntity(this);
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
        _updateAuxGraphics();
    }

    Entity fetch() {
        return new Entity(this);
    }

    void setData(const(EntityData) data) {
        _name = data.name;
        _tags ~= data.tags.dup;
        _layer = asEnum!Layer(data.layer);
        setPosition(data.position);

        if (data.controller.length) {
            setController(data.controller);
        }
    }

    void setBaseEntityData(const(BaseEntityData) data) {
        _tags ~= data.tags.dup;
        _baseControllerId = data.controller;
        _baseBehaviorId = data.behavior;
        _zOrderOffset = data.zOrderOffset;
        _material = data.material;
        setShadow(data.shadow);
    }

    Layer getLayer() const {
        return _layer;
    }

    void setLayer(Layer layer) {
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

    T addComponent(T : EntityComponent)() {
        auto p = T.stringof in _components;
        if (p)
            return cast(T)(*p);
        T component = new T;
        component.entity = this;
        component.setup();
        _components[T.stringof] = component;
        return component;
    }

    void removeComponent(T : EntityComponent)() {
        _components.remove(T.stringof);
    }

    void setupRepulsor(RepulsorData data) {
        if (_repulsor) {
            _repulsor.unregister();
            _repulsor = null;
        }

        if (data.type == "none")
            return;

        _repulsor = new Repulsor(this, data);
    }

    Repulsor getRepulsor() {
        return _repulsor;
    }

    void setCollider(HitboxData data) {
        removeCollider();
        _collider = data.fetch();

        if (_collider) {
            _collider.setEntity(this);
        }
    }

    void setCollider(Collider collider) {
        removeCollider();
        _collider = collider;

        if (_collider) {
            _collider.setEntity(this);
        }
    }

    void removeCollider() {
        if (_collider) {
            _collider.setEntity(null);
            _collider.unregister();
            _collider = null;
        }
    }

    Collider getCollider() {
        return _collider;
    }

    EntityBehavior getBehavior() {
        return _behavior;
    }

    EntityBehavior setBehavior(string id) {
        _behavior = Atelier.world.fetchBehavior(id);
        _behavior.entity = this;
        _behavior.setup();
        return _behavior;
    }

    void unregister() {
        _isRegistered = false;
    }

    int getColumn() const {
        return _position.x / 16;
    }

    int getLine() const {
        return _position.y / 16;
    }

    int getLevel() const {
        return _position.z / 16;
    }

    Vec3i getTilePosition() const {
        return _position >> 4;
    }

    void setTilePosition(Vec3i pos) {
        _position = pos << 4;
        if (_collider) {
            Vec2i offset = _collider.getTileOffset();
            _position.x += offset.x;
            _position.y += offset.y;
        }
        _subPosition = Vec3f.zero;
        reloadTerrainInfo();
    }

    int getYOrder() const {
        if (_collider) {
            return _collider.down();
        }
        else if (_graphic) {
            return cast(int) _graphic.getDown(_position.y).ceil();
        }
        return _position.y;
    }

    Vec3i getGroundPosition() const {
        return Vec3i(_position.x, _position.y, _baseZ);
    }

    Vec3i getPosition() const {
        return _position;
    }

    void setPosition(Vec3i pos) {
        _position = pos;
        _subPosition = Vec3f.zero;
        reloadTerrainInfo();
    }

    void addPosition(Vec3i pos) {
        _position += pos;
        reloadTerrainInfo();
    }

    void setPosition(Vec3f pos) {
        _position = Vec3i.zero;
        moveRaw(pos);
    }

    Vec3f getSubPosition() const {
        return _subPosition;
    }

    void setSubPosition(Vec3f pos) {
        _subPosition = pos;
    }

    void setPositionRaw(Vec3i pos, Vec3f subPos) {
        _position = pos;
        _subPosition = subPos;
        reloadTerrainInfo();
    }

    void addGraphic(string name, EntityGraphic graphic) {
        _graphics[name] = graphic;
    }

    void addAuxGraphic(string name, EntityGraphic graphic) {
        _auxGraphics[name] = graphic;
    }

    void setDefaultGraphic() {
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
                _updateAuxGraphics();

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

    void setGraphic(string id, bool forceUpdate = false) {
        if (!id.length) {
            setDefaultGraphic();
            return;
        }
        else if (_graphicId == id && !forceUpdate) {
            return;
        }

        if (_graphic) {
            _graphic.stop();
        }

        _graphicId = id;

        if (_graphicId !in _graphics) {
            if (_graphicId.length) {
                Atelier.log("Pas d’état `", _graphicId, "` trouvé");
            }
            _graphic = null;
            _updateAuxGraphics();
            return;
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
        _updateAuxGraphics();
    }

    private void _updateAuxGraphics() {
        if (!_graphic)
            return;

        foreach (id; _graphic.getAuxGraphics()) {
            setAuxGraphic(id);
        }

        for (uint i; i < _auxGraphicSlots.length; ++i) {
            if (!_auxGraphicSlots[i].isUpdated) {
                _setAuxGraphic(i, "");
            }
            _auxGraphicSlots[i].isUpdated = false;
        }

        _auxGraphicStack.length = 0;
        for (uint i; i < _auxGraphicSlots.length; ++i) {
            if (!_auxGraphicSlots[i].graphic)
                continue;

            _auxGraphicStack ~= _auxGraphicSlots[i].graphic;
        }
        _auxGraphicStack.sort!((a, b) => a.getOrder() < b.getOrder())();
    }

    void setAuxGraphic(string id) {
        auto p = id in _auxGraphics;
        if (!p) {
            if (id.length) {
                Atelier.log("Pas d’état auxiliaire `", id, "` trouvé");
                assert(false);
            }
            return;
        }
        EntityGraphic graphic = *p;
        uint slot = graphic.getSlot();

        if (getAuxGraphic(slot) == graphic) {
            _auxGraphicSlots[slot].isUpdated = true;
            return;
        }

        if (slot >= _auxGraphicSlots.length) {
            if (!id.length)
                return;

            _auxGraphicSlots.length = slot + 1;
        }

        if (_auxGraphicSlots[slot].graphic) {
            _auxGraphicSlots[slot].graphic.stop();
        }

        _auxGraphicSlots[slot].isUpdated = true;
        _auxGraphicSlots[slot].graphic = graphic;
        _auxGraphicSlots[slot].graphic.start();
        _auxGraphicSlots[slot].graphic.setAngle(_angle);
    }

    private void _setAuxGraphic(uint index, string id) {
        if (index >= _auxGraphicSlots.length) {
            if (!id.length)
                return;

            _auxGraphicSlots.length = index + 1;
        }

        if (!id.length) {
            _auxGraphicSlots[index].id.length = 0;
            _auxGraphicSlots[index].graphic = null;
            return;
        }
        else if (_auxGraphicSlots[index].id == id) {
            return;
        }

        _auxGraphicSlots[index].id = id;

        if (id !in _auxGraphics) {
            if (id.length) {
                Atelier.log("Pas d’état auxiliaire `", id, "` trouvé");
                assert(false);
            }
            _auxGraphicSlots[index].graphic = null;
            return;
        }

        if (_auxGraphicSlots[index].graphic) {
            _auxGraphicSlots[index].graphic.stop();
        }

        _auxGraphicSlots[index].graphic = _graphics[id];
        _auxGraphicSlots[index].graphic.start();
        _auxGraphicSlots[index].graphic.setAngle(_angle);
    }

    EntityGraphic getGraphic(string id) {
        auto p = id in _graphics;
        return p ? *p : null;
    }

    EntityGraphic getGraphic() {
        return _graphic;
    }

    EntityGraphic[string] getGraphics() {
        return _graphics;
    }

    EntityGraphic getAuxGraphic(string id) {
        auto p = id in _auxGraphics;
        return p ? *p : null;
    }

    EntityGraphic getAuxGraphic(uint index) {
        if (index >= _auxGraphicSlots.length)
            return null;

        return _auxGraphicSlots[index].graphic;
    }

    EntityGraphic[string] getAuxGraphics() {
        return _auxGraphics;
    }

    void setEffect(EntityGraphicEffect effect) {
        _effect = effect.setup(this);
    }

    void setShadow(string shadow) {
        _shadow = shadow.length ?
            Atelier.res.get!Shadow(shadow) : null;
    }

    void setMaterial(int mat) {
        _material = mat;
    }

    int getMaterial() const {
        return _material;
    }

    int getBaseMaterial() const {
        return _baseMaterial;
    }

    void setupHurtbox(HurtboxData data) {
        if (_hurtbox) {
            _hurtbox.unregister();
            _hurtbox = null;
        }

        if (!data.hasHurtbox)
            return;

        _hurtbox = new Hurtbox(this, data);
    }

    void updateGraphics() {
        if (_graphic) {
            _graphic.update();
        }

        foreach (ref auxGraphic; _auxGraphicSlots) {
            if (!auxGraphic.graphic)
                continue;

            auxGraphic.graphic.update();
        }
    }

    void update() {
        if (_isEnabled) {
            if (_behavior) {
                _behavior.update();
            }

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

    void clearRenderInfo() {
        _isInRenderList = 0;
        _renderEntitiesAbove.length = 0;
        _renderEntitiesBehind.length = 0;
    }

    void addRenderChild(Entity child, bool inFront) {
        if (inFront)
            _renderEntitiesAbove ~= child;
        else
            _renderEntitiesBehind ~= child;
    }

    void setZOrderOffset(int offset) {
        _zOrderOffset = offset;
    }

    int getZOrder() const {
        return _position.z + _zOrderOffset;
    }

    bool isAbove(Entity entity, bool verbose = false) {
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

    bool isBehind(Entity entity) {
        if (_collider && entity._collider)
            return _collider.isBehind(entity._collider);
        if (_graphic && entity._graphic)
            return (entity._graphic.getLeft(entity._position.x) < _graphic.getRight(_position.x)) &&
                (entity._graphic.getRight(entity._position.x) > _graphic.getLeft(_position.x));
        return false;
    }

    void setCulling(bool culling) {
        _hasCulling = culling;
    }

    bool isCulled(Vec4f bounds) const {
        if (!_graphic)
            return true;
        if (!_hasCulling)
            return false;
        return (_graphic.getRight(_position.x) < bounds.x) ||
            (_graphic.getLeft(_position.x) > bounds.z) ||
            (_graphic.getDown(_position.y - _position.z) < bounds.y) ||
            (_graphic.getUp(_position.y - _position.z) > bounds.w);
    }

    void moveRaw(Vec3f dir) {
        _subPosition += dir;
        Vec3i delta = cast(Vec3i) _subPosition.round();
        _subPosition -= cast(Vec3f) delta;
        _position += delta;
        reloadTerrainInfo();
    }

    void moveTileRaw(Vec3i dir) {
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

    void moveRaw(Vec3i dir, int baseZ_, int material_) {
        _position += dir;
        _baseZ = baseZ_;
        _baseMaterial = material_;
    }

    void moveTile(Vec3i dir) {
        if (_collider) {
            _collider.moveTile(dir);
        }
        else {
            moveTileRaw(dir);
        }
    }

    void move(Vec3f dir) {
        version (AtelierEtabli) {
            moveRaw(dir);
        }
        else {
            if (_collider) {
                if (!_collider.move(dir)) {
                    _velocity.set(0f, 0f, 0f);
                    _accel.set(0f, 0f, 0f);
                }
            }
            else {
                moveRaw(dir);
            }
            _sectorID = Atelier.nav.getSectorID(_position);
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

    void setName(string name_) {
        _name = name_;
    }

    string getName() const {
        return _name;
    }

    void addTag(string tag_) {
        if (hasTag(tag_))
            return;
        _tags ~= tag_;
    }

    bool hasTag(string tag_) const {
        foreach (tag; _tags) {
            if (tag == tag_)
                return true;
        }
        return false;
    }

    /// À changer plus tard
    bool hasGraphic(string graphic_) const {
        return _graphic == _graphics[graphic_];
    }

    string sendEvent(string event) {
        return "";
    }

    void setSpeed(float xySpeed, float zSpeed) {
        _velocity = Vec3f(Vec2f.angled(degToRad(_angle)) * xySpeed, zSpeed);
    }

    void addSpeed(float xySpeed, float zSpeed) {
        _velocity += Vec3f(Vec2f.angled(degToRad(_angle)) * xySpeed, zSpeed);
    }

    void setVelocity(Vec3f dir) {
        _velocity = dir;
    }

    void addVelocity(Vec3f dir) {
        _velocity += dir;
    }

    Vec3f getAccel() const {
        return _accel;
    }

    void setAccel(Vec3f dir) {
        _accel = dir;
    }

    uint getSectorID() {
        return _sectorID;
    }

    void lookAt(Vec2i target) {
        Vec2i origin = getPosition().xy;

        if (target == origin)
            return;

        const float angle_ = (cast(Vec2f)(target - origin)).angle();

        angle(clampDeg(radToDeg(angle_)));
    }

    void lookAt(Entity target) {
        lookAt(target.getPosition().xy);
    }

    void draw(Vec2f offset) {
        Vec2f drawPos = offset + cameraPosition();

        foreach (child; _renderEntitiesBehind) {
            child.draw(offset);
        }

        if (_isEnabled) {
            renderShadow(drawPos);

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
            child.draw(offset);
        }
    }

    void drawTransition(Vec2f offset, float tTransition, bool drawGraphics) {
        Vec2f drawPos = offset + cameraPosition();

        foreach (child; _renderEntitiesBehind) {
            child.drawTransition(offset, tTransition, drawGraphics);
        }

        if (_isEnabled) {
            Atelier.world.renderEntityTransition(this, drawPos, tTransition, drawGraphics);
        }

        foreach (child; _renderEntitiesAbove) {
            child.drawTransition(offset, tTransition, drawGraphics);
        }
    }

    void render(Vec2f offset, float alpha = 1f) {
        if (_effect) {
            _effect.draw(offset, alpha);
        }
        else {
            renderGraphic(offset, alpha);
        }
    }

    void renderShadow(Vec2f offset, float alpha = 1f) {
        if (!_shadow)
            return;

        /*int alt = getAltitude();
        float t = easeInOutSine(clamp(alt, 0, 16) / 16f);
        shadowSprite.alpha = lerp(0.6f, 0.2f,
            t) * Atelier.world.lighting.getBrightnessAt(
            _position.xy) * alpha;
        shadowSprite.size = Vec2f.one * lerp(15f, 10f, t);
        shadowSprite.draw(offset + Vec2f(0f, alt));*/
        _shadow.draw(offset, _position.xy, getAltitude(), _angle, alpha);
    }

    void renderGraphic(Vec2f offset, float alpha = 1f) {
        Color color = Atelier.world.getDepthColor(_position.z);

        if (_auxGraphicStack.length) {
            for (size_t i; i < _auxGraphicStack.length; ++i) {
                if (_auxGraphicStack[i].isBehind()) {
                    _auxGraphicStack[i].setColor(color);
                    _auxGraphicStack[i].draw(offset, alpha);
                }
            }

            _graphic.setColor(color);
            _graphic.draw(offset, alpha);

            for (size_t i; i < _auxGraphicStack.length; ++i) {
                if (!_auxGraphicStack[i].isBehind()) {
                    _auxGraphicStack[i].setColor(color);
                    _auxGraphicStack[i].draw(offset, alpha);
                }
            }
        }
        else {
            _graphic.setColor(color);
            _graphic.draw(offset, alpha);
        }
    }

    void setEnabled(bool enabled) {
        if (enabled) {
            _isEnabled = true;
            onEnable();
            if (_collider)
                _collider.register();
            if (_hurtbox)
                _hurtbox.register();
        }
        else {
            _isEnabled = false;
            onDisable();
            if (_collider)
                _collider.unregister();
            if (_hurtbox)
                _hurtbox.unregister();
        }
    }

    void onRegister() {
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

        if (!_behavior) {
            if (_baseBehaviorId.length) {
                setBehavior(_baseBehaviorId);
            }
        }

        if (_repulsor) {
            _repulsor.register();
        }
    }

    void onUnregister() {
        if (_collider) {
            _collider.unregister();
        }
        if (_hurtbox) {
            _hurtbox.unregister();
        }
        removeController();

        if (_repulsor) {
            _repulsor.unregister();
        }
    }

    void onEnable() {
        onEnableController();
    }

    void onDisable() {
        onDisableController();
    }

    void onCollide(Physics.CollisionHit hit) {
        if (!_isEnabled)
            return;

        final switch (hit.type) with (Physics.CollisionHit.Type) {
        case none:
            Vec3f normal = hit.normal;
            if (normal.lengthSquared() > 0f) {
                Vec3f bounceVec = _velocity.dot(normal) * normal;
                float bounciness = hit.solid ? hit.solid.bounciness : 0f;
                bounciness += _collider ? (cast(ActorCollider) _collider).bounciness : 0f;
                _velocity += -(1f + bounciness) * bounceVec;
            }
            if (normal.z > 0f) {
                _velocity.z = 0f;

                if (hit.solid && _collider) {
                    _baseZ = hit.solid.getBaseZ(cast(ActorCollider) _collider);
                    _baseMaterial = hit.solid.entity.getMaterial();
                }
                else {
                    _baseMaterial = Atelier.world.scene.getMaterial(_position);
                }
            }
            onHit(hit.entity, hit.normal);
            break;
        case squish:
            onSquish(hit.normal);
            break;
        case impact:
            onImpact(hit.entity, hit.normal);
            break;
        }
    }

    void onTrigger() {
        foreach (component; _components) {
            if (TriggerComponent trigger = cast(TriggerComponent) component) {
                trigger.onTrigger();
            }
        }
    }
}
