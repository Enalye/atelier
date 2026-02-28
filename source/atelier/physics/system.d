module atelier.physics.system;

import std.conv : to;
import std.exception : enforce;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.world;
import atelier.physics.actor;
import atelier.physics.collider;
import atelier.physics.hitbox;
import atelier.physics.repulsor;
import atelier.physics.solid;
import atelier.physics.shot;
import atelier.physics.trigger;

final class Physics {
    enum Shape {
        box,
        slopeUp,
        slopeDown,
        slopeLeft,
        slopeRight,
        startSlopeUp,
        middleSlopeUp,
        endSlopeUp,
        startSlopeDown,
        middleSlopeDown,
        endSlopeDown,
        startSlopeLeft,
        middleSlopeLeft,
        endSlopeLeft,
        startSlopeRight,
        middleSlopeRight,
        endSlopeRight,
    }

    private struct HitboxLayerInternal {
        ubyte[] collisionList;
        Array!Hitbox hitboxes;
    }

    struct HitboxLayer {
        string name;
        uint collisionMask;
        uint repeatMask;
        uint removeMask;
        uint iframes;

        mixin Serializer;

        bool getCollision(uint layer) {
            if (layer >= 32)
                return false;

            return (collisionMask & (1 << layer)) > 0;
        }

        void setCollision(uint layer, bool value) {
            if (layer >= 32)
                return;

            uint mask = 1 << layer;
            if (value) {
                collisionMask |= mask;
            }
            else {
                collisionMask &= ~mask;
            }
        }

        bool getRepeat(uint layer) {
            if (layer >= 32)
                return false;

            return (repeatMask & (1 << layer)) > 0;
        }

        void setRepeat(uint layer, bool value) {
            if (layer >= 32)
                return;

            uint mask = 1 << layer;
            if (value) {
                repeatMask |= mask;
            }
            else {
                repeatMask &= ~mask;
            }
        }

        bool getRemove(uint layer) {
            if (layer >= 32)
                return false;

            return (removeMask & (1 << layer)) > 0;
        }

        void setRemove(uint layer, bool value) {
            if (layer >= 32)
                return;

            uint mask = 1 << layer;
            if (value) {
                removeMask |= mask;
            }
            else {
                removeMask &= ~mask;
            }
        }
    }

    private {
        Array!ActorCollider _actors;
        Array!SolidCollider _solids;
        Array!ShotCollider _shots;
        Array!TriggerCollider _triggers;
        Array!Repulsor _repulsors;
        bool _hasColliderToRemove;
        bool _hasRepulsorToRemove;
        bool _areTriggersActive;
        bool _isBounded;
        Vec4i _customBounds;
        bool _hasCustomBounds;

        // Affichage des collisions
        bool _showActors;
        bool _showSolids;
        bool _showShots;
        bool _showTriggers;
        bool _showHitboxes;
        bool _showRepulsors;

        HitboxLayer[32] _hitboxLayers;
        HitboxLayerInternal[32] _hitboxLayersInternal;
    }

    void load(Farfadet ffd) {
        if (!ffd.hasNode("physics"))
            return;

        Farfadet node = ffd.getNode("physics");
        foreach (hitboxLayerNode; node.getNodes("hitboxLayer")) {
            HitboxLayer data;
            data.load(hitboxLayerNode);
            setHitboxLayer(hitboxLayerNode.get!uint(0), data);
        }
    }

    void save(Farfadet ffd) {
        Farfadet node = ffd.addNode("physics");

        foreach (i, data; _hitboxLayers) {
            Farfadet hitboxLayerNode = node.addNode("hitboxLayer").add!uint(cast(uint) i);
            data.save(hitboxLayerNode);
        }
    }

    void deserialize(InStream stream) {
        for (uint i; i < 32; ++i) {
            HitboxLayer data;
            data.deserialize(stream);
            setHitboxLayer(i, data);
        }
    }

    void serialize(OutStream stream) {
        for (uint i; i < 32; ++i) {
            _hitboxLayers[i].serialize(stream);
        }
    }

    void setHitboxLayer(uint layer, HitboxLayer data) {
        enforce(layer < _hitboxLayers.length, "Le calque de collision " ~ to!string(
                layer) ~ " dépasse la limite");

        uint collisionMask = data.collisionMask;

        _hitboxLayers[layer] = data;
        _hitboxLayersInternal[layer].collisionList.length = 0;
        for (ubyte maskId; maskId < 32; ++maskId) {
            if (collisionMask & (1 << maskId)) {
                _hitboxLayersInternal[layer].collisionList ~= maskId;
            }
        }
    }

    HitboxLayer getHitboxLayer(uint layer) {
        enforce(layer < _hitboxLayers.length, "Le calque de collision " ~ to!string(
                layer) ~ " dépasse la limite");
        return _hitboxLayers[layer];
    }

    @property {
        bool hasCustomBounds() const {
            return _hasCustomBounds;
        }

        Vec4i customBounds() const {
            return _customBounds;
        }
    }

    /// Informations de collision
    struct CollisionHit {
        /// Boite de collision touchée
        SolidCollider solid;

        /// Élément touché
        Entity entity;

