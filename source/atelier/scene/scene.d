/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.scene.scene;

import std.algorithm;
import std.exception : enforce;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.ui;
import atelier.scene.actor;
import atelier.scene.camera;
import atelier.scene.collider;
import atelier.scene.entity;
import atelier.scene.particle;
import atelier.scene.solid;
import atelier.scene.world;

enum Entity_Max = ushort.max;
enum Entity_Size = Entity_Max + 1;

union EntityID {
    struct {
        ushort version_;
        ushort address;
    }

    uint id;

    alias id this;

    this(uint id_) {
        id = id_;
    }
}

struct RenderComponent {
    bool isVisible = true;
    Image image;
    Canvas canvas;
    Sprite sprite;
}

struct ParticleComponent {
    ParticleSource source;
    EntityID id;
    bool isFront;
}

interface IEntityComponentPool {
    ushort addComponent(EntityID id);
    void removeComponent(EntityID id);
}

void updateParticleSystem(Scene scene) {
    EntityComponentPool!ParticleComponent pool = scene.getComponentPool!ParticleComponent();
    foreach (ref ParticleComponent component; pool.each()) {
        component.source.update(*scene.getWorldPosition(component.id));
    }
}

void renderParticleSystem(Scene scene, Vec2f offset, bool isFront) {
    EntityComponentPool!ParticleComponent pool = scene.getComponentPool!ParticleComponent();
    foreach (ref ParticleComponent component; pool.each()) {
        if (component.isFront != isFront)
            continue;
        component.source.draw(offset);
    }
}

final class EntityComponentPool(T) : IEntityComponentPool {
    private {
        T[Entity_Size] _components;
        ushort _top = 0u;
        EntityID[Entity_Size] _slots;
        ushort[Entity_Size] _addresses;
    }

    pragma(inline, true) T* getComponent(EntityID id) {
        EntityID slot = _slots[id.address];
        return cast(T*)(slot.version_ * (cast(size_t)&_components[slot.address]));
    }

    /// À n’utiliser que juste après addComponent.
    pragma(inline, true) T* getInternalComponent(ushort internal) {
        return &_components[internal];
    }

    /// Retourne l’id interne du composant ne pouvant être utilisé qu’avec getInternalComponent.
    /// Cet identifiant n’est valide qu’immédiatement après qu’addComponent a été appelé.
    pragma(inline, true) ushort addComponent(EntityID id) {
        EntityID* slot = &_slots[id.address];
        slot.address = cast(ushort)((slot.version_ ^ 0x1) * _top + (slot.version_ * slot.address));
        _addresses[slot.address] = id.address;
        _top += slot.version_ ^ 0x1;
        slot.version_ = 1;
        return slot.address;
    }

    pragma(inline, true) void removeComponent(EntityID id) {
        EntityID* slot = &_slots[id.address];
        if (slot.version_ == 0) {
            return;
        }
        slot.version_ = 0;
        _top--;
        EntityID* otherSlot = &_slots[_addresses[_top]];
        _components[slot.address] = _components[_top];
        otherSlot.address = slot.address;
    }

    T[] each() {
        return _components[0 .. _top];
    }
}

struct EntityPool {
    Vec2f[Entity_Size] localPositions;
    Vec2f[Entity_Size] worldPositions;
    ushort[][Entity_Size] children;
    ushort[Entity_Size] parents;
    RenderComponent[Entity_Size] renders;
    IEntityComponentPool[string] componentPools;

    ushort top = 0u;
    ushort availableAddressesTop = 0u;

    ushort[Entity_Size] availableAddresses;
    EntityID[Entity_Size] slots;
    ushort[Entity_Size] reverseTranslationTable;

    SystemUpdater[] systemUpdatersBack, systemUpdatersFront;
    SystemRenderer[] systemRenderersBack, systemRenderersFront;
    SystemEntityUpdater systemEntityUpdater;
    SystemEntityRenderer systemEntityRenderer;
}

/// Représente un contexte contenant des entités
final class Scene {
    private {
        Canvas _canvas;
        Sprite _sprite;
        UIManager _uiManager;
        bool _isAlive = true;
        bool _isVisible = true;
        Vec2i _size;
        Camera[] _cameras;
        EntityPool _entityPool;
    }

    string name;
    string[] tags;
    int zOrder;
    Vec2f position = Vec2f.zero;
    Vec2f parallax = Vec2f.one;
    Vec2f mousePosition = Vec2f.zero;

