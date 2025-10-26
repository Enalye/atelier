module atelier.world.entity.particle;

import std.math;
import std.conv : to, ConvException;
import farfadet;
import grimoire;
import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.world.entity.base;
import atelier.world.entity.renderer;

struct ParticleData {
    string mode;
    bool repeat;
    uint duration;
    uint delay;
    uint quantity;
    uint quantityVariance;
    Vec3f size = Vec3f.zero;
    float distance = 0f;
    float distanceVariance = 0f;
    float angle = 0f;
    float angleVariance = 0f;
    float angleSpread = 0f;
    string event;
    string layer;

    mixin Serializer;
}

enum ParticleMode {
    spread,
    rectangle,
    ellipsis
}

final class ParticleSource : Resource!ParticleSource {
    private {
        Entity _base;
        bool _isAttachedToCamera;
        EntityGraphic[string] _graphics;
        bool _isRegistered;

        ParticleData _data;
        ParticleMode _mode;

        GrEvent _grEvent;
        Timer _emitTimer, _delayTimer;
        uint _generation;
        Vec3i _position;
    }

    @property {
        bool isRegistered() const {
            return _isRegistered;
        }

        bool isRegistered(bool value) {
            return _isRegistered = value;
        }
    }

    this(ParticleData particleData) {
        _data = particleData;

        try {
            _mode = to!ParticleMode(_data.mode);
        }
        catch (ConvException e) {
            _mode = ParticleMode.spread;
        }
    }

    this(ParticleSource other) {
        _data = other._data;
        _mode = other._mode;

        foreach (id, renderer; other._graphics) {
            _graphics[id] = renderer.fetch();
        }
    }

    ParticleSource fetch() {
        return new ParticleSource(this);
    }

    void onRegister() {

    }

    void update() {
        _emitTimer.update();
        _delayTimer.update();

        if (_data.repeat && !_emitTimer.isRunning()) {
            _emitTimer.start();
            _generation = 0;
        }

        if (_emitTimer.isRunning()) {
            if (!_delayTimer.isRunning()) {
                _delayTimer.start(_data.delay);
                emit();
            }
        }
    }

    void start() {
        _grEvent = Atelier.script.getEvent(_data.event, [
                grGetNativeType("Particle")
            ]);
        if (!_grEvent)
            return;

        _emitTimer.start(_data.duration);
        _generation = 0;
        emit();
    }

    void stop() {
        _emitTimer.stop();
        _delayTimer.stop();
        _grEvent = null;
    }

    void clear() {
        //_particles.clear();
        _grEvent = null;
    }

    void unregister() {
        _isRegistered = false;
    }

    void setRepeat(bool value) {
        _data.repeat = value;
    }

    void emit() {
        if (!_grEvent) {
            _grEvent = Atelier.script.getEvent(_data.event, [
                    grGetNativeType("Particle")
                ]);
            if (!_grEvent)
                return;
        }

        switch (_data.mode) {
        case "spread":
            _emitSpread();
            break;
        case "rectangle":
            _emitRectangle();
            break;
        case "ellipsis":
            _emitEllipsis();
            break;
        default:
            break;
        }
        _generation++;
    }

    void addGraphic(string name, EntityGraphic renderer) {
        _graphics[name] = renderer;
    }

    void setPosition(Vec3i position) {
        _position = position;
    }

    void setQuantity(uint count, uint variance = 0) {
        _data.quantity = count;
        _data.quantityVariance = variance;
    }

    void attachTo(Entity entity) {
        _isAttachedToCamera = false;
        _base = entity;
    }

    void attachToCamera() {
        _isAttachedToCamera = true;
        _base = null;
    }

    void setMode(ParticleMode mode) {
        _mode = mode;
    }

    void setSize(Vec3f size) {
        _data.size = size;
    }

    void setDistance(float distance, float variance) {
        _data.distance = max(0f, distance);
        _data.distanceVariance = max(0f, variance);
    }

    void setSpread(float angle, float variance, float angleSpread) {
        _data.angle = angle;
        _data.angleVariance = max(0f, variance);
        _data.angleSpread = max(0f, angleSpread);
    }

    private Vec3f _getOffset() {
        Vec3f offset = (cast(Vec3f) _position) - (cast(Vec3f) _data.size) / 2f;
        if (_isAttachedToCamera) {
            offset += Vec3f(Atelier.world.camera.getPosition().round(), 0f);
        }
        else if (_base) {
            offset += cast(Vec3f) _base.getPosition();
        }
        return offset;
    }

    private void _emitSpread() {
        uint particleCount = Atelier.rng.randVariance(_data.quantity, _data.quantityVariance);
        float angle = Atelier.rng.randVariance(_data.angle, _data.angleVariance) - (
            _data.angleSpread / 2f);
        float distance = Atelier.rng.randVariance(_data.distance, _data.distanceVariance);
        float spreadPerParticle = _data.angleSpread / particleCount;
        bool _isVertical = false;

        for (int i; i < particleCount; ++i) {
            Particle particle = new Particle(_graphics, _generation, i, _grEvent);
            particle.setRelativeDistance(distance);
            particle.setRelativeAngle(angle); //vertical ?
            particle.angle = angle;
            //particle.pivotAngle = angle;
            _addParticle(particle);

            angle += spreadPerParticle;
        }
    }

