module atelier.physics.system;

import atelier.common;
import atelier.core;
import atelier.world;
import atelier.physics.collider;
import atelier.physics.actor;
import atelier.physics.solid;
import atelier.physics.shot;
import atelier.physics.trigger;
import atelier.physics.hurt;

final class Physics {
    private {
        Array!ActorCollider _actors;
        Array!SolidCollider _solids;
        Array!ShotCollider _shots;
        Array!TriggerCollider _triggers;
        Array!Hurtbox _playerImpactHurtboxes, _playerTargetHurtboxes;
        Array!Hurtbox _enemyImpactHurtboxes, _enemyTargetHurtboxes;
        Array!Hurtbox _globalImpactHurtboxes, _globalTargetHurtboxes;
        bool _hasColliderToRemove;
        bool _hasHurtboxToRemove;
        bool _areTriggersActive;
        bool _isBounded;
        Vec4i _combatBounds;
        bool _hasCombatBounds;

        // Affichage des collisions
        bool _showActors;
        bool _showSolids;
        bool _showShots;
        bool _showTriggers;
        bool _showPlayerImpactHurtboxes;
        bool _showPlayerTargetHurtboxes;
        bool _showEnemyImpactHurtboxes;
        bool _showEnemyTargetHurtboxes;
        bool _showGlobalImpactHurtboxes;
        bool _showGlobalTargetHurtboxes;
    }

