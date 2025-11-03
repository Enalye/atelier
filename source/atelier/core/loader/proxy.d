module atelier.core.loader.proxy;

import farfadet;
import atelier.common;
import atelier.physics;
import atelier.render;
import atelier.world;
import atelier.core.runtime;
import atelier.core.loader.util;

package void compileProxy(string path, const Farfadet ffd, OutStream stream) {
    const string rid = ffd.get!string(0);
    stream.write!string(rid);

    string name;
    if (ffd.hasNode("name")) {
        name = ffd.getNode("name").get!string(0);
    }
    stream.write!string(name);

    HurtboxData hurtbox;
    if (ffd.hasNode("hurtbox")) {
        hurtbox.load(ffd.getNode("hurtbox"));
    }
    hurtbox.serialize(stream);

    BaseEntityData baseEntityData;
    baseEntityData.load(ffd);
    baseEntityData.serialize(stream);

    serializeEntityGraphicData(ffd, stream);
}

package void loadProxy(InStream stream) {
    const string rid = stream.read!string();
    const string name = stream.read!string();
    HurtboxData hurtbox;
    hurtbox.deserialize(stream);

    BaseEntityData baseEntityData;
    baseEntityData.deserialize(stream);

    EntityGraphicData[] graphicDataList = unserializeEntityGraphicData(stream);

    Atelier.res.store(rid, {
        Proxy proxy = new Proxy;
        buildEntityGraphics(proxy, graphicDataList);
        proxy.setupHurtbox(hurtbox);
        proxy.setName(name);
        return proxy;
    });
}
