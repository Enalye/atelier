/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.editor;

import std.file;
import std.path;
import atelier;
import farfadet;
import studio.project;
import studio.ui.propertyeditor;
import studio.ui.tabbar;
import studio.ui.resourcelist;
import studio.ui.newproject;
import studio.ui.resourcemanager;

void initApp() {
    MenuBar bar = new MenuBar;
    Editor editor = new Editor;

    bar.add("Projet", "Nouveau Projet").addEventListener("click", {
        auto modal = new NewProject;
        modal.addEventListener("newProject", {
            Project.create(modal.path, modal.configName, modal.sourceFile);
            Atelier.ui.popModalUI();
        });
        Atelier.ui.pushModalUI(modal);
    });
    bar.add("Projet", "Ouvrir").addEventListener("click", {
        auto modal = new BrowseDir(Project.getDirectory());
        modal.addEventListener("value", {
            Project.open(modal.value);
            Atelier.ui.popModalUI();
        });
        Atelier.ui.pushModalUI(modal);
    });
    bar.add("Projet", "Fermer").addEventListener("click", { Project.close(); });
    bar.addSeparator("Projet");
    bar.add("Projet", "Lancer").addEventListener("click", { Project.run(); });
    bar.add("Projet", "Exporter").addEventListener("click", { Project.build(); });
    bar.addSeparator("Projet");
    bar.add("Projet", "Quitter").addEventListener("click", { Atelier.close(); });

    bar.add("Ressource", "Gérer les Dossiers").addEventListener("click", {
        if (!Project.isOpen())
            return;

        auto modal = new ResourceFolderManager;
        Atelier.ui.pushModalUI(modal);
    });
    bar.addSeparator("Ressource");
    bar.add("Ressource", "Nouvelle Ressource");
    bar.add("Ressource", "Enregistrer");
    bar.add("Ressource", "Enregistrer Sous…");
    bar.addSeparator("Ressource");
    bar.add("Ressource", "Fermer");
    Atelier.ui.addUI(bar);
    Atelier.ui.addUI(editor);
}

final class Editor : UIElement {
    private {
        TabBar _tabBar;
        //Visualizer _visualizer;
        PropertyEditor _propertyEditor;
        ResourceList _resourceList;
    }

    this() {
        setSize(Vec2f(Atelier.renderer.size.x, Atelier.renderer.size.y - 35f));
        setAlign(UIAlignX.center, UIAlignY.bottom);

        _tabBar = new TabBar;
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
            setSize(Vec2f(Atelier.window.width, Atelier.window.height - 35f));
        });
    }
}