        /// Normale de la surface
        Vec3f normal;

        enum Type {
            none,
            squish,
            impact
        }

        Type type;
    }

    struct TerrainHit {
        bool isColliding = false;
        bool isOnGround = false;
        Vec3f normal = Vec3f.zero;
        int height = -16;
        Shape shape = Shape.box;
    }

    struct SolidHit {
        bool isColliding = false;
        SolidCollider solid;
        int baseZ = -16;
    }

    struct HitboxHit {
        bool isColliding = false;
        Vec3f normal = Vec3f.zero;
    }

    struct ActorHit {
        bool isColliding = false;
        ActorCollider actor;
    }

    this() {
        _actors = new Array!ActorCollider;
        _solids = new Array!SolidCollider;
        _shots = new Array!ShotCollider;
        _triggers = new Array!TriggerCollider;
        _repulsors = new Array!Repulsor;

        for (uint i; i < 32; ++i) {
            _hitboxLayersInternal[i].hitboxes = new Array!Hitbox;
        }
    }

    void clear() {
        _actors.clear();
        _solids.clear();
        _shots.clear();
        _triggers.clear();
        _repulsors.clear();

        for (uint i; i < 32; ++i) {
            _hitboxLayersInternal[i].hitboxes.clear();
        }
    }

    void setTriggersActive(bool value) {
        _areTriggersActive = value;
    }

    void setBounds(bool value) {
        _isBounded = value;
    }

    void setCustomBounds(Vec4i bounds) {
        _customBounds = bounds;
        _hasCustomBounds = true;
    }

    void unsetCustomBounds() {
        _hasCustomBounds = false;
    }

    void update() {
        if (_hasColliderToRemove) {
            _hasColliderToRemove = false;

            // À faire: la boucle ne sert qu’à vérifier l’existance des collider.
            // -> Trouver un autre endroit où le faire
            foreach (i, solid; _solids) {
                if (!solid.isRegistered) {
                    _solids.mark(i);
                }
            }
            _solids.sweep();

            foreach (i, shot; _shots) {
                if (!shot.isRegistered) {
                    _shots.mark(i);
                }
            }
            _shots.sweep();

            foreach (i, actor; _actors) {
                if (!actor.isRegistered) {
                    _actors.mark(i);
                }
            }
            _actors.sweep();
        }

        if (Atelier.world.player) {
            Collider player = Atelier.world.player.getCollider();
            if (player) {
                foreach (i, trigger; _triggers) {
                    if (!trigger.isRegistered) {
                        _triggers.mark(i);
                    }
                    else if (_areTriggersActive && trigger.isActive) {
                        bool hit = trigger.collidesWith(player.entity.getPosition(), player
                                .collider);
                        if (hit) {
                            if (trigger.isActiveOnce) {
                                trigger.isActive = false;
                            }

                            trigger.entity.onTrigger();
                        }
                    }
                }
                _triggers.sweep();
            }
        }

        // Repulsor
        if (_hasRepulsorToRemove) {
            _hasRepulsorToRemove = false;

            // À faire: la boucle ne sert qu’à vérifier l’existance des collider.
            // -> Trouver un autre endroit où le faire
            foreach (i, collider; _repulsors) {
                if (!collider.isRegistered) {
                    _repulsors.mark(i);
                }
            }
            _repulsors.sweep();
        }

        for (uint i; i < _repulsors.length; ++i) {
            for (uint y = i + 1; y < _repulsors.length; ++y) {
                _repulsors[i].update(_repulsors[y]);
            }
        }

        for (uint i; i < _repulsors.length; ++i) {
            _repulsors[i].apply();
        }

        // Hitbox
        for (uint layer; layer < 32; ++layer) {
            foreach (hitboxID, hitbox; _hitboxLayersInternal[layer].hitboxes) {
                hitbox.update();
                if (!hitbox.isRegistered) {
                    hitbox.clear();
                    _hitboxLayersInternal[layer].hitboxes.mark(hitboxID);
                    continue;
                }
            }

            _hitboxLayersInternal[layer].hitboxes.sweep();
        }

        for (uint layerA; layerA < 32; ++layerA) {
            foreach (layerB; _hitboxLayersInternal[layerA].collisionList) {
                foreach (hitboxAID, hitboxA; _hitboxLayersInternal[layerA].hitboxes) {
                    if (!hitboxA.isCollidable())
                        continue;

                    foreach (hitboxBID, hitboxB; _hitboxLayersInternal[layerB].hitboxes) {
                        if (hitboxA == hitboxB ||
                            !hitboxB.isCollidable() ||
                            hitboxA.isExcluded(hitboxB) ||
                            hitboxB.isExcluded(hitboxA))
                            continue;

                        HitboxHit hitboxHit = hitboxA.collidesWith(hitboxB);
                        if (hitboxHit.isColliding) {
                            CollisionHit hit;
                            hit.type = CollisionHit.Type.impact;
                            hit.normal = hitboxHit.normal;
                            hit.entity = hitboxA.entity;
                            hitboxB.entity.onCollide(hit);
                            hit.normal = -hitboxHit.normal;
                            hit.entity = hitboxB.entity;
                            hitboxA.entity.onCollide(hit);

                            if (!_hitboxLayers[layerA].getRepeat(layerB))
                                hitboxA.exclude(hitboxB);

                            if (!_hitboxLayers[layerB].getRepeat(layerA))
                                hitboxB.exclude(hitboxA);

                            if (_hitboxLayers[layerA].getRemove(layerB))
                                hitboxA.isRegistered = false;
                            else
                                hitboxA.setIFrames(_hitboxLayers[layerA].iframes);

                            if (_hitboxLayers[layerB].getRemove(layerA))
                                hitboxB.isRegistered = false;
                            else
                                hitboxB.setIFrames(_hitboxLayers[layerB].iframes);
                        }
                    }
                }
            }
        }
    }

