module atelier.etabli.media.res.scene.parameter;

import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.render;

import atelier.etabli.media.res.base;
import atelier.etabli.media.res.scene.common;
import atelier.etabli.media.res.scene.settings;
import atelier.etabli.media.res.scene.editor;
import atelier.etabli.media.res.scene.entity;
import atelier.etabli.media.res.scene.light;
import atelier.etabli.media.res.scene.topography;
import atelier.etabli.media.res.scene.terrain;
import atelier.etabli.media.res.scene.parallax;
import atelier.etabli.media.res.scene.collision;

import atelier.etabli.ui;

package final class ParameterWindow : UIElement {
    private {
        SceneDefinition _definition;
        TabGroup _tabs;
        VBox _vbox;
        Vec2f _viewDestination = Vec2f.zero;
        SceneSubEditor _subEditor;
        SceneResourceEditor.SubEditorFunc[string] _subEditors;
    }

    this(SceneDefinition definition, SceneResourceEditor.SubEditorDefinition[] subEditorDefinitions) {
        _definition = definition;

        SceneResourceEditor.SubEditorDefinition[] subEditors;
        subEditors ~= SceneResourceEditor.SubEditorDefinition(
            "entity",
            "editor:scene-entity",
            (SceneDefinition def) { return new EntityParameters(def); });
        subEditors ~= SceneResourceEditor.SubEditorDefinition(
            "topography",
            "editor:scene-topography",
            (SceneDefinition def) { return new TopographicMap(def); });
        subEditors ~= SceneResourceEditor.SubEditorDefinition(
            "terrain",
            "editor:scene-terrain",
            (SceneDefinition def) { return new TerrainList(def); });
        subEditors ~= SceneResourceEditor.SubEditorDefinition(
            "parallax",
            "editor:scene-parallax",
            (SceneDefinition def) { return new ParallaxList(def); });
        subEditors ~= SceneResourceEditor.SubEditorDefinition(
            "collision",
            "editor:scene-collision",
            (SceneDefinition def) { return new CollisionList(def); });
        subEditors ~= SceneResourceEditor.SubEditorDefinition(
            "lighting",
            "editor:scene-lighting",
            (SceneDefinition def) { return new LightParameters(def); });

        subEditors ~= subEditorDefinitions;

        VList vlist = new VList;
        vlist.setPosition(Vec2f(8f, 8f));
        vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        vlist.setAlign(UIAlignX.left, UIAlignY.top);
        vlist.setColor(Atelier.theme.surface);
        vlist.setSpacing(8f);
        vlist.setChildAlign(UIAlignX.left);
        addUI(vlist);

        {
            HBox hbox = new HBox;
            hbox.setSpacing(8f);
            vlist.addList(hbox);

            NeutralButton paramBtn = new NeutralButton("Paramètres");
            paramBtn.addEventListener("click", {
                SceneSettings modal = new SceneSettings(_definition);
                modal.addEventListener("apply", {
                    _definition.setSize(modal.getGridWidth(), modal.getGridHeight());
                    _definition.mainLevel = modal.getMainLevel();
                    _definition.levels = modal.getLevels();
                    _definition.brightness = modal.getBrightness();
                    _definition.weatherType = modal.getWeatherType();
                    _definition.weatherValue = modal.getWeatherValue();
                    Atelier.ui.popModalUI();
                    dispatchEvent("property_settings", false);
                });
                Atelier.ui.pushModalUI(modal);
            });
            hbox.addUI(paramBtn);

            NeutralButton testBtn = new NeutralButton("Tester");
            testBtn.addEventListener("click", {
                Atelier.etabli.runScene(_definition.name);
            });
            hbox.addUI(testBtn);
        }

        {
            _tabs = new TabGroup;
            _tabs.setWidth(284f);
            _tabs.setMaxPerLine(6);

            foreach (def; subEditors) {
                _tabs.addTab("", def.id, def.icon);
                _subEditors[def.id] = def.editorFunc;
            }
            vlist.addList(_tabs);

            Atelier.log(_tabs.getSize());

            _tabs.selectTab("entity");

            _tabs.addEventListener("value", &_onTabChange);
        }

        {
            _vbox = new VBox;
            vlist.addList(_vbox);
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });

        _onTabChange();
    }

    Vec2f getViewDestination() {
        return _viewDestination;
    }

    private void _onTabChange() {
        _vbox.clearUI();
        closeToolbox();

        _subEditor = null;

        string id = _tabs.value();
        auto p = id in _subEditors;
        if (p) {
            _subEditor = (*p)(_definition);

            _subEditor.addEventListener("property_dirty", {
                dispatchEvent("property_dirty", false);
            });
            _subEditor.addEventListener("property_centerView", {
                _viewDestination = _subEditor.getViewDestination();
                dispatchEvent("property_centerView", false);
            });
            _vbox.addUI(_subEditor);
        }
        openToolbox();
    }

    void openToolbox() {
        if (_subEditor) {
            _subEditor.openToolbox();
        }
    }

    void closeToolbox() {
        if (_subEditor) {
            _subEditor.closeToolbox();
        }
    }

    void updateView(Vec2f centerPosition, Vec2f mapPosition, float zoom) {
        if (_subEditor) {
            _subEditor.updateView(centerPosition, mapPosition, zoom);
        }
    }

    void startTool(Vec2f mousePosition) {
        if (_subEditor) {
            _subEditor.startTool(mousePosition);
        }
    }

    void updateTool(Vec2f mousePosition) {
        if (_subEditor) {
            _subEditor.updateTool(mousePosition);
        }
    }

    void endTool(Vec2f mousePosition) {
        if (_subEditor) {
            _subEditor.endTool(mousePosition);
        }
    }

    Vec4f getCurrentLayerClip() const {
        if (_subEditor) {
            return _subEditor.getCurrentLayerClip();
        }
        return Vec4f.zero;
    }

    void renderTool() {
        if (_subEditor) {
            _subEditor.renderTool();
        }
    }

    void saveView() {
        view.tab = _tabs.value;

        if (_subEditor) {
            _subEditor.saveView();
        }
    }

    void loadView() {
        _tabs.selectTab(view.tab);

        if (_subEditor) {
            _subEditor.loadView();
        }
    }
}

private {
    struct EditorView {
        string tab;
    }

    EditorView view;
}
