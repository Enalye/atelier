/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
import core.runtime;
import std.exception : enforce;
import std.stdio : writeln;

version (AtelierDev) {
    export extern (D) void startupDev(string[]);

    void main(string[] args) {
        try {
            void* lib = Runtime.loadLibrary("./atelier.dll");
            enforce(lib, "could not find `atelier.dll`");

            version (Windows) {
                import core.sys.windows.winbase : GetProcAddress;

                auto startup = cast(typeof(&startupDev)) GetProcAddress(lib, startupDev.mangleof);
                enforce(startup, "startup error");
                startup(args);
            }
            else version (Posix) {
                import core.sys.posix.dlfcn : dlsym;

                auto startup = cast(typeof(&startupDev)) dlsym(lib, startupDev.mangleof);
                enforce(startup, "startup error");
                startup(args);
            }
        }
        catch (Exception e) {
            writeln(e.msg);
        }
    }
}
else version (AtelierRedist) {
    export extern (D) void startupRedist(string[]);

    void main(string[] args) {
        try {
            void* lib = Runtime.loadLibrary("./atelier.dll");
            enforce(lib, "could not find `atelier.dll`");

            version (Windows) {
                import core.sys.windows.winbase : GetProcAddress;

                auto startup = cast(typeof(&startupRedist)) GetProcAddress(lib,
                    startupRedist.mangleof);
                enforce(startup, "startup error");
                startup(args);
            }
            else version (Posix) {
                import core.sys.posix.dlfcn : dlsym;

                auto startup = cast(typeof(&startupRedist)) dlsym(lib, startupRedist.mangleof);
                enforce(startup, "startup error");
                startup(args);
            }
        }
        catch (Exception e) {
            writeln(e.msg);
        }
    }
}
