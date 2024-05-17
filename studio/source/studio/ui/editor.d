/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.editor;

import std.exception : enforce;
import std.file;
import std.path;
import atelier;
import farfadet;
import studio.editors;
import studio.project;
import studio.ui.tabbar;
import studio.ui.resourcelist;
import studio.ui.newproject;
import studio.ui.resourcemanager;

void initApp() {
    MenuBar bar = new MenuBar;
    Studio studio = new Studio;

    Project.setDirectory(getcwd());

    bar.add("Projet", "Nouveau Projet").addEventListener("click", {
        auto modal = new NewProject;
        modal.addEventListener("newProject", {
            Project.create(modal.path, modal.configName, modal.sourceFile);
            Atelier.ui.popModalUI();
            studio.updateRessourceFolders();
        });
        Atelier.ui.pushModalUI(modal);
    });
    bar.add("Projet", "Ouvrir").addEventListener("click", {
        auto modal = new BrowseDir(Project.getDirectory());
        modal.addEventListener("value", {
            Project.open(modal.value);
            Atelier.ui.popModalUI();
            studio.updateRessourceFolders();
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
            studio.updateRessourceFolders();
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
    Atelier.ui.addUI(studio);
}

final class Studio : UIElement {
    struct ResourceInfo {
        Farfadet farfadet;
        string path;

        string getPath(string subPath) {
            return buildNormalizedPath(path, subPath);
        }
    }

    static final class FarfadetCache {
        ResourceInfo[string] resources;
    }

    private static {
        TabBar _tabBar;
        ContentEditor[string] _contentEditors;
        ContentEditor _contentEditor;
        ResourceList _resourceList;
        ResourceManager _resourceManager;
        FarfadetCache[string] _farfadets;
    }

    static @property {
        ResourceManager res() {
            return _resourceManager;
        }

        ResourceInfo getResource(string type, string name) {
            auto p = type in _farfadets;
            enforce(p, "le type de ressource `" ~ type ~ "` n’existe pas");
            auto res = name in p.resources;
            enforce(res, "la ressource `" ~ name ~ "` n’existe pas");
            return *res;
        }

        string[] getResourceList(string type) {
            auto p = type in _farfadets;
            enforce(p, "le type de ressource `" ~ type ~ "` n’existe pas");
            return p.resources.keys;
        }
    }

    this() {
        setSize(Vec2f(Atelier.renderer.size.x, Atelier.renderer.size.y - 35f));
        setAlign(UIAlignX.center, UIAlignY.bottom);

        _tabBar = new TabBar;
        _tabBar.setWidth(Atelier.window.width - 500f);
        _tabBar.setAlign(UIAlignX.left, UIAlignY.top);
        _tabBar.setPosition(Vec2f(250f, 0f));
        _tabBar.addEventListener("value", &_onTab);
        _tabBar.addEventListener("close", &_onTabClose);
        addUI(_tabBar);

        {
            _resourceList = new ResourceList;
            addUI(_resourceList);
        }

        addEventListener("windowSize", {
            setSize(Vec2f(Atelier.window.width, Atelier.window.height - 35f));
        });
    }

    void updateRessourceFolders() {
        _resourceList.updateRessourceFolders();
    }

    private void _onTabClose() {
        string path = _tabBar.lastRemovedTab;
        _contentEditors.remove(path);
    }

    private void _onTab() {
        if (_contentEditor) {
            _contentEditor.remove();
            _contentEditor = null;
        }

        string path = _tabBar.value;
        auto p = path in _contentEditors;

        if (!path.length)
            return;

        if (!p) {
            _contentEditor = ContentEditor.create(path, getSize());
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
            case ".ffd":
                icon = "editor:file-farfadet";
                break;
            default:
                icon = "editor:file";
                break;
            }
            _tabBar.addTab(baseName(path), path, icon);
        }
    }

    static void reloadResources() {
        _resourceManager = new ResourceManager;
        Archive.File[] resourceFiles;
        foreach (path, isArchived; Project.getMedias()) {
            Archive archive = new Archive;

            path = buildNormalizedPath(Project.getMediaDir(), path);

            if (isDir(path)) {
                if (!exists(path)) {
                    log("le dossier `" ~ path ~ "` n’existe pas");
                    continue;
                }
                archive.pack(path);
            }
            else if (extension(path) == Atelier_Archive_Extension) {
                if (!exists(path)) {
                    log("l’archive `" ~ path ~ "` n’existe pas");
                    continue;
                }
                archive.load(path);
            }

            foreach (file; archive) {
                const string ext = extension(file.name);
                switch (ext) {
                case Atelier_Resource_Extension:
                    resourceFiles ~= file;
                    break;
                default:
                    //_resourceManager.write(file.path, file.data);
                    break;
                }
            }
        }

        _farfadets.clear();
        foreach (Archive.File file; resourceFiles) {
            Farfadet ffd = Farfadet.fromBytes(file.data);
            foreach (resNode; ffd.getNodes()) {
                auto p = resNode.name in _farfadets;
                FarfadetCache cache;

                if (p) {
                    cache = *p;
                }
                else {
                    cache = new FarfadetCache;
                    _farfadets[resNode.name] = cache;
                }

                ResourceInfo info;
                info.farfadet = resNode;
                info.path = buildNormalizedPath(Project.getMediaDir(), dirName(file.path));
                cache.resources[resNode.get!string(0)] = info;
            }
        }
    }
}
