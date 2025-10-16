module atelier.world.world;

import std.algorithm;
import std.conv : to;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.physics;
import atelier.render;
import atelier.ui;
import atelier.world.audio;
import atelier.world.camera;
import atelier.world.dialog;
import atelier.world.entity;
import atelier.world.glow;
import atelier.world.grid;
import atelier.world.lighting;
import atelier.world.particle;
import atelier.world.scene;
import atelier.world.transition;
import atelier.world.weather;

private Transition _createDefaultTransition(string sceneRid, string tpName, Actor actor, bool skip) {
    return new DefaultTransition(sceneRid, tpName, actor, skip);
}

/// Gère les différentes scènes
final class World {
    private {
        UIManager _uiManager;
        Scene _scene;
        Camera _camera;
        Dialog _dialog;
        Lighting _lighting;
        Weather _weather;
        Array!ParticleSource _particleSources;
        Array!Entity _entities, _enemies;
        Array!Entity _renderedEntities;
        Array!ControllerWrapper _controllers;
        int _frame;
        Vec2f _mousePosition = Vec2f.zero;

        Sprite _shadowSprite;
        bool _isInCombat;
        Vec3i _lastPlayerPosition;

        int[] _renderReferenceCounters;
        size_t _renderUpdateIndex;
        Entity[] _renderListRoots, _postRenderListAbove, _postRenderListGlow;
        Glow _glow;

        // Transition
        Transition _transition;
        string _sceneRid, _tpName;
        Actor _player;

        bool _isPaused;

        Factory _factory;
        string _playerControllerId;
        Controller!Actor _playerController;
        Transition function(string, string, Actor, bool) _transitionFunc;
    }

    @property {
        Camera camera() {
            return _camera;
        }

        Scene scene() {
            return _scene;
        }

        Lighting lighting() {
            return _lighting;
        }

        Dialog dialog() {
            return _dialog;
        }

        Weather weather() {
            return _weather;
        }

        Actor player() {
            return _player;
        }
    }

    this() {
        _uiManager = new UIManager();
        _uiManager.isWorldUI = true;
        _camera = new Camera;
        _dialog = new Dialog;
        _lighting = new Lighting;
        _entities = new Array!Entity;
        _renderedEntities = new Array!Entity;
        _controllers = new Array!ControllerWrapper;
        _weather = new Weather;
        _enemies = new Array!Entity;
        _particleSources = new Array!ParticleSource;
        _glow = new Glow;
        _factory = new Factory;

        setTransition(&_createDefaultTransition);
        addController!Actor("player", { return new DefaultPlayerController(); });
        setPlayerControllerID("player");
    }

    void setTransition(Transition function(string, string, Actor, bool) transitionFunc = &_createDefaultTransition) {
        _transitionFunc = transitionFunc;
    }

    void setPlayerControllerID(string id) {
        _playerControllerId = id;
    }

    void setPause(bool value) {
        _isPaused = value;
    }

    /// Ajoute un élément d’interface
    void addUI(UIElement ui) {
        _uiManager.addUI(ui);
    }

    /// Supprime les interfaces
    void clearUI() {
        _uiManager.clearUI();
    }

    /// Récupère l’entité par son nom (peut être nul)
    Entity find(string name) {
        foreach (entity; _entities) {
            if (entity.getName() == name)
                return entity;
        }
        return null;
    }

    /// Récupère l’entité par tag
    Entity[] findByTag(string tag) {
        Entity[] result;
        foreach (entity; _entities) {
            if (entity.hasTag(tag))
                result ~= entity;
        }
        return result;
    }

    /// Récupère l’entité par tags
    Entity[] findByTags(string[] tags) {
        if (!tags.length)
            return _entities.array;

        Entity[] result;
        __findByTag_entityLoop: foreach (entity; _entities) {
            foreach (tag; tags) {
                if (!entity.hasTag(tag))
                    continue __findByTag_entityLoop;
            }
            result ~= entity;
        }
        return result;
    }

    /// Récupère toutes les entités
    Array!Entity getEntities() {
        return _entities;
    }

