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
import studio.editors;
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
            editor.updateRessourceFolders();
        });
        Atelier.ui.pushModalUI(modal);
    });
    bar.add("Projet", "Ouvrir").addEventListener("click", {
        auto modal = new BrowseDir(Project.getDirectory());
        modal.addEventListener("value", {
            Project.open(modal.value);
            Atelier.ui.popModalUI();
            editor.updateRessourceFolders();
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
        modal.addEventListener("updateRessourceFolders", {
            editor.updateRessourceFolders();
        });
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
    private static {
        TabBar _tabBar;
        ContentEditor[string] _contentEditors;
        ContentEditor _contentEditor;
        PropertyEditor _propertyEditor;
        ResourceList _resourceList;
    }

    this() {
        setSize(Vec2f(Atelier.renderer.size.x, Atelier.renderer.size.y - 35f));
        setAlign(UIAlignX.center, UIAlignY.bottom);

        _tabBar = new TabBar;
        _tabBar.setWidth(Atelier.window.width - 500f);
        _tabBar.setAlign(UIAlignX.left, UIAlignY.top);
        _tabBar.setPosition(Vec2f(250f, 0f));
        _tabBar.addEventListener("value", &_onTab);
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

    void updateRessourceFolders() {
        _resourceList.updateRessourceFolders();
    }

    private void _onTab() {
        if (_contentEditor) {
            _contentEditor.remove();
            if (!_tabBar.hasTab(_contentEditor.path)) {
                _contentEditors.remove(_contentEditor.path);
            }
            _contentEditor = null;
        }

        string path = _tabBar.value;
        auto p = path in _contentEditors;

        if (!path.length)
            return;

        if (!p) {
            _contentEditor = ContentEditor.create(path);
            _contentEditors[path] = _contentEditor;
        }
        else {
            _contentEditor = *p;
        }
        addUI(_contentEditor);
    }

    static void editFile(string path) {
        if (_tabBar.hasTab(path)) {
            _tabBar.select(path);
        }
        else {
            string icon;
            switch (extension(path)) {
            case ".png":
            case ".bmp":
            case ".jpg":
            case ".jpeg":
            case ".gif":
                icon = "editor:file-image";
                break;
            case ".ogg":
            case ".wav":
            case ".mp3":
                icon = "editor:file-audio";
                break;
            case ".ttf":
                icon = "editor:file-font";
                break;
            case ".gr":
                icon = "editor:file-grimoire";
                break;
            default:
                icon = "editor:file";
                break;
            }
            _tabBar.addTab(baseName(path), path, icon);
        }
    }
}
