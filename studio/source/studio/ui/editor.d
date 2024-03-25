/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.editor;

import ciel;
import studio.ui.propertyeditor;
import studio.ui.tabbar;
import studio.ui.resourcelist;
import studio.ui.newproject;

void initApp() {
    MenuBar bar = new MenuBar;
    bar.add("Projet", "Nouveau Projet").addEventListener("click", {
        Ciel.pushModalUI(new NewProject);
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

    Editor editor = new Editor;
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

        {
            auto bc = new FileBrowser();
            bc.setAlign(UIAlignX.center, UIAlignY.center);
            addUI(bc);
        }

        addEventListener("windowSize", {
            setSize(Vec2f(Ciel.width, Ciel.height - 35f));
        });
    }
}
