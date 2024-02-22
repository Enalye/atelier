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

package void loadLibAudio_effect(GrLibDefinition library) {
    library.setModule("audio.effect");
    library.setModuleInfo(GrLocale.fr_FR, "Effet audio de base");

    GrType effectType = library.addNative("AudioEffect");

    library.setDescription(GrLocale.fr_FR, "Retire l’effet de la chaîne d’effet.");
    library.setParameters(["effect"]);
    library.addFunction(&_remove, "remove", [effectType]);
}

private void _remove(GrCall call) {
    AudioEffect effect = call.getNative!AudioEffect(0);
    effect.remove();
}
