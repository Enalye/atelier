module atelier.console.cmd.nav;

import atelier.common;
import atelier.core;
import atelier.nav;
import atelier.console.system;

package void _navCmd(Cli cli) {
    cli.addCommand(&_nav, "nav", "Débogue la navigation");
    cli.addCommandOption("nav", "dbg", "debug",
        "Affiche le navmesh", [], ["B:visible"]);
    cli.addCommandOption("nav", "lvl", "level",
        "Restreint le niveau à afficher", [], ["I:level"]);
    cli.addCommandOption("nav", "gen", "generate",
        "Regénère le navmesh");
}

private void _nav(Cli.Result cli) {
    if (cli.hasOption("debug")) {
        Cli.Result.Option option = cli.getOption("debug");
        if (option.optionalParamCount() > 0) {
            Atelier.nav.isDebug = option.getOptionalParamAs!bool(0);
        }
        else {
            Atelier.nav.isDebug = !Atelier.nav.isDebug;
        }

        if (Atelier.nav.isDebug)
            Atelier.log("Navigation affichée");
        else
            Atelier.log("Navigation masquée");
    }

    if (cli.hasOption("level")) {
        Cli.Result.Option option = cli.getOption("level");
        if (option.optionalParamCount() > 0) {
            Atelier.nav.levelToDraw = option.getOptionalParamAs!int(0);
        }
        else {
            Atelier.nav.levelToDraw = -1;
        }
        Atelier.log("Niveau de navigation affiché reglé sur ", Atelier.nav.levelToDraw);
    }

    if (cli.hasOption("gen")) {
        Atelier.log("Génération du navmesh");
        Atelier.nav.generate();
    }
}
