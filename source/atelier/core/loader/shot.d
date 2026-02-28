module atelier.core.loader.shot;

import farfadet;
import atelier.common;
import atelier.physics;
import atelier.render;
import atelier.world;
import atelier.core.runtime;
import atelier.core.loader.util;

struct ColliderData {
    bool hasCollider = false;
    Vec3u size;

    void load(const Farfadet ffd) {
        if (ffd.hasNode("collider")) {
            hasCollider = true;
            Farfadet colliderNode = ffd.getNode("collider");
            if (colliderNode.hasNode("size")) {
                size = colliderNode.getNode("size").get!Vec3u(0);
            }
        }
    }

    void serialize(OutStream stream) {
        stream.write!bool(hasCollider);

        if (hasCollider) {
            stream.write!Vec3u(size);
        }
    }

    void deserialize(InStream stream) {
        hasCollider = stream.read!bool();

        if (hasCollider) {
            size = stream.read!Vec3u();
        }
    }
}
/*
package void compileShot(string path, const Farfadet ffd, OutStream stream) {
    const string rid = ffd.get!string(0);
    stream.write!string(rid);

    string name;
    if (ffd.hasNode("name")) {
        name = ffd.getNode("name").get!string(0);
    }
    stream.write!string(name);

    ColliderData collider;
    if (ffd.hasNode("collider")) {
        collider.load(ffd);
    }
    collider.serialize(stream);

    HitboxData hitbox;
    if (ffd.hasNode("hitbox")) {
        hitbox.load(ffd.getNode("hitbox"));
    }
    hitbox.serialize(stream);

    bool hasTtl = false;
    uint ttl;
    if (ffd.hasNode("ttl")) {
        ttl = ffd.getNode("ttl").get!uint(0);
        hasTtl = true;
    }
    stream.write!bool(hasTtl);
    stream.write!uint(ttl);

    bool hasBounces = false;
    uint bounces;
    if (ffd.hasNode("bounces")) {
        bounces = ffd.getNode("bounces").get!uint(0);
        hasBounces = true;
    }
    stream.write!bool(hasBounces);
    stream.write!uint(bounces);

    int material;
    if (ffd.hasNode("material")) {
        material = ffd.getNode("material").get!int(0);
    }

    stream.write!int(material);

    serializeEntityGraphicData(ffd, stream);
}

package void loadShot(InStream stream) {
    const string rid = stream.read!string();
    const string name = stream.read!string();

    ColliderData collider;
    collider.deserialize(stream);

    HitboxData hitbox;
    hitbox.deserialize(stream);

    bool hasTtl = stream.read!bool();
    uint ttl = stream.read!uint();
    bool hasBounces = stream.read!bool();
    uint bounces = stream.read!uint();
    int material = stream.read!int();
    EntityGraphicData[] graphicDataList = unserializeEntityGraphicData(stream);

    Atelier.res.store(rid, {
        Shot shot = new Shot;
        buildEntityGraphics(shot, graphicDataList);
        if (collider.hasCollider) {
            shot.setupCollider(collider.size);
        }
        shot.setupHitbox(hitbox);
        shot.setMaterial(material);
        shot.setName(name);
        shot.setTtl(hasTtl, ttl);
        shot.setBounces(hasBounces, bounces);
        return shot;
    });
}
*/
