module atelier.console.cmd.loader;

import atelier.common;
import atelier.console.system;
import atelier.console.cmd.base;
import atelier.console.cmd.entity;
import atelier.console.cmd.physics;
import atelier.console.cmd.runtime;
import atelier.console.cmd.lighting;
import atelier.console.cmd.nav;
import atelier.console.cmd.script;
import atelier.console.cmd.weather;
import atelier.console.cmd.world;

private void function(Console)[] _cmdList = [
    &_baseCmd, //
    &_entityCmd, //
    &_physicsCmd, //
    &_runtimeCmd, //
    &_lightingCmd, //
    &_navCmd, //
    &_scriptCmd, //
    &_weatherCmd, //
    &_worldCmd, //
];

package(atelier.console) void console_registerCommands(Console console) {
    foreach (cmd; _cmdList) {
        cmd(console);
    }
}
