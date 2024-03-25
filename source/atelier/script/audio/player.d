/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.audio.player;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_player(GrModule mod) {
    mod.setModule("audio.player");
    mod.setModuleInfo(GrLocale.fr_FR, "Instance d’un élément audio.
Permet la lecture d’un élément sonore une seule fois.");

    GrType playerType = mod.addNative("AudioPlayer");
    GrType effectType = grGetNativeType("AudioEffect");

    mod.setDescription(GrLocale.fr_FR, "Lance la lecture sur le bus `master`.");
    mod.setParameters(["player"]);
    mod.addFunction(&_play, "play", [playerType]);

    mod.setDescription(GrLocale.fr_FR, "Applique un effet audio.");
    mod.setParameters(["player", "effect"]);
    mod.addFunction(&_addEffect, "addEffect", [playerType, effectType]);
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
