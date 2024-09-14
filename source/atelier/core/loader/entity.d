/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.core.loader.entity;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.core.runtime;

package void compileEntity(string path, const Farfadet ffd, OutStream stream) {
    const string rid = ffd.get!string(0);
    //LevelBuilder level = new LevelBuilder(ffd);
    stream.write!string(rid);
    //level.serialize(stream);
}

package void loadEntity(InStream stream) {
    const string rid = stream.read!string();
    //LevelBuilder level = new LevelBuilder;
    //level.deserialize(stream);
    //Atelier.res.store(rid, { return level; });
}
