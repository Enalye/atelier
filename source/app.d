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

    export extern (D) void startupDev(string[] args) {
        try {
            openLogger(false);
            parseCli(args);
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
        finally {
            closeLogger();
        }
    }

    export extern (D) void startupRedist(string[] args) {
        try {
            openLogger(true);
            boot(args);
        }
        catch (Exception e) {
            log("Erreur: ", e.msg);
            foreach (trace; e.info) {
                log("à: ", trace);
            }
        }
        finally {
            closeLogger();
        }
    }
}
else {
    extern (C) __gshared string[] rt_options = [
        "gcopt=initReserve:128 minPoolSize:256 parallel:2 profile:1"
    ];

    void main(string[] args) {
        openLogger(false);

        version (AtelierDebug) {
            args = args[0] ~ ["run", "test"];
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
                log("à: ", trace);
            }
        }
        finally {
            closeLogger();
        }
    }
}