    @property {
        int width() const {
            return _size.x;
        }

        int height() const {
            return _size.y;
        }

        bool isAlive() const {
            return _isAlive;
        }

        Canvas canvas() {
            return _canvas;
        }

        bool isVisible() const {
            return _isVisible;
        }

        bool isVisible(bool isVisible_) {
            return _isVisible = isVisible_;
        }

        Vec2f globalPosition() const {
            return position + Atelier.scene.camera.getPosition() * parallax;
        }
    }

    this() {
        _size = Atelier.renderer.size;

        _uiManager = new UIManager();
        _uiManager.isSceneUI = true;

        _canvas = new Canvas(_size.x, _size.y);
        _sprite = new Sprite(_canvas);
        _sprite.anchor = Vec2f.half;

        for (ushort i; i < Entity_Max; ++i) {
            _entityPool.localPositions[i] = Vec2f.zero;
        }
        for (ushort i; i < Entity_Max; ++i) {
            _entityPool.worldPositions[i] = Vec2f.zero;
        }
        for (ushort i; i < Entity_Max; ++i) {
            _entityPool.parents[i] = i;
        }

        setSystemEntityRender(&renderEntitySystem_recursive);
        setSystemEntityUpdate(&updateEntitySystem_recursive);
    }

    /// Vérifie si l’identifiant est valide
    bool hasEntity(EntityID id) {
        return _entityPool.slots[id.address].version_ == id.version_;
    }

    /// Génère un nouvel identifiant d’entité
    EntityID createEntity() {
        EntityID id;
        if (_entityPool.availableAddressesTop) {
            //Retire la dernière adresse disponible dans la liste
            --_entityPool.availableAddressesTop;
            id.address = _entityPool.availableAddresses[_entityPool.availableAddressesTop];
        }
        else {
            //Ou on utilise une nouvelle adresse
            id.address = _entityPool.top;
        }

        //Ajoute la valeur à la pile
        id.version_ = _entityPool.slots[id.address].version_;
        _entityPool.slots[id.address].address = _entityPool.top;
        _entityPool.reverseTranslationTable[_entityPool.top] = id.address;

        ++_entityPool.top;

        return id;
    }

    /// Supprime l’entité
    void removeEntity(EntityID id) {
        if (_entityPool.slots[id.address].version_ != id.version_) {
            return;
        }

        ushort internal = _entityPool.slots[id.address].address;

        //Ajoute l’adresse à la pile des emplacements disponibles
        _entityPool.availableAddresses[_entityPool.availableAddressesTop] = id.address;
        _entityPool.availableAddressesTop++;

        _entityPool.top--;

        //Augmente la génération de l’emplacement qui sera libéré
        _entityPool.slots[id.address].version_++;
        _entityPool.slots[id.address].address = _entityPool.top;

        foreach (componentPool; _entityPool.componentPools) {
            componentPool.removeComponent(id);
        }

        //Prend la dernière valeur de la pile et comble le trou
        if (internal < _entityPool.top) {
            ushort otherAddress = _entityPool.reverseTranslationTable[_entityPool.top];

            _entityPool.localPositions[internal] = _entityPool.localPositions[_entityPool.top];
            _entityPool.worldPositions[internal] = _entityPool.worldPositions[_entityPool.top];
            _entityPool.children[internal] = _entityPool.children[_entityPool.top];
            _entityPool.renders[internal] = _entityPool.renders[_entityPool.top];

            if (_entityPool.children[internal].length) {
                foreach (child; _entityPool.children[internal]) {
                    _entityPool.parents[child] = internal;
                }
            }

            if (_entityPool.parents[_entityPool.top] == _entityPool.top) {
                _entityPool.parents[internal] = internal;
            }
            else {
                ushort parent = _entityPool.parents[_entityPool.top];
                _entityPool.parents[internal] = parent;

                for (ushort y; y < _entityPool.children[parent].length; ++y) {
                    ushort child = _entityPool.children[parent][y];
                    _entityPool.parents[child] = internal;
                }
            }

            _entityPool.slots[otherAddress].address = internal;
            _entityPool.reverseTranslationTable[internal] = otherAddress;
        }
    }

    /// Supprime les entités
    void clearEntities() {
        _entityPool.top = 0u;
        _entityPool.availableAddressesTop = 0u;

        for (ushort i; i < Entity_Size; ++i) {
            _entityPool.slots[i].version_++;
        }
        for (ushort i; i < Entity_Size; ++i) {
            RenderComponent* renderComponent = &_entityPool.renders[i];
            renderComponent.isVisible = true;
            renderComponent.image = null;
            renderComponent.canvas = null;
            renderComponent.sprite = null;
        }
    }

