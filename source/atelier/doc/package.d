/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.doc;

import std.stdio : writeln, write;
import std.string;
import std.datetime;
import std.conv : to;
import std.path;
import std.file;
import grimoire;

import atelier.script;

void generateDoc() {
    const GrLocale locale = GrLocale.fr_FR;
    auto startTime = MonoTime.currTime();

    generate(GrLocale.fr_FR);

    auto elapsedTime = MonoTime.currTime() - startTime;
    writeln("Documentation générée en: \t", elapsedTime);
}

alias LibLoader = void function(GrLibDefinition);
void generate(GrLocale locale) {
    LibLoader[] libLoaders = getLibraryLoaders();

    string[] libFileNames;

    int i;
    foreach (libLoader; libLoaders) {
        GrDoc doc = new GrDoc(["docgen" ~ to!string(i)]);
        libLoader(doc);

        const string generatedText = doc.generate(locale);

        string fileName;
        foreach (part; doc.getModule()) {
            if (fileName.length)
                fileName ~= "_";
            fileName ~= part;
        }
        libFileNames ~= fileName;
        fileName ~= ".md";
        string folderName = to!string(locale);
        auto parts = folderName.split("_");
        if (parts.length >= 1)
            folderName = parts[0];
        std.file.write(buildNormalizedPath("docs", "lib", fileName), generatedText);
        i++;
    }

    { // Barre latérale
        string generatedText = "* [Accueil](/)\n";
        generatedText ~= "* [Bibliothèque](/lib/)\n";
        foreach (fileName; libFileNames) {
            string line;

            line = "\t- [" ~ fileName ~ "](" ~ buildNormalizedPath("lib", fileName) ~ ")\n";

            generatedText ~= line;
        }
        std.file.write(buildNormalizedPath("docs", "_sidebar.md"), generatedText);
    }
}
