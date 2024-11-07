/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.audio;

import grimoire;

import atelier.script.audio.bus;
import atelier.script.audio.delay;
import atelier.script.audio.effect;
import atelier.script.audio.fader;
import atelier.script.audio.gain;
import atelier.script.audio.lowpass;
import atelier.script.audio.music;
import atelier.script.audio.musicplayer;
import atelier.script.audio.panner;
import atelier.script.audio.player;
import atelier.script.audio.reverb;
import atelier.script.audio.sound;
import atelier.script.audio.soundplayer;
import atelier.script.audio.spacializer;

package(atelier.script) GrModuleLoader[] getLibLoaders_audio() {
    return [
        &loadLibAudio_bus,
        &loadLibAudio_delay,
        &loadLibAudio_effect,
        &loadLibAudio_fader,
        &loadLibAudio_gain,
        &loadLibAudio_lowpass,
        &loadLibAudio_panner,
        &loadLibAudio_player,
        &loadLibAudio_reverb,
        &loadLibAudio_music,
        &loadLibAudio_musicPlayer,
        &loadLibAudio_sound,
        &loadLibAudio_soundPlayer,
        &loadLibAudio_spacializer
    ];
}
