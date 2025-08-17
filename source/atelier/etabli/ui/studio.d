module atelier.etabli.ui.studio;

import std.exception : enforce;
import std.process;

import farfadet;
import atelier;

import atelier.etabli.media;

import atelier.etabli.ui.fileexplorer;
import atelier.etabli.ui.newfile;
import atelier.etabli.ui.newproject;
import atelier.etabli.ui.openfile;
import atelier.etabli.ui.resourcemanager;
import atelier.etabli.ui.warning;

/*
private final class ExplorerToggleButton : TextButton!Rectangle {
    private {
        Rectangle _background;
    }

    this(string text_) {
        super(text_);

        setFxColor(Atelier.theme.neutral);
        setTextColor(Atelier.theme.onNeutral);
        setSize(Vec2f(Atelier.etabli.LeftPanelSize / 2f, 35f));

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
*/
final class EtabliUI : UIElement {
    private static {
        TabBar _tabBar;
        ContentEditor[string] _contentEditors;
        ContentEditor _contentEditor;
        FileExplorer _mediaExplorer;
        UIElement _lowerPanel, _rightPanel;

        enum LeftPanelSize = 250f;
        enum RightPanelSize = 317f;
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
            _mediaExplorer = new FileExplorer;
            _mediaExplorer.setAlign(UIAlignX.left, UIAlignY.top);
            addUI(_mediaExplorer);
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
                _mediaExplorer.setSize(Vec2f(LeftPanelSize, sz));
                _lowerPanel.setSize(Vec2f(LeftPanelSize, sz));
            }
            else {
                float sz = getHeight();
                _mediaExplorer.setSize(Vec2f(LeftPanelSize, sz));
            }

            if (_contentEditor) {
                _contentEditor.setSize(Vec2f(max(0f, getWidth() - (_rightPanel ?
                    (LeftPanelSize + RightPanelSize) : LeftPanelSize)), max(0f,
                    getHeight() - _tabBar.getHeight())));
            }
        });

        addEventListener("globalkey", &_onKey);
    }

    private void _onKey() {
        InputEvent event = getManager().input;

        if (event.isPressed()) {
            InputEvent.KeyButton keyEvent = event.asKeyButton();
            switch (keyEvent.button) with (InputEvent.KeyButton.Button) {
            case s:
                if (Atelier.input.hasCtrl()) {
                    saveFile();
                }
                break;
            case r:
                if (Atelier.input.hasCtrl()) {
                    reloadFile();
                }
                break;
            case n:
                if (Atelier.input.hasCtrl()) {
                    Atelier.etabli.createFile();
                }
                break;
            case o:
                if (Atelier.input.hasCtrl()) {
                }
                break;
            case p:
                if (Atelier.input.hasCtrl()) {
                    Atelier.etabli.openFile();
                }
                break;
            case f5:
                Atelier.etabli.runProject();
                break;
            case f6:
                Atelier.etabli.buildProject();
                break;
            default:
                break;
            }
        }
    }

    void reloadFile() {
        void reload() {
            Atelier.etabli.reloadResources();

            if (!_contentEditor)
                return;

            _contentEditor.saveView();

            _contentEditor.removeUI();
            _contentEditor = null;

            string path = _tabBar.value;
            auto p = path in _contentEditors;

            if (!path.length)
                return;

            _contentEditor = ContentEditor.create(path, getSize());
            _contentEditors[path] = _contentEditor;

            _contentEditor.addEventListener("panel", {
                setRightPanel(_contentEditor.getRightPanel());
            });
            _contentEditor.setAlign(UIAlignX.left, UIAlignY.bottom);
            _contentEditor.setPosition(Vec2f(LeftPanelSize, 0f));
            addUI(_contentEditor);

            _contentEditor.loadView();
            setLowerPanel(_contentEditor.getPanel());
            setRightPanel(_contentEditor.getRightPanel());
            setDirty(_contentEditor.path, false);
        }

        if (_contentEditor && _tabBar.getDirty(_contentEditor.path)) {
            WarningModal.choice("Fichier non-sauvegardé", "Le fichier n’est pas sauvegardé, recharger quand même ?",
                "Recharger sans Sauvegarder", true, { reload(); },
                "Sauvegarder puis Recharger", false, { saveFile(); reload(); });
        }
        else {
            reload();
        }
    }

    void editFile(string path) {
        if (_tabBar.hasTab(path)) {
            _tabBar.selectTab(path);
            _tabBar.dispatchEvent("value", false);
        }
        else {
            string icon;
            import std.path : extension, baseName; //Temp

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
            case ".seq":
                icon = "editor:file-sequencer";
                break;
            default:
                icon = "editor:file";
                break;
            }
            _tabBar.addTab(baseName(path), path, icon);
            _tabBar.dispatchEvent("value", false);
        }
    }

    void saveFile() {
        if (_contentEditor) {
            _contentEditor.save();
            setDirty(_contentEditor.path, false);
        }
    }

    void setDirty(string path, bool isDirty) {
        _tabBar.setDirty(path, isDirty);
    }

    void updateRessourceFolders() {
        _mediaExplorer.updateRessourceFolders();
    }

    private void setLowerPanel(UIElement element) {
        if (_lowerPanel) {
            _lowerPanel.removeUI();
        }
        _lowerPanel = element;

        if (_lowerPanel) {
            float sz = getHeight() / 2f;
            _mediaExplorer.setSize(Vec2f(LeftPanelSize, sz));
            _mediaExplorer.setAlign(UIAlignX.left, UIAlignY.top);
            _lowerPanel.setSize(Vec2f(LeftPanelSize, sz));
            _lowerPanel.setAlign(UIAlignX.left, UIAlignY.bottom);
            addUI(_lowerPanel);
        }
        else {
            float sz = getHeight();
            _mediaExplorer.setSize(Vec2f(LeftPanelSize, sz));
            _mediaExplorer.setAlign(UIAlignX.left, UIAlignY.top);
        }
    }

    private void setRightPanel(UIElement element) {
        if (_rightPanel) {
            _rightPanel.removeUI();
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
        setLowerPanel(null);
        setRightPanel(null);
    }

    private void _onTab() {
        if (_contentEditor) {
            _contentEditor.removeUI();
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

    ContentEditor getCurrentEditor() {
        return _contentEditor;
    }
}
