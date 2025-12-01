module atelier.console.cmd.physics;

import atelier.common;
import atelier.core;
import atelier.world;
import atelier.physics;
import atelier.console.system;

package void _physicsCmd(Cli cli) {
    cli.addCommand(&_showcoll, "showcoll", "Affiche les boites de collisions");
    cli.addCommandOption("showcoll", "a", "actor",
        "Affiche toutes les boites de collision des acteurs", ["B:visible"]);
    cli.addCommandOption("showcoll", "p", "prop",
        "Affiche toutes les boites de collision des solides", ["B:visible"]);
    cli.addCommandOption("showcoll", "s", "shot",
        "Affiche toutes les boites de collision des tirs", ["B:visible"]);
    cli.addCommandOption("showcoll", "l", "all",
        "Affiche toutes les boites de collisions", ["B:visible"]);
    cli.addCommandOption("showcoll", "h", "hurtbox",
        "Affiche toutes les hurtbox", ["B:visible"]);
}

private void _showcoll(Cli.Result cli) {
    if (cli.hasOption("actors")) {
        Cli.Result.Option option = cli.getOption("actors");
        Atelier.physics.showActors(option.getRequiredParamAs!bool(0));
    }

    if (cli.hasOption("solids")) {
        Cli.Result.Option option = cli.getOption("solids");
        Atelier.physics.showSolids(option.getRequiredParamAs!bool(0));
    }

    if (cli.hasOption("shots")) {
        Cli.Result.Option option = cli.getOption("shots");
        Atelier.physics.showShots(option.getRequiredParamAs!bool(0));
    }

    if (cli.hasOption("hurtbox")) {
        Cli.Result.Option option = cli.getOption("h");
        bool value = option.getRequiredParamAs!bool(0);
        Atelier.physics.showHurtboxes(value);
    }
}
