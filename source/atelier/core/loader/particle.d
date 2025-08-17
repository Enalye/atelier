module atelier.core.loader.particle;

import std.conv : to, ConvException;
import std.exception : enforce;
import std.format : format;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.world;
import atelier.core.runtime;
import atelier.core.loader.util;

package void compileParticle(string path, const Farfadet ffd, OutStream stream) {
    const string rid = ffd.get!string(0);
    stream.write!string(rid);
    serializeEntityGraphicData(ffd, stream);

    ParticleData data;
    data.load(ffd);
    data.serialize(stream);
}

package void loadParticle(InStream stream) {
    const string rid = stream.read!string();
    EntityGraphicData[] graphicDataList = unserializeEntityGraphicData(stream);

    ParticleData data;
    data.deserialize(stream);

    Atelier.res.store(rid, {
        ParticleSource source = new ParticleSource(data);
        for (uint i; i < graphicDataList.length; ++i) {
            EntityGraphic graphic = createEntityGraphicData(graphicDataList[i]);
            if (!graphic)
                continue;
            source.addGraphic(graphicDataList[i].name, graphic);
        }

        return source;
    });
}