    private void _emitRectangle() {
        uint particleCount = Atelier.rng.randVariance(_data.quantity, _data.quantityVariance);
        float angle = Atelier.rng.randVariance(_data.angle, _data.angleVariance) - (
            _data.angleSpread / 2f);
        float spreadPerParticle = _data.angleSpread / particleCount;

        Vec3f offset = ((cast(Vec3f) _position) - (cast(Vec3f) _data.size) / 2f);
        if (_isAttachedToCamera) {
            offset += Vec3f(Atelier.world.camera.getPosition().round(), 0f);
        }
        else if (_base) {
            offset += cast(Vec3f) _base.getPosition();
        }
        for (int i; i < particleCount; ++i) {
            float x = Atelier.rng.rand01();
            float y = Atelier.rng.rand01();
            float z = Atelier.rng.rand01();

            Particle particle = new Particle(_graphics, _generation, i, _grEvent);
            particle.setRelativePosition(Vec3f(x, y, z) * (cast(Vec3f) _data.size) + offset);
            particle.angle = angle;
            //particle.pivotAngle = angle;
            _addParticle(particle);

            angle += spreadPerParticle;
        }
    }

    private void _emitEllipsis() {
        uint particleCount = Atelier.rng.randVariance(_data.quantity, _data.quantityVariance);
        float angle = Atelier.rng.randVariance(_data.angle, _data.angleVariance) - (
            _data.angleSpread / 2f);
        float spreadPerParticle = _data.angleSpread / particleCount;

        for (int i; i < particleCount; ++i) {
            float phi = Atelier.rng.rand01() * PI * 2f;
            float rho = Atelier.rng.rand01();
            Vec3f pos = Vec3f(sqrt(rho) * Vec2f.angled(phi), 1f);

            Particle particle = new Particle(_graphics, _generation, i, _grEvent);
            particle.setRelativePosition(pos * _data.size / 2f);
            particle.angle = angle;
            _addParticle(particle);

            angle += spreadPerParticle;
        }
    }

    private void _addParticle(Particle particle) {
        EntityData entityData;
        entityData.layer = _data.layer;
        particle.setData(entityData);
        particle.setupPosition();
        Atelier.world.addEntity(particle);
    }
}

final class Particle : Entity {
    private {
        Entity _base;
        bool _isAttachedToCamera;
        Vec3i _origin;
        Vec3f _relativePosition = Vec3f.zero;
        float _relativeAngle = 0f;
        float _relativeDistance = 0f;
        uint _frame, _generation, _count;
        GrTask _task;
    }

    this(EntityGraphic[string] graphics, uint generation, uint count, GrEvent event) {
        super(Entity.Type.particle);
        _generation = generation;
        _count = count;

        foreach (id, graphic; graphics) {
            addGraphic(id, graphic.fetch());
        }

        setDefaultGraphic();
        _task = Atelier.script.callEvent(event, [GrValue(this)]);
    }

    this(Particle other) {
        super(other);
        _base = other._base;
        _relativePosition = other._relativePosition;
        _relativeAngle = other._relativeAngle;
        _relativeDistance = other._relativeDistance;
    }

    void setupCollider(Vec3u size_, float bounciness) {
        if (_collider) {
            _collider.setEntity(null);
        }
        _collider = new ActorCollider(size_, bounciness);

        if (_collider) {
            _collider.setEntity(this);
        }
    }

    override void onCollide(Physics.CollisionHit hit) {
        final switch (hit.type) with (Physics.CollisionHit.Type) {
        case none:
            /*Vec3f normal = hit.normal;
            if (normal.lengthSquared() > 0f) {
                Vec3f bounceVec = _velocity.dot(normal) * normal;
                float bounciness = hit.solid ? hit.solid.bounciness : 0f;
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
            break;*/
        case squish:
        case impact:
            Atelier.log("DETRUIRE");
            if (_task) {
                _task.kill();
                unregister();
                _task = null;
            }
            break;
        }
    }

    void attachTo(Entity entity) {
        detach();
        _base = entity;
    }

    void attachToCamera() {
        detach();
        _isAttachedToCamera = true;
    }

    void detach() {
        if (_isAttachedToCamera) {
            _origin = Vec3i(cast(Vec2i) Atelier.world.camera.getPosition().round(), _origin.z);
        }
        else if (_base) {
            _origin = _base.getPosition();
        }
        _base = null;
    }

    void setRelativePosition(Vec3f position) {
        _relativePosition = position;
    }

    void setRelativeAngle(float angle) {
        _relativeAngle = angle;
    }

    void setRelativeDistance(float distance) {
        _relativeDistance = distance;
    }

    void setupPosition() {
        Vec3f pos = Vec3f.zero;
        if (_isAttachedToCamera) {
            pos = Vec3f(Atelier.world.camera.getPosition().round(), _origin.z);
        }
        else if (_base) {
            pos = cast(Vec3f) _base.getPosition();
        }
        else {
            pos = cast(Vec3f) _origin;
        }
        pos += _relativePosition;
        pos += Vec3f(Vec2f.angled(degToRad(_relativeAngle - 90f)) * _relativeDistance, 0f).round();

        setPosition(pos);
    }

    override void updateMovement() {
        if (!_task || _task.isKilled) {
            unregister();
            _task = null;
            return;
        }

        Vec3f pos = Vec3f.zero;
        if (_isAttachedToCamera) {
            pos = Vec3f(Atelier.world.camera.getPosition().round(), _origin.z);
        }
        else if (_base) {
            pos = cast(Vec3f) _base.getPosition();
        }
        else {
            pos = cast(Vec3f) _origin;
        }
        _relativePosition += _velocity;
        pos += _relativePosition;
        pos += Vec3f(Vec2f.angled(degToRad(_relativeAngle - 90f)) * _relativeDistance, 0f).round();

        Vec3f dir = pos - (getSubPosition() + cast(Vec3f) getPosition());
        move(dir);

        _frame++;
    }
}
