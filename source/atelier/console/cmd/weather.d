module atelier.console.cmd.weather;

import atelier.common;
import atelier.core;
import atelier.world;
import atelier.console.system;

package void _weatherCmd(Cli cli) {
    cli.addCommand(&_command, "weather", "Météo");
    cli.addCommandOption("weather", "l", "list", "Liste des météos disponibles");
    cli.addCommandOption("weather", "c", "change",
        "Change la météo actuelle", ["S:type"], ["F:strength", "I:duration"]);
}

private void _command(Cli.Result cli) {
    if (cli.hasOption("list")) {
        Atelier.console.log("Météos disponibles: ", Atelier.world.weather.getList());
    }
    if (cli.hasOption("change")) {
        Cli.Result.Option option = cli.getOption("change");

        string type = option.getRequiredParamAs!string(0);
        float strength = 1f;
        uint duration = 0;
        if (option.optionalParamCount() >= 1) {
            strength = clamp(option.getOptionalParamAs!float(0), 0f, 1f);
        }
        if (option.optionalParamCount() >= 2) {
            duration = option.getOptionalParamAs!uint(1);
        }
        if (duration > 0) {
            Atelier.world.weather.run(type, strength, duration);
        }
        else {
            Atelier.world.weather.set(type, strength);
        }
        Atelier.console.log("Météo changée en ", type, " d’intensité ", strength);
    }
}
