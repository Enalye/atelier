module atelier.console.cmd.physics;

import atelier.common;
import atelier.core;
import atelier.world;
import atelier.physics;
import atelier.console.system;

package void _physicsCmd(Cli cli) {
    cli.addCommand(&_coll, "coll", "Affiche les boites de collisions");
    cli.addCommandOption("coll", "a", "actor",
        "Affiche toutes les boites de collision des acteurs", ["B:visible"]);
    cli.addCommandOption("coll", "p", "prop",
        "Affiche toutes les boites de collision des solides", ["B:visible"]);
    cli.addCommandOption("coll", "s", "shot",
        "Affiche toutes les boites de collision des tirs", ["B:visible"]);
    cli.addCommandOption("coll", "h", "hurtbox",
        "Affiche toutes les hurtbox", ["B:visible"]);
}

private void _coll(Cli.Result cli) {
    if (cli.hasOption("actor")) {
        Cli.Result.Option option = cli.getOption("actor");
        Atelier.physics.showActors(option.getRequiredParamAs!bool(0));
    }

    if (cli.hasOption("prop")) {
        Cli.Result.Option option = cli.getOption("prop");
        Atelier.physics.showSolids(option.getRequiredParamAs!bool(0));
    }

    if (cli.hasOption("shot")) {
        Cli.Result.Option option = cli.getOption("shot");
        Atelier.physics.showShots(option.getRequiredParamAs!bool(0));
    }

    if (cli.hasOption("hurtbox")) {
        Cli.Result.Option option = cli.getOption("h");
        bool value = option.getRequiredParamAs!bool(0);
        Atelier.physics.showHurtboxes(value);
    }
}