    void setCombat(bool value) { //TODO: Migrer hors du moteur
        /*if (!_player || _isInCombat == value)
            return;

        _isInCombat = value;

        if (_isInCombat) {
            _camera.stop(false);
            _lastPlayerPosition = _player.getPosition();
            _camera.focus(_player, _lastPlayerPosition, Vec2f.one, Vec2f.zero);
            //_player.isHovering = true;

            Vec4i bounds;
            bounds.xy = _player.getPosition().xy;
            bounds.zw = _player.getPosition().xy;
            Vec2i halfSize = Atelier.renderer.size >> 1;
            bounds.x -= halfSize.x;
            bounds.z += halfSize.x;
            bounds.y -= halfSize.y;
            bounds.w += halfSize.y;
            Atelier.physics.setCombatBounds(bounds);
            addBehavior(new PlayerCombatBehavior(_player));
        }
        else {
            _camera.follow(_player, Vec2f.one * 1f, Vec2f.zero);
            //_player.isHovering = false;
            _player.setPosition(_lastPlayerPosition + Vec3i(0, 0, 8));
            Atelier.physics.unsetCombatBounds();
            addBehavior(new PlayerWalkBehavior(_player));
        }*/
    }

    void transitionScene(string rid, string tpName, uint direction) {
        bool skip = _transition !is null;

        if (_transitionFunc) {
            _transition = _transitionFunc(rid, tpName, _player, skip);
        }

        _setupPlayerController();
        if (_playerController) {
            _playerController.onTeleport(direction, false);
        }

        _weather.run("", 0f, 60);
        Atelier.physics.setTriggersActive(false);
        Atelier.physics.setBounds(false);
        Atelier.script.killTasks();
        _transition.update();
    }

    private void _setupPlayerController() {
        if (!_playerController) {
            _playerController = fetchController!Actor(_playerControllerId);
            if (_playerController) {
                _playerController.setup(_player);
                _controllers ~= _playerController;
            }
        }
    }

    void load(string sceneRid, string tpName = "") {
        _sceneRid = sceneRid;
        _tpName = tpName;
        _frame = 0;

        Vec2f oldCameraDeltaPosition = _camera.getTargetPosition() - _camera.getPosition(true);

        clear();
        _lighting.setup();
        _scene = Atelier.res.get!Scene(_sceneRid);
        _shadowSprite = Atelier.res.get!Sprite("atelier:shadow");

        Atelier.nav.generate();

        Vec2f rendererSize = cast(Vec2f) Atelier.renderer.size;
        Vec2f halfRendererSize = rendererSize / 2f;
        Vec2f mapSize = Vec2f(_scene.columns, _scene.lines) * 16f;

        bool hasXBounds = rendererSize.x <= mapSize.x;
        bool hasYBounds = rendererSize.y <= mapSize.y;

        if (_playerController) {
            _controllers ~= _playerController;
        }

        if (_player) {
            addEntity(_player);
            addRenderedEntity(_player);
            _player.setName("player");
        }
        else {
            _player = Atelier.res.get!Actor("nume");
            _player.setPosition(Vec3i(0, 0, 0));
            _player.setName("player");
            _player.setGraphic("idle");
            _player.angle = 0f;
            addEntity(_player);

            _player.setShadow(true);
            _camera.setPosition(_player.cameraPosition() - oldCameraDeltaPosition);
            _camera.follow(_player, Vec2f.one * 1f, Vec2f.zero);

            _setupPlayerController();
            if (_playerController) {
                _playerController.onStart();
            }
            _player.isPlayer = true;
        }

        _camera.setBounds(hasXBounds, hasYBounds, halfRendererSize, mapSize - halfRendererSize);

        foreach (entityBuilder; _scene.entities) {
            final switch (entityBuilder.type) with (EntityBuilder.Type) {
            case prop:
                Prop prop = Atelier.res.get!Prop(entityBuilder.prop.rid);
                prop.setData(entityBuilder.data);
                prop.setGraphic(entityBuilder.prop.graphic);
                prop.angle = entityBuilder.prop.angle;
                addEntity(prop);
                break;
            case actor:
                Actor actor = Atelier.res.get!Actor(entityBuilder.actor.rid);
                actor.setData(entityBuilder.data);
                actor.setGraphic(entityBuilder.actor.graphic);
                actor.angle = entityBuilder.actor.angle;
                addEntity(actor);
                break;
            case trigger:
                Trigger trigger = new Trigger;
                trigger.setData(entityBuilder.data);
                trigger.setEvent(entityBuilder.trigger.event);
                trigger.setupCollider(cast(Vec3u) entityBuilder.trigger.hitbox);
                addEntity(trigger);
                break;
            case teleporter:
                Teleporter teleporter = new Teleporter;
                teleporter.setData(entityBuilder.data);
                teleporter.setTarget(entityBuilder.teleporter.scene, entityBuilder
                        .teleporter.target, entityBuilder.teleporter.direction);
                teleporter.setupCollider(cast(Vec3u) entityBuilder.teleporter.hitbox);
                addEntity(teleporter);

                if (_player && teleporter.getName() == _tpName) {
                    if (_transition) {
                        _player.setPosition(teleporter.getExitPosition(_player));

                        _setupPlayerController();
                        if (_playerController) {
                            _playerController.onTeleport(teleporter.direction + 4, true);
                        }
                    }
                    else { // Position par défaut
                        _player.setPosition(teleporter.getPosition());

                        _setupPlayerController();
                        if (_playerController) {
                            _playerController.onStart();
                        }
                        _player.angle = entityBuilder.teleporter.direction * -45f;
                    }
                }

                if (!teleporter.getName().length) {
                    teleporter.getCollider().isActive(false);
                }
                break;
            case note:
                break;
            }
        }

        if (_player) {
            _camera.setPosition(_player.cameraPosition() - oldCameraDeltaPosition);
            _camera.follow(_player, Vec2f.one * 1f, Vec2f.zero);
            _camera.setDefault();

            if (_transition) {
                _camera.moveTo(_camera.getBoundedPositionOf(_player.cameraPosition()), 30, Spline
                        .quadInOut);
                _camera.setOnMoveCallback(&_onTransitionMoved);
            }
        }

        foreach (lightBuilder; _scene.lights) {
            final switch (lightBuilder.type) with (LightBuilder.Type) {
            case pointLight:
                PointLight light = new PointLight(lightBuilder.position, lightBuilder.radius);
                light.color = lightBuilder.color;
                light.brightness = lightBuilder.brightness;
                _lighting.addLight(light);
                break;
            }
        }

        _weather.run(_scene.weatherType, _scene.weatherValue, 30);
        _lighting.setBrightness(_scene.brightness, 30, Spline.sineInOut);

        if (!_transition) {
            Atelier.script.callEvent("scene_" ~ _sceneRid);
            Atelier.physics.setTriggersActive(true);
        }

        Atelier.physics.setBounds(true);
        _tpName = "";
    }

