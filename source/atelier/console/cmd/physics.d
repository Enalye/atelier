module atelier.console.cmd.physics;

import atelier.common;
import atelier.core;
import atelier.world;
import atelier.physics;
import atelier.console.system;

package void _physicsCmd(Cli cli) {
    cli.addCommand(&_showcoll, "showcoll", "Affiche les boites de collisions");
    cli.addCommandOption("showcoll", "a", "actors",
        "Affiche toutes les boites de collision des acteurs", ["B:visible"]);
    cli.addCommandOption("showcoll", "p", "solids",
        "Affiche toutes les boites de collision des solides", ["B:visible"]);
    cli.addCommandOption("showcoll", "s", "shots",
        "Affiche toutes les boites de collision des tirs", ["B:visible"]);
    cli.addCommandOption("showcoll", "l", "all",
        "Affiche toutes les zones d’impact", ["B:visible"]);
    cli.addCommandOption("showcoll", "pi", "",
        "Affiche les tirs joueurs", ["B:visible"]);
    cli.addCommandOption("showcoll", "pt", "",
        "Affiche les cibles joueurs", ["B:visible"]);
    cli.addCommandOption("showcoll", "ei", "",
        "Affiche les tirs adverses", ["B:visible"]);
    cli.addCommandOption("showcoll", "et", "",
        "Affiche les cibles adverses", ["B:visible"]);
    cli.addCommandOption("showcoll", "gi", "",
        "Affiche les tirs globaux", ["B:visible"]);
    cli.addCommandOption("showcoll", "gt", "",
        "Affiche les cibles globales", ["B:visible"]);
    cli.addCommandOption("showcoll", "h", "hurt",
        "Affiche les hurtbox", ["B:visible"]);
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

    if (cli.hasOption("pi")) {
        Cli.Result.Option option = cli.getOption("pi");
        Atelier.physics.showPlayerImpactHurtboxes(option.getRequiredParamAs!bool(0));
    }

    if (cli.hasOption("pt")) {
        Cli.Result.Option option = cli.getOption("pt");
        Atelier.physics.showPlayerTargetHurtboxes(option.getRequiredParamAs!bool(0));
    }

    if (cli.hasOption("ei")) {
        Cli.Result.Option option = cli.getOption("ei");
        Atelier.physics.showEnemyImpactHurtboxes(option.getRequiredParamAs!bool(0));
    }

    if (cli.hasOption("et")) {
        Cli.Result.Option option = cli.getOption("et");
        Atelier.physics.showEnemyTargetHurtboxes(option.getRequiredParamAs!bool(0));
    }

    if (cli.hasOption("gi")) {
        Cli.Result.Option option = cli.getOption("gi");
        Atelier.physics.showGlobalImpactHurtboxes(option.getRequiredParamAs!bool(0));
    }

    if (cli.hasOption("gt")) {
        Cli.Result.Option option = cli.getOption("gt");
        Atelier.physics.showGlobalTargetHurtboxes(option.getRequiredParamAs!bool(0));
    }

    if (cli.hasOption("h")) {
        Cli.Result.Option option = cli.getOption("h");
        bool value = option.getRequiredParamAs!bool(0);
        Atelier.physics.showPlayerImpactHurtboxes(value);
        Atelier.physics.showPlayerTargetHurtboxes(value);
        Atelier.physics.showEnemyImpactHurtboxes(value);
        Atelier.physics.showEnemyTargetHurtboxes(value);
        Atelier.physics.showGlobalImpactHurtboxes(value);
        Atelier.physics.showGlobalTargetHurtboxes(value);
    }
}
