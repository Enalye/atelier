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

private final class ExplorerToggleButton : TextButton!Rectangle {
    private {
        Rectangle _background;
    }

    this(string text_) {
        super(text_);

        setFxColor(Atelier.theme.neutral);
        setTextColor(Atelier.theme.onNeutral);
        setSize(Vec2f(Studio.LeftPanelSize / 2f, 35f));

        _background = Rectangle.fill(getSize());
        _background.color = Atelier.theme.background;
        _background.anchor = Vec2f.zero;
        addImage(_background);

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);

        addEventListener("enable", &_onEnable);
        addEventListener("disable", &_onDisable);
    }

    private void _onEnable() {
        _background.alpha = Atelier.theme.activeOpacity;
        setTextColor(Atelier.theme.onNeutral);

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onDisable() {
        _background.alpha = Atelier.theme.inactiveOpacity;
        setTextColor(Atelier.theme.neutral);

        removeEventListener("mouseenter", &_onMouseEnter);
        removeEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onMouseEnter() {
        Color rgb = Atelier.theme.neutral;
        HSLColor hsl = HSLColor.fromColor(rgb);
        hsl.l = hsl.l * .8f;
        _background.color = hsl.toColor();
    }

    private void _onMouseLeave() {
        _background.color = Atelier.theme.accent;
    }
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
        FileExplorer _mediaExplorer, _sourceExplorer;
        UIElement _lowerPanel, _rightPanel;
        ResourceManager _resourceManager;
        FarfadetCache[string] _farfadets;
        TabGroup _explorerTab;

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
            _explorerTab = new TabGroup;
            _explorerTab.setAlign(UIAlignX.left, UIAlignY.top);
            addUI(_explorerTab);

            _explorerTab.addTab("Média", "media", "");
            _explorerTab.addTab("Source", "source", "");
            _explorerTab.select("media");

            _explorerTab.addEventListener("value", &_onExplorerTab);

            _mediaExplorer = new FileExplorer(true);
            _mediaExplorer.setPosition(Vec2f(0f, _explorerTab.getHeight()));
            _mediaExplorer.setAlign(UIAlignX.left, UIAlignY.top);
            addUI(_mediaExplorer);

            _sourceExplorer = new FileExplorer(false);
            _sourceExplorer.setPosition(Vec2f(0f, _explorerTab.getHeight()));
            _sourceExplorer.setAlign(UIAlignX.left, UIAlignY.top);

            _explorerTab.addEventListener("size", {
                _mediaExplorer.setPosition(Vec2f(0f, _explorerTab.getHeight()));
                _sourceExplorer.setPosition(Vec2f(0f, _explorerTab.getHeight()));
            });
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
                float sz = (getHeight() - _explorerTab.getHeight()) / 2f;
                _mediaExplorer.setSize(Vec2f(LeftPanelSize, sz));
                _sourceExplorer.setSize(Vec2f(LeftPanelSize, sz));
                _lowerPanel.setSize(Vec2f(LeftPanelSize, sz));
            }
            else {
                float sz = getHeight() - _explorerTab.getHeight();
                _mediaExplorer.setSize(Vec2f(LeftPanelSize, sz));
                _sourceExplorer.setSize(Vec2f(LeftPanelSize, sz));
            }

            if (_contentEditor) {
                _contentEditor.setSize(Vec2f(max(0f, getWidth() - (_rightPanel ?
                    (LeftPanelSize + RightPanelSize) : LeftPanelSize)), max(0f,
                    getHeight() - _tabBar.getHeight())));
            }
        });
    }

    void updateRessourceFolders() {
        _mediaExplorer.updateRessourceFolders();
        _sourceExplorer.updateRessourceFolders();
    }

    private void _onExplorerTab() {
        switch (_explorerTab.value) {
        case "media":
            _sourceExplorer.remove();
            addUI(_mediaExplorer);
            break;
        case "source":
            _mediaExplorer.remove();
            addUI(_sourceExplorer);
            break;
        default:
            break;
        }
    }

    private void setLowerPanel(UIElement element) {
        if (_lowerPanel) {
            _lowerPanel.remove();
        }
        _lowerPanel = element;

        if (_lowerPanel) {
            float sz = (getHeight() - _explorerTab.getHeight()) / 2f;
            _mediaExplorer.setSize(Vec2f(LeftPanelSize, sz));
            _mediaExplorer.setAlign(UIAlignX.left, UIAlignY.top);
            _sourceExplorer.setSize(Vec2f(LeftPanelSize, sz));
            _sourceExplorer.setAlign(UIAlignX.left, UIAlignY.top);
            _lowerPanel.setSize(Vec2f(LeftPanelSize, sz));
            _lowerPanel.setAlign(UIAlignX.left, UIAlignY.bottom);
            addUI(_lowerPanel);
        }
        else {
            float sz = getHeight() - _explorerTab.getHeight();
            _mediaExplorer.setSize(Vec2f(LeftPanelSize, sz));
            _mediaExplorer.setAlign(UIAlignX.left, UIAlignY.top);
            _sourceExplorer.setSize(Vec2f(LeftPanelSize, sz));
            _sourceExplorer.setAlign(UIAlignX.left, UIAlignY.top);
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

        auto p = path in _contentEditors;
        if (p) {
            p.onClose();
            _contentEditors.remove(path);
        }

        _mediaExplorer.setSize(Vec2f(LeftPanelSize, getHeight()));
        _sourceExplorer.setSize(Vec2f(LeftPanelSize, getHeight()));
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

    static ContentEditor getCurrentEditor() {
        return _contentEditor;
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
