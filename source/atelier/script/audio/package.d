/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.audio;

import grimoire;

import atelier.script.audio.bus;
import atelier.script.audio.effect;
import atelier.script.audio.fader;
import atelier.script.audio.gain;
import atelier.script.audio.music;
import atelier.script.audio.musicplayer;
import atelier.script.audio.panner;
import atelier.script.audio.player;
import atelier.script.audio.sound;
import atelier.script.audio.soundplayer;

package(atelier.script) GrLibLoader[] getLibLoaders_audio() {
    return [
        &loadLibAudio_bus,
        &loadLibAudio_effect,
        &loadLibAudio_fader,
        &loadLibAudio_gain,
        &loadLibAudio_panner,
        &loadLibAudio_player,
        &loadLibAudio_music,
        &loadLibAudio_musicPlayer,
        &loadLibAudio_sound,
        &loadLibAudio_soundPlayer
    ];
}
