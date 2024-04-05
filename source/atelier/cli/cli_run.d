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
import atelier.cli.settings;

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

    ProjectSettings settings = new ProjectSettings;
    settings.load(projectFile);

    string sourceFile;
    string configName;

    if (cli.hasOption("config")) {
        configName = cli.getOption("config").getRequiredParam(0);
    }
    else {
        configName = settings.getDefault();
    }

    ProjectSettings.Config config = settings.getConfig(configName);
    enforce(config,
        "aucune configuration `" ~ configName ~ "` défini dans `" ~ Atelier_Project_File ~ "`");

    sourceFile = buildNormalizedPath(dir, "source", config.getSource());
    enforce(exists(sourceFile),
        "le fichier source `" ~ sourceFile ~ "` référencé dans `" ~
        Atelier_Project_File ~ "` n’existe pas");

    string[] archives;
    foreach (media; config.getMedias().byKey) {
        string mediaPath = buildNormalizedPath(dir, "media", media);
        enforce(exists(mediaPath),
            "le dossier de ressources `" ~ mediaPath ~ "` référencé dans `" ~
            Atelier_Project_File ~ "` n’existe pas");
        archives ~= mediaPath;
    }

    Atelier atelier = new Atelier(false, (GrLibrary[] libraries) {
        GrCompiler compiler = new GrCompiler(Atelier_Version_ID);
        foreach (library; libraries) {
            compiler.addLibrary(library);
        }

        compiler.addFile(sourceFile);

        GrBytecode bytecode = compiler.compile(GrOption.safe | GrOption.profile | GrOption.symbols,
            GrLocale.fr_FR);

        enforce!GrCompilerException(bytecode, compiler.getError().prettify(GrLocale.fr_FR));

        return bytecode;
    }, [grGetStandardLibrary(), getEngineLibrary()], config.getWidth(),
        config.getHeight(), config.getTitle());

    foreach (string archive; archives) {
        atelier.addArchive(archive);
    }

    atelier.loadResources();

    if (config.getIcon().length) {
        atelier.window.setIcon(config.getIcon());
    }
    else {
        atelier.window.setIcon("atelier:logo128");
    }

    atelier.run();
}
