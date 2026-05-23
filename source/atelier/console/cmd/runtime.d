module atelier.console.cmd.runtime;

import atelier.common;
import atelier.core;
import atelier.console.command;
import atelier.console.system;
import atelier.console.value;

package void _runtimeCmd(Console console) {
    // timescale <F:factor>
    ConsoleCommand timescale = console.addCommand("timescale");
    timescale.addParameter("factor", ConsoleType.float_);
    timescale.setHint("Change la vitesse du jeu");
    timescale.setCallback(&_timescale);

    // profile
    ConsoleCommand profile = console.addCommand("profile");
    profile.setCallback(&_profile);

    ConsoleCommand profile_enable = profile.addCommand("enable");
    profile_enable.setHint("Active le profiling");
    profile_enable.setCallback(&_profile_enable);

    ConsoleCommand profile_disable = profile.addCommand("disable");
    profile_disable.setHint("Désactive le profiling");
    profile_disable.setCallback(&_profile_disable);

    ConsoleCommand profile_add = profile.addCommand("add");
    profile_add.addParameter("filter", ConsoleType.string_);
    profile_add.setHint("Ajoute une passe au filtre");
    profile_add.setCallback(&_profile_add);

    ConsoleCommand profile_remove = profile.addCommand("remove");
    profile_remove.addParameter("filter", ConsoleType.string_);
    profile_remove.setHint("Retire une passe au filtre");
    profile_remove.setCallback(&_profile_remove);

    ConsoleCommand profile_clear = profile.addCommand("clear");
    profile_clear.setHint("Retire tous les filtres");
    profile_clear.setCallback(&_profile_clear);

    ConsoleCommand profile_restart = profile.addCommand("restart");
    profile_restart.setHint("Redémarre les passes");
    profile_restart.setCallback(&_profile_restart);

    // ui
    ConsoleCommand ui = console.addCommand("ui");

    // ui debug <B:active>
    ConsoleCommand ui_debug = ui.addCommand("debug");
    ui_debug.addOption("active", ConsoleType.bool_, ConsoleValue(true));
    ui_debug.setHint("Active le débug de l’interface");
    ui_debug.setCallback(&_ui_debug);
}

private void _timescale(ConsoleCall call) {
    float timescale = call.getArgument!float("factor");
    Atelier.setTimeScale(timescale);
    call.console.log("Vitesse du jeu changée en ", Atelier.getTimeScale());
}

private void _profile(ConsoleCall call) {
    if (Atelier.profiler.isRunning()) {
        call.console.log("Le profiler est actif avec les filtres: ", Atelier.profiler.getFilters());
    }
    else {
        call.console.log("Le profiler est inactif");
    }
}

private void _profile_enable(ConsoleCall call) {
    call.console.log("Profiler activé");
    Atelier.profiler.open();
}

private void _profile_disable(ConsoleCall call) {
    call.console.log("Profiler désactivé");
    Atelier.profiler.close();
}

private void _profile_add(ConsoleCall call) {
    string filter = call.getArgument!string("filter");
    call.console.log("`", filter, "` ajouté au profilage");
    Atelier.profiler.addFilter(filter);
}

private void _profile_remove(ConsoleCall call) {
    string filter = call.getArgument!string("filter");
    call.console.log("`", filter, "` retiré du profilage");
    Atelier.profiler.removeFilter(filter);
}

private void _profile_clear(ConsoleCall call) {
    call.console.log("Tous les filtres ont été supprimés du profilage");
    Atelier.profiler.clearFilters();
}

private void _profile_restart(ConsoleCall call) {
    call.console.log("Toutes les passes ont été réinitialisé du profilage");
    Atelier.profiler.restartPasses();
}

private void _ui_debug(ConsoleCall call) {
    Atelier.ui.isDebug = call.getArgument!bool("active");
    call.console.log("Le mode débug de l’interface est maintenant ",
        Atelier.ui.isDebug ? "active" : "inactive");
}
