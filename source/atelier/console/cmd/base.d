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

    // echo <S:message>
    ConsoleCommand echo = console.addCommand("echo");
    echo.addParameter("message", ConsoleType.string_);
    echo.setHint("Répète le message");
    echo.setCallback(&_echo);
}

private void _clear(ConsoleCall call) {
    call.console.clearLog();
}

private void _echo(ConsoleCall call) {
    call.console.log(call.getArgument!string("message"));
}
