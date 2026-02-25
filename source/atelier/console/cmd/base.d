module atelier.console.cmd.base;

import atelier.common;
import atelier.core;
import atelier.console.command;
import atelier.console.system;

package void _baseCmd(Console console) {
    // clear
    ConsoleCommand clear = console.addCommand("clear");
    clear.setHint("Supprime l’historique de la console");
    clear.setCallback(&_clear);

    // echo
    ConsoleCommand echo = console.addCommand("echo");
    echo.addParameter("message", ConsoleType.string_);
    echo.setHint("Répète le message");
    echo.setCallback(&_echo);
}

private void _clear(ConsoleResult result) {
    result.console.clearLog();
}

private void _echo(ConsoleResult result) {
    result.console.log(result.getArgument!string("message"));
}
