/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.audio.effect;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_effect(GrModule mod) {
    mod.setModule("audio.effect");
    mod.setModuleInfo(GrLocale.fr_FR, "Effet audio de base");

    GrType effectType = mod.addNative("AudioEffect");

    mod.setDescription(GrLocale.fr_FR, "Retire l’effet de la chaîne d’effet.");
    mod.setParameters(["effect"]);
    mod.addFunction(&_remove, "remove", [effectType]);
}

private void _remove(GrCall call) {
    AudioEffect effect = call.getNative!AudioEffect(0);
    effect.remove();
}
