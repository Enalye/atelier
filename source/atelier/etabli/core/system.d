module atelier.etabli.core.system;

import std.exception : enforce;
import std.file;
import std.format;
import std.path;
import std.process;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.ui;
import atelier.etabli.ui;
import atelier.etabli.media;
import atelier.etabli.core.midi;

final class Etabli {
    struct ResourceInfo {
        Farfadet farfadet;
        string path;

        string getPath(string subPath) {
            return buildNormalizedPath(path, subPath);
        }
    }

    final class FarfadetCache {
        ResourceInfo[string] resources;
    }

    private {
        MenuBar _bar;
        EtabliUI _ui;
        ResourceManager _resourceManager;
        FarfadetCache[string] _farfadets;
        bool[string] _mediaFolders;
        string[] _scriptFiles;
    }

    @property {
        ResourceManager res() {
            return _resourceManager;
        }

        MenuBar bar() {
            return _bar;
        }

        string currentMedia() const {
            return _ui.currentMedia;
        }
    }

    this() {
    }

    void open() {
        Atelier.res.store("editor:small-font", {
            import atelier.core.data.vera : veraFontData;

            return TrueTypeFont.fromMemory(veraFontData, 10, 0);
        });

        _bar = new MenuBar;
        _ui = new EtabliUI;

        _bar.add("Projet", "Lancer (F5)").addEventListener("click", &(runProject));
        _bar.add("Projet", "Exporter (F6)").addEventListener("click", &(buildProject));
        _bar.addSeparator("Projet");
        _bar.add("Projet", "Quitter").addEventListener("click", {
            Atelier.close();
        });

        _bar.add("Fichier", "Nouveau (Ctrl+N)").addEventListener("click", &(createFile));
        _bar.add("Fichier", "Ouvrir (Ctrl+P)").addEventListener("click", &(openFile));
        _bar.add("Fichier", "Recharger (Ctrl+R)").addEventListener("click", &(_onReloadFile));
        _bar.add("Fichier", "Enregistrer (Ctrl+S)").addEventListener("click", &(_onSaveFile));
        _bar.add("Fichier", "Gérer les Dossiers").addEventListener("click",
            &(_onManageFolders));
        _bar.add("Fichier", "Fermer");

        Atelier.ui.addUI(_bar);
        Atelier.ui.addUI(_ui);

        loadConfig();
        initializeMidiDevices();
        reloadResources();
        Atelier.script.setCustomFiles(getScripts());
        updateRessourceFolders();

        _loadEditors();
    }

    void close() {
        closeMidiDevices();
    }

