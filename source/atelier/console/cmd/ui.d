module atelier.console.cmd.ui;

import atelier.common;
import atelier.core;
import atelier.world;
import atelier.console.command;
import atelier.console.system;
import atelier.console.value;

package void _uiCmd(Console console) {
    // ui
    ConsoleCommand ui = console.addCommand("ui");

    // ui debug <B:active>
    ConsoleCommand ui_debug = ui.addCommand("debug");
    ui_debug.addOption("active", ConsoleType.bool_, ConsoleValue(true));
    ui_debug.setHint("Active le débug de l’interface");
    ui_debug.setCallback(&_ui_debug);

    // ui scene
    ConsoleCommand ui_scene = ui.addCommand("scene");

    // ui scene debug <B:active>
    ConsoleCommand ui_scene_debug = ui_scene.addCommand("debug");
    ui_scene_debug.addOption("active", ConsoleType.bool_, ConsoleValue(true));
    ui_scene_debug.setHint("Active le débug de l’interface de la scène");
    ui_scene_debug.setCallback(&_ui_scene_debug);
}

private void _ui_debug(ConsoleCall call) {
    Atelier.ui.isDebug = call.getArgument!bool("active");
    call.console.log("Le mode débug de l’interface est maintenant ",
        Atelier.ui.isDebug ? "active" : "inactive");
}

private void _ui_scene_debug(ConsoleCall call) {
    Atelier.world.isDebugUI = call.getArgument!bool("active");
    call.console.log("Le mode débug de l’interface de scène est maintenant ",
        Atelier.ui.isDebug ? "active" : "inactive");
}
