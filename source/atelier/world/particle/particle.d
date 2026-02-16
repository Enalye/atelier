module atelier.world.particle.particle;

import farfadet;
import atelier.common;
import atelier.core;
import atelier.etabli;
import atelier.render;
import atelier.world.particle.element;
import atelier.world.particle.source;
import atelier.world.particle.system;

final class Particle : Resource!Particle {
    private {
        Texture _texture;
        Farfadet[string] _elementsInstructions;
        Farfadet[string] _sourcesInstructions;

        Array!ParticleSource _sources;
        Vec3i _position;
    }

    @property {
        bool isRunning() const {
            return _sources.length > 0;
        }

        const(Farfadet[string]) getElementsInstructions() const {
            return _elementsInstructions;
        }

        const(Farfadet[string]) getSourcesInstructions() const {
            return _sourcesInstructions;
        }
    }

    this() {
    }

    this(Particle other) {
        _texture = other._texture;
        _elementsInstructions = other._elementsInstructions;
        _sourcesInstructions = other._sourcesInstructions;
    }

    void setup() {
        _sources = new Array!ParticleSource;
    }

    void setTexture(string id) {
        version (AtelierEtabli) {
            _texture = Atelier.etabli.getTexture(id);
        }
        else {
            _texture = Atelier.res.get!Texture(id);
        }
    }

    void load(Farfadet ffd) {
        if (ffd.hasNode("texture")) {
            setTexture(ffd.getNode("texture").get!string(0));
        }

        _elementsInstructions.clear();
        foreach (elementNode; ffd.getNodes("element")) {
            _elementsInstructions[elementNode.get!string(0)] = elementNode;
        }
        _sourcesInstructions.clear();
        foreach (sourceNode; ffd.getNodes("source")) {
            _sourcesInstructions[sourceNode.get!string(0)] = sourceNode;
        }
    }

    Particle fetch() {
        Particle particle = new Particle(this);
        particle.setup();
        return particle;
    }

    void start() {
        foreach (sourceNode; _sourcesInstructions) {
            ParticleSource source = new ParticleSource(this, sourceNode);
            _sources ~= source;
        }
    }

    ParticleElement create(string id) {
        auto p = id in _elementsInstructions;
        if (p) {
            return new ParticleElement(*p);
        }
        return null;
    }

    Vec3i getPosition() const {
        return _position;
    }

    void setPosition(Vec3i position_) {
        _position = position_;
    }

    void addPosition(Vec3i position_) {
        _position += position_;
    }

    void update(ParticleSystem system) {
        foreach (i, source; _sources) {
            source.update(system);
            if (!source.isRunning) {
                _sources.mark(i);
            }
        }
        _sources.sweep();
    }

    void draw(Vec2f offset, float zoom = 1f) {
        if (!_texture)
            return;

        offset += cast(Vec2f) _position.proj2D();

        foreach (i, source; _sources) {
            source.draw(_texture, offset, zoom);
        }
    }
}
