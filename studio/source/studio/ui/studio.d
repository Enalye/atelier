/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.studio;

import std.exception : enforce;
import std.file;
import std.path;
import atelier;
import farfadet;
import studio.editor;
import studio.project;
import studio.ui.tabbar;
import studio.ui.fileexplorer;
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
        FileExplorer _fileExplorer;
        UIElement _lowerPanel, _rightPanel;
        ResourceManager _resourceManager;
        FarfadetCache[string] _farfadets;

        enum LeftPanelSize = 250f;
        enum RightPanelSize = 317f;
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
        _tabBar.setWidth(max(0f, getWidth() - LeftPanelSize));
        _tabBar.setAlign(UIAlignX.left, UIAlignY.top);
        _tabBar.setPosition(Vec2f(LeftPanelSize, 0f));
        _tabBar.addEventListener("value", &_onTab);
        _tabBar.addEventListener("close", &_onTabClose);
        addUI(_tabBar);

        {
            _fileExplorer = new FileExplorer;
            addUI(_fileExplorer);
        }

        addEventListener("windowSize", {
            setSize(Vec2f(Atelier.window.width, Atelier.window.height - 35f));
            if (_rightPanel) {
                _tabBar.setWidth(max(0f, getWidth() - (LeftPanelSize + RightPanelSize)));
                _rightPanel.setSize(Vec2f(RightPanelSize, getHeight()));
            }
            else {
                _tabBar.setWidth(max(0f, getWidth() - LeftPanelSize));
            }
            if (_lowerPanel) {
                float sz = getHeight() / 2f;
                _fileExplorer.setSize(Vec2f(LeftPanelSize, sz));
                _lowerPanel.setSize(Vec2f(LeftPanelSize, sz));
            }
            else {
                _fileExplorer.setSize(Vec2f(LeftPanelSize, getHeight()));
            }

            if (_contentEditor) {
                _contentEditor.setSize(Vec2f(max(0f, getWidth() - (_rightPanel ?
                    (LeftPanelSize + RightPanelSize) : LeftPanelSize)), max(0f,
                    getHeight() - _tabBar.getHeight())));
            }
        });
    }

    void updateRessourceFolders() {
        _fileExplorer.updateRessourceFolders();
    }

    private void setLowerPanel(UIElement element) {
        if (_lowerPanel) {
            _lowerPanel.remove();
        }
        _lowerPanel = element;

        if (_lowerPanel) {
            float sz = getHeight() / 2f;
            _fileExplorer.setSize(Vec2f(LeftPanelSize, sz));
            _fileExplorer.setAlign(UIAlignX.left, UIAlignY.top);
            _lowerPanel.setSize(Vec2f(LeftPanelSize, sz));
            _lowerPanel.setAlign(UIAlignX.left, UIAlignY.bottom);
            addUI(_lowerPanel);
        }
        else {
            _fileExplorer.setSize(Vec2f(LeftPanelSize, getHeight()));
            _fileExplorer.setAlign(UIAlignX.left, UIAlignY.top);
        }
    }

    private void setRightPanel(UIElement element) {
        if (_rightPanel) {
            _rightPanel.remove();
        }
        _rightPanel = element;

        if (_rightPanel) {
            _tabBar.setWidth(max(0f, getWidth() - (LeftPanelSize + RightPanelSize)));
            _rightPanel.setSize(Vec2f(RightPanelSize, getHeight()));
            _rightPanel.setAlign(UIAlignX.right, UIAlignY.bottom);
            addUI(_rightPanel);

            if (_contentEditor) {
                _contentEditor.setSize(Vec2f(max(0f, getWidth() - (LeftPanelSize + RightPanelSize)),
                        max(0f, getHeight() - _tabBar.getHeight())));
            }
        }
        else {
            _tabBar.setWidth(max(0f, getWidth() - LeftPanelSize));
            if (_contentEditor) {
                _contentEditor.setSize(Vec2f(max(0f, getWidth() - LeftPanelSize),
                        max(0f, getHeight() - _tabBar.getHeight())));
            }
        }
    }

    private void _onTabClose() {
        string path = _tabBar.lastRemovedTab;
        _contentEditors.remove(path);
        _fileExplorer.setSize(Vec2f(LeftPanelSize, getHeight()));
        setLowerPanel(null);
        setRightPanel(null);
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

        _contentEditor.addEventListener("panel", {
            setRightPanel(_contentEditor.getRightPanel());
        });
        _contentEditor.setAlign(UIAlignX.left, UIAlignY.bottom);
        _contentEditor.setPosition(Vec2f(LeftPanelSize, 0f));
        addUI(_contentEditor);

        setLowerPanel(_contentEditor.getPanel());
        setRightPanel(_contentEditor.getRightPanel());
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