    private void _onTransitionMoved() {
        if (_transition) {
            _transition.onCameraMoved();
        }
        if (_player) {
            _setupPlayerController();
            if (_playerController) {
                _playerController.onStart();
            }
            Atelier.script.callEvent("scene_" ~ _sceneRid);
            Atelier.physics.setTriggersActive(true);
        }
    }

    void addEntity(Entity entity) {
        _entities ~= entity;

        entity.isRegistered = true;
        entity.onRegister();
    }

    void addRenderedEntity(Entity entity) {
        if (!entity.getGraphic())
            return;

        _renderedEntities ~= entity;
    }

    void addParticleSource(ParticleSource source) {
        _particleSources ~= source;
        source.isRegistered = true;
    }

    void addController(T)(string id, Controller!T delegate() func) {
        _factory.store(id, func);
    }

    package Controller!T fetchController(T)(string id) {
        return _factory.build!(Controller!T)(id);
    }

    package void registerController(T)(Controller!T controller) {
        _controllers ~= controller;
    }

    void clear() {
        _uiManager.clearUI();
        _controllers.clear();
        _entities.clear();
        _renderedEntities.clear();
        _particleSources.clear();
        _lighting.clear();
        Atelier.physics.clear();
        _renderReferenceCounters.length = 0;
        _renderUpdateIndex = 0;
        _renderListRoots.length = 0;
        _postRenderListAbove.length = 0;
        _isInCombat = false;
    }

    private void _dispatch(InputEvent event) {
        switch (event.type) with (InputEvent.Type) {
        case mouseButton:
            Vec2f pos = event.asMouseButton().position;
            _mousePosition = pos - _camera.getPosition();
            break;
        case mouseMotion:
            Vec2f pos = event.asMouseMotion().position;
            _mousePosition = pos - _camera.getPosition();
            break;
        default:
            break;
        }
        _uiManager.dispatch(event);
    }

