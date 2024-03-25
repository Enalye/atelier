/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.core.boot;

import grimoire;
import std.exception : enforce;
import std.file : exists, isFile, thisExePath, read;
import std.path : dirName, buildNormalizedPath, setExtension;
import std.zlib;

import atelier.common;
import atelier.script;
import atelier.core.runtime;

export extern (C) void boot(string[] args) {
    string windowTitle = "Atelier ~ v" ~ Atelier_Version_Display;
    uint windowWidth = Atelier_Window_Width_Default;
    uint windowHeight = Atelier_Window_Height_Default;
    bool windowEnabled = Atelier_Window_Enabled_Default;
    string windowIcon;

    string[] archives;
    string exeDir = dirName(thisExePath());
    string envPath = setExtension(thisExePath(), Atelier_Application_Extension);

    enforce(exists(envPath), "le fichier d’initialisation `" ~ envPath ~ "` n’existe pas");

    InStream envStream = new InStream;
    envStream.set(cast(const ubyte[]) uncompress(read(envPath)));
    enforce(envStream.read!string() == Atelier_Environment_MagicWord,
        "le fichier `" ~ envPath ~ "` est invalide");
    enforce(envStream.read!size_t() == Atelier_Version_ID,
        "le fichier `" ~ envPath ~ "` est invalide");

    windowEnabled = envStream.read!bool();
    if (windowEnabled) {
        windowTitle = envStream.read!string();
        windowWidth = envStream.read!uint();
        windowHeight = envStream.read!uint();

        string iconFile = envStream.read!string();

        if (iconFile.length) {
            windowIcon = buildNormalizedPath(exeDir, iconFile);
            if (!exists(windowIcon) || isFile(windowIcon))
                windowIcon.length = 0;
        }
    }

    size_t archiveCount = envStream.read!size_t();
    for (int i; i < archiveCount; ++i) {
        archives ~= envStream.read!string();
    }

    GrBytecode bytecode = new GrBytecode();
    bytecode.deserialize(envStream.read!(ubyte[])());

    GrLibrary[] libraries = [grGetStandardLibrary(), getEngineLibrary()];

    Atelier atelier = new Atelier(true, (GrLibrary[]) => bytecode, libraries,
        windowWidth, windowHeight, windowTitle);

    foreach (string archive; archives) {
        atelier.loadArchive(archive);
    }

    if (windowIcon.length) {
        atelier.window.setIcon(windowIcon);
    }
    else {
        atelier.window.setIcon("atelier:logo128");
    }

    atelier.run();
}
