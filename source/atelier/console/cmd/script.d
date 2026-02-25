module atelier.console.cmd.script;

import std.file;
import std.path;
import grimoire;
import atelier.common;
import atelier.core;
import atelier.console.command;
import atelier.console.value;
import atelier.console.system;

package void _scriptCmd(Console console) {
    ConsoleCommand script = console.addCommand("script");

    ConsoleCommand script_bytecode = script.addCommand("bytecode");
    script_bytecode.addParameter("path", ConsoleType.string_);
    script_bytecode.setHint("Enregistre le bytecode en format lisible");
    script_bytecode.setCallback(&_script_bytecode);
}

private void _script_bytecode(ConsoleResult result) {
    string path = result.getArgument!string("path");
    GrBytecode bytecode = Atelier.script.getBytecode();
    if (!bytecode) {
        Atelier.console.log("Aucun bytecode de disponible");
        return;
    }
    string exeDir = dirName(thisExePath());
    path = buildNormalizedPath(exeDir, path);
    std.file.write(path, bytecode.prettify());
    Atelier.console.log("Bytecode enregistré dans `", path, "`");
}
