/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.audio.effect;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_effect(GrLibDefinition library) {
    GrType effectType = library.addNative("AudioEffect");

    library.addFunction(&_remove, "remove", [effectType]);
}

private void _remove(GrCall call) {
    AudioEffect effect = call.getNative!AudioEffect(0);
    effect.remove();
}
