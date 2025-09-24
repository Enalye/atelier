module atelier.physics.hurt;

import std.conv : to;
import std.math;
import farfadet;
import atelier.common;
import atelier.core;
import atelier.world.entity;
import atelier.physics.system;

struct HurtboxData {
    string faction = "none";
    string type = "none";
    uint minRadius, maxRadius;
    uint height;
    int angle, angleDelta;
    int offsetDist, offsetAngle;

    void load(Farfadet ffd) {
        if (ffd.hasNode("faction")) {
            faction = ffd.getNode("faction").get!string(0);
        }
        else {
            faction = "none";
        }

        if (ffd.hasNode("type")) {
            type = ffd.getNode("type").get!string(0);
        }
        else {
            type = "none";
        }

        if (ffd.hasNode("minRadius")) {
            minRadius = ffd.getNode("minRadius").get!uint(0);
        }

        if (ffd.hasNode("maxRadius")) {
            maxRadius = ffd.getNode("maxRadius").get!uint(0);
        }

        if (ffd.hasNode("height")) {
            height = ffd.getNode("height").get!uint(0);
        }

        if (ffd.hasNode("angle")) {
            angle = ffd.getNode("angle").get!int(0);
        }

        if (ffd.hasNode("angleDelta")) {
            angleDelta = ffd.getNode("angleDelta").get!int(0);
        }

        if (ffd.hasNode("offsetDist")) {
            offsetDist = ffd.getNode("offsetDist").get!int(0);
        }

        if (ffd.hasNode("offsetAngle")) {
            offsetAngle = ffd.getNode("offsetAngle").get!int(0);
        }
    }

    void save(Farfadet ffd) {
        Farfadet node = ffd.addNode("hurtbox");
        if (faction != "none" && type != "none") {
            node.addNode("type").add(type);
            node.addNode("minRadius").add(minRadius);
            node.addNode("maxRadius").add(maxRadius);
            node.addNode("height").add(height);
            node.addNode("angle").add(angle);
            node.addNode("angleDelta").add(angleDelta);
            node.addNode("offsetDist").add(offsetDist);
            node.addNode("offsetAngle").add(offsetAngle);
        }
    }

    void serialize(OutStream stream) {
        bool hasValue = faction != "none" && type != "none";
        stream.write!bool(hasValue);
        if (hasValue) {
            stream.write!string(faction);
            stream.write!string(type);
            stream.write!uint(minRadius);
            stream.write!uint(maxRadius);
            stream.write!uint(height);
            stream.write!uint(angle);
            stream.write!uint(angleDelta);
            stream.write!uint(offsetDist);
            stream.write!uint(offsetAngle);
        }
    }

    void deserialize(InStream stream) {
        if (stream.read!bool()) {
            faction = stream.read!string();
            type = stream.read!string();
            minRadius = stream.read!uint();
            maxRadius = stream.read!uint();
            height = stream.read!uint();
            angle = stream.read!uint();
            angleDelta = stream.read!uint();
            offsetDist = stream.read!uint();
            offsetAngle = stream.read!uint();
        }
    }
}

final class Hurtbox {
    enum Faction {
        neutral,
        allied,
        enemy
    }

    enum Type {
        target,
        projectile,
        both
    }

    private {
        bool _isRegistered = true;
        Entity _entity;
        uint _minRadius, _maxRadius;
        uint _height;
        int _angle, _angleDelta;
        int _offsetDist, _offsetAngle;
        Faction _faction;
        Type _type;
        bool _isDisplayed;
        bool _isCollidable = true;
    }

    @property {
        bool isRegistered() const {
            return _isRegistered;
        }

        package bool isRegistered(bool value) {
            return _isRegistered = value;
        }

        Entity entity() {
            return _entity;
        }

        uint radius() const {
            return _maxRadius;
        }

        Faction faction() const {
            return _faction;
        }

        Type type() const {
            return _type;
        }

        bool isDisplayed() const {
            return _isDisplayed;
        }

        bool isDisplayed(bool isDisplayed_) {
            return _isDisplayed = isDisplayed_;
        }

        bool isCollidable() const {
            return _isCollidable;
        }

        bool isCollidable(bool isCollidable_) {
            return _isCollidable = isCollidable_;
        }
    }

