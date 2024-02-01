/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
import atelier.cli;

import std.stdio;
import grimoire;

void main(string[] args) {
    version (AtelierDebug) {
        args = args[0] ~ ["run", "test"];
    }

    version (Windows) {
        import core.sys.windows.windows : SetConsoleOutputCP;

        SetConsoleOutputCP(65_001);
    }

    try {
        version (AtelierDoc) {
            import atelier.doc : generateDoc;

            generateDoc();
        }
        else {
            parseCli(args);
        }
    }
    catch (GrCompilerException e) {
        writeln(e.msg);
    }
    catch (Exception e) {
        writeln("Erreur: ", e.msg);
        foreach (trace; e.info) {
            writeln("at: ", trace);
        }
    }
}
