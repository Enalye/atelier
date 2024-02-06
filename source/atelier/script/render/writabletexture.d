/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.render.writabletexture;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.script.util;

void loadLibRender_writableTexture(GrLibDefinition library) {
    library.setModule("render.writabletexture");
    library.setModuleInfo(GrLocale.fr_FR, "Texture générée procéduralement");

    GrType wtextureType = library.addNative("WritableTexture", [], "ImageData");
    GrType vec4iType = grGetNativeType("Vec4", [grInt]);

    library.addConstructor(&_ctor, wtextureType, [grUInt, grUInt]);

    library.setDescription(GrLocale.fr_FR, "Modifie la texture");
    library.addFunction(&_update, "update", [
            wtextureType, vec4iType, grList(grUInt)
        ]);
}

private void _ctor(GrCall call) {
    WritableTexture tex = new WritableTexture(call.getUInt(0), call.getUInt(1));
    call.setNative(tex);
}

private void _update(GrCall call) {
    WritableTexture tex = call.getNative!WritableTexture(0);
    Vec4i clip = call.getNative!SVec4i(1);
    GrUInt[] texels = call.getList(1).getUInts();

    if (tex.width == 0 || tex.height == 0)
        return;

    clip.x = min(tex.width, clip.x);
    clip.y = min(tex.height, clip.y);

    clip.z = min(tex.width - clip.x, clip.z);
    clip.w = min(tex.height - clip.y, clip.w);

    if (clip.z <= 0 || clip.w <= 0)
        return;

    if (texels.length != clip.z * clip.w)
        return;

    tex.update(clip, texels);
}