    this(Entity entity_, HurtboxData data) {
        _entity = entity_;
        _minRadius = data.minRadius;
        _maxRadius = data.maxRadius;
        _height = data.height;
        _angle = data.angle;
        _angleDelta = data.angleDelta;
        _offsetDist = data.offsetDist;
        _offsetAngle = data.offsetAngle;

        try {
            _faction = to!Faction(data.faction);
        }
        catch (Exception e) {
            Atelier.log(data.type, " n’est pas un type de hurtbox valide");
        }

        try {
            _type = to!Type(data.type);
        }
        catch (Exception e) {
            Atelier.log(data.type, " n’est pas un type de hurtbox valide");
        }
    }

    this(Hurtbox other) {
        _entity = other._entity;
        _faction = other._faction;
        _type = other._type;
        _minRadius = other._minRadius;
        _maxRadius = other._maxRadius;
        _height = other._height;
        _angle = other._angle;
        _angleDelta = other._angleDelta;
        _offsetDist = other._offsetDist;
        _offsetAngle = other._offsetAngle;
    }

    void setEntity(Entity entity_) {
        _entity = entity_;
    }

    void register() {
        Atelier.physics.addHurtbox(this);
    }

    void unregister() {
        Atelier.physics.removeHurtbox(this);
    }

    float getAngle() const {
        return _angle + _entity.angle;
    }

    Vec2f getCameraCenter() const {
        Vec2f cameraCenter = cast(Vec2f) getPosition().proj2D();
        cameraCenter.y -= _height / 2f;
        return cameraCenter;
    }

    Vec3i getPosition() const {
        Vec3i basePosition = _entity.getPosition();
        if (_offsetDist) {
            Vec2i offset = cast(Vec2i)(Vec2f.angled(
                    degToRad(_entity.angle + cast(float) _offsetAngle)) * _offsetDist).round();
            basePosition.x += offset.x;
            basePosition.y += offset.y;
        }
        return Vec3i(basePosition.x, basePosition.y, basePosition.z);
    }

    private bool _checkSegment(Vec2f center, float maxRadius, Vec2f startPoint, Vec2f endPoint) const {
        Vec2f d = endPoint - startPoint;
        Vec2f f = startPoint - center;
        float r = maxRadius;

        float a = d.dot(d);
        float b = 2f * f.dot(d);
        float c = f.dot(f) - r * r;

        float disc = b * b - 4f * a * c;

        if (disc < 0f)
            return false;

        disc = sqrt(disc);
        float t1 = (-b - disc) / (2f * a);
        float t2 = (-b + disc) / (2f * a);

        if (t1 >= 0f && t1 <= 1f) {
            Vec2f tp1 = startPoint + t1 * d;
            Vec2f v1 = tp1 - center;
            float d1sq = v1.lengthSquared();
            if (d1sq <= (maxRadius * maxRadius)) {
                return true;
            }
        }

        if (t2 >= 0f && t2 <= 1f) {
            Vec2f tp2 = startPoint + t2 * d;
            Vec2f v2 = tp2 - center;
            float d2sq = v2.lengthSquared();
            if (d2sq <= (maxRadius * maxRadius)) {
                return true;
            }
        }

        return false;
    }

    private bool _checkSegment(Vec2f center, float angle, float angleDelta, float minRadius, float maxRadius, Vec2f startPoint, Vec2f endPoint) const {
        Vec2f d = endPoint - startPoint;
        Vec2f f = startPoint - center;
        float r = maxRadius;

        float a = d.dot(d);
        float b = 2f * f.dot(d);
        float c = f.dot(f) - r * r;

        float disc = b * b - 4f * a * c;

        if (disc < 0f)
            return false;

        disc = sqrt(disc);
        float t1 = (-b - disc) / (2f * a);
        float t2 = (-b + disc) / (2f * a);

        if (t1 >= 0f && t1 <= 1f) {
            Vec2f tp1 = startPoint + t1 * d;
            Vec2f v1 = tp1 - center;
            float d1sq = v1.lengthSquared();
            if (d1sq >= (minRadius * minRadius) && d1sq <= (maxRadius * maxRadius)) {
                float v1a = v1.angle();
                if (angleBetweenDeg(angle, v1a) <= angleDelta) {
                    return true;
                }
            }
        }

        if (t2 >= 0f && t2 <= 1f) {
            Vec2f tp2 = startPoint + t2 * d;
            Vec2f v2 = tp2 - center;
            float d2sq = v2.lengthSquared();
            if (d2sq >= (minRadius * minRadius) && d2sq <= (maxRadius * maxRadius)) {
                float v2a = v2.angle();
                if (angleBetweenDeg(angle, v2a) <= angleDelta) {
                    return true;
                }
            }
        }

        return false;
    }