    private void _loadEditors() {
        foreach (type; [".png", ".bmp", ".jpg", ".jpeg", ".gif"]) {
            import atelier.etabli.media.imageviewer : ImageViewer;

            ContentEditor.add(type, (string path, Vec2f size) {
                return new ImageViewer(path, size);
            });
        }
        foreach (type; [".ogg", ".wav", ".mp3"]) {
            import atelier.etabli.media.audioviewer : AudioViewer;

            ContentEditor.add(type, (string path, Vec2f size) {
                return new AudioViewer(path, size);
            });
        }
        ContentEditor.add(".ttf", (string path, Vec2f size) {
            import atelier.etabli.media.fontviewer : FontViewer;

            return new FontViewer(path, size);
        });
        foreach (type; [".txt", ".log", ".ini", "md"]) {
            import atelier.etabli.media.texteditor : TextEditor;

            ContentEditor.add(type, (string path, Vec2f size) {
                return new TextEditor(path, size);
            });
        }
        ContentEditor.add(".gr", (string path, Vec2f size) {
            import atelier.etabli.media.codeeditor : CodeEditor;

            return new CodeEditor(path, size);
        });
        ContentEditor.add(".ffd", (string path, Vec2f size) {
            return new ResourceEditor(path, size);
        });
        ContentEditor.add(".seq", (string path, Vec2f size) {
            import atelier.etabli.media.sequencer : SequencerEditor;

            return new SequencerEditor(path, size);
        });

        ResourceEditor.add("texture", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.texture : TextureResourceEditor;

            return new TextureResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("sprite", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.sprite : SpriteResourceEditor;

            return new SpriteResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("ninepatch", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.ninepatch : NinePatchResourceEditor;

            return new NinePatchResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("animation", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.animation : AnimationResourceEditor;

            return new AnimationResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("multidiranimation", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.multidiranimation : MultiDirAnimationResourceEditor;

            return new MultiDirAnimationResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("tileset", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.tileset : TilesetResourceEditor;

            return new TilesetResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("tilemap", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.tilemap : TilemapResourceEditor;

            return new TilemapResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("particle", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.particle : ParticleResourceEditor;

            return new ParticleResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("sound", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.sound : SoundResourceEditor;

            return new SoundResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("music", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.music : MusicResourceEditor;

            return new MusicResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("truetype", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.truetype : TrueTypeResourceEditor;

            return new TrueTypeResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("terrain", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.terrain : TerrainResourceEditor;

            return new TerrainResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("scene", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.scene : SceneResourceEditor;

            return new SceneResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("prop", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.prop : PropResourceEditor;

            return new PropResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("actor", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.actor : ActorResourceEditor;

            return new ActorResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("shot", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.shot : ShotResourceEditor;

            return new ShotResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("proxy", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.proxy : ProxyResourceEditor;

            return new ProxyResourceEditor(editor, path, ffd, size);
        });
        ResourceEditor.add("grid", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.grid : GridResourceEditor;

            switch (ffd.getNode("type").get!string(0)) {
            case "bool":
                return cast(ResourceBaseEditor) new GridResourceEditor!bool(editor, path, ffd, size);
            case "int":
                return cast(ResourceBaseEditor) new GridResourceEditor!int(editor, path, ffd, size);
            case "uint":
                return cast(ResourceBaseEditor) new GridResourceEditor!uint(editor, path, ffd, size);
            case "float":
                return cast(ResourceBaseEditor) new GridResourceEditor!float(editor, path, ffd, size);
            default:
                return cast(ResourceBaseEditor) new InvalidResourceEditor(editor, path, ffd, size);
            }
        });
        ResourceEditor.add("instrument", (ResourceEditor editor, string path, Farfadet ffd, Vec2f size) {
            import atelier.etabli.media.res.instrument : InstrumentResourceEditor;

            return new InstrumentResourceEditor(editor, path, ffd, size);
        });
    }

    bool hasResource(string type, string rid) {
        if (type.length == 0 || rid.length == 0)
            return false;

        auto p = type in _farfadets;
        if (!p) {
            return false;
        }
        auto res = rid in p.resources;
        if (!res) {
            return false;
        }
        return true;
    }

    ResourceInfo getResource(string type, string rid) {
        auto p = type in _farfadets;
        enforce(p, "le type de ressource `" ~ type ~ "` n’existe pas");
        auto res = rid in p.resources;
        enforce(res, "la ressource `" ~ rid ~ "` n’existe pas");
        return *res;
    }

    ResourceInfo getSafeResource(T)(string rid, string default_ = "") {
        auto p = T.stringof in _farfadets;
        enforce(p, "le type de ressource `" ~ T.stringof ~ "` n’existe pas");
        auto res = rid in p.resources;
        if (!default_.length) {
            enforce(res, "la ressource `" ~ rid ~ "` n’existe pas");
            return *res;
        }
        else if (!res) {
            return Atelier.res.get!T(default_);
        }
        return *res;
    }

    string[] getResourceList(string type) {
        auto p = type in _farfadets;
        enforce(p, "le type de ressource `" ~ type ~ "` n’existe pas");
        return p.resources.keys;
    }

    string[] getScripts() {
        return _scriptFiles;
    }

    TerrainMap getTerrain(string rid) {
        TerrainMap terrainMap;

        if (hasResource("terrain", rid)) {
            auto terrainRes = getResource("terrain", rid);
            terrainMap = new TerrainMap;

            if (terrainRes.farfadet.hasNode("tileset")) {
                terrainMap.tileset = terrainRes.farfadet.getNode("tileset").get!string(0);
            }

            if (terrainRes.farfadet.hasNode("collision")) {
                terrainMap.setCollisions(0, 0,
                    terrainRes.farfadet.getNode("collision").get!(int[][])(0));
            }

            if (terrainRes.farfadet.hasNode("material")) {
                terrainMap.setMaterials(0, 0,
                    terrainRes.farfadet.getNode("material").get!(int[][])(0));
            }

            foreach (brushNode; terrainRes.farfadet.getNodes("brush")) {
                TerrainMap.Brush brush = terrainMap.addBrush(brushNode.get!string(0));
                foreach (tileNode; brushNode.getNodes("tiles")) {
                    uint id = tileNode.get!uint(0);
                    if (id >= TerrainMap.Brush.TilesSize)
                        continue;
                    brush.tiles[id] = tileNode.get!(int[])(1);
                }
                foreach (tileNode; brushNode.getNodes("cliffs")) {
                    uint id = tileNode.get!uint(0);
                    if (id >= TerrainMap.Brush.CliffsSize)
                        continue;
                    brush.cliffs[id] = tileNode.get!(int[])(1);
                }
            }
        }

        return terrainMap;
    }

    Texture getTexture(string rid) {
        Texture texture;

        if (hasResource("texture", rid)) {
            ResourceInfo info = getResource("texture", rid);

            if (info.farfadet.hasNode("file")) {
                string filePath = info.farfadet.getNode("file").get!string(0);
                filePath = info.getPath(filePath);

                if (exists(filePath)) {
                    texture = Texture.fromFile(filePath);
                }
            }
        }

        if (!texture) {
            texture = Atelier.res.get!Texture("editor:?");
        }

        return texture;
    }

    Sprite getSprite(string rid) {
        Sprite sprite;

        if (hasResource("sprite", rid)) {
            ResourceInfo info = getResource("sprite", rid);

            string textureRID;
            if (info.farfadet.hasNode("texture")) {
                textureRID = info.farfadet.getNode("texture").get!string(0);
            }
            Texture texture = getTexture(textureRID);

            Vec4u clip = Vec4u(0, 0, texture.width, texture.height);
            if (info.farfadet.hasNode("clip")) {
                clip = info.farfadet.getNode("clip").get!Vec4u(0);
            }

            sprite = new Sprite(texture, clip);
        }

        return sprite;
    }

    Animation getAnimation(string rid) {
        Animation anim;

        if (hasResource("animation", rid)) {
            ResourceInfo info = getResource("animation", rid);

            string textureRID;
            if (info.farfadet.hasNode("texture")) {
                textureRID = info.farfadet.getNode("texture").get!string(0);
            }
            Texture texture = getTexture(textureRID);

            Vec4u clip = Vec4u(0, 0, texture.width, texture.height);
            if (info.farfadet.hasNode("clip")) {
                clip = info.farfadet.getNode("clip").get!Vec4u(0);
            }

            Vec2i margin;
            if (info.farfadet.hasNode("margin")) {
                margin = info.farfadet.getNode("margin").get!Vec2i(0);
            }

            uint columns = 1;
            if (info.farfadet.hasNode("columns")) {
                columns = info.farfadet.getNode("columns").get!uint(0);
            }

            uint lines = 1;
            if (info.farfadet.hasNode("lines")) {
                lines = info.farfadet.getNode("lines").get!uint(0);
            }

            uint maxCount = columns * lines;
            if (info.farfadet.hasNode("maxCount")) {
                maxCount = info.farfadet.getNode("maxCount").get!uint(0);
            }

            int[] frames;
            if (info.farfadet.hasNode("frames")) {
                frames = info.farfadet.getNode("frames").get!(int[])(0);
            }

            uint frameTime;
            if (info.farfadet.hasNode("frameTime")) {
                frameTime = info.farfadet.getNode("frameTime").get!uint(0);
            }

            bool repeat = true;
            if (info.farfadet.hasNode("repeat")) {
                repeat = info.farfadet.getNode("repeat").get!bool(0);
            }

            anim = new Animation(texture, clip, columns, lines, maxCount);
            anim.frames = frames;
            anim.frameTime = frameTime;
            anim.margin = margin;
            anim.repeat = repeat;
        }

        return anim;
    }

    MultiDirAnimation getMultiDirAnimation(string rid) {
        MultiDirAnimation anim;

        if (hasResource("multidiranimation", rid)) {
            ResourceInfo info = getResource("multidiranimation", rid);

            string textureRID;
            if (info.farfadet.hasNode("texture")) {
                textureRID = info.farfadet.getNode("texture").get!string(0);
            }
            Texture texture = getTexture(textureRID);

            Vec4u clip = Vec4u(0, 0, texture.width, texture.height);
            if (info.farfadet.hasNode("clip")) {
                clip = info.farfadet.getNode("clip").get!Vec4u(0);
            }

            Vec2i margin;
            if (info.farfadet.hasNode("margin")) {
                margin = info.farfadet.getNode("margin").get!Vec2i(0);
            }

            uint columns = 1;
            if (info.farfadet.hasNode("columns")) {
                columns = info.farfadet.getNode("columns").get!uint(0);
            }

            uint lines = 1;
            if (info.farfadet.hasNode("lines")) {
                lines = info.farfadet.getNode("lines").get!uint(0);
            }

            uint maxCount = columns * lines;
            if (info.farfadet.hasNode("maxCount")) {
                maxCount = info.farfadet.getNode("maxCount").get!uint(0);
            }

            int[] frames;
            if (info.farfadet.hasNode("frames")) {
                frames = info.farfadet.getNode("frames").get!(int[])(0);
            }

            uint frameTime;
            if (info.farfadet.hasNode("frameTime")) {
                frameTime = info.farfadet.getNode("frameTime").get!uint(0);
            }

            bool repeat = true;
            if (info.farfadet.hasNode("repeat")) {
                repeat = info.farfadet.getNode("repeat").get!bool(0);
            }

            float dirStartAngle = 90f;
            if (info.farfadet.hasNode("dirStartAngle")) {
                dirStartAngle = info.farfadet.getNode("dirStartAngle").get!float(0);
            }

            Vec2i dirOffset;
            if (info.farfadet.hasNode("dirOffset")) {
                dirOffset = info.farfadet.getNode("dirOffset").get!Vec2i(0);
            }

            int[] dirIndexes;
            if (info.farfadet.hasNode("dirIndexes")) {
                dirIndexes = info.farfadet.getNode("dirIndexes").get!(int[])(0);
            }

            int[] dirFlipXs;
            if (info.farfadet.hasNode("dirFlipXs")) {
                dirFlipXs = info.farfadet.getNode("dirFlipXs").get!(int[])(0);
            }

            anim = new MultiDirAnimation(texture, clip, columns, lines, maxCount);
            anim.frames = frames;
            anim.frameTime = frameTime;
            anim.margin = margin;
            anim.repeat = repeat;
            anim.dirStartAngle = dirStartAngle;
            anim.dirOffset = dirOffset;
            anim.dirIndexes = dirIndexes;
            anim.dirFlipXs = dirFlipXs;
        }

        return anim;
    }

    Tileset getTileset(string name) {
        Texture texture;
        string textureRID;
        Vec4u tilesetClip;
        uint tilesetColumns;
        uint tilesetLines;
        uint tilesetMaxCount;

        if (hasResource("tileset", name)) {
            auto tilesetRes = getResource("tileset", name);

            if (tilesetRes.farfadet.hasNode("texture")) {
                textureRID = tilesetRes.farfadet.getNode("texture").get!string(0);
            }

            texture = getTexture(textureRID);

            if (tilesetRes.farfadet.hasNode("clip")) {
                tilesetClip = tilesetRes.farfadet.getNode("clip").get!Vec4u(0);
            }
            if (tilesetRes.farfadet.hasNode("columns")) {
                tilesetColumns = tilesetRes.farfadet.getNode("columns").get!uint(0);
            }
            if (tilesetRes.farfadet.hasNode("lines")) {
                tilesetLines = tilesetRes.farfadet.getNode("lines").get!uint(0);
            }
            tilesetMaxCount = tilesetColumns * tilesetLines;
            if (tilesetRes.farfadet.hasNode("maxCount")) {
                tilesetMaxCount = tilesetRes.farfadet.getNode("maxCount").get!uint(0);
            }

            uint frameTime;
            if (tilesetRes.farfadet.hasNode("frameTime")) {
                frameTime = tilesetRes.farfadet.getNode("frameTime", 1).get!uint(0);
            }

            int[] tileFrames;
            foreach (node; tilesetRes.farfadet.getNodes("tileFrame")) {
                tileFrames ~= node.get!int(0);
                tileFrames ~= node.get!int(1);
            }
        }
        else {
            texture = Atelier.res.get!Texture("editor:?");
        }

        Tileset tileset = new Tileset(texture, tilesetClip, tilesetColumns,
            tilesetLines, tilesetMaxCount);
        return tileset;
    }

    void buildProject() {
        //if (Project.isOpen()) {
        //    Project.build();
        //}
    }

    void runProject() {
        try {
            spawnProcess(["dub", "run", "--", "test"]);
        }
        catch (Exception e) {
            Atelier.log("[Atelier] Impossible de lancer le processus");
        }
    }

    void createFile() {
        auto modal = new NewFile();
        modal.addEventListener("newFile", {
            string filePath = modal.getFilePath();
            std.file.write(filePath, "");
            Atelier.ui.popModalUI();
            updateRessourceFolders();
            editFile(filePath);
        });
        Atelier.ui.pushModalUI(modal);
    }

    void openFile() {
        auto modal = new OpenFile;
        modal.addEventListener("openFile", {
            string filePath = modal.getFilePath();
            Atelier.ui.popModalUI();
            editFile(filePath);
        });
        Atelier.ui.pushModalUI(modal);
    }

    private void _onReloadFile() {
        _ui.reloadFile();
    }

    private void _onSaveFile() {
        _ui.saveFile();
    }

    private void _onManageFolders() {
        auto modal = new ResourceFolderManager;
        modal.addEventListener("updateRessourceFolders", {
            updateRessourceFolders();
            saveConfig();
        });
        Atelier.ui.pushModalUI(modal);
    }

    void updateRessourceFolders() {
        _ui.updateRessourceFolders();
    }

    ContentEditor getCurrentEditor() {
        return _ui.getCurrentEditor();
    }

    void setDirty(string path, bool isDirty) {
        _ui.setDirty(path, isDirty);
    }

    void loadConfig() {
        _mediaFolders.clear();

        string path = buildNormalizedPath(getDir(), Atelier_Configuration);
        if (!exists(path))
            return;

        Farfadet configFfd = Farfadet.fromFile(path);
        foreach (mediaNode; configFfd.getNodes("media")) {
            _mediaFolders[mediaNode.get!string(0)] = mediaNode.get!bool(1);
        }
    }

    void saveConfig() {
        Farfadet configFfd = new Farfadet();
        foreach (folder, isArchived; _mediaFolders) {
            configFfd.addNode("media").add(folder).add(isArchived);
        }

        configFfd.save(buildNormalizedPath(getDir(), Atelier_Configuration));
    }

    void editFile(string path) {
        path = buildNormalizedPath(getMediaDir(), path);
        _ui.editFile(path);
    }

    string getDir() {
        return buildNormalizedPath(getcwd());
    }

    string getMediaDir() {
        return buildNormalizedPath(getcwd(), Atelier_Media_Dir);
    }

    bool[string] getMediaFolders() {
        return _mediaFolders;
    }

    void setMediaFolders(bool[string] folders) {
        _mediaFolders = folders;
    }

    void reloadResources() {
        _resourceManager = new ResourceManager;
        Archive.File[] resourceFiles;
        _scriptFiles.length = 0;
        foreach (entry; dirEntries(getMediaDir(), SpanMode.shallow)) {
            if (stripExtension(baseName(entry)) !in _mediaFolders)
                continue;

            Archive archive = new Archive;

            string path = buildNormalizedPath(getMediaDir(), entry);

            if (isDir(path)) {
                if (!exists(path)) {
                    Atelier.log("le dossier `" ~ path ~ "` n’existe pas");
                    continue;
                }
                archive.pack(path);
            }
            else if (extension(path) == Atelier_Archive_Extension) {
                if (!exists(path)) {
                    Atelier.log("l’archive `" ~ path ~ "` n’existe pas");
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
                case Atelier_Script_Extension:
                    _scriptFiles ~= buildNormalizedPath(getMediaDir(), file.path);
                    break;
                default:
                    //_resourceManager.write(file.path, file.data);
                    break;
                }
            }
        }

        _farfadets.clear();
        foreach (Archive.File file; resourceFiles) {
            Farfadet ffd;
            try {
                ffd = Farfadet.fromBytes(file.data);
            }
            catch (FarfadetSyntaxException e) {
                WarningModal.warn("Fichier corrompu",
                    format!"Le fichier `%s` est corrompu:\nLigne %d col. %d: %s"(file.path,
                        e.tokenLine, e.tokenColumn, e.msg));
                continue;
            }
            foreach (resNode; ffd.getNodes()) {
                if (resNode.getCount() == 0)
                    continue;

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
                info.path = buildNormalizedPath(getMediaDir(), dirName(file.path));

                cache.resources[resNode.get!string(0)] = info;
            }
        }
    }
}