    void update(InputEvent[] inputEvents) {
        foreach (InputEvent event; inputEvents) {
            _dispatch(event);
        }

        if (_isPaused)
            return;

        if (!_dialog.isRunning) {
            foreach (i, controller; _controllers) {
                controller.update();
                if (!controller.isRunning) {
                    _controllers.mark(i);
                }
            }
            _controllers.sweep();
        }

        _dialog.update();

        foreach (i, source; _particleSources) {
            source.update();
            if (!source.isRegistered) {
                _particleSources.mark(i);
            }
        }
        _particleSources.sweep();

        foreach (i, entity; _entities) {
            entity.update();
            entity.updateMovement();
            entity.updateEntity();
            if (!entity.isRegistered) {
                _entities.mark(i);
                entity.onUnregister();
            }
        }
        _entities.sweep();

        // Rendus
        foreach (i, entity; _renderedEntities) {
            EntityGraphic graphic = entity.getGraphic();
            if (!graphic || !entity.isRegistered) {
                _renderedEntities.mark(i);
                continue;
            }
            entity.updateEntityGraphics();
        }
        _renderedEntities.sweep();

        _camera.update();
        _uiManager.cameraPosition = (
            ((cast(Vec2f) Atelier.renderer.size) / 2f) -
                _camera.getPosition(_transition is null)
                .round());
        _uiManager.update();
        _lighting.update();

        _weather.update();

        if (_transition) {
            _transition.update();

            if (!_transition.isRunning) {
                _transition = null;
            }
        }
        _updateRenderList();
        _frame++;
    }

    private void _updateRenderList() {
        sort!((a, b) => (a.getZOrder() < b.getZOrder()), SwapStrategy.stable)(
            _renderedEntities.array);

        foreach (entity; _renderedEntities) {
            entity.clearRenderInfo();
        }

        void _updateRenderNode(size_t index) {
            Entity entity = _renderedEntities[index];

            struct RenderNode {
                Entity entity;
                bool inFront;
                int rc;
            }

            RenderNode[] renderNodes;
            for (size_t i = index + 1; i < _renderedEntities.length; ++i) {
                Entity other = _renderedEntities[i];

                if (other.getLayer() != Entity.Layer.scene)
                    continue;

                if ((other.getLevel() > entity.getLevel()) &&
                    (other.getLine() == entity.getLine()) && other.isBehind(entity)) {

                    renderNodes ~= RenderNode(other, false, other.isInRenderList);
                    _updateRenderNode(i);
                }
                else if (other.isAbove(entity) && entity.getYOrder() > other.getYOrder() &&
                    entity.getZOrder() < other.getZOrder()) {

                    renderNodes ~= RenderNode(other, true, other.isInRenderList);
                    _updateRenderNode(i);
                }
            }

            foreach (RenderNode node; renderNodes) {
                if (node.entity.isInRenderList == node.rc) {
                    node.entity.isInRenderList = node.entity.isInRenderList + 1;
                    entity.addRenderChild(node.entity, node.inFront);
                }
            }
        }

        Vec2f rendererSize = cast(Vec2f) Atelier.renderer.size;
        Vec2f halfRendererSize = rendererSize / 2f;
        Vec2f cameraPos = _camera.getPosition();
        Vec4f cameraBounds;
        cameraBounds.x = cameraPos.x - halfRendererSize.x;
        cameraBounds.y = cameraPos.y - halfRendererSize.y;
        cameraBounds.z = cameraPos.x + halfRendererSize.x;
        cameraBounds.w = cameraPos.y + halfRendererSize.y;

        _renderUpdateIndex = 0;
        _renderListRoots.length = 0;
        _postRenderListAbove.length = 0;
        _postRenderListGlow.length = 0;
        for (; _renderUpdateIndex < _renderedEntities.length; ++_renderUpdateIndex) {
            Entity entity = _renderedEntities[_renderUpdateIndex];

            if (entity.isCulled(cameraBounds)) {
                continue;
            }

            if (entity.isInRenderList == 0) {
                final switch (entity.getLayer()) with (Entity.Layer) {
                case scene:
                    _updateRenderNode(_renderUpdateIndex);
                    _renderListRoots ~= entity;
                    break;
                case above:
                    _postRenderListAbove ~= entity;
                    break;
                case glow:
                    _postRenderListGlow ~= entity;
                    break;
                }
            }
        }

        sort!((a, b) => (a.getYOrder() < b.getYOrder()), SwapStrategy.stable)(
            _renderListRoots);
    }

    void renderEntityTransition(Entity entity, Vec2f offset, Sprite shadowSprite, float tTransition, bool drawGraphics) {
        if (!_transition)
            return;

        _transition.renderEntity(entity, offset, shadowSprite, tTransition, drawGraphics);
    }

