module atelier.etabli.media.res.scene.topography.toolbox;

import std.conv : to;
import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.scene.tilepicker;
import atelier.etabli.media.res.scene.selection;

package(atelier.etabli.media.res.scene) class TopographyToolbox : Modal {
    private {
        SelectButton _brushSelect;
        IntegerField _levelField, _brushSizeField;
        CarouselButton _debugLevelMode;
        IntegerField _debugLevelField;
    }

    this(TerrainMap terrainMap) {
        setSize(Vec2f(284f, 228f));
        setAlign(UIAlignX.left, UIAlignY.top);
        setPosition(Vec2f(258f, 75f));

        {
            Label title = new Label("Outils", Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 8f));
            addUI(title);
        }

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.center, UIAlignY.top);
        vbox.setChildAlign(UIAlignX.left);
        vbox.setPosition(Vec2f(0f, 32f));
        vbox.setSpacing(4f);
        addUI(vbox);

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(getWidth() - 16f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Pinceau:", Atelier.theme.font));

            _brushSelect = new SelectButton(terrainMap ? terrainMap.getBrushNames() : [
                ], "");
            hlayout.addUI(_brushSelect);

            _brushSelect.addEventListener("value", {
                dispatchEvent("tool", false);
            });
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(getWidth() - 16f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Niveau:", Atelier.theme.font));

            _levelField = new IntegerField;
            _levelField.setMinValue(-1);
            hlayout.addUI(_levelField);

            _levelField.addEventListener("value", {
                dispatchEvent("tool", false);
            });
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(getWidth() - 16f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Taille:", Atelier.theme.font));

            _brushSizeField = new IntegerField;
            _brushSizeField.setMinValue(1);
            _brushSizeField.value = 1;
            hlayout.addUI(_brushSizeField);

            _brushSizeField.addEventListener("value", {
                dispatchEvent("tool", false);
            });
        }

        {
            LabelSeparator sep = new LabelSeparator("Débug", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(getWidth() - 16f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vbox.addUI(sep);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(getWidth() - 16f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Affichage:", Atelier.theme.font));

            _debugLevelMode = new CarouselButton([
                "Rendu", "Calque", "Topologie", "Calque+Topo"
            ], "Rendu");
            hlayout.addUI(_debugLevelMode);

            _debugLevelMode.addEventListener("value", {
                dispatchEvent("debug", false);
            });
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(getWidth() - 16f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Niveau:", Atelier.theme.font));

            _debugLevelField = new IntegerField;
            _debugLevelField.setMinValue(0);
            hlayout.addUI(_debugLevelField);

            _debugLevelField.addEventListener("value", {
                dispatchEvent("debug", false);
            });
        }
    }

    void setTerrainMap(TerrainMap terrainMap) {
        _brushSelect.setItems(terrainMap ? terrainMap.getBrushNames() : []);
    }

    int getBrushSize() {
        return _brushSizeField.value;
    }

    int getBrushLevel() {
        return _levelField.value;
    }

    string getBrushName() {
        return _brushSelect.value;
    }

    int getDebugMode() {
        return _debugLevelMode.ivalue;
    }

    int getDebugLevel() {
        return _debugLevelField.value;
    }
}
