module atelier.console.cmd.script;

import std.file;
import std.path;
import grimoire;
import atelier.common;
import atelier.core;
import atelier.console.system;

package void _scriptCmd(Cli cli) {
    cli.addCommand(&_bytecode, "bytecode", "Enregistre le bytecode en format lisible", [
            "S:file"
        ]);
}

private void _bytecode(Cli.Result cli) {
    string path = cli.getRequiredParamAs!string(0);
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
