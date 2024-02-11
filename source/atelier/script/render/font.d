/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.render.font;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.script.util;

package void loadLibRender_font(GrLibDefinition library) {
    library.setModule("render.font");
    library.setModuleInfo(GrLocale.fr_FR, "Police de caractères");

    GrType fontType = library.addNative("Font", [], "ImageData");
    GrType ttfType = library.addNative("TrueTypeFont", [], "Font");
    GrType bmpfType = library.addNative("BitmapFont", [], "Font");

    library.setParameters();
    library.addConstructor(&_ttfCtor, ttfType, [grString]);
}

private void _ttfCtor(GrCall call) {
    call.setNative(Atelier.res.get!TrueTypeFont(call.getString(0)));
}