    Vec2f* getWorldPosition(EntityID id) {
        short internal = _entityPool.slots[id.address].address;
        return &_entityPool.worldPositions[internal];
    }

    Vec2f* getLocalPosition(EntityID id) {
        short internal = _entityPool.slots[id.address].address;
        return &_entityPool.localPositions[internal];
    }

    RenderComponent* getRender(EntityID id) {
        short internal = _entityPool.slots[id.address].address;
        return &_entityPool.renders[internal];
    }

    EntityComponentPool!T getComponentPool(T)() {
        return cast(EntityComponentPool!T) _entityPool.componentPools.require(T.stringof, {
            EntityComponentPool!T pool = new EntityComponentPool!T;
            return pool;
        }());
    }

    void addSystemUpdate(SystemUpdater system, bool isBefore) {
        if (isBefore) {
            _entityPool.systemUpdatersBack ~= system;
        }
        else {
            _entityPool.systemUpdatersFront ~= system;
        }
    }

    void addSystemRender(SystemRenderer system, bool isBefore) {
        if (isBefore) {
            _entityPool.systemRenderersBack ~= system;
        }
        else {
            _entityPool.systemRenderersFront ~= system;
        }
    }

    void setSystemEntityUpdate(SystemEntityUpdater system) {
        _entityPool.systemEntityUpdater = system;
    }

    void setSystemEntityRender(SystemEntityRenderer system) {
        _entityPool.systemEntityRenderer = system;
    }

    T* getComponent(T)(EntityID id) {
        return getComponentPool!(T).getComponent(id);
    }

    T* addComponent(T)(EntityID id) {
        EntityComponentPool!T pool = getComponentPool!(T);
        return pool.getInternalComponent(pool.addComponent(id));
    }

    void removeComponent(T)(EntityID id) {
        getComponentPool!(T).removeComponent(id);
    }

    /// Ajoute un élément d’interface
    void addUI(UIElement ui) {
        _uiManager.addUI(ui);
    }

    /// Supprime les interfaces
    void clearUI() {
        _uiManager.clearUI();
    }

    void dispatch(InputEvent event) {
        switch (event.type) with (InputEvent.Type) {
        case mouseButton:
            Vec2f pos = event.asMouseButton().position;
            mousePosition = pos - (_sprite.size / 2f - globalPosition);
            break;
        case mouseMotion:
            Vec2f pos = event.asMouseMotion().position;
            mousePosition = pos - (_sprite.size / 2f - globalPosition);
            break;
        default:
            break;
        }
        _uiManager.dispatch(event);
    }
    /*
    private Array!T _getArray(T)() {
        static if (is(T == Entity)) {
            return _entities;
        }
        else {
            static assert(false, "type non-supporté");
        }
    }*/
    /*
    T findByName(T)(string name) {
        foreach (element; _getArray!T()) {
            if (element.name == name)
                return element;
        }
        return null;
    }

    T[] findByTag(T)(string[] tags) {
        T[] result;
        __elementLoop: foreach (element; _getArray!T()) {
            foreach (string tag; tags) {
                if (!canFind(element.tags, tag)) {
                    continue __elementLoop;
                }
            }
            result ~= element;
        }
        return result;
    }*/

    void update() {
        _uiManager.cameraPosition = _sprite.size / 2f - globalPosition;
        _uiManager.update();

        foreach (system; _entityPool.systemUpdatersBack) {
            system(this);
        }
        if (_entityPool.systemEntityUpdater) {
            _entityPool.systemEntityUpdater(this);
        }
        foreach (system; _entityPool.systemUpdatersFront) {
            system(this);
        }
    }

    void remove() {
        if (!_isAlive)
            return;
        _isAlive = false;
    }

    void render() {
        /*Vec2f offset = _sprite.size / 2f - globalPosition;
        foreach (entity; _entities) {
            entity.draw(offset);
        }*/

        Vec2f offset = _sprite.size / 2f - globalPosition;
        foreach (system; _entityPool.systemRenderersBack) {
            system(this, offset, false);
        }
        if (_entityPool.systemEntityRenderer) {
            _entityPool.systemEntityRenderer(this, offset);
        }
        foreach (system; _entityPool.systemRenderersFront) {
            system(this, offset, true);
        }
        _uiManager.draw();
    }

    void draw(Vec2f origin) {
        if (_isVisible) {
            _sprite.draw(origin);
        }
    }
}