    void draw(Vec2f origin) {
        if (!_scene)
            return;

        size_t renderEntityIndex = 0;
        _renderReferenceCounters.length = _renderedEntities.length;
        _renderReferenceCounters[] = 0;

        Atelier.renderer.pushCanvas(_camera.canvas);
        Atelier.renderer.clearCanvas(Color.black, 1f);

        Vec2f cameraPosition = _camera.getPosition(_transition is null).round();
        Vec2f rendererSize = cast(Vec2f) Atelier.renderer.size;
        Vec2f halfRendererSize = rendererSize / 2f;
        Vec2f mapSize = Vec2f(_scene.columns, _scene.lines) * 16f;

        Vec2f offset = mapSize / 2f + halfRendererSize - cameraPosition;
        Vec2f entityOffset = halfRendererSize - cameraPosition;

        Vec4f cameraBounds;
        cameraBounds.x = cameraPosition.x - halfRendererSize.x;
        cameraBounds.y = cameraPosition.y - halfRendererSize.y;
        cameraBounds.z = cameraPosition.x + halfRendererSize.y;
        cameraBounds.w = cameraPosition.y + halfRendererSize.y;

        foreach (entity; _renderedEntities) {
            entity.isRendered = false;
        }

        if (_transition) {
            // Parallax
            if (_transition.showTiles()) {
                foreach_reverse (layer; _scene.parallaxLayers) {
                    layer.draw(offset - 16 + cameraPosition / layer.distance);
                }
            }

            // Entités en haut
            for (; renderEntityIndex < _renderListRoots.length; ++renderEntityIndex) {
                Entity entity = _renderListRoots[renderEntityIndex];

                if (entity.getYOrder() >= 0f)
                    break;

                if (!entity.isRendered) {
                    entity.isRendered = true;
                    _transition.drawEntity(entity, entityOffset, _shadowSprite);
                }
            }

            for (size_t i = renderEntityIndex; i < _renderListRoots.length; ++i) {
                Entity entity = _renderListRoots[i];

                if (entity.getPosition().z >= 0f || entity.getYOrder() >= (_scene.lines - 1) * 16f)
                    continue;

                if (!entity.isRendered) {
                    _renderReferenceCounters[i]++;
                    if (_renderReferenceCounters[i] >= entity.isInRenderList) {
                        entity.isRendered = true;
                        _transition.drawEntity(entity, entityOffset, _shadowSprite);
                    }
                }
            }

            _transition.setupDrawStep(_scene, entityOffset, _camera.getTargetPosition().round());

            int levels = _scene.levels;
            Tilemap[] lowerTopographicLayers;
            Tilemap[] upperTopographicLayers;

            if (_transition.showTiles()) {
                lowerTopographicLayers = _scene.topologicMap.lowerTilemaps;
                upperTopographicLayers = _scene.topologicMap.upperTilemaps;
            }

            for (int y = 0; y < _scene.lines; ++y) {
                for (size_t level; level < levels; ++level) {
                    const float yLine = (y - cast(int) level) << 4;
                    if ((yLine + 16) < cameraBounds.y || (yLine > cameraBounds.w))
                        continue;

                    if (level < lowerTopographicLayers.length) {
                        lowerTopographicLayers[level].drawLine(y, offset);
                    }

                    if (level < upperTopographicLayers.length) {
                        upperTopographicLayers[level].drawLine(y, offset);
                    }

                    if (y > 0 && _transition.showTiles()) {
                        foreach_reverse (layer; _scene.terrainLayers) {
                            if (layer.level != level)
                                continue;

                            layer.drawLine(y, offset - Vec2f(0f, level << 4));
                        }
                    }

                    _transition.drawLine(offset, y, level);

                    for (size_t i = renderEntityIndex; i < _renderListRoots.length;
                        ++i) {
                        Entity entity = _renderListRoots[i];

                        if (entity.getLevel() != level ||
                            entity.getYOrder() < (y << 4) ||
                            entity.getYOrder() >= ((y + 1) << 4))
                            continue;

                        if (!entity.isRendered) {
                            entity.isRendered = true;
                            _transition.drawEntity(entity, entityOffset, _shadowSprite);
                        }
                    }
                }

                if (_transition.showTiles()) {
                    foreach_reverse (layer; _scene.terrainLayers) {
                        if (layer.level <= levels)
                            continue;

                        layer.drawLine(y, offset - Vec2f(0f, layer.level * 16f));
                    }
                }
            }

            // Entités en bas
            for (; renderEntityIndex < _renderListRoots.length; ++renderEntityIndex) {
                Entity entity = _renderListRoots[renderEntityIndex];

                if (!entity.isRendered) {
                    entity.isRendered = true;
                    _transition.drawEntity(entity, entityOffset, _shadowSprite);
                }
            }

            // Entités en post-rendu
            foreach (Entity entity; _postRenderListAbove) {
                if (!entity.isRendered) {
                    entity.isRendered = true;
                    _transition.drawEntity(entity, entityOffset, _shadowSprite);
                }
            }

            // Entités en post-rendu additif
            _glow.drawTransition(_transition, _postRenderListGlow, entityOffset, _shadowSprite);

            _transition.drawAbove();
        }
        else {
            // Parallax
            foreach_reverse (layer; _scene.parallaxLayers) {
                layer.draw(offset - 16 + cameraPosition / layer.distance);
            }

            // Entités en haut
            for (; renderEntityIndex < _renderListRoots.length; ++renderEntityIndex) {
                Entity entity = _renderListRoots[renderEntityIndex];

                if (entity.getYOrder() >= 0f)
                    break;

                if (!entity.isRendered) {
                    entity.isRendered = true;
                    entity.draw(entityOffset, _shadowSprite);
                }
            }

            for (size_t i = renderEntityIndex; i < _renderListRoots.length; ++i) {
                Entity entity = _renderListRoots[i];

                if (entity.getPosition().z >= 0f || entity.getYOrder() >= (_scene.lines - 1) * 16f)
                    continue;

                if (!entity.isRendered) {
                    _renderReferenceCounters[i]++;
                    if (_renderReferenceCounters[i] >= entity.isInRenderList) {
                        entity.isRendered = true;
                        entity.draw(entityOffset, _shadowSprite);
                    }
                }
            }

            int levels = _scene.levels;
            Tilemap[] lowerTopographicLayers = _scene.topologicMap.lowerTilemaps;
            Tilemap[] upperTopographicLayers = _scene.topologicMap.upperTilemaps;

            for (int y = 0; y < (_scene.lines + levels); ++y) {
                for (size_t level; level < levels; ++level) {
                    const float yLine = (y - cast(int) level) << 4;
                    if ((yLine + 16) < cameraBounds.y || (yLine > cameraBounds.w))
                        continue;

                    if (level < lowerTopographicLayers.length) {
                        lowerTopographicLayers[level].drawLine(y, offset);
                    }

                    if (level < upperTopographicLayers.length) {
                        upperTopographicLayers[level].drawLine(y, offset);
                    }

                    if (y > 0) {
                        foreach_reverse (layer; _scene.terrainLayers) {
                            if (layer.level != level)
                                continue;

                            layer.drawLine(y, offset - Vec2f(0f, level << 4));
                        }
                    }

                    for (size_t i = renderEntityIndex; i < _renderListRoots.length;
                        ++i) {
                        Entity entity = _renderListRoots[i];

                        if (entity.getLevel() != level ||
                            entity.getYOrder() < (y << 4) ||
                            entity.getYOrder() >= ((y + 1) << 4))
                            continue;

                        if (!entity.isRendered) {
                            entity.isRendered = true;
                            entity.draw(entityOffset, _shadowSprite);
                        }
                    }
                }

                foreach_reverse (layer; _scene.terrainLayers) {
                    if (layer.level <= levels)
                        continue;

                    layer.drawLine(y, offset - Vec2f(0f, layer.level * 16f));
                }
            }

            // Entités en bas
            for (; renderEntityIndex < _renderListRoots.length; ++renderEntityIndex) {
                Entity entity = _renderListRoots[renderEntityIndex];

                if (!entity.isRendered) {
                    entity.isRendered = true;
                    entity.draw(entityOffset, _shadowSprite);
                }
            }

            // Entités en post-rendu
            foreach (Entity entity; _postRenderListAbove) {
                if (!entity.isRendered) {
                    entity.isRendered = true;
                    entity.draw(entityOffset, _shadowSprite);
                }
            }

            // Entités en post-rendu additif
            _glow.draw(_postRenderListGlow, entityOffset, _shadowSprite);
        }

        _displayBorders(entityOffset);

        Atelier.nav.draw(entityOffset);

        _lighting.draw(entityOffset);
        _weather.draw(entityOffset);
        _uiManager.draw();
        Atelier.renderer.popCanvas();
        _camera.draw();
    }

