/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.audio.bus;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_bus(GrLibDefinition library) {
    library.setModule("audio.bus");
    library.setModuleInfo(GrLocale.fr_FR, "Route les sons et leur applique des effets");

    GrType busType = library.addNative("AudioBus");

    GrType playerType = grGetNativeType("AudioPlayer");
    GrType soundType = grGetNativeType("Sound");
    GrType musicType = grGetNativeType("Music");
    GrType effectType = grGetNativeType("AudioEffect");

    library.addConstructor(&_ctor, busType);

    library.setDescription(GrLocale.fr_FR, "Joue le son sur le bus.");
    library.setParameters(["bus", "player"]);
    library.addFunction(&_play, "play", [busType, playerType]);
    library.addFunction(&_playSound, "play", [busType, soundType]);
    library.addFunction(&_playMusic, "play", [busType, musicType]);

    library.setDescription(GrLocale.fr_FR, "Ajoute un effet.");
    library.setParameters(["bus", "effect"]);
    library.addFunction(&_addEffect, "addEffect", [busType, effectType]);

    library.setDescription(GrLocale.fr_FR, "Connecte le bus à un bus destinataire.");
    library.setParameters(["srcBus", "destBus"]);
    library.addFunction(&_connectTo, "connectTo", [busType, busType]);

    library.setDescription(GrLocale.fr_FR, "Connecte le bus au bus maître.");
    library.setParameters(["bus"]);
    library.addFunction(&_connectToMaster, "connectToMaster", [busType]);

    library.setDescription(GrLocale.fr_FR, "Déconnecte le bus de toute destination.");
    library.setParameters(["srcBus", "destBus"]);
    library.addFunction(&_disconnect, "disconnect", [busType]);
}

private void _ctor(GrCall call) {
    AudioBus bus = new AudioBus();
    bus.connectToMaster();
    call.setNative(bus);
}

private void _play(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);
    AudioPlayer player = call.getNative!AudioPlayer(1);
    bus.play(player);
}

private void _playSound(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);
    Sound sound = call.getNative!Sound(1);
    bus.play(new SoundPlayer(sound));
}

private void _playMusic(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);
    Music music = call.getNative!Music(1);
    bus.play(new MusicPlayer(music));
}

private void _addEffect(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);
    AudioEffect effect = call.getNative!AudioEffect(1);
    bus.addEffect(effect);
}

private void _connectTo(GrCall call) {
    AudioBus bus1 = call.getNative!AudioBus(0);
    AudioBus bus2 = call.getNative!AudioBus(1);
    bus1.connectTo(bus2);
}

private void _connectToMaster(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);
    bus.connectToMaster();
}

private void _disconnect(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);
    bus.disconnect();
}