    Physics.HurtboxHit collidesWith(Hurtbox other) const {
        Physics.HurtboxHit hit;

        if (!_isCollidable || !other._isCollidable)
            return hit;

        Vec3i posAi = getPosition();
        Vec3i posBi = other.getPosition();
        Vec2f posA = cast(Vec2f) posAi.xy;
        Vec2f posB = cast(Vec2f) posBi.xy;
        float distAB = posA.distanceSquared(posB);
        uint maxRadiusAB = _maxRadius + other._maxRadius;
        float angleA = getAngle();
        float angleB = other.getAngle();

        // On exclut les cercles externes disjoints
        if (distAB > (maxRadiusAB * maxRadiusAB))
            return hit;

        // On exclut les désalignements en Z
        if ((posAi.z > (posBi.z + other._height)) ||
            (posBi.z > (posAi.z + _height)))
            return hit;

        // On exclut les cercles externes inscrits dans les cercles internes
        if (((distAB + (other._maxRadius * other._maxRadius)) < _minRadius * _minRadius) ||
            ((distAB + (_maxRadius * _maxRadius)) < other._minRadius * other._minRadius))
            return hit;

        hit.normal = (cast(Vec3f)(posBi - posAi)).normalized();

        bool hasAnglesA = (_angleDelta > 0 && _angleDelta < 180);
        bool hasAnglesB = (other._angleDelta > 0 && other._angleDelta < 180);

        // Si les deux cercles sont complets, il y a collision
        if (!hasAnglesA && !hasAnglesB) {
            hit.isColliding = true;
            return hit;
        }

        float minAngleA = angleA - _angleDelta;
        float maxAngleA = angleA + _angleDelta;
        float minAngleB = angleB - other._angleDelta;
        float maxAngleB = angleB + other._angleDelta;

        // Un des deux cercles est complet
        // Il suffit que l’axe AB soit dans la section du cercle
        if (hasAnglesA && !hasAnglesB) {
            float angle = radToDeg((posB - posA).angle());
            if (angleBetweenDeg(angleA, angle) <= _angleDelta) {
                hit.isColliding = true;
            }
            else {
                // Il y a collision si un point des segments formé par les bords de la section A
                // est inscrit dans le cercle B ou si au moins un des points est différent
                // des autres sur sa position interne/externe au cercle B
                Vec2f pMinStartA = posA + Vec2f.angled(degToRad(minAngleA)) * _minRadius;
                Vec2f pMinEndA = posA + Vec2f.angled(degToRad(minAngleA)) * _maxRadius;
                Vec2f pMaxStartA = posA + Vec2f.angled(degToRad(maxAngleA)) * _minRadius;
                Vec2f pMaxEndA = posA + Vec2f.angled(degToRad(maxAngleA)) * _maxRadius;

                float distMinStartSq = pMinStartA.distanceSquared(posB);
                float distMinEndSq = pMinEndA.distanceSquared(posB);
                float distMaxStartSq = pMaxStartA.distanceSquared(posB);
                float distMaxEndSq = pMaxEndA.distanceSquared(posB);

                float minRadiusBSq = other._minRadius * other._minRadius;
                float maxRadiusBSq = other._maxRadius * other._maxRadius;

                int isInsideMinStartA = distMinStartSq > maxRadiusBSq ? 1 : ( //
                    distMinStartSq < minRadiusBSq ? -1 : 0); //
                int isInsideMinEndA = distMinEndSq > maxRadiusBSq ? 1 : ( //
                    distMinEndSq < minRadiusBSq ? -1 : 0); //
                int isInsideMaxStartA = distMaxStartSq > maxRadiusBSq ? 1 : ( //
                    distMaxStartSq < minRadiusBSq ? -1 : 0); //
                int isInsideMaxEndA = distMaxEndSq > maxRadiusBSq ? 1 : ( //
                    distMaxEndSq < minRadiusBSq ? -1 : 0); //

                int totalInside = isInsideMinStartA + isInsideMinEndA + isInsideMaxStartA + isInsideMaxEndA;

                if ((isInsideMinStartA == 0) || (isInsideMinEndA == 0) || (isInsideMaxStartA == 0) || (
                        isInsideMaxEndA == 0) || ((
                        totalInside != 4) && (totalInside != -4))) {
                    hit.isColliding = true;
                }
                else if (totalInside == 4) {
                    // Si tous les points sont externes, le bord du cercle B peut quand même toucher la section A
                    if (_checkSegment(posB, other._maxRadius, pMinStartA, pMinEndA)) {
                        hit.isColliding = true;
                    }
                    else if (_checkSegment(posB, other._maxRadius, pMaxStartA, pMaxEndA)) {
                        hit.isColliding = true;
                    }
                }
            }
            return hit;
        }
        else if (!hasAnglesA && hasAnglesB) {
            float angle = radToDeg((posA - posB).angle());
            if (angleBetweenDeg(angleB, angle) <= other._angleDelta) {
                hit.isColliding = true;
            }
            else {
                // Il y a collision si un point des segments formé par les bords de la section B
                // est inscrit dans le cercle A ou si au moins un des points est différent
                // des autres sur sa position interne/externe au cercle B
                Vec2f pMinStartB = posB + Vec2f.angled(degToRad(minAngleB)) * other._minRadius;
                Vec2f pMinEndB = posB + Vec2f.angled(degToRad(minAngleB)) * other._maxRadius;
                Vec2f pMaxStartB = posB + Vec2f.angled(degToRad(maxAngleB)) * other._minRadius;
                Vec2f pMaxEndB = posB + Vec2f.angled(degToRad(maxAngleB)) * other._maxRadius;

                float distMinStartSq = pMinStartB.distanceSquared(posA);
                float distMinEndSq = pMinEndB.distanceSquared(posA);
                float distMaxStartSq = pMaxStartB.distanceSquared(posA);
                float distMaxEndSq = pMaxEndB.distanceSquared(posA);

                float minRadiusASq = _minRadius * _minRadius;
                float maxRadiusASq = _maxRadius * _maxRadius;

                int isInsideMinStartB = distMinStartSq > maxRadiusASq ? 1 : ( //
                    distMinStartSq < minRadiusASq ? -1 : 0); //
                int isInsideMinEndB = distMinEndSq > maxRadiusASq ? 1 : ( //
                    distMinEndSq < minRadiusASq ? -1 : 0); //
                int isInsideMaxStartB = distMaxStartSq > maxRadiusASq ? 1 : ( //
                    distMaxStartSq < minRadiusASq ? -1 : 0); //
                int isInsideMaxEndB = distMaxEndSq > maxRadiusASq ? 1 : ( //
                    distMaxEndSq < minRadiusASq ? -1 : 0); //

                int totalInside = isInsideMinStartB + isInsideMinEndB + isInsideMaxStartB + isInsideMaxEndB;

                if ((isInsideMinStartB == 0) || (isInsideMinEndB == 0) || (isInsideMaxStartB == 0) || (
                        isInsideMaxEndB == 0) || ((
                        totalInside != 4) && (totalInside != -4))) {
                    hit.isColliding = true;
                }
                else if (totalInside == 4) {
                    // Si tous les points sont externes, le bord du cercle B peut quand même toucher la section A
                    if (_checkSegment(posA, _maxRadius, pMinStartB, pMinEndB)) {
                        hit.isColliding = true;
                    }
                    else if (_checkSegment(posA, _maxRadius, pMaxStartB, pMaxEndB)) {
                        hit.isColliding = true;
                    }
                }
            }
            return hit;
        }

        // Deux sections de cercles
        { // Il y a collision si l’axe AB passe par les deux sections
            float angleAB = radToDeg((posB - posA).angle());
            float angleBA = radToDeg((posA - posB).angle());

            if ((angleBetweenDeg(angleA, angleAB) <= _angleDelta) &&
                (angleBetweenDeg(angleB, angleBA) <= other._angleDelta)) {
                hit.isColliding = true;
                return hit;
            }
        }

        // Il y a collision si un point des segments formé par les bords des sections
        // est inscrit dans la section de l’autre cercle
        {
            Vec2f pMinStartA = posA + Vec2f.angled(degToRad(minAngleA)) * _minRadius;
            Vec2f pMinEndA = posA + Vec2f.angled(degToRad(minAngleA)) * _maxRadius;
            Vec2f pMaxStartA = posA + Vec2f.angled(degToRad(maxAngleA)) * _minRadius;
            Vec2f pMaxEndA = posA + Vec2f.angled(degToRad(maxAngleA)) * _maxRadius;

            Vec2f pMinStartB = posB + Vec2f.angled(degToRad(minAngleB)) * other._minRadius;
            Vec2f pMinEndB = posB + Vec2f.angled(degToRad(minAngleB)) * other._maxRadius;
            Vec2f pMaxStartB = posB + Vec2f.angled(degToRad(maxAngleB)) * other._minRadius;
            Vec2f pMaxEndB = posB + Vec2f.angled(degToRad(maxAngleB)) * other._maxRadius;

            // Un segment de la section d’un cercle coupe l’autre cercle dans l’angle souhaité
            if (_checkSegment(posA, angleA, _angleDelta, _minRadius, _maxRadius, pMinStartB, pMinEndB)) {
                hit.isColliding = true;
                return hit;
            }
            if (_checkSegment(posA, angleA, _angleDelta, _minRadius, _maxRadius, pMaxStartB, pMaxEndB)) {
                hit.isColliding = true;
                return hit;
            }
            if (_checkSegment(posB, angleB, other._angleDelta, other._minRadius, other._maxRadius, pMinStartA, pMinEndA)) {
                hit.isColliding = true;
                return hit;
            }
            if (_checkSegment(posB, angleB, other._angleDelta, other._minRadius, other._maxRadius, pMaxStartA, pMaxEndA)) {
                hit.isColliding = true;
                return hit;
            }
        }

        return hit;
    }

