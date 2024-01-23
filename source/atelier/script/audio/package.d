/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.audio;

import grimoire;

import atelier.script.audio.manager;
import atelier.script.audio.sound;

package(atelier.script) GrLibLoader[] getLibLoaders_audio() {
    return [
        &loadLibAudio_manager,
        &loadLibAudio_sound
    ];
}
