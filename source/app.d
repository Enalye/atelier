/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
import std.stdio;
import grimoire;

import atelier.cli;
import atelier.core;
import atelier.doc : generateDoc;

version (AtelierDLL) {
    version (Windows) {
        import core.sys.windows.dll;

        mixin SimpleDllMain;
    }

    export extern(D) void startupDev(string[] args) {
        parseCli(args);
    }

    export extern(D) void startupRedist(string[] args) {
        boot(args);
    }
}
else {
    void main(string[] args) {
        version (AtelierDebug) {
            args = args[0] ~ ["run", "test"];
        }

        version (AtelierDebug) {
            version (Windows) {
                import core.sys.windows.windows : SetConsoleOutputCP;

                SetConsoleOutputCP(65_001);
            }
        }

        try {
            version (AtelierDoc) {
                generateDoc();
            }
            else version (AtelierDebug) {
                parseCli(args);
            }
        }
        catch (GrCompilerException e) {
            log(e.msg);
        }
        catch (Exception e) {
            log("Erreur: ", e.msg);
            foreach (trace; e.info) {
                log("at: ", trace);
            }
        }
    }
}
