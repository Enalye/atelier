module atelier.console.cmd.runtime;

import atelier.common;
import atelier.core;
import atelier.console.system;
import atelier.console.command;

package void _runtimeCmd(Console console) {
    ConsoleCommand timescale = console.addCommand("timescale");
    timescale.addParameter("factor", ConsoleType.float_);
    timescale.setHint("Change la vitesse du jeu");
    timescale.setCallback(&_timescale);
}

private void _timescale(ConsoleResult result) {
    float timescale = result.getArgument!float("factor");
    Atelier.setTimeScale(timescale);
    Atelier.console.log("Vitesse du jeu changée en ", Atelier.getTimeScale());
}
