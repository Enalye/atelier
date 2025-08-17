module atelier.etabli.media.res.scene.settings;

import std.array;
import std.conv : to;
import std.path;
import std.file;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui;
import atelier.etabli.media.res.scene.common;

package final class SceneSettings : Modal {
    private {
        IntegerField _widthField, _heightField, _levelsField, _mainLevelField;
        HSlider _brightnessSlider;
        NumberField _brightnessField;
        SelectButton _weatherTypeBtn;
        HSlider _weatherValueSlider;
        NumberField _weatherValueField;
        AccentButton _applyBtn;
    }

    this(SceneDefinition definition) {
        setAlign(UIAlignX.center, UIAlignY.center);
        setSize(Vec2f(600f, 500f));

        {
            Label title = new Label("Paramètres de la scène", Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 4f));
            addUI(title);
        }

        {
            IconButton exitBtn = new IconButton("editor:exit");
            exitBtn.setAlign(UIAlignX.right, UIAlignY.top);
            exitBtn.setPosition(Vec2f(4f, 4f));
            exitBtn.addEventListener("click", &removeUI);
            addUI(exitBtn);
        }

        {
            HBox validationBox = new HBox;
            validationBox.setAlign(UIAlignX.right, UIAlignY.bottom);
            validationBox.setPosition(Vec2f(10f, 10f));
            validationBox.setSpacing(8f);
            addUI(validationBox);

            auto cancelBtn = new NeutralButton("Annuler");
            cancelBtn.addEventListener("click", &removeUI);
            validationBox.addUI(cancelBtn);

            _applyBtn = new AccentButton("Appliquer");
            _applyBtn.addEventListener("click", { dispatchEvent("apply", false); });
            validationBox.addUI(_applyBtn);
        }

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.center, UIAlignY.center);
        vbox.setChildAlign(UIAlignX.left);
        vbox.setSpacing(8f);
        addUI(vbox);

        {
            HBox hbox = new HBox;
            hbox.setSpacing(8f);
            vbox.addUI(hbox);

            hbox.addUI(new Label("Largeur:", Atelier.theme.font));

            _widthField = new IntegerField;
            _widthField.value = definition.getWidth();
            _widthField.setMinValue(0);
            hbox.addUI(_widthField);

            hbox.addUI(new Label("Hauteur:", Atelier.theme.font));

            _heightField = new IntegerField;
            _heightField.value = definition.getHeight();
            _heightField.setMinValue(0);
            hbox.addUI(_heightField);
        }

        {
            HBox hbox = new HBox;
            hbox.setSpacing(8f);
            vbox.addUI(hbox);

            hbox.addUI(new Label("Niveaux:", Atelier.theme.font));

            _levelsField = new IntegerField;
            _levelsField.value = definition.levels;
            _levelsField.setMinValue(0);
            hbox.addUI(_levelsField);

            hbox.addUI(new Label("Niveau Principal:", Atelier.theme.font));

            _mainLevelField = new IntegerField;
            _mainLevelField.value = definition.mainLevel;
            _mainLevelField.setMinValue(0);
            hbox.addUI(_mainLevelField);

            /*AccentButton addBtn = new AccentButton("+ Ajouter");
            addBtn.setAlign(UIAlignX.left, UIAlignY.top);
            addBtn.setPosition(Vec2f(4f, 32f));
            addBtn.addEventListener("click", {
                _list.addList(new LevelElement(_list.getList().length, 0));
            });
            hbox.addUI(addBtn);*/
        }

        {
            HBox hbox = new HBox;
            hbox.setSpacing(8f);
            vbox.addUI(hbox);

            hbox.addUI(new Label("Luminosité:", Atelier.theme.font));

            _brightnessSlider = new HSlider;
            _brightnessSlider.minValue = 0f;
            _brightnessSlider.maxValue = 1f;
            _brightnessSlider.steps = 100;
            _brightnessSlider.fvalue = definition.brightness;
            _brightnessSlider.addEventListener("value", {
                _brightnessField.value = _brightnessSlider.fvalue;
            });
            hbox.addUI(_brightnessSlider);

            _brightnessField = new NumberField;
            _brightnessField.setRange(0f, 1f);
            _brightnessField.setStep(.1f);
            _brightnessField.value = definition.brightness;
            _brightnessField.addEventListener("value", {
                _brightnessSlider.fvalue = _brightnessField.value;
            });
            hbox.addUI(_brightnessField);
        }

        {
            HBox hbox = new HBox;
            hbox.setSpacing(8f);
            vbox.addUI(hbox);

            hbox.addUI(new Label("Météo:", Atelier.theme.font));

            _weatherTypeBtn = new SelectButton(Atelier.world.weather.getList(),
                definition.weatherType);
            hbox.addUI(_weatherTypeBtn);

            _weatherValueSlider = new HSlider;
            _weatherValueSlider.minValue = 0f;
            _weatherValueSlider.maxValue = 1f;
            _weatherValueSlider.steps = 100;
            _weatherValueSlider.fvalue = definition.weatherValue;
            _weatherValueSlider.addEventListener("value", {
                _weatherValueField.value = _weatherValueSlider.fvalue;
            });
            hbox.addUI(_weatherValueSlider);

            _weatherValueField = new NumberField;
            _weatherValueField.setRange(0f, 1f);
            _weatherValueField.setStep(.1f);
            _weatherValueField.value = definition.weatherValue;
            _weatherValueField.addEventListener("value", {
                _weatherValueSlider.fvalue = _weatherValueField.value;
            });
            hbox.addUI(_weatherValueField);
        }

        /+{
            _list = new VList;
            _list.setSize(Vec2f(getWidth() - 10f, 300f));
            _list.setPosition(Vec2f(0f, 8f));
            _list.addEventListener("removelist", {
                foreach (const size_t i, ref UIElement child; _list.getList()) {
                    (cast(LevelElement) child).setID(i);
                }
            });
            vbox.addUI(_list);

            size_t i;
            foreach (level; definition.levels) {
                auto elt = new LevelElement(i, level);
                _list.addList(elt);
                i++;
            }
        }+/
    }

    int getGridWidth() {
        return _widthField.value;
    }

    int getGridHeight() {
        return _heightField.value;
    }

    int getLevels() {
        return _levelsField.value;
    }

    int getMainLevel() {
        return _mainLevelField.value;
    }

    float getBrightness() {
        return _brightnessSlider.fvalue;
    }

    string getWeatherType() {
        return _weatherTypeBtn.value();
    }

    float getWeatherValue() {
        return _weatherValueSlider.fvalue;
    }

    /+
    int[] getLevels() {
        int[] result;
        foreach (elt; cast(LevelElement[]) _list.getList()) {
            result ~= elt.getLevel();
        }
        return result;
    }+/
}
/+
package final class LevelElement : UIElement {
    private {
        Label _idLabel;
        IntegerField _heightField;
        DangerButton _removeBtn;
    }

    this(size_t id, int height) {
        setSize(Vec2f(580f, 48f));

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.left, UIAlignY.center);
            hbox.setSpacing(8f);
            addUI(hbox);

            _idLabel = new Label("Niveau " ~ to!string(id) ~ " - ", Atelier.theme.font);
            hbox.addUI(_idLabel);

            hbox.addUI(new Label("Hauteur:", Atelier.theme.font));

            _heightField = new IntegerField;
            _heightField.value = height;
            hbox.addUI(_heightField);
            /*
            hbox.addUI(new Label("Distance:", Atelier.theme.font));

            _distanceField = new NumberField;
            _distanceField.value = distance;
            _distanceField.setStep(0.1f);
            _distanceField.setRange(0.1f, 2f);
            hbox.addUI(_distanceField);*/
        }

        {
            _removeBtn = new DangerButton("Retirer");
            _removeBtn.setAlign(UIAlignX.right, UIAlignY.center);
            _removeBtn.addEventListener("click", &removeUI);
            addUI(_removeBtn);
        }
    }

    void setID(size_t id) {
        _idLabel.text = "Niveau " ~ to!string(id) ~ " - ";
    }

    int getLevel() {
        return _heightField.value;
    }
}
+/
