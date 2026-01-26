module atelier.core.loader.entity;

import farfadet;
import atelier.common;
import atelier.physics;
import atelier.render;
import atelier.world;
import atelier.core.runtime;
import atelier.core.loader.util;

package void compileEntity(string path, const Farfadet ffd, OutStream stream) {
    const string rid = ffd.get!string(0);
    stream.write!string(rid);

    string name;
    if (ffd.hasNode("name")) {
        name = ffd.getNode("name").get!string(0);
    }
    stream.write!string(name);

    HitboxData hitbox;
    hitbox.load(ffd);
    hitbox.serialize(stream);

    RepulsorData repulsor;
    repulsor.load(ffd);
    repulsor.serialize(stream);

    HurtboxData hurtbox;
    hurtbox.load(ffd);
    hurtbox.serialize(stream);

    BaseEntityData baseEntityData;
    baseEntityData.load(ffd);
    baseEntityData.serialize(stream);

    serializeEntityGraphicData(ffd, stream);
}

package void loadEntity(InStream stream) {
    const string rid = stream.read!string();
    const string name = stream.read!string();

    HitboxData hitbox;
    hitbox.deserialize(stream);

    RepulsorData repulsor;
    repulsor.deserialize(stream);

    HurtboxData hurtbox;
    hurtbox.deserialize(stream);

    BaseEntityData baseEntityData;
    baseEntityData.deserialize(stream);

    EntityGraphicData[] graphicDataList = unserializeEntityGraphicData(stream);

    Atelier.res.store(rid, {
        Entity entity = new Entity;
        buildEntityGraphics(entity, graphicDataList);
        entity.setCollider(hitbox);
        entity.setupRepulsor(repulsor);
        entity.setupHurtbox(hurtbox);
        entity.setName(name);
        entity.setBaseEntityData(baseEntityData);
        return entity;
    });
}
