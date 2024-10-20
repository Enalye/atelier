/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.world.scene;

import std.algorithm;
import std.exception : enforce;
import std.typecons : Tuple, tuple;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.ui;
import atelier.world.camera;
import atelier.world.particle;
import atelier.world.world;

package(atelier.world) void registerSystems_scene(World world) {
    world.registerSystem!SystemEntityUpdater("linear", &updateEntitySystem_linear);
    world.registerSystem!SystemEntityRenderer("linear", &renderEntitySystem_linear);
    world.registerSystem!SystemEntityUpdater("recursive", &updateEntitySystem_recursive);
    world.registerSystem!SystemEntityRenderer("recursive", &renderEntitySystem_recursive);
}

private enum Entity_Max = ushort.max;
private enum Entity_Size = Entity_Max + 1;

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

interface IEntityComponentPool {
    void removeComponent(EntityID id);
}

final class EntityComponentPool(T) : IEntityComponentPool {
    private {
        struct Pair {
            T component;
            EntityID id;
        }

        Pair[Entity_Size] _components;
        ushort _top = 0u;
        EntityID[Entity_Size] _slots;
    }

    pragma(inline, true) bool hasComponent(EntityID id) {
        return _slots[id.address].version_ > 0;
    }

    pragma(inline, true) T* getComponent(EntityID id) {
        EntityID slot = _slots[id.address];
        return cast(T*)(slot.version_ * (cast(size_t)&_components[slot.address].component));
    }

    pragma(inline, true) T* addComponent(EntityID id) {
        EntityID* slot = &_slots[id.address];
        slot.address = cast(ushort)((slot.version_ ^ 0x1) * _top + (slot.version_ * slot.address));
        _components[slot.address].id = id;
        _top += slot.version_ ^ 0x1;
        slot.version_ = 1;
        return &_components[slot.address].component;
    }

    pragma(inline, true) void removeComponent(EntityID id) {
        EntityID* slot = &_slots[id.address];
        if (slot.version_ == 0) {
            return;
        }
        slot.version_ = 0;
        _top--;
        EntityID* otherSlot = &_slots[_components[_top].id];
        _components[slot.address] = _components[_top];
        otherSlot.address = slot.address;
    }

    int opApply(int delegate(EntityID, T*) dlg) {
        int result;

        for (ushort i; i < _top; ++i) {
            Pair* pair = &_components[i];
            result = dlg(pair.id, &pair.component);

            if (result)
                break;
        }

        return result;
    }
}

struct PositionComponent {
    Vec2f localPosition;
    Vec2f worldPosition;
}

struct EntityPool {
    PositionComponent[Entity_Size] positions;
    ushort[][Entity_Size] children;
    ushort[Entity_Size] parents;
    RenderComponent[Entity_Size] renders;
    IEntityComponentPool[string] componentPools;

    ushort top = 0u;
    ushort availableAddressesTop = 0u;

    ushort[Entity_Size] availableAddresses;
    EntityID[Entity_Size] slots;
    ushort[Entity_Size] reverseTranslationTable;

    void*[string] systemContexts;
    Tuple!(SystemUpdater, void*)[] systemUpdatersBack, systemUpdatersFront;
    Tuple!(SystemRenderer, void*)[] systemRenderersBack, systemRenderersFront;
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
            return position + Atelier.world.camera.getPosition() * parallax;
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
            _entityPool.positions[i].localPosition = Vec2f.zero;
            _entityPool.positions[i].worldPosition = Vec2f.zero;
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

            _entityPool.positions[internal] = _entityPool.positions[_entityPool.top];
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

    EntityComponentPool!T getComponentPool(T)() {
        return cast(EntityComponentPool!T) _entityPool.componentPools.require(T.stringof, {
            EntityComponentPool!T pool = new EntityComponentPool!T;
            return pool;
        }());
    }

    void* getSystemContext(string name) {
        auto p = name in _entityPool.systemContexts;
        void* context;
        if (!p) {
            auto initializer = Atelier.world.getSystem!SystemInitializer(name);
            if(initializer) {
                context = initializer(this);
            }
            _entityPool.systemContexts[name] = context;
        }
        else {
            context = *p;
        }
        return context;
    }

