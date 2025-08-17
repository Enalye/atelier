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
    }

    this(TerrainMap terrainMap) {
        setSize(Vec2f(200f, 140f));
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
            HBox hbox = new HBox;
            hbox.setSpacing(4f);
            vbox.addUI(hbox);

            hbox.addUI(new Label("Pinceau:", Atelier.theme.font));

            _brushSelect = new SelectButton(terrainMap ? terrainMap.getBrushNames() : [
                ], "");
            hbox.addUI(_brushSelect);

            _brushSelect.addEventListener("value", {
                dispatchEvent("tool", false);
            });
        }

        {
            HBox hbox = new HBox;
            hbox.setSpacing(4f);
            vbox.addUI(hbox);

            hbox.addUI(new Label("Niveau:", Atelier.theme.font));

            _levelField = new IntegerField;
            _levelField.setMinValue(-1);
            hbox.addUI(_levelField);

            _levelField.addEventListener("value", {
                dispatchEvent("tool", false);
            });
        }

        {
            HBox hbox = new HBox;
            hbox.setSpacing(4f);
            vbox.addUI(hbox);

            hbox.addUI(new Label("Taille:", Atelier.theme.font));

            _brushSizeField = new IntegerField;
            _brushSizeField.setMinValue(1);
            _brushSizeField.value = 1;
            hbox.addUI(_brushSizeField);

            _brushSizeField.addEventListener("value", {
                dispatchEvent("tool", false);
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
}
