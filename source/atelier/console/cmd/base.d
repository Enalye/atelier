module atelier.console.cmd.base;

import atelier.common;
import atelier.core;
import atelier.console.system;

package void _baseCmd(Cli cli) {
    cli.addCommand(&_help, "help", "Affiche l’aide", [], ["S:command"]);
    cli.addCommand(&_clear, "clear", "Supprime l’historique de la console");
    cli.addCommand(&_echo, "echo", "Répète le message", ["S:msg"]);
}

private void _help(Cli.Result cli) {
    if (cli.optionalParamCount() >= 1)
        Atelier.console.showHelp(cli.getOptionalParamAs!string(0));
    else
        Atelier.console.showHelp();
}

private void _clear(Cli.Result cli) {
    Atelier.console.clearLog();
}

private void _echo(Cli.Result cli) {
    Atelier.console.log(cli.getRequiredParamAs!string(0));
}
