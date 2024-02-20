/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
import std.stdio;
import grimoire;

import atelier.cli;
import atelier.core;

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
        else version(AtelierDev) {
            parseCli(args);
        }
        else version(AtelierRedist) {
            boot(args);
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
