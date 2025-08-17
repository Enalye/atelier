module atelier.console.cmd.runtime;

import atelier.common;
import atelier.core;
import atelier.console.system;

package void _runtimeCmd(Cli cli) {
    cli.addCommand(&_timescale, "timescale", "Change la vitesse du jeu", [
            "F:factor"
        ]);
}

private void _timescale(Cli.Result cli) {
    float timescale = cli.getRequiredParamAs!float(0);
    Atelier.setTimeScale(timescale);
    Atelier.console.log("Vitesse du jeu changée en ", Atelier.getTimeScale());
}
