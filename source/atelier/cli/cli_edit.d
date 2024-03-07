/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.cli.cli_edit;

import std.stdio, std.file, std.path;
import std.exception;
import std.process;

import grimoire;
import atelier.common;
import atelier.core;
import atelier.edit;
import atelier.render;

void cliEdit(Cli.Result cli) {
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

    Json json = new Json(projectFile);

    string sourceFile;
    string configName = json.getString(Atelier_Project_DefaultConfiguration_Node, "");

    if (cli.hasOption("config")) {
        configName = cli.getOption("config").getRequiredParam(0);
    }

    Json[] configsNode = json.getObjects(Atelier_Project_Configurations_Node, []);
    foreach (Json configNode; configsNode) {
        if (configNode.getString(Atelier_Project_Name_Node, "") == configName) {
            sourceFile = buildNormalizedPath(dir, configNode.getString(Atelier_Project_Source_Node));

            enforce(exists(sourceFile),
                "le fichier source `" ~ sourceFile ~ "` référencé dans `" ~
                Atelier_Project_File ~ "` n’existe pas");

            Json[string] resourcesNode = configNode.getObject(Atelier_Project_Resources_Node)
                .getChildren();
            string[] archives;

            foreach (string resName, Json resNode; resourcesNode) {
                string resFolder = buildNormalizedPath(dir, resNode.getString("path", resName));
                enforce(exists(resFolder), "le dossier de ressources `" ~ resFolder ~
                        "` référencé dans `" ~ Atelier_Project_File ~ "` n’existe pas");

                archives ~= resFolder;
            }

            // Temporaire
            int windowWidth = 800;
            int windowHeight = 600;
            string windowTitle = "Studio Atelier";

            Atelier atelier = new Atelier(false, null, [], windowWidth, windowHeight, windowTitle);

            foreach (string archive; archives) {
                atelier.loadArchive(archive);
            }

            atelier.renderer.setScaling(Renderer.Scaling.desktop);
            atelier.window.setIcon("atelier:logo128");

            atelier.ui.addUI(new Editor);

            atelier.run();

            return;
        }
    }

    enforce(false,
        "aucune configuration `" ~ configName ~ "` défini dans `" ~ Atelier_Project_File ~ "`");
}