    @property {
        bool hasCombatBounds() const {
            return _hasCombatBounds;
        }

        Vec4i combatBounds() const {
            return _combatBounds;
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
    }

    struct SolidHit {
        bool isColliding = false;
        SolidCollider solid;
        int baseZ = -16;
    }

    struct HurtboxHit {
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
        _playerImpactHurtboxes = new Array!Hurtbox;
        _playerTargetHurtboxes = new Array!Hurtbox;
        _enemyImpactHurtboxes = new Array!Hurtbox;
        _enemyTargetHurtboxes = new Array!Hurtbox;
        _globalImpactHurtboxes = new Array!Hurtbox;
        _globalTargetHurtboxes = new Array!Hurtbox;
    }

    void clear() {
        _actors.clear();
        _solids.clear();
        _shots.clear();
        _triggers.clear();
        _playerImpactHurtboxes.clear();
        _playerTargetHurtboxes.clear();
        _enemyImpactHurtboxes.clear();
        _enemyTargetHurtboxes.clear();
        _globalImpactHurtboxes.clear();
        _globalTargetHurtboxes.clear();
    }

    void setTriggersActive(bool value) {
        _areTriggersActive = value;
    }

    void setBounds(bool value) {
        _isBounded = value;
    }

    void setCombatBounds(Vec4i bounds) {
        _combatBounds = bounds;
        _hasCombatBounds = true;
    }

    void unsetCombatBounds() {
        _hasCombatBounds = false;
    }

    void update() {
        if (_hasColliderToRemove) {
            _hasColliderToRemove = false;

            // À faire: la boucle ne sert qu’à vérifier l’existance des hurtbox.
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
        }

        foreach (i, actor; _actors) {
            if (!actor.isRegistered) {
                _actors.mark(i);
            }
        }
        _actors.sweep();

        if (Atelier.world.player) {
            ActorCollider player = Atelier.world.player.getCollider();
            if (player) {
                foreach (i, trigger; _triggers) {
                    if (!trigger.isRegistered) {
                        _triggers.mark(i);
                    }
                    else if (_areTriggersActive && trigger.isActive) {
                        ActorHit hit = player.collidesWith(trigger.entity.getPosition(), trigger
                                .hitbox);
                        if (hit.isColliding) {
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

        if (_hasHurtboxToRemove) {
            // À faire: la boucle ne sert qu’à vérifier l’existance des hurtbox.
            // -> Trouver un autre endroit où le faire
            _hasHurtboxToRemove = false;

            foreach (i, target; _globalTargetHurtboxes) {
                if (!target.isRegistered) {
                    _globalTargetHurtboxes.mark(i);
                }
            }
            _globalTargetHurtboxes.sweep();

            foreach (i, target; _enemyTargetHurtboxes) {
                if (!target.isRegistered) {
                    _enemyTargetHurtboxes.mark(i);
                }
            }
            _enemyTargetHurtboxes.sweep();

            foreach (i, target; _playerTargetHurtboxes) {
                if (!target.isRegistered) {
                    _playerTargetHurtboxes.mark(i);
                }
            }
            _playerTargetHurtboxes.sweep();
        }

        __enemyImpactHurboxesLoop: foreach (i, impact; _enemyImpactHurtboxes) {
            if (!impact.isRegistered) {
                _enemyImpactHurtboxes.mark(i);
                continue __enemyImpactHurboxesLoop;
            }

            foreach (y, target; _globalTargetHurtboxes) {
                HurtboxHit hurtboxHit = impact.collidesWith(target);
                if (hurtboxHit.isColliding) {
                    CollisionHit hit;
                    hit.type = CollisionHit.Type.impact;
                    hit.normal = hurtboxHit.normal;
                    hit.entity = impact.entity;
                    target.entity.onCollide(hit);
                    hit.normal = -hurtboxHit.normal;
                    hit.entity = target.entity;
                    impact.entity.onCollide(hit);
                    _enemyImpactHurtboxes.mark(i);
                    continue __enemyImpactHurboxesLoop;
                }
            }

            foreach (y, target; _playerTargetHurtboxes) {
                HurtboxHit hurtboxHit = impact.collidesWith(target);
                if (hurtboxHit.isColliding) {
                    CollisionHit hit;
                    hit.type = CollisionHit.Type.impact;
                    hit.normal = hurtboxHit.normal;
                    hit.entity = impact.entity;
                    target.entity.onCollide(hit);
                    hit.normal = -hurtboxHit.normal;
                    hit.entity = target.entity;
                    impact.entity.onCollide(hit);
                    _enemyImpactHurtboxes.mark(i);
                    continue __enemyImpactHurboxesLoop;
                }
            }
        }
        _enemyImpactHurtboxes.sweep();

        __playerImpactHurboxesLoop: foreach (i, impact; _playerImpactHurtboxes) {
            foreach (y, target; _globalTargetHurtboxes) {
                if (!impact.isRegistered) {
                    _playerImpactHurtboxes.mark(i);
                    continue __playerImpactHurboxesLoop;
                }

                HurtboxHit hurtboxHit = impact.collidesWith(target);
                if (hurtboxHit.isColliding) {
                    CollisionHit hit;
                    hit.type = CollisionHit.Type.impact;
                    hit.normal = hurtboxHit.normal;
                    hit.entity = impact.entity;
                    target.entity.onCollide(hit);
                    hit.normal = -hurtboxHit.normal;
                    hit.entity = target.entity;
                    impact.entity.onCollide(hit);
                    _enemyImpactHurtboxes.mark(i);
                    continue __playerImpactHurboxesLoop;
                }
            }

            foreach (y, target; _enemyTargetHurtboxes) {
                HurtboxHit hurtboxHit = impact.collidesWith(target);
                if (hurtboxHit.isColliding) {
                    CollisionHit hit;
                    hit.type = CollisionHit.Type.impact;
                    hit.normal = hurtboxHit.normal;
                    hit.entity = impact.entity;
                    target.entity.onCollide(hit);
                    hit.normal = -hurtboxHit.normal;
                    hit.entity = target.entity;
                    impact.entity.onCollide(hit);
                    _playerImpactHurtboxes.mark(i);
                    continue __playerImpactHurboxesLoop;
                }
            }
        }
        _playerImpactHurtboxes.sweep();

        __globalImpactHurboxesLoop: foreach (i, impact; _globalImpactHurtboxes) {
            if (!impact.isRegistered) {
                _enemyImpactHurtboxes.mark(i);
                continue __globalImpactHurboxesLoop;
            }

            /*foreach (y, target; _globalTargetHurtboxes) {
                HurtboxHit hurtboxHit = impact.collidesWith(target);
                if (hurtboxHit.isColliding) {
                    CollisionHit hit;
                    hit.type = CollisionHit.Type.impact;
                    hit.normal = hurtboxHit.normal;
                    hit.entity = impact.entity;
                    target.entity.onCollide(hit);
                    hit.normal = -hurtboxHit.normal;
                    hit.entity = target.entity;
                    impact.entity.onCollide(hit);
                    _enemyImpactHurtboxes.mark(i);
                    continue __globalImpactHurboxesLoop;
                }
            }*/

            foreach (y, target; _enemyTargetHurtboxes) {
                HurtboxHit hurtboxHit = impact.collidesWith(target);
                if (hurtboxHit.isColliding) {
                    CollisionHit hit;
                    hit.type = CollisionHit.Type.impact;
                    hit.normal = hurtboxHit.normal;
                    hit.entity = impact.entity;
                    target.entity.onCollide(hit);
                    hit.normal = -hurtboxHit.normal;
                    hit.entity = target.entity;
                    impact.entity.onCollide(hit);
                    _globalImpactHurtboxes.mark(i);
                    continue __globalImpactHurboxesLoop;
                }
            }

            foreach (y, target; _playerTargetHurtboxes) {
                HurtboxHit hurtboxHit = impact.collidesWith(target);
                if (hurtboxHit.isColliding) {
                    CollisionHit hit;
                    hit.type = CollisionHit.Type.impact;
                    hit.normal = hurtboxHit.normal;
                    hit.entity = impact.entity;
                    target.entity.onCollide(hit);
                    hit.normal = -hurtboxHit.normal;
                    hit.entity = target.entity;
                    impact.entity.onCollide(hit);
                    _globalImpactHurtboxes.mark(i);
                    continue __globalImpactHurboxesLoop;
                }
            }
        }
        _globalImpactHurtboxes.sweep();
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

    void addHurtbox(Hurtbox hurtbox) {
        final switch (hurtbox.faction) with (Hurtbox.Faction) {
        case allied:
            if (hurtbox.type == Hurtbox.Type.target || hurtbox.type == Hurtbox.Type.both) {
                _playerTargetHurtboxes ~= hurtbox;
                hurtbox.isRegistered = true;
                hurtbox.isDisplayed = _showPlayerTargetHurtboxes;
            }
            if (hurtbox.type == Hurtbox.Type.projectile || hurtbox.type == Hurtbox.Type.both) {
                _playerImpactHurtboxes ~= hurtbox;
                hurtbox.isRegistered = true;
                hurtbox.isDisplayed = _showPlayerImpactHurtboxes;
            }
            break;
        case enemy:
            if (hurtbox.type == Hurtbox.Type.target || hurtbox.type == Hurtbox.Type.both) {
                _enemyTargetHurtboxes ~= hurtbox;
                hurtbox.isRegistered = true;
                hurtbox.isDisplayed = _showEnemyTargetHurtboxes;
            }
            if (hurtbox.type == Hurtbox.Type.projectile || hurtbox.type == Hurtbox.Type.both) {
                _enemyImpactHurtboxes ~= hurtbox;
                hurtbox.isRegistered = true;
                hurtbox.isDisplayed = _showEnemyImpactHurtboxes;
            }
            break;
        case neutral:
            if (hurtbox.type == Hurtbox.Type.target || hurtbox.type == Hurtbox.Type.both) {
                _globalTargetHurtboxes ~= hurtbox;
                hurtbox.isRegistered = true;
                hurtbox.isDisplayed = _showGlobalTargetHurtboxes;
            }
            if (hurtbox.type == Hurtbox.Type.projectile || hurtbox.type == Hurtbox.Type.both) {
                _globalImpactHurtboxes ~= hurtbox;
                hurtbox.isRegistered = true;
                hurtbox.isDisplayed = _showGlobalImpactHurtboxes;
            }
            break;
        }
    }

    void removeHurtbox(Hurtbox hurtbox) {
        if (hurtbox.isRegistered) {
            _hasHurtboxToRemove = true;
            hurtbox.isRegistered = false;
        }
    }

    /// Est-ce qu’on chevauche un solide ?
    SolidHit collidesAt(Vec3i point, Vec3i hitbox) {
        SolidHit hit;
        foreach (SolidCollider solid; _solids) {
            hit = solid.collidesWith(point, hitbox);
            if (hit.isColliding) {
                break;
            }
        }

        return hit;
    }

    TerrainHit hitTileTerrain(Vec3i tile, Vec3i hitbox) {
        TerrainHit hit;
        hit.height = 0;
        return hit;
    }

    TerrainHit hitTerrain(Vec3i point, Vec3i hitbox) {
        TerrainHit hitTopology = hitTerrainTopology(point, hitbox);
        if (hitTopology.isColliding)
            return hitTopology;
        TerrainHit hitCollisionLayer = hitTerrainCollisionLayers(point, hitbox);
        if (hitTopology.height > hitCollisionLayer.height)
            return hitTopology;
        return hitCollisionLayer;
    }

    TerrainHit hitTerrainCollisionLayers(Vec3i point, Vec3i hitbox) {
        point.x -= (hitbox.x - (hitbox.x >> 1));
        point.y -= (hitbox.y - (hitbox.y >> 1));
        Vec3i coords = Vec3i(((point.x / 16) - (point.x < 0 ? 1 : 0)),
            ((point.y / 16) - (point.y < 0 ? 1 : 0)),
            ((point.z / 16) - (point.z < 0 ? 1 : 0)));

        Vec3i endPoint = point + hitbox;
        Vec3i endCoords = Vec3i(((endPoint.x / 16) - (endPoint.x < 0 ? 1 : 0)),
            ((endPoint.y / 16) - (endPoint.y < 0 ? 1 : 0)),
            ((endPoint.z / 16) - (endPoint.z < 0 ? 1 : 0)));

        TerrainHit endResult;
        TerrainHit result;

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
                        point.x + hitbox.x,
                        point.y + hitbox.y);

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

            if (result.isColliding) {
                result.height = (layer.level + 1) * 16;

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

    TerrainHit hitTerrainTopology(Vec3i point, Vec3i hitbox) {
        point.x -= (hitbox.x - (hitbox.x >> 1));
        point.y -= (hitbox.y - (hitbox.y >> 1));
        Vec2i coords = Vec2i(((point.x / 16) - (point.x < 0 ? 1 : 0)),
            ((point.y / 16) - (point.y < 0 ? 1 : 0)));

        Vec2i endPoint = point.xy + hitbox.xy;
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
                        Vec4i aabb = Vec4i(point.x, point.y, point.x + hitbox.x, point.y + hitbox.y);
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
            else if (_hasCombatBounds) {
                if (coll.x < _combatBounds.x && coll.y < _combatBounds.y) {
                    endResult.isColliding = true;
                    endResult.normal = Vec3f(1f, 1f, 0f);
                }
                else if (coll.x < _combatBounds.x) {
                    endResult.isColliding = true;
                    endResult.normal = Vec3f(1f, 0f, 0f);
                }
                else if (coll.y < _combatBounds.y) {
                    endResult.isColliding = true;
                    endResult.normal = Vec3f(0f, 1f, 0f);
                }
                else if (coll.z > _combatBounds.z && coll.w > _combatBounds.w) {
                    endResult.isColliding = true;
                    endResult.normal = Vec3f(-1f, -1f, 0f);
                }
                else if (coll.z > _combatBounds.z) {
                    endResult.isColliding = true;
                    endResult.normal = Vec3f(-1f, 0f, 0f);
                }
                else if (coll.w > _combatBounds.w) {
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

    Array!Hurtbox getAllPlayerImpactHurtboxes() {
        return _playerImpactHurtboxes;
    }

    Array!Hurtbox getAllPlayerTargetHurtboxes() {
        return _playerTargetHurtboxes;
    }

    Array!Hurtbox getAllEnemyImpactHurtboxes() {
        return _enemyImpactHurtboxes;
    }

    Array!Hurtbox getAllEnemyTargetHurtboxes() {
        return _enemyTargetHurtboxes;
    }

    Array!Hurtbox getAllGlobalImpactHurtboxes() {
        return _globalImpactHurtboxes;
    }

    Array!Hurtbox getAllGlobalTargetHurtboxes() {
        return _globalTargetHurtboxes;
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

    void showPlayerImpactHurtboxes(bool show) {
        if (show == _showPlayerImpactHurtboxes)
            return;

        _showPlayerImpactHurtboxes = show;
        foreach (impact; _playerImpactHurtboxes) {
            impact.isDisplayed = _showPlayerImpactHurtboxes;
        }
    }

    void showPlayerTargetHurtboxes(bool show) {
        if (show == _showPlayerTargetHurtboxes)
            return;

        _showPlayerTargetHurtboxes = show;
        foreach (target; _playerTargetHurtboxes) {
            target.isDisplayed = _showPlayerTargetHurtboxes;
        }
    }

    void showEnemyImpactHurtboxes(bool show) {
        if (show == _showEnemyImpactHurtboxes)
            return;

        _showEnemyImpactHurtboxes = show;
        foreach (impact; _enemyImpactHurtboxes) {
            impact.isDisplayed = _showEnemyImpactHurtboxes;
        }
    }

    void showEnemyTargetHurtboxes(bool show) {
        if (show == _showEnemyTargetHurtboxes)
            return;

        _showEnemyTargetHurtboxes = show;
        foreach (target; _enemyTargetHurtboxes) {
            target.isDisplayed = _showEnemyTargetHurtboxes;
        }
    }

    void showGlobalImpactHurtboxes(bool show) {
        if (show == _showGlobalImpactHurtboxes)
            return;

        _showGlobalImpactHurtboxes = show;
        foreach (impact; _globalImpactHurtboxes) {
            impact.isDisplayed = _showGlobalImpactHurtboxes;
        }
    }

    void showGlobalTargetHurtboxes(bool show) {
        if (show == _showGlobalTargetHurtboxes)
            return;

        _showGlobalTargetHurtboxes = show;
        foreach (target; _globalTargetHurtboxes) {
            target.isDisplayed = _showGlobalTargetHurtboxes;
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
}
