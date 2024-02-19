/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.doc;

import std.stdio : writeln, write;
import std.algorithm : min;
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

    generate(locale);

    auto elapsedTime = MonoTime.currTime() - startTime;
    writeln("Documentation générée en ", elapsedTime);
}

alias LibLoader = void function(GrLibDefinition);
void generate(GrLocale locale) {
    LibLoader[] libLoaders = getLibraryLoaders();

    string[] modules;

    int i;
    foreach (libLoader; libLoaders) {
        GrDoc doc = new GrDoc("docgen" ~ to!string(i));
        libLoader(doc);

        const string generatedText = doc.generate(locale);

        string fileName = doc.getModule();
        modules ~= fileName;
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
        generatedText ~= "* [Ressources](/resources)\n";
        generatedText ~= "* [Bibliothèque](/lib/)\n";

        string[] oldParts;
        foreach (fileName; modules) {
            string line;

            string[] parts = fileName.split(".");

            if (parts.length > 1) {
                if (parts.length > oldParts.length) {
                    for (int k = 1; k < parts.length; k++) {
                        generatedText ~= "\t";
                    }

                    int count = (cast(int) parts.length) - (cast(int) oldParts.length);
                    generatedText ~= "* ";
                    for (int k = 0; k < count - 1; k++) {
                        if (k > 0)
                            generatedText ~= ".";
                        generatedText ~= parts[k];
                    }
                    generatedText ~= "\n";
                }
                else {
                    int count = (cast(int) min(oldParts.length, parts.length)) - 1;
                    for (int p; p < count; p++) {
                        if (oldParts[p] != parts[p]) {
                            for (int k = 1; k < parts.length; k++) {
                                generatedText ~= "\t";
                            }

                            generatedText ~= "* ";
                            for (int k = p; k < cast(int)(parts.length) - 1; k++) {
                                if (k > 0)
                                    generatedText ~= ".";
                                generatedText ~= parts[k];
                            }
                            generatedText ~= "\n";
                            break;
                        }
                    }
                }
            }
            oldParts = parts;

            foreach (string key; parts) {
                line ~= "\t";
            }
            line ~= "- [" ~ parts[$ - 1] ~ "](" ~ "lib/" ~ fileName ~ ")\n";

            generatedText ~= line;
        }
        std.file.write(buildNormalizedPath("docs", "_sidebar.md"), generatedText);
    }
}
