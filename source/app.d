/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
import std.stdio;
import grimoire;

import atelier.core;
import atelier.doc : generateDoc;

/*
version (AtelierExe) {
    extern (C) __gshared string[] rt_options = [
        "gcopt=initReserve:128 minPoolSize:256 parallel:2"
    ];

    void main(string[] args) {
        version (AtelierDebug) {
            Atelier.openLogger(false);
        }
        else {
            Atelier.openLogger(true);
        }

        try {
            startup(args);
        }
        catch (GrCompilerException e) {
            Atelier.log(e.msg);
        }
        catch (Exception e) {
            Atelier.log("Erreur: ", e.msg);
            version (AtelierDebug) {
                foreach (trace; e.info) {
                    Atelier.log("à: ", trace);
                }
            }
        }
        finally {
            Atelier.closeLogger();
            Atelier.close();
        }
    }
}
*/
