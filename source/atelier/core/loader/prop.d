module atelier.core.loader.prop;

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
    string shape = "box";
    float bounciness = 0f;

    void load(const Farfadet ffd) {
        if (ffd.hasNode("hitbox")) {
            hasHitbox = true;
            Farfadet hitboxNode = ffd.getNode("hitbox");
            if (hitboxNode.hasNode("size")) {
                size = hitboxNode.getNode("size").get!Vec3u(0);
            }
            if (hitboxNode.hasNode("shape")) {
                shape = hitboxNode.getNode("shape").get!string(0);
            }
            if (hitboxNode.hasNode("bounciness")) {
                bounciness = hitboxNode.getNode("bounciness").get!float(0);
            }
        }
    }

    void serialize(OutStream stream) {
        stream.write!bool(hasHitbox);

        if (hasHitbox) {
            stream.write!Vec3u(size);
            stream.write!string(shape);
            stream.write!float(bounciness);
        }
    }

    void deserialize(InStream stream) {
        hasHitbox = stream.read!bool();

        if (hasHitbox) {
            size = stream.read!Vec3u();
            shape = stream.read!string();
            bounciness = stream.read!float();
        }
    }
}

package void compileProp(string path, const Farfadet ffd, OutStream stream) {
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

    HurtboxData hurtbox;
    if (ffd.hasNode("hurtbox")) {
        hurtbox.load(ffd.getNode("hurtbox"));
    }
    hurtbox.serialize(stream);

    int material;
    if (ffd.hasNode("material")) {
        material = ffd.getNode("material").get!int(0);
    }
    stream.write!int(material);

    serializeEntityGraphicData(ffd, stream);
}

package void loadProp(InStream stream) {
    const string rid = stream.read!string();
    const string name = stream.read!string();

    HitboxData hitbox;
    hitbox.deserialize(stream);

    HurtboxData hurtbox;
    hurtbox.deserialize(stream);

    int material = stream.read!int();
    EntityGraphicData[] graphicDataList = unserializeEntityGraphicData(stream);

    Atelier.res.store(rid, {
        Prop prop = new Prop;
        for (uint i; i < graphicDataList.length; ++i) {
            EntityGraphic graphic = createEntityGraphicData(graphicDataList[i]);
            if (!graphic)
                continue;
            prop.addGraphic(graphicDataList[i].name, graphic);
        }
        if (hitbox.hasHitbox) {
            prop.setupCollider(hitbox.size, hitbox.shape, hitbox.bounciness);
        }
        prop.setupHurtbox(hurtbox);
        prop.setMaterial(material);
        prop.setName(name);
        return prop;
    });
}
