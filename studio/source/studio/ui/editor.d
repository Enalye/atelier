/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.editor;

import std.file;
import std.path;
import ciel;
import farfadet;
import studio.ui.propertyeditor;
import studio.ui.tabbar;
import studio.ui.resourcelist;
import studio.ui.newproject;

private enum Default_SourceFileContent = `
event app {
    // Début du programme
    print("Bonjour le monde !");
}
`;

private enum Default_GitIgnoreContent = `
# Dossiers
export/

# Fichiers
*.pqt
*.atl
*.exe
*.dll
*.so
`;

void initApp() {
    MenuBar bar = new MenuBar;
    Editor editor = new Editor;

    bar.add("Projet", "Nouveau Projet").addEventListener("click", {
        auto modal = new NewProject;
        modal.addEventListener("newProject", {
            editor.createProject(modal.path, modal.configName, modal.sourceFile);
        });
        Ciel.pushModalUI(modal);
    });
    bar.addSeparator("Projet");
    bar.add("Projet", "Lancer");
    bar.add("Projet", "Exporter");
    bar.addSeparator("Projet");
    bar.add("Projet", "Quitter");

    bar.add("Ressource", "Nouveau Fichier");
    bar.addSeparator("Ressource");
    bar.add("Ressource", "Enregistrer");
    bar.add("Ressource", "Enregistrer Sous…");
    bar.addSeparator("Ressource");
    bar.add("Ressource", "Fermer");
    Ciel.addUI(bar);

    Ciel.addUI(editor);
}

final class Editor : UIElement {
    private {
        TabBar _tabBar;
        //Visualizer _visualizer;
        PropertyEditor _propertyEditor;
        ResourceList _resourceList;
    }

    this() {
        setSize(Vec2f(Ciel.width, Ciel.height - 35f));
        setAlign(UIAlignX.center, UIAlignY.bottom);

        _tabBar = new TabBar;
        _tabBar.setPosition(Vec2f(0f, 50f));
        addUI(_tabBar);

        {
            _resourceList = new ResourceList;
            addUI(_resourceList);
        }

        {
            _propertyEditor = new PropertyEditor;
            addUI(_propertyEditor);
        }

        addEventListener("windowSize", {
            setSize(Vec2f(Ciel.width, Ciel.height - 35f));
        });
    }

    void createProject(string path, string configName, string sourceFile) {
        Farfadet ffd = new Farfadet;

        { // Programme par défaut
            Farfadet default_ = ffd.addNode("default");
            default_.add(configName);
        }

        {
            Farfadet configNode = ffd.addNode("config").add(configName);
            configNode.addNode("source").add(sourceFile);
            configNode.addNode("export").add("export");

            Farfadet windowNode = configNode.addNode("window");
            windowNode.addNode("size").add(800).add(600);
        }

        if (!exists(path))
            mkdir(path);

        ffd.save(buildNormalizedPath(path, "atelier.ffd"));

        std.file.write(buildNormalizedPath(path, ".gitignore"), Default_GitIgnoreContent);
        std.file.write(buildNormalizedPath(path, sourceFile), Default_SourceFileContent);
    }
}