    void addCollider(Collider collider) {
        final switch (collider.type) with (Collider.Type) {
        case solid:
            _solids ~= cast(SolidCollider) collider;
            collider.isRegistered = true;
            collider.isDisplayed = _showSolids;
            break;
        case actor:
            _actors ~= cast(ActorCollider) collider;
            collider.isRegistered = true;
            collider.isDisplayed = _showActors;
            break;
        case shot:
            _shots ~= cast(ShotCollider) collider;
            collider.isRegistered = true;
            collider.isDisplayed = _showShots;
            break;
        case trigger:
            _triggers ~= cast(TriggerCollider) collider;
            collider.isRegistered = true;
            collider.isDisplayed = _showTriggers;
            break;
        }
    }

    void removeCollider(Collider collider) {
        if (collider.isRegistered) {
            _hasColliderToRemove = true;
            collider.isRegistered = false;
        }
    }

    void addRepulsor(Repulsor repulsor) {
        _repulsors ~= repulsor;
        repulsor.isRegistered = true;
        repulsor.isDisplayed = _showRepulsors;
    }

    void removeRepulsor(Repulsor repulsor) {
        if (repulsor.isRegistered) {
            _hasRepulsorToRemove = true;
            repulsor.isRegistered = false;
        }
    }

    void addHitbox(Hitbox hitbox) {
        enforce(hitbox.layer < _hitboxLayers.length, "Le calque de collision " ~ to!string(
                hitbox.layer) ~ " dépasse la limite");

        hitbox.isRegistered = true;
        _hitboxLayersInternal[hitbox.layer].hitboxes ~= hitbox;
        hitbox.isDisplayed = _showHitboxes;
    }

    void removeHitbox(Hitbox hitbox) {
        if (hitbox.isRegistered) {
            hitbox.isRegistered = false;
        }
    }

    /// Est-ce qu’on chevauche un solide ?
    SolidHit collidesAt(Vec3i point, Vec3i collider) {
        SolidHit hit;
        foreach (SolidCollider solid; _solids) {
            hit = solid.collidesWith(point, collider);
            if (hit.isColliding) {
                break;
            }
        }

        return hit;
    }

    TerrainHit hitTileTerrain(Vec3i tile, Vec3i collider) {
        TerrainHit hit;
        hit.height = 0;
        return hit;
    }

    TerrainHit hitTerrain(Vec3i point, Vec3i collider) {
        TerrainHit hitTopology = hitTerrainTopology(point, collider);
        if (hitTopology.isColliding)
            return hitTopology;
        TerrainHit hitCollisionLayer = hitTerrainCollisionLayers(point, collider);
        if (hitTopology.height > hitCollisionLayer.height)
            return hitTopology;
        return hitCollisionLayer;
    }

