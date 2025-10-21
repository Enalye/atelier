module atelier.core.loader.actor;

import farfadet;
import atelier.common;
import atelier.physics;
import atelier.render;
import atelier.world;
import atelier.core.runtime;
import atelier.core.loader.util;

struct HitboxData {
    bool hasHitbox = false;
    Vec3u size;

    void load(const Farfadet ffd) {
        if (ffd.hasNode("hitbox")) {
            hasHitbox = true;
            Farfadet hitboxNode = ffd.getNode("hitbox");
            if (hitboxNode.hasNode("size")) {
                size = hitboxNode.getNode("size").get!Vec3u(0);
            }
        }
    }

    void serialize(OutStream stream) {
        stream.write!bool(hasHitbox);

        if (hasHitbox) {
            stream.write!Vec3u(size);
        }
    }

    void deserialize(InStream stream) {
        hasHitbox = stream.read!bool();

        if (hasHitbox) {
            size = stream.read!Vec3u();
        }
    }
}

package void compileActor(string path, const Farfadet ffd, OutStream stream) {
    const string rid = ffd.get!string(0);
    stream.write!string(rid);

    string name;
    if (ffd.hasNode("name")) {
        name = ffd.getNode("name").get!string(0);
    }
    stream.write!string(name);

    HitboxData hitbox;
    if (ffd.hasNode("hitbox")) {
        hitbox.load(ffd);
    }
    hitbox.serialize(stream);

    RepulsorData repulsor;
    if (ffd.hasNode("repulsor")) {
        repulsor.load(ffd.getNode("repulsor"));
    }
    repulsor.serialize(stream);

    HurtboxData hurtbox;
    if (ffd.hasNode("hurtbox")) {
        hurtbox.load(ffd.getNode("hurtbox"));
    }
    hurtbox.serialize(stream);

    serializeEntityGraphicData(ffd, stream);
}

package void loadActor(InStream stream) {
    const string rid = stream.read!string();
    const string name = stream.read!string();

    HitboxData hitbox;
    hitbox.deserialize(stream);

    RepulsorData repulsor;
    repulsor.deserialize(stream);

    HurtboxData hurtbox;
    hurtbox.deserialize(stream);

    EntityGraphicData[] graphicDataList = unserializeEntityGraphicData(stream);

    Atelier.res.store(rid, {
        Actor actor = new Actor;
        for (uint i; i < graphicDataList.length; ++i) {
            EntityGraphic graphic = createEntityGraphicData(graphicDataList[i]);
            if (!graphic)
                continue;

            actor.addGraphic(graphicDataList[i].name, graphic);
        }
        if (hitbox.hasHitbox) {
            actor.setupCollider(hitbox.size);
        }
        actor.setupRepulsor(repulsor);
        actor.setupHurtbox(hurtbox);
        actor.setName(name);
        return actor;
    });
}