    private void _displayBorders(Vec2f entityOffset) {
        if (!_player || !Atelier.physics.hasCombatBounds)
            return;

        const Vec4i bounds = Atelier.physics.combatBounds;
        ActorCollider collider = _player.getCollider();
        const Vec4i corners = Vec4i(
            collider.left,
            collider.up,
            collider.right,
            collider.down
        );
        Vec4i delta = Vec4i(
            corners.x - bounds.x,
            corners.y - bounds.y,
            corners.z - bounds.z,
            corners.w - bounds.w
        ).abs().min(Vec4i.one * 50);
        Vec4f alpha = (50f - (cast(Vec4f) delta)) / 50f;

        Vec4i borders = Vec4i(
            max(corners.x - 50, bounds.x),
            max(corners.y - 50, bounds.y),
            min(corners.z + 50, bounds.z),
            min(corners.w + 50, bounds.w)
        );

        float alphaMax = alpha.max();
        entityOffset.y -= _player.getPosition().z;

        float t1 = easeOutSine((_frame % 32) / 32f);
        int p1 = cast(int) lerp(0f, 16f, t1 * alphaMax);

        float t2 = easeOutSine(((_frame + 16) % 32) / 32f);
        int p2 = cast(int) lerp(0f, 16f, t2 * alphaMax);

        if (alpha.x > 0f) {
            Atelier.renderer.drawLine(
                entityOffset + Vec2f(bounds.x, borders.y),
                entityOffset + Vec2f(bounds.x, borders.w),
                Color.white, alpha.x);

            Atelier.renderer.drawLine(
                entityOffset + Vec2f(bounds.x - p1, borders.y - p1),
                entityOffset + Vec2f(bounds.x - p1, borders.w + p1),
                Color.white, (1f - t1) * alpha.x);

            Atelier.renderer.drawLine(
                entityOffset + Vec2f(bounds.x - p2, borders.y - p2),
                entityOffset + Vec2f(bounds.x - p2, borders.w + p2),
                Color.white, (1f - t2) * alpha.x);
        }
        if (alpha.y > 0f) {
            Atelier.renderer.drawLine(
                entityOffset + Vec2f(borders.x, bounds.y),
                entityOffset + Vec2f(borders.z, bounds.y),
                Color.white, alpha.y);

            Atelier.renderer.drawLine(
                entityOffset + Vec2f(borders.x - p1, bounds.y - p1),
                entityOffset + Vec2f(borders.z + p1, bounds.y - p1),
                Color.white, (1f - t1) * alpha.y);

            Atelier.renderer.drawLine(
                entityOffset + Vec2f(borders.x - p2, bounds.y - p2),
                entityOffset + Vec2f(borders.z + p2, bounds.y - p2),
                Color.white, (1f - t2) * alpha.y);
        }
        if (alpha.z > 0f) {
            Atelier.renderer.drawLine(
                entityOffset + Vec2f(bounds.z, borders.y),
                entityOffset + Vec2f(bounds.z, borders.w),
                Color.white, alpha.z);

            Atelier.renderer.drawLine(
                entityOffset + Vec2f(bounds.z + p1, borders.y - p1),
                entityOffset + Vec2f(bounds.z + p1, borders.w + p1),
                Color.white, (1f - t1) * alpha.z);

            Atelier.renderer.drawLine(
                entityOffset + Vec2f(bounds.z + p2, borders.y - p2),
                entityOffset + Vec2f(bounds.z + p2, borders.w + p2),
                Color.white, (1f - t2) * alpha.z);
        }
        if (alpha.w > 0f) {
            Atelier.renderer.drawLine(
                entityOffset + Vec2f(borders.x, bounds.w),
                entityOffset + Vec2f(borders.z, bounds.w),
                Color.white, alpha.w);

            Atelier.renderer.drawLine(
                entityOffset + Vec2f(borders.x - p1, bounds.w + p1),
                entityOffset + Vec2f(borders.z + p1, bounds.w + p1),
                Color.white, (1f - t1) * alpha.w);

            Atelier.renderer.drawLine(
                entityOffset + Vec2f(borders.x - p2, bounds.w + p2),
                entityOffset + Vec2f(borders.z + p2, bounds.w + p2),
                Color.white, (1f - t2) * alpha.w);
        }
    }
}