    TerrainHit hitTerrainCollisionLayers(Vec3i point, Vec3i collider) {
        point.x -= (collider.x - (collider.x >> 1));
        point.y -= (collider.y - (collider.y >> 1));
        Vec3i coords = Vec3i(((point.x / 16) - (point.x < 0 ? 1 : 0)),
            ((point.y / 16) - (point.y < 0 ? 1 : 0)),
            ((point.z / 16) - (point.z < 0 ? 1 : 0)));

        Vec3i endPoint = point + collider;
        Vec3i endCoords = Vec3i(((endPoint.x / 16) - (endPoint.x < 0 ? 1 : 0)),
            ((endPoint.y / 16) - (endPoint.y < 0 ? 1 : 0)),
            ((endPoint.z / 16) - (endPoint.z < 0 ? 1 : 0)));

        TerrainHit endResult;
        TerrainHit result;

        int tileZ = 16;

        foreach_reverse (layer; Atelier.world.scene.collisionLayers) {
            if (layer.level > endCoords.z)
                continue;

            __tilesLoop: for (int y = coords.y; y <= endCoords.y; y++) {
                for (int x = coords.x; x <= endCoords.x; x++) {
                    int id = layer.getId(x, y);

                    Vec4i tileBox = Vec4i(x * 16, y * 16,
                        (x + 1) * 16,
                        (y + 1) * 16);
                    Vec4i aabb = Vec4i(point.x, point.y,
                        point.x + collider.x,
                        point.y + collider.y);

                    Vec4i relativePos = aabb;
                    relativePos.x -= tileBox.x;
                    relativePos.y -= tileBox.y;
                    relativePos.z -= tileBox.x;
                    relativePos.w -= tileBox.y;

                    bool checkSubColl(Vec4i offset_) {
                        return (((tileBox.x + offset_.x) < aabb.z) &&
                                ((tileBox.y + offset_.y) < aabb.w) &&
                                (tileBox.z > (aabb.x + offset_.z)) &&
                                (tileBox.w > (aabb.y + offset_.w)));
                    }

                    if (!checkSubColl(Vec4i(0, 0, 0, 0)))
                        continue;

                    if (id > 0xf) {
                        Shape shape = cast(Shape)(id & 0xf);
                        int relativeZ = point.z - (layer.level * 16);
                        final switch (shape) with (Shape) {
                        case box:
                            result.isColliding = true;
                            result.normal = Vec3f(0f, 0f, 1f);
                            break __tilesLoop;
                        case slopeUp:
                            tileZ = clamp(16 - relativePos.y, 0, 16);
                            result.height = (layer.level * 16) + tileZ;
                            if (relativeZ < tileZ) {
                                result.isColliding = true;
                                result.normal = Vec3f(0f, 1f, 1f);
                                result.shape = shape;
                                break __tilesLoop;
                            }
                            break;
                        case slopeDown:
                            tileZ = clamp(relativePos.w, 0, 16);
                            result.height = (layer.level * 16) + tileZ;
                            if (relativeZ < tileZ) {
                                result.isColliding = true;
                                result.normal = Vec3f(0f, -1f, 1f);
                                result.shape = shape;
                                break __tilesLoop;
                            }
                            break;
                        case slopeRight:
                            tileZ = clamp(relativePos.z, 0, 16);
                            result.height = (layer.level * 16) + tileZ;
                            if (relativeZ < tileZ) {
                                result.isColliding = true;
                                result.normal = Vec3f(1f, 0f, 1f);
                                result.shape = shape;
                                break __tilesLoop;
                            }
                            break;
                        case slopeLeft:
                            tileZ = clamp(16 - relativePos.x, 0, 16);
                            result.height = (layer.level * 16) + tileZ;
                            if (relativeZ < tileZ) {
                                result.isColliding = true;
                                result.normal = Vec3f(-1f, 0f, 1f);
                                result.shape = shape;
                                break __tilesLoop;
                            }
                            break;
                        case startSlopeUp:
                            tileZ = clamp(8 - relativePos.y, 0, 8);
                            result.height = (layer.level * 16) + tileZ;
                            if (relativeZ < tileZ) {
                                result.isColliding = true;
                                result.normal = Vec3f(0f, 1f, 1f);
                                result.shape = shape;
                                break __tilesLoop;
                            }
                            break;
                        case middleSlopeUp:
                            tileZ = clamp(24 - relativePos.y, 8, 24);
                            result.height = (layer.level * 16) + tileZ;
                            if (relativeZ < tileZ) {
                                result.isColliding = true;
                                result.normal = Vec3f(0f, 1f, 1f);
                                result.shape = shape;
                                break __tilesLoop;
                            }
                            break;
                        case endSlopeUp:
                            tileZ = clamp(24 - relativePos.y, 8, 16);
                            result.height = (layer.level * 16) + tileZ;
                            if (relativeZ < tileZ) {
                                result.isColliding = true;
                                result.normal = Vec3f(0f, 1f, 1f);
                                result.shape = shape;
                                break __tilesLoop;
                            }
                            break;
                        case startSlopeDown:
                            tileZ = clamp(relativePos.w - 8, 0, 8);
                            result.height = (layer.level * 16) + tileZ;
                            if (relativeZ < tileZ) {
                                result.isColliding = true;
                                result.normal = Vec3f(0f, -1f, 1f);
                                result.shape = shape;
                                break __tilesLoop;
                            }
                            break;
                        case middleSlopeDown:
                            tileZ = clamp(relativePos.w + 8, 8, 24);
                            result.height = (layer.level * 16) + tileZ;
                            if (relativeZ < tileZ) {
                                result.isColliding = true;
                                result.normal = Vec3f(0f, -1f, 1f);
                                result.shape = shape;
                                break __tilesLoop;
                            }
                            break;
                        case endSlopeDown:
                            tileZ = clamp(relativePos.w + 8, 8, 16);
                            result.height = (layer.level * 16) + tileZ;
                            if (relativeZ < tileZ) {
                                result.isColliding = true;
                                result.normal = Vec3f(0f, -1f, 1f);
                                result.shape = shape;
                                break __tilesLoop;
                            }
                            break;
                        case startSlopeRight:
                            tileZ = clamp(relativePos.z - 8, 0, 8);
                            result.height = (layer.level * 16) + tileZ;
                            if (relativeZ < tileZ) {
                                result.isColliding = true;
                                result.normal = Vec3f(1f, 0f, 1f);
                                result.shape = shape;
                                break __tilesLoop;
                            }
                            break;
                        case middleSlopeRight:
                            tileZ = clamp(relativePos.z + 8, 8, 24);
                            result.height = (layer.level * 16) + tileZ;
                            if (relativeZ < tileZ) {
                                result.isColliding = true;
                                result.normal = Vec3f(1f, 0f, 1f);
                                result.shape = shape;
                                break __tilesLoop;
                            }
                            break;
                        case endSlopeRight:
                            tileZ = clamp(relativePos.z + 8, 8, 16);
                            result.height = (layer.level * 16) + tileZ;
                            if (relativeZ < tileZ) {
                                result.isColliding = true;
                                result.normal = Vec3f(1f, 0f, 1f);
                                result.shape = shape;
                                break __tilesLoop;
                            }
                            break;
                        case startSlopeLeft:
                            tileZ = clamp(8 - relativePos.x, 0, 8);
                            result.height = (layer.level * 16) + tileZ;
                            if (relativeZ < tileZ) {
                                result.isColliding = true;
                                result.normal = Vec3f(-1f, 0f, 1f);
                                result.shape = shape;
                                break __tilesLoop;
                            }
                            break;
                        case middleSlopeLeft:
                            tileZ = clamp(24 - relativePos.x, 8, 24);
                            result.height = (layer.level * 16) + tileZ;
                            if (relativeZ < tileZ) {
                                result.isColliding = true;
                                result.normal = Vec3f(-1f, 0f, 1f);
                                result.shape = shape;
                                break __tilesLoop;
                            }
                            break;
                        case endSlopeLeft:
                            tileZ = clamp(24 - relativePos.x, 8, 16);
                            result.height = (layer.level * 16) + tileZ;
                            if (relativeZ < tileZ) {
                                result.isColliding = true;
                                result.normal = Vec3f(-1f, 0f, 1f);
                                result.shape = shape;
                                break __tilesLoop;
                            }
                            break;
                        }
                    }
                    else {
                        switch (id & 0xf) {
                        case 0b1111: // Zone pleine
                            result.isColliding = true;
                            result.normal = Vec3f(0f, 0f, 1f);
                            break __tilesLoop;
                        case 0b0110: // Coin gauche
                            if (relativePos.z > 8) {
                                result.isColliding = true;
                                result.normal = Vec3f(-1f, 0f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b1001: // Coin droite
                            if (relativePos.x < 8) {
                                result.isColliding = true;
                                result.normal = Vec3f(1f, 0f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b1100: // Coin haut
                            if (relativePos.w > 8) {
                                result.isColliding = true;
                                result.normal = Vec3f(0f, -1f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b0011: // Coin bas
                            if (relativePos.y < 8) {
                                result.isColliding = true;
                                result.normal = Vec3f(0f, 1f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b1110: // Coin 3/4 haut-gauche
                            if (checkSubColl(Vec4i(0, 0, 8, 8))) {
                                if ((relativePos.z + relativePos.w) > 8) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(-1f, -1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            else {
                                result.isColliding = true;
                                result.normal = Vec3f(-1f, -1f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b1011: // Coin 3/4 bas-droite
                            if (checkSubColl(Vec4i(8, 8, 0, 0))) {
                                if ((relativePos.x + relativePos.y) < 24) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(1f, 1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            else {
                                result.isColliding = true;
                                result.normal = Vec3f(1f, 1f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b1101: // Coin 3/4 haut-droite
                            if (checkSubColl(Vec4i(8, 0, 0, 8))) {
                                if ((relativePos.w + 8) > relativePos.x) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(1f, -1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            else {
                                result.isColliding = true;
                                result.normal = Vec3f(1f, -1f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b0111: // Coin 3/4 bas-gauche
                            if (checkSubColl(Vec4i(0, 8, 8, 0))) {
                                if ((relativePos.z + 8) > relativePos.y) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(-1f, 1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            else {
                                result.isColliding = true;
                                result.normal = Vec3f(-1f, 1f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b0100: // Coin 1/4 haut-gauche
                            if (checkSubColl(Vec4i(8, 8, 0, 0))) {
                                if ((relativePos.z + relativePos.w) > 24) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(-1f, -1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            break;
                        case 0b0001: // Coin 1/4 bas-droite
                            if (checkSubColl(Vec4i(0, 0, 8, 8))) {
                                if ((relativePos.x + relativePos.y) < 8) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(1f, 1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            break;
                        case 0b1000: // Coin 1/4 haut-droite
                            if (checkSubColl(Vec4i(0, 8, 8, 0))) {
                                if ((relativePos.w - 8) > relativePos.x) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(1f, -1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            break;
                        case 0b0010: // Coin 1/4 bas-gauche
                            if (checkSubColl(Vec4i(8, 0, 0, 8))) {
                                if ((relativePos.z - 8) > relativePos.y) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(-1f, 1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            break;
                        case 0b0101: // Diagonale haut-gauche / bas-droite
                            if (checkSubColl(Vec4i(8, 0, 0, 8))) {
                                if ((relativePos.w + 8) > relativePos.x) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(1f, -1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            else if (checkSubColl(Vec4i(0, 8, 8, 0))) {
                                if ((relativePos.z + 8) > relativePos.y) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(-1f, 1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            else {
                                result.isColliding = true;
                                result.normal = (relativePos.x > relativePos.y) ?
                                    Vec3f(1f, -1f, 0f) : Vec3f(-1f, 1f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b1010: // Diagonale haut-droite / bas-gauche
                            if (checkSubColl(Vec4i(0, 0, 8, 8))) {
                                if ((relativePos.z + relativePos.w) > 8) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(-1f, -1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            else if (checkSubColl(Vec4i(8, 8, 0, 0))) {
                                if ((relativePos.x + relativePos.y) < 24) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(1f, 1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            else {
                                result.isColliding = true;
                                result.normal = (relativePos.x + relativePos.y > 16) ?
                                    Vec3f(1f, 1f, 0f) : Vec3f(-1f, -1f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        default:
                            break;
                        }
                    }
                }
            }

            if (result.isColliding) {
                result.height = (layer.level * 16) + tileZ;

                if (point.z > result.height) {
                    result.isColliding = false;
                    result.normal = Vec3f(0f, 0f, 1f);
                }
                else if (point.z == result.height) {
                    result.isColliding = false;
                    result.isOnGround = true;
                    result.normal = Vec3f(0f, 0f, 1f);
                }
                endResult = result;
                break;
            }
            else {
                endResult.height = result.height;
            }
        }

        if (endResult.normal.lengthSquared() > 0f) {
            endResult.normal.normalize();
        }

        return endResult;
    }

    TerrainHit hitTerrainTopology(Vec3i point, Vec3i collider) {
        point.x -= (collider.x - (collider.x >> 1));
        point.y -= (collider.y - (collider.y >> 1));
        Vec2i coords = Vec2i(((point.x / 16) - (point.x < 0 ? 1 : 0)),
            ((point.y / 16) - (point.y < 0 ? 1 : 0)));

        Vec2i endPoint = point.xy + collider.xy;
        Vec2i endCoords = Vec2i(((endPoint.x / 16) - (endPoint.x < 0 ? 1 : 0)),
            ((endPoint.y / 16) - (endPoint.y < 0 ? 1 : 0)));

        TerrainHit endResult;
        int typeId;

        for (int baseZ = Atelier.world.scene.levels() - 1; baseZ >= -1; --baseZ) {
            TerrainHit result;

            __tilesLoop: for (int y = coords.y; y <= endCoords.y; y++) {
                for (int x = coords.x; x <= endCoords.x; x++) {
                    int minZ = Atelier.world.scene.levels() * 16;
                    int maxZ = -16;
                    int id;
                    int z;

                    static foreach (i, coordOffset; [
                            Vec2i(0, 0), Vec2i(1, 0), Vec2i(1, 1), Vec2i(0, 1),
                        ]) {

                        z = Atelier.world.scene.getLevel(x + coordOffset.x,
                            y + coordOffset.y) * 16;

                        if (z < minZ)
                            minZ = z;

                        if (z > maxZ)
                            maxZ = z;

                        if (z > (baseZ * 16)) {
                            id |= 1 << i;
                        }
                    }

                    if (minZ > result.height) {
                        result.height = minZ;
                    }

                    if (point.z < minZ) {
                        result.isColliding = true;
                        result.normal = Vec3f(0f, 0f, 1f);
                    }
                    else if ((point.z == maxZ) && (maxZ == (baseZ * 16))) {
                        //result.isOnGround = true;
                    }

                    if (point.z <= maxZ) {
                        Vec4i tileBox = Vec4i(x * 16, y * 16, (x + 1) * 16, (y + 1) * 16);
                        Vec4i aabb = Vec4i(point.x, point.y, point.x + collider.x, point.y + collider
                                .y);
                        Vec4i relativePos = aabb;
                        relativePos.x -= tileBox.x;
                        relativePos.y -= tileBox.y;
                        relativePos.z -= tileBox.x;
                        relativePos.w -= tileBox.y;

                        bool checkSubColl(Vec4i offset_) {
                            return (((tileBox.x + offset_.x) < aabb.z) &&
                                    ((tileBox.y + offset_.y) < aabb.w) &&
                                    (tileBox.z > (aabb.x + offset_.z)) &&
                                    (tileBox.w > (aabb.y + offset_.w)));
                        }

                        if (!checkSubColl(Vec4i(0, 0, 0, 0)))
                            continue;

                        typeId = id;

                        switch (id) {
                        case 0b1111: // Zone pleine
                            result.isColliding = true;
                            result.normal = Vec3f(0f, 0f, 1f);
                            break __tilesLoop;
                        case 0b0110: // Coin gauche
                            if (relativePos.z > 8) {
                                result.isColliding = true;
                                result.normal = Vec3f(-1f, 0f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b1001: // Coin droite
                            if (relativePos.x < 8) {
                                result.isColliding = true;
                                result.normal = Vec3f(1f, 0f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b1100: // Coin haut
                            if (relativePos.w > 8) {
                                result.isColliding = true;
                                result.normal = Vec3f(0f, -1f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b0011: // Coin bas
                            if (relativePos.y < 8) {
                                result.isColliding = true;
                                result.normal = Vec3f(0f, 1f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b1110: // Coin 3/4 haut-gauche
                            if (checkSubColl(Vec4i(0, 0, 8, 8))) {
                                if ((relativePos.z + relativePos.w) > 8) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(-1f, -1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            else {
                                result.isColliding = true;
                                result.normal = Vec3f(-1f, -1f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b1011: // Coin 3/4 bas-droite
                            if (checkSubColl(Vec4i(8, 8, 0, 0))) {
                                if ((relativePos.x + relativePos.y) < 24) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(1f, 1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            else {
                                result.isColliding = true;
                                result.normal = Vec3f(1f, 1f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b1101: // Coin 3/4 haut-droite
                            if (checkSubColl(Vec4i(8, 0, 0, 8))) {
                                if ((relativePos.w + 8) > relativePos.x) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(1f, -1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            else {
                                result.isColliding = true;
                                result.normal = Vec3f(1f, -1f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b0111: // Coin 3/4 bas-gauche
                            if (checkSubColl(Vec4i(0, 8, 8, 0))) {
                                if ((relativePos.z + 8) > relativePos.y) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(-1f, 1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            else {
                                result.isColliding = true;
                                result.normal = Vec3f(-1f, 1f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b0100: // Coin 1/4 haut-gauche
                            if (checkSubColl(Vec4i(8, 8, 0, 0))) {
                                if ((relativePos.z + relativePos.w) > 24) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(-1f, -1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            break;
                        case 0b0001: // Coin 1/4 bas-droite
                            if (checkSubColl(Vec4i(0, 0, 8, 8))) {
                                if ((relativePos.x + relativePos.y) < 8) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(1f, 1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            break;
                        case 0b1000: // Coin 1/4 haut-droite
                            if (checkSubColl(Vec4i(0, 8, 8, 0))) {
                                if ((relativePos.w - 8) > relativePos.x) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(1f, -1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            break;
                        case 0b0010: // Coin 1/4 bas-gauche
                            if (checkSubColl(Vec4i(8, 0, 0, 8))) {
                                if ((relativePos.z - 8) > relativePos.y) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(-1f, 1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            break;
                        case 0b0101: // Diagonale haut-gauche / bas-droite
                            if (checkSubColl(Vec4i(8, 0, 0, 8))) {
                                if ((relativePos.w + 8) > relativePos.x) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(1f, -1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            else if (checkSubColl(Vec4i(0, 8, 8, 0))) {
                                if ((relativePos.z + 8) > relativePos.y) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(-1f, 1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            else {
                                result.isColliding = true;
                                result.normal = (relativePos.x > relativePos.y) ?
                                    Vec3f(1f, -1f, 0f) : Vec3f(-1f, 1f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        case 0b1010: // Diagonale haut-droite / bas-gauche
                            if (checkSubColl(Vec4i(0, 0, 8, 8))) {
                                if ((relativePos.z + relativePos.w) > 8) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(-1f, -1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            else if (checkSubColl(Vec4i(8, 8, 0, 0))) {
                                if ((relativePos.x + relativePos.y) < 24) {
                                    result.isColliding = true;
                                    result.normal = Vec3f(1f, 1f, 0f);
                                    break __tilesLoop;
                                }
                            }
                            else {
                                result.isColliding = true;
                                result.normal = (relativePos.x + relativePos.y > 16) ?
                                    Vec3f(1f, 1f, 0f) : Vec3f(-1f, -1f, 0f);
                                break __tilesLoop;
                            }
                            break;
                        default:
                            break;
                        }
                    }
                }
            }

            if (result.isColliding) {
                result.height = (baseZ + 1) * 16;

                if (point.z > result.height) {
                    result.isColliding = false;
                    result.normal = Vec3f(0f, 0f, 1f);
                }
                else if (point.z == result.height) {
                    result.isColliding = false;
                    result.isOnGround = true;
                    result.normal = Vec3f(0f, 0f, 1f);
                }
                endResult = result;
                break;
            }
            else {
                endResult.height = result.height;
            }
        }

        if (_isBounded) {
            Vec4i coll = Vec4i(point.xy, endPoint);
            Vec2i mapSize = Vec2i(Atelier.world.scene.columns, Atelier.world.scene.lines) << 4;

            if (coll.x < 0 && coll.y < 0) {
                endResult.isColliding = true;
                endResult.normal = Vec3f(1f, 1f, 0f);
            }
            else if (coll.x < 0) {
                endResult.isColliding = true;
                endResult.normal = Vec3f(1f, 0f, 0f);
            }
            else if (coll.y < 0) {
                endResult.isColliding = true;
                endResult.normal = Vec3f(0f, 1f, 0f);
            }
            else if (coll.z > mapSize.x && coll.w > mapSize.y) {
                endResult.isColliding = true;
                endResult.normal = Vec3f(-1f, -1f, 0f);
            }
            else if (coll.z > mapSize.x) {
                endResult.isColliding = true;
                endResult.normal = Vec3f(-1f, 0f, 0f);
            }
            else if (coll.w > mapSize.y) {
                endResult.isColliding = true;
                endResult.normal = Vec3f(0f, -1f, 0f);
            }
            else if (_hasCustomBounds) {
                if (coll.x < _customBounds.x && coll.y < _customBounds.y) {
                    endResult.isColliding = true;
                    endResult.normal = Vec3f(1f, 1f, 0f);
                }
                else if (coll.x < _customBounds.x) {
                    endResult.isColliding = true;
                    endResult.normal = Vec3f(1f, 0f, 0f);
                }
                else if (coll.y < _customBounds.y) {
                    endResult.isColliding = true;
                    endResult.normal = Vec3f(0f, 1f, 0f);
                }
                else if (coll.z > _customBounds.z && coll.w > _customBounds.w) {
                    endResult.isColliding = true;
                    endResult.normal = Vec3f(-1f, -1f, 0f);
                }
                else if (coll.z > _customBounds.z) {
                    endResult.isColliding = true;
                    endResult.normal = Vec3f(-1f, 0f, 0f);
                }
                else if (coll.w > _customBounds.w) {
                    endResult.isColliding = true;
                    endResult.normal = Vec3f(0f, -1f, 0f);
                }
            }
        }

        if (endResult.normal.lengthSquared() > 0f) {
            endResult.normal.normalize();
        }

        return endResult;
    }

    Array!ActorCollider getAllActors() {
        return _actors;
    }

    Array!SolidCollider getAllSolids() {
        return _solids;
    }

    Array!ShotCollider getAllShots() {
        return _shots;
    }

    Array!TriggerCollider getAllTriggers() {
        return _triggers;
    }

    Array!Hitbox getAllHitboxes(uint layer) {
        enforce(layer < _hitboxLayers.length, "Le calque de collision " ~ to!string(
                layer) ~ " dépasse la limite");

        return _hitboxLayersInternal[layer].hitboxes;
    }

    void showActors(bool show) {
        if (show == _showActors)
            return;

        _showActors = show;
        foreach (actor; _actors) {
            actor.isDisplayed = _showActors;
        }
    }

    void showSolids(bool show) {
        if (show == _showSolids)
            return;

        _showSolids = show;
        foreach (solid; _solids) {
            solid.isDisplayed = _showSolids;
        }
    }

    void showShots(bool show) {
        if (show == _showShots)
            return;

        _showShots = show;
        foreach (shot; _shots) {
            shot.isDisplayed = _showShots;
        }
    }

    void showTriggers(bool show) {
        if (show == _showTriggers)
            return;

        _showTriggers = show;
        foreach (trigger; _triggers) {
            trigger.isDisplayed = _showTriggers;
        }
    }

    void showHitboxes(bool show) {
        if (show == _showHitboxes)
            return;

        _showHitboxes = show;
        for (uint i; i < 32; ++i) {
            foreach (hitbox; _hitboxLayersInternal[i].hitboxes) {
                hitbox.isDisplayed = _showHitboxes;
            }
        }
    }

    struct SolidUnderHit {
        bool isUnder;
        SolidCollider solid;
        int baseZ = -16;
    }

    SolidUnderHit getSolidUnder(ActorCollider actor) {
        SolidUnderHit hit;

        foreach (solid; _solids) {
            int baseZ = solid.getBaseZ(actor);
            if (!hit.isUnder) {
                hit.isUnder = true;
                hit.baseZ = baseZ;
                hit.solid = solid;
            }
            else if (baseZ > hit.baseZ) {
                hit.baseZ = baseZ;
                hit.solid = solid;
            }
        }
        return hit;
    }

    SolidUnderHit getSolidUnder(Vec3i position) {
        SolidUnderHit hit;

        foreach (solid; _solids) {
            int baseZ = solid.getBaseZ(position);
            if (!hit.isUnder) {
                hit.isUnder = true;
                hit.baseZ = baseZ;
                hit.solid = solid;
            }
            else if (baseZ > hit.baseZ) {
                hit.baseZ = baseZ;
                hit.solid = solid;
            }
        }
        return hit;
    }

    void draw(Vec2f offset) {
        if (_showActors) {
            foreach (actor; _actors) {
                if (actor.entity.isInRenderList())
                    continue;

                actor.drawBack(offset + actor.entity.cameraPosition());
                actor.drawFront(offset + actor.entity.cameraPosition());
            }
        }
        if (_showSolids) {
            foreach (solid; _solids) {
                if (solid.entity.isInRenderList())
                    continue;

                solid.drawBack(offset + solid.entity.cameraPosition());
                solid.drawFront(offset + solid.entity.cameraPosition());
            }
        }
        if (_showShots) {
            foreach (shot; _shots) {
                if (shot.entity.isInRenderList())
                    continue;

                shot.drawBack(offset + shot.entity.cameraPosition());
                shot.drawFront(offset + shot.entity.cameraPosition());
            }
        }
        if (_showTriggers) {
            foreach (trigger; _triggers) {
                if (trigger.entity.isInRenderList())
                    continue;

                trigger.drawBack(offset + trigger.entity.cameraPosition());
                trigger.drawFront(offset + trigger.entity.cameraPosition());
            }
        }
        if (_showHitboxes) {
            for (uint i; i < 32; ++i) {
                foreach (hitbox; _hitboxLayersInternal[i].hitboxes) {
                    if (hitbox.entity.isInRenderList())
                        continue;

                    hitbox.draw(offset + hitbox.entity.cameraPosition());
                }
            }
        }
    }
}
