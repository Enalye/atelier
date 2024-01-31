/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.audio.player;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_player(GrLibDefinition library) {
    GrType playerType = library.addNative("AudioPlayer");
    GrType effectType = grGetNativeType("AudioEffect");

    library.addFunction(&_play, "play", [playerType]);
    library.addFunction(&_addEffect, "addEffect", [playerType, effectType]);
}

private void _play(GrCall call) {
    AudioPlayer player = call.getNative!AudioPlayer(0);
    Atelier.audio.play(player);
}

private void _addEffect(GrCall call) {
    AudioPlayer player = call.getNative!AudioPlayer(0);
    AudioEffect effect = call.getNative!AudioEffect(1);
    player.addEffect(effect);
}
