/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.cli.cli_run;

import std.stdio, std.file, std.path;
import std.exception;
import std.process;

import farfadet;
import grimoire;
import atelier.common;
import atelier.core;
import atelier.script;

void cliRun(Cli.Result cli) {
    if (cli.hasOption("help")) {
        log(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();
    string dirName = baseName(dir);

    if (cli.optionalParamCount() >= 1) {
        enforce(isValidPath(cli.getOptionalParam(0)), "chemin non valide");
        dirName = baseName(cli.getOptionalParam(0));
        dir = buildNormalizedPath(dir, cli.getOptionalParam(0));
    }
    enforce(!extension(dirName).length, "le nom du projet ne peut pas être un fichier");

    string projectFile = buildNormalizedPath(dir, Atelier_Project_File);
    enforce(exists(projectFile),
        "aucun fichier de project `" ~ Atelier_Project_File ~
        "` de trouvé à l’emplacement `" ~ dir ~ "`");

    Farfadet ffd = Farfadet.fromFile(projectFile);

    string sourceFile;
    string configName;

    if (cli.hasOption("config")) {
        configName = cli.getOption("config").getRequiredParam(0);
    }
    else {
        configName = ffd.getNode("default", 1).get!string(0);
    }

    const Farfadet[] configsNode = ffd.getNodes("config", 1);
    foreach (configNode; configsNode) {
        if (configNode.get!string(0) == configName) {
            sourceFile = buildNormalizedPath(dir, configNode.getNode("source", 1).get!string(0));

            enforce(exists(sourceFile),
                "le fichier source `" ~ sourceFile ~ "` référencé dans `" ~
                Atelier_Project_File ~ "` n’existe pas");

            const(Farfadet[]) resourcesNode = configNode.getNodes("resource", 1);
            string[] archives;

            foreach (resNode; resourcesNode) {
                string resFolder = resNode.get!string(0);
                if (resNode.hasNode("path")) {
                    resFolder = resNode.getNode("path", 1).get!string(0);
                }
                resFolder = buildNormalizedPath(dir, resFolder);
                enforce(exists(resFolder), "le dossier de ressources `" ~ resFolder ~
                        "` référencé dans `" ~ Atelier_Project_File ~ "` n’existe pas");

                archives ~= resFolder;
            }

            bool windowEnabled = configNode.hasNode("window");

            string windowTitle = configName;
            int windowWidth = Atelier_Window_Width_Default;
            int windowHeight = Atelier_Window_Height_Default;
            string windowIcon = "";

            if (windowEnabled) {
                const Farfadet windowNode = configNode.getNode("window");

                if (windowNode.hasNode("size")) {
                    const Farfadet sizeNode = windowNode.getNode("size", 2);
                    windowWidth = sizeNode.get!uint(0);
                    windowHeight = sizeNode.get!uint(1);
                }

                if (windowNode.hasNode("title"))
                    windowTitle = windowNode.getNode("title", 1).get!string(0);

                if (windowNode.hasNode("icon"))
                    windowIcon = windowNode.getNode("icon", 1).get!string(0);
            }

            Atelier atelier = new Atelier(false, (GrLibrary[] libraries) {
                GrCompiler compiler = new GrCompiler(Atelier_Version_ID);
                foreach (library; libraries) {
                    compiler.addLibrary(library);
                }

                compiler.addFile(sourceFile);

                GrBytecode bytecode = compiler.compile(GrOption.safe | GrOption.profile | GrOption.symbols,
                    GrLocale.fr_FR);

                enforce!GrCompilerException(bytecode, compiler.getError()
                    .prettify(GrLocale.fr_FR));

                return bytecode;
            }, [grGetStandardLibrary(), getEngineLibrary()], windowWidth,
                windowHeight, windowTitle);

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

            return;
        }
    }

    enforce(false,
        "aucune configuration `" ~ configName ~ "` défini dans `" ~ Atelier_Project_File ~ "`");
}
