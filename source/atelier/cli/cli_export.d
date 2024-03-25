/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.cli.cli_export;

import std.conv : to;
import std.datetime;
import std.exception;
import std.file;
import std.path;
import std.zlib;

import farfadet;
import grimoire;
import atelier.common;
import atelier.core;
import atelier.script;

void cliExport(Cli.Result cli) {
    if (cli.hasOption("help")) {
        log(cli.getHelp(cli.name));
        return;
    }

    string redistPath = buildNormalizedPath(dirName(thisExePath()), Atelier_Exe);
    enforce(redistPath, "impossible de trouver `" ~ redistPath ~ "`");

    string libraryPath = buildNormalizedPath(dirName(thisExePath()), Atelier_Library);
    enforce(libraryPath, "impossible de trouver `" ~ libraryPath ~ "`");

    string dir = getcwd();
    string dirBaseName = baseName(dir);

    if (cli.optionalParamCount() >= 1) {
        enforce(isValidPath(cli.getOptionalParam(0)), "chemin non valide");
        dirBaseName = baseName(cli.getOptionalParam(0));
        dir = buildNormalizedPath(dir, cli.getOptionalParam(0));
    }
    enforce(!extension(dirBaseName).length, "le nom du projet ne peut pas être un fichier");

    string projectFile = buildNormalizedPath(dir, Atelier_Project_File);
    enforce(exists(projectFile),
        "aucun fichier de projet `" ~ Atelier_Project_File ~
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

            string exportDir = buildNormalizedPath(dir,
                configNode.getNode("export", 1).get!string(0));

            if (!exists(exportDir))
                mkdir(exportDir);

            string newRedistPath = buildNormalizedPath(exportDir, setExtension(configName, "exe"));
            std.file.copy(redistPath, newRedistPath);

            string newLibraryPath = buildNormalizedPath(exportDir, Atelier_Library);
            std.file.copy(libraryPath, newLibraryPath);

            string envPath = buildNormalizedPath(exportDir,
                setExtension(configName, Atelier_Application_Extension));

            const(Farfadet[]) resourcesNode = configNode.getNodes("resource", 1);
            string[] archives;

            ResourceManager res = new ResourceManager;
            setupDefaultResourceLoaders(res);

            foreach (resNode; resourcesNode) {
                string resName = resNode.get!string(0);
                string resFolder = resName;
                if (resNode.hasNode("path")) {
                    resFolder = resNode.getNode("path", 1).get!string(0);
                }
                resFolder = buildNormalizedPath(dir, resFolder);
                enforce(exists(resFolder), "le dossier de ressources `" ~ resFolder ~
                        "` référencé dans `" ~ Atelier_Project_File ~ "` n’existe pas");

                Archive archive = new Archive;
                archive.pack(resFolder);

                bool isArchived = true;
                if (resNode.hasNode("archived")) {
                    isArchived = resNode.getNode("archived", 1).get!bool(0);
                }

                if (isArchived) {
                    string resDir = buildNormalizedPath(exportDir,
                        setExtension(resName, Atelier_Archive_Extension));
                    log("Archivage de `" ~ resFolder ~ "` vers `", resDir, "`");

                    foreach (file; archive) {
                        if (extension(file.name) == Atelier_Resource_Extension) {
                            try {
                                OutStream stream = new OutStream;
                                stream.write!string(Atelier_Resource_Compiled_MagicWord);

                                Farfadet resFfd = Farfadet.fromBytes(file.data);
                                stream.write!uint(cast(uint) resFfd.getNodes().length);
                                foreach (resNode; resFfd.getNodes()) {
                                    stream.write!string(resNode.name);

                                    ResourceManager.Loader loader = res.getLoader(resNode.name);
                                    loader.compile(dirName(file.path) ~ Archive.Separator,
                                        resNode, stream);
                                }

                                file.name = setExtension(file.name,
                                    Atelier_Resource_Compiled_Extension);
                                file.data = cast(ubyte[]) stream.data;
                            }
                            catch (FarfadetSyntaxException e) {
                                string msg = file.path ~ "(" ~ to!string(
                                    e.tokenLine) ~ "," ~ to!string(e.tokenColumn) ~ "): ";
                                e.msg = msg ~ e.msg;
                                throw e;
                            }
                        }
                    }

                    archive.save(resDir);
                    archives ~= setExtension(resName, Atelier_Archive_Extension);
                }
                else {
                    string resDir = buildNormalizedPath(exportDir, resName);
                    log("Copie de `" ~ resFolder ~ "` vers `", resDir, "`");
                    archive.unpack(resDir);
                    archives ~= resName;
                }
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

            if (windowIcon.length) {
                std.file.copy(buildNormalizedPath(dir, windowIcon),
                    buildNormalizedPath(exportDir, windowIcon));
            }

            foreach (fileName; Atelier_Dependencies) {
                string filePath = buildNormalizedPath(dirName(thisExePath()), fileName);
                enforce(exists(filePath), "fichier manquant `" ~ filePath ~ "`");

                std.file.copy(filePath, buildNormalizedPath(exportDir, fileName));
            }

            GrLibrary[] libraries = [grGetStandardLibrary(), getEngineLibrary()];

            GrCompiler compiler = new GrCompiler(Atelier_Version_ID);
            foreach (library; libraries) {
                compiler.addLibrary(library);
            }

            compiler.addFile(sourceFile);

            int options = GrOption.none;

            if (cli.hasOption("profile")) {
                options |= GrOption.profile;
            }
            if (cli.hasOption("safe")) {
                options |= GrOption.safe;
            }
            if (cli.hasOption("symbols")) {
                options |= GrOption.symbols;
            }
            log("compilation de `", sourceFile, "`");

            ubyte[] bytecodeBinary;

            try {
                long startTime = Clock.currStdTime();
                GrBytecode bytecode = compiler.compile(options, GrLocale.fr_FR);
                enforce(bytecode, compiler.getError().prettify(GrLocale.fr_FR));
                double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
                log("compilation effectuée en ", to!string(loadDuration), "sec");
                bytecodeBinary = bytecode.serialize();
            }
            catch (Exception e) {
                log(e.msg);
                log("compilation échouée");
                return;
            }

            {
                OutStream envStream = new OutStream;
                envStream.write!string(Atelier_Environment_MagicWord);
                envStream.write!size_t(Atelier_Version_ID);
                envStream.write!bool(windowEnabled);

                if (windowEnabled) {
                    envStream.write!string(windowTitle);
                    envStream.write!uint(windowWidth);
                    envStream.write!uint(windowHeight);
                    envStream.write!string(windowIcon);
                }

                envStream.write!size_t(archives.length);
                foreach (string archive; archives) {
                    envStream.write!string(archive);
                }
                envStream.write!(ubyte[])(bytecodeBinary);
                std.file.write(envPath, compress(envStream.data));
                log("génération de l’application `", envPath, "`");
            }

            return;
        }
    }

    enforce(false,
        "aucune configuration `" ~ configName ~ "` défini dans `" ~ Atelier_Project_File ~ "`");
}
