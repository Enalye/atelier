module atelier.world.particle.system;

import farfadet;
import atelier.common;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.lib;

struct ParticleParam {
    enum Type {
        bool_,
        uint_,
        int_,
        float_,
        float01,
        string_,
        enum_,
        spline,
        color,
    }

    Type type;
    string name;
    string[] enumList;

    this(string name_, Type type_, string[] enumList_ = []) {
        name = name_;
        type = type_;
        enumList = enumList_;
    }
}

final class ParticleSystem {
    alias ElementCallback = void function(ParticleElement, Farfadet);
    alias SourceCallback = void function(ParticleSource, Farfadet);

    struct SourceCommand {
        SourceCallback callback;
        ParticleParam[] params;
        ParticleParam[][string] subParams;
    }

    struct ElementCommand {
        ElementCallback callback;
        ParticleParam[] params;
        ParticleParam[][string] subParams;
    }

    private {
        Array!Particle _particles;
        SourceCommand[string] _sourceFunctions;
        ElementCommand[string] _elementFunctions;
    }

    @property {
        bool isPlaying() const {
            return _particles.length > 0;
        }
    }

    this() {
        _particles = new Array!Particle;
        particle_loadSourceLibrary(this);
        particle_loadElementLibrary(this);
    }

    void addElementFunc(ElementCallback callback, string name, ParticleParam[] params = [
        ]) {
        ElementCommand command;
        command.params = params;
        command.callback = callback;
        _elementFunctions[name] = command;
    }

    void addElementParam(string name, string paramName, ParticleParam[] params = [
        ]) {
        auto p = name in _elementFunctions;
        if (!p)
            return;

        p.subParams[paramName] = params;
    }

    void callElementFunction(ParticleElement element, Farfadet ffd) {
        auto p = ffd.name in _elementFunctions;
        if (!p || !p.callback)
            return;

        p.callback(element, ffd);
    }

    string[] getElementFunctions() {
        return _elementFunctions.keys;
    }

    ElementCommand getElement(string name) {
        auto p = name in _elementFunctions;
        return p ? *p : ElementCommand();
    }

    void addSourceFunc(SourceCallback callback, string name, ParticleParam[] params = [
        ]) {
        SourceCommand command;
        command.params = params;
        command.callback = callback;
        _sourceFunctions[name] = command;
    }

    void addSourceParam(string name, string paramName, ParticleParam[] params = [
        ]) {
        auto p = name in _sourceFunctions;
        if (!p)
            return;

        p.subParams[paramName] = params;
    }

    void callSourceFunction(ParticleSource source, Farfadet ffd) {
        auto p = ffd.name in _sourceFunctions;
        if (!p || !p.callback)
            return;

        p.callback(source, ffd);
    }

    string[] getSourceFunctions() {
        return _sourceFunctions.keys;
    }

    SourceCommand getSource(string name) {
        auto p = name in _sourceFunctions;
        return p ? *p : SourceCommand();
    }

    void addParticle(Particle particle) {
        particle.start();
        _particles ~= particle;
    }

    void update() {
        foreach (i, particle; _particles) {
            particle.update(this);
            if (!particle.isRunning) {
                _particles.mark(i);
            }
        }
        _particles.sweep();
    }

    void draw(Vec2f offset, float zoom = 1f) {
        foreach (i, particle; _particles) {
            particle.draw(offset, zoom);
        }
    }

    void clear() {
        _particles.clear();
    }
}
