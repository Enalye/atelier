module atelier.console.cmd.state;

import std.file;
import std.path;
import grimoire;
import atelier.common;
import atelier.core;
import atelier.console.command;
import atelier.console.value;
import atelier.console.system;

package void _stateCmd(Console console) {
    // state
    ConsoleCommand state = console.addCommand("state");

    // state autosave
    ConsoleCommand state_autosave = state.addCommand("autosave");
    state_autosave.setHint("Enregistre l’état du jeu dans le fichier auto.save");
    state_autosave.setCallback(&_state_autosave);

    // state autoload
    ConsoleCommand state_autoload = state.addCommand("autoload");
    state_autoload.setHint("Charge l’état du jeu depuis le fichier auto.save");
    state_autoload.setCallback(&_state_autoload);

    // state create
    ConsoleCommand state_create = state.addCommand("create");
    state_create.setHint("Enregistre l’état du jeu dans un nouveau fichier");
    state_create.setCallback(&_state_create);
}

private void _state_autosave(ConsoleCall call) {
    Atelier.state.saveAutoFile();
    call.console.log("Sauvegarde effectuée");
}

private void _state_autoload(ConsoleCall call) {
    Atelier.state.loadAutoFile();
    call.console.log("Chargement effectué");
}

private void _state_create(ConsoleCall call) {
    Atelier.state.saveAsNewFile();
    call.console.log("Sauvegarde effectuée");
}