    void draw(Vec2f origin) {
        Vec2f hurtOrigin = origin + Vec2f.angled(
            degToRad(_entity.angle + cast(float) _offsetAngle)) * _offsetDist;

        bool hasAngles = (_angleDelta > 0 && _angleDelta < 180);
        int startAngle, endAngle;
        if (hasAngles) {
            int angle = cast(int) getAngle().round();
            startAngle = angle - _angleDelta;
            endAngle = angle + _angleDelta;
        }
        else {
            startAngle = 0;
            endAngle = 360;
        }

        int deltaAngle = abs(endAngle - startAngle);
        if (deltaAngle > 360) {
            startAngle = 0;
            endAngle = 360;
            deltaAngle = 360;
            hasAngles = false;
        }

        void drawLine(Vec2f a, Vec2f b, float height) {
            Atelier.renderer.drawLine(
                hurtOrigin + (a + Vec2f(0f, -height)),
                hurtOrigin + (b + Vec2f(0f, -height)),
                Color.red, 1f);
        }

        void drawCurve(float startAngle, float endAngle, float dist, float height) {
            Vec2f a = Vec2f.angled(degToRad(cast(float) startAngle)) * dist;
            Vec2f b = Vec2f.angled(degToRad(cast(float) endAngle)) * dist;
            drawLine(a, b, height);
        }

        void drawAngleLine(float angle, float startDist, float endDist, float height) {
            Vec2f a = Vec2f.angled(degToRad(cast(float) angle)) * startDist;
            Vec2f b = Vec2f.angled(degToRad(cast(float) angle)) * endDist;
            drawLine(a, b, height);
        }

        void drawAngleHeightLine(float angle, float dist, float height) {
            Vec2f a = Vec2f.angled(degToRad(cast(float) angle)) * dist;
            Vec2f b = a + Vec2f(0f, -height);
            drawLine(a, b, 0);
        }

        {
            int segments = deltaAngle / 5;
            int currentAngle = startAngle;
            for (int i; i < segments; ++i) {
                int currentEnd = currentAngle + 5;

                drawCurve(currentAngle, currentEnd, _minRadius, 0);
                drawCurve(currentAngle, currentEnd, _maxRadius, 0);
                drawCurve(currentAngle, currentEnd, _minRadius, _height);
                drawCurve(currentAngle, currentEnd, _maxRadius, _height);

                currentAngle = currentEnd;
            }

            if ((endAngle - currentAngle) > 0) {
                drawCurve(currentAngle, endAngle, _minRadius, 0);
                drawCurve(currentAngle, endAngle, _maxRadius, 0);
                drawCurve(currentAngle, endAngle, _minRadius, _height);
                drawCurve(currentAngle, endAngle, _maxRadius, _height);
            }

            if (!hasAngles || (0 > startAngle && 0 < endAngle) || (360 > startAngle && 360 < endAngle)) {
                drawAngleHeightLine(0f, _minRadius, _height);
                drawAngleHeightLine(0f, _maxRadius, _height);
            }

            if (!hasAngles || (180 > startAngle && 180 < endAngle)) {
                drawAngleHeightLine(180f, _minRadius, _height);
                drawAngleHeightLine(180f, _maxRadius, _height);
            }

            if (hasAngles) {
                drawAngleLine(startAngle, _minRadius, _maxRadius, 0);
                drawAngleLine(endAngle, _minRadius, _maxRadius, 0);
                drawAngleLine(startAngle, _minRadius, _maxRadius, _height);
                drawAngleLine(endAngle, _minRadius, _maxRadius, _height);

                drawAngleHeightLine(startAngle, _minRadius, _height);
                drawAngleHeightLine(startAngle, _maxRadius, _height);
                drawAngleHeightLine(endAngle, _minRadius, _height);
                drawAngleHeightLine(endAngle, _maxRadius, _height);
            }
        }
    }
}