    void addSystemUpdate(SystemUpdater system, void* context, bool isBefore) {
        if (isBefore) {
            _entityPool.systemUpdatersBack ~= tuple(system, context);
        }
        else {
            _entityPool.systemUpdatersFront ~= tuple(system, context);
        }
    }

    void addSystemRender(SystemRenderer system, void* context, bool isBefore) {
        if (isBefore) {
            _entityPool.systemRenderersBack ~= tuple(system, context);
        }
        else {
            _entityPool.systemRenderersFront ~= tuple(system, context);
        }
    }

    void setSystemEntityUpdate(SystemEntityUpdater system) {
        _entityPool.systemEntityUpdater = system;
    }

    void setSystemEntityRender(SystemEntityRenderer system) {
        _entityPool.systemEntityRenderer = system;
    }

    alias getPosition = getComponent!PositionComponent;
    alias getRender = getComponent!RenderComponent;

    T* getComponent(T)(EntityID id) {
        static if (is(T == PositionComponent)) {
            short internal = _entityPool.slots[id.address].address;
            return &_entityPool.positions[internal];
        }
        else static if (is(T == RenderComponent)) {
            short internal = _entityPool.slots[id.address].address;
            return &_entityPool.renders[internal];
        }
        else {
            return getComponentPool!(T).getComponent(id);
        }
    }

    T* addComponent(T)(EntityID id) {
        return getComponentPool!(T).addComponent(id);
    }

    bool hasComponent(T)(EntityID id) {
        return getComponentPool!(T).hasComponent(id);
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
            system[0](this, system[1]);
        }
        if (_entityPool.systemEntityUpdater) {
            _entityPool.systemEntityUpdater(this);
        }
        foreach (system; _entityPool.systemUpdatersFront) {
            system[0](this, system[1]);
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
            system[0](this, system[1], offset, false);
        }
        if (_entityPool.systemEntityRenderer) {
            _entityPool.systemEntityRenderer(this, offset);
        }
        foreach (system; _entityPool.systemRenderersFront) {
            system[0](this, system[1], offset, true);
        }
        _uiManager.draw();
    }

    void draw(Vec2f origin) {
        if (_isVisible) {
            _sprite.draw(origin);
        }
    }
}

void updateEntitySystem_linear(Scene scene) {
    for (ushort i; i < scene._entityPool.top; ++i) {
        scene._entityPool.positions[i].worldPosition = scene._entityPool.positions[i].localPosition;
    }
}

void renderEntitySystem_linear(Scene scene, Vec2f offset) {
    for (ushort i; i < scene._entityPool.top; ++i) {
        RenderComponent* renderComponent = &scene._entityPool.renders[i];
        if (renderComponent.isVisible && renderComponent.image) {
            Vec2f renderPosition = scene._entityPool.positions[i].worldPosition + offset;
            renderComponent.image.draw(renderPosition);
        }
    }
}

void updateEntitySystem_recursive(Scene scene) {
    for (ushort i; i < scene._entityPool.top; ++i) {
        if (scene._entityPool.parents[i] != i) {
            continue;
        }

        scene._entityPool.positions[i].worldPosition = scene._entityPool.positions[i].localPosition;
        if (scene._entityPool.children[i].length) {
            foreach (child; scene._entityPool.children[i]) {
                _updateEntitySystem_recursive_child(scene, child,
                    scene._entityPool.positions[i].worldPosition);
            }
        }
    }
}

private void _updateEntitySystem_recursive_child(Scene scene, ushort i, Vec2f parentPosition) {
    scene._entityPool.positions[i].worldPosition = parentPosition +
        scene._entityPool.positions[i].localPosition;

    if (scene._entityPool.children[i].length) {
        foreach (child; scene._entityPool.children[i]) {
            _updateEntitySystem_recursive_child(scene, child,
                scene._entityPool.positions[i].worldPosition);
        }
    }
}

void renderEntitySystem_recursive(Scene scene, Vec2f offset) {
    for (ushort i; i < scene._entityPool.top; ++i) {
        RenderComponent* renderComponent = &scene._entityPool.renders[i];

        if (!renderComponent.isVisible || scene._entityPool.parents[i] != i) {
            continue;
        }

        Vec2f renderPosition = scene._entityPool.positions[i].localPosition + offset;

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
    Vec2f renderPosition = scene._entityPool.positions[i].localPosition + offset;
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
