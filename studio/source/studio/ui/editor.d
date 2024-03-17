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

void initApp() {
    MenuBar bar = new MenuBar;
    bar.add("Projet", "Nouveau Projet").addEventListener("click", {
        import std.stdio;

        writeln("nouvprojet");
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

        addEventListener("windowSize", {
            setSize(Vec2f(Ciel.width, Ciel.height - 35f));
        });
    }
}