void registerEntitySystems() {
    Atelier.scene.registerSystem!SystemEntityUpdater("linear", &updateEntitySystem_linear);
    Atelier.scene.registerSystem!SystemEntityRenderer("linear", &renderEntitySystem_linear);
    Atelier.scene.registerSystem!SystemEntityUpdater("recursive", &updateEntitySystem_recursive);
    Atelier.scene.registerSystem!SystemEntityRenderer("recursive", &renderEntitySystem_recursive);

    Atelier.scene.registerSystem!SystemUpdater("particle", &updateParticleSystem);
    Atelier.scene.registerSystem!SystemRenderer("particle", &renderParticleSystem);
}

void updateEntitySystem_linear(Scene scene) {
    for (ushort i; i < scene._entityPool.top; ++i) {
        scene._entityPool.worldPositions[i] = scene._entityPool.localPositions[i];
    }
}

void renderEntitySystem_linear(Scene scene, Vec2f offset) {
    for (ushort i; i < scene._entityPool.top; ++i) {
        RenderComponent* renderComponent = &scene._entityPool.renders[i];
        if (renderComponent.isVisible && renderComponent.image) {
            Vec2f renderPosition = scene._entityPool.worldPositions[i] + offset;
            renderComponent.image.draw(renderPosition);
        }
    }
}

void updateEntitySystem_recursive(Scene scene) {
    for (ushort i; i < scene._entityPool.top; ++i) {
        if (scene._entityPool.parents[i] != i) {
            continue;
        }

        scene._entityPool.worldPositions[i] = scene._entityPool.localPositions[i];
        if (scene._entityPool.children[i].length) {
            foreach (child; scene._entityPool.children[i]) {
                _updateEntitySystem_recursive_child(scene, child,
                    scene._entityPool.worldPositions[i]);
            }
        }
    }
}

private void _updateEntitySystem_recursive_child(Scene scene, ushort i, Vec2f parentPosition) {
    scene._entityPool.worldPositions[i] = parentPosition + scene._entityPool.localPositions[i];

    if (scene._entityPool.children[i].length) {
        foreach (child; scene._entityPool.children[i]) {
            _updateEntitySystem_recursive_child(scene, child, scene._entityPool.worldPositions[i]);
        }
    }
}

void renderEntitySystem_recursive(Scene scene, Vec2f offset) {
    for (ushort i; i < scene._entityPool.top; ++i) {
        RenderComponent* renderComponent = &scene._entityPool.renders[i];

        if (!renderComponent.isVisible || scene._entityPool.parents[i] != i) {
            continue;
        }

        Vec2f renderPosition = scene._entityPool.localPositions[i] + offset;

        if (renderComponent.canvas) {
            Atelier.renderer.pushCanvas(renderComponent.canvas);
            if (renderComponent.image) {
                renderComponent.image.draw(Vec2f.zero);
            }
            if (scene._entityPool.children[i].length) {
                foreach (child; scene._entityPool.children[i]) {
                    _renderEntitySystem_recursive_child(scene, child, Vec2f.zero);
                }
            }
            Atelier.renderer.popCanvas();
            renderComponent.sprite.draw(renderPosition);
        }
        else {
            if (renderComponent.image) {
                renderComponent.image.draw(renderPosition);
            }
            if (scene._entityPool.children[i].length) {
                foreach (child; scene._entityPool.children[i]) {
                    _renderEntitySystem_recursive_child(scene, child, renderPosition);
                }
            }
        }
    }
}

private void _renderEntitySystem_recursive_child(Scene scene, short i, Vec2f offset) {
    Vec2f renderPosition = scene._entityPool.localPositions[i] + offset;
    RenderComponent* renderComponent = &scene._entityPool.renders[i];

    if (!renderComponent.isVisible) {
        return;
    }

    if (renderComponent.canvas) {
        Atelier.renderer.pushCanvas(renderComponent.canvas);
        if (renderComponent.image) {
            renderComponent.image.draw(Vec2f.zero);
        }
        if (scene._entityPool.children[i].length) {
            foreach (child; scene._entityPool.children[i]) {
                _renderEntitySystem_recursive_child(scene, child, Vec2f.zero);
            }
        }
        Atelier.renderer.popCanvas();
        renderComponent.sprite.draw(renderPosition);
    }
    else {
        if (renderComponent.image) {
            renderComponent.image.draw(renderPosition);
        }
        if (scene._entityPool.children[i].length) {
            foreach (child; scene._entityPool.children[i]) {
                _renderEntitySystem_recursive_child(scene, child, renderPosition);
            }
        }
    }
}
