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
        EntityParameters _entityParameters;
        LightParameters _lightParameters;
        TopographicMap _topographicMap;
        TerrainList _terrainList;
        ParallaxList _parallaxList;
        CollisionList _collisionList;
    }

    this(SceneDefinition definition) {
        _definition = definition;

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
            _tabs.addTab("", "entity", "editor:scene-entity");
            _tabs.addTab("", "topography", "editor:scene-topography");
            _tabs.addTab("", "terrain", "editor:scene-terrain");
            _tabs.addTab("", "parallax", "editor:scene-parallax");
            _tabs.addTab("", "collision", "editor:scene-collision");
            _tabs.addTab("", "lighting", "editor:scene-lighting");
            vlist.addList(_tabs);

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

    private void _onTabChange() {
        _vbox.clearUI();
        closeToolbox();

        _entityParameters = null;
        _lightParameters = null;
        _topographicMap = null;
        _terrainList = null;
        _parallaxList = null;
        _collisionList = null;

        switch (_tabs.value()) {
        case "entity":
            _entityParameters = new EntityParameters(_definition);
            _entityParameters.addEventListener("property_dirty", {
                dispatchEvent("property_dirty", false);
            });
            _vbox.addUI(_entityParameters);
            break;
        case "topography":
            _topographicMap = new TopographicMap(_definition);
            _topographicMap.addEventListener("property_dirty", {
                dispatchEvent("property_dirty", false);
            });
            _vbox.addUI(_topographicMap);
            break;
        case "terrain":
            _terrainList = new TerrainList(_definition);
            _terrainList.addEventListener("property_dirty", {
                dispatchEvent("property_dirty", false);
            });
            _vbox.addUI(_terrainList);
            break;
        case "parallax":
            _parallaxList = new ParallaxList(_definition);
            _parallaxList.addEventListener("property_dirty", {
                dispatchEvent("property_dirty", false);
            });
            _vbox.addUI(_parallaxList);
            break;
        case "collision":
            _collisionList = new CollisionList(_definition);
            _collisionList.addEventListener("property_dirty", {
                dispatchEvent("property_dirty", false);
            });
            _vbox.addUI(_collisionList);
            break;
        case "lighting":
            _lightParameters = new LightParameters(_definition);
            _lightParameters.addEventListener("property_dirty", {
                dispatchEvent("property_dirty", false);
            });
            _vbox.addUI(_lightParameters);
            break;
        default:
            break;
        }

        openToolbox();
    }

    void openToolbox() {
        switch (_tabs.value()) {
        case "entity":
            if (_entityParameters) {
                _entityParameters.openToolbox();
            }
            break;
        case "topography":
            if (_topographicMap) {
                _topographicMap.openToolbox();
            }
            break;
        case "terrain":
            if (_terrainList) {
                _terrainList.openToolbox();
            }
            break;
        case "parallax":
            if (_parallaxList) {
                _parallaxList.openToolbox();
            }
            break;
        case "collision":
            if (_collisionList) {
                _collisionList.openToolbox();
            }
            break;
        case "lighting":
            if (_lightParameters) {
                _lightParameters.openToolbox();
            }
            break;
        default:
            break;
        }
    }

    void closeToolbox() {
        if (_entityParameters) {
            _entityParameters.closeToolbox();
        }
        if (_topographicMap) {
            _topographicMap.closeToolbox();
        }
        if (_terrainList) {
            _terrainList.closeToolbox();
        }
        if (_parallaxList) {
            _parallaxList.closeToolbox();
        }
        if (_collisionList) {
            _collisionList.closeToolbox();
        }
        if (_lightParameters) {
            _lightParameters.closeToolbox();
        }
    }

    void updateView(Vec2f centerPosition, Vec2f mapPosition, float zoom) {
        switch (_tabs.value()) {
        case "entity":
            _entityParameters.updateView(centerPosition, mapPosition, zoom);
            break;
        case "topography":
            _topographicMap.updateView(centerPosition, mapPosition, zoom);
            break;
        case "terrain":
            _terrainList.updateView(centerPosition, mapPosition, zoom);
            break;
        case "parallax":
            _parallaxList.updateView(centerPosition, mapPosition, zoom);
            break;
        case "collision":
            _collisionList.updateView(centerPosition, mapPosition, zoom);
            break;
        case "lighting":
            _lightParameters.updateView(centerPosition, mapPosition, zoom);
            break;
        default:
            break;
        }
    }

    void startTool(Vec2f mousePosition) {
        switch (_tabs.value()) {
        case "entity":
            _entityParameters.startTool(mousePosition);
            break;
        case "topography":
            _topographicMap.startTool(mousePosition);
            break;
        case "terrain":
            _terrainList.startTool(mousePosition);
            break;
        case "parallax":
            _parallaxList.startTool(mousePosition);
            break;
        case "collision":
            _collisionList.startTool(mousePosition);
            break;
        case "lighting":
            _lightParameters.startTool(mousePosition);
            break;
        default:
            break;
        }
    }

    void updateTool(Vec2f mousePosition) {
        switch (_tabs.value()) {
        case "entity":
            _entityParameters.updateTool(mousePosition);
            break;
        case "topography":
            _topographicMap.updateTool(mousePosition);
            break;
        case "terrain":
            _terrainList.updateTool(mousePosition);
            break;
        case "parallax":
            _parallaxList.updateTool(mousePosition);
            break;
        case "collision":
            _collisionList.updateTool(mousePosition);
            break;
        case "lighting":
            _lightParameters.updateTool(mousePosition);
            break;
        default:
            break;
        }
    }

    void endTool(Vec2f mousePosition) {
        switch (_tabs.value()) {
        case "entity":
            _entityParameters.endTool(mousePosition);
            break;
        case "topography":
            _topographicMap.endTool(mousePosition);
            break;
        case "terrain":
            _terrainList.endTool(mousePosition);
            break;
        case "parallax":
            _parallaxList.endTool(mousePosition);
            break;
        case "collision":
            _collisionList.endTool(mousePosition);
            break;
        case "lighting":
            _lightParameters.endTool(mousePosition);
            break;
        default:
            break;
        }
    }

    Vec4f getCurrentLayerClip() const {
        switch (_tabs.value()) {
        case "entity":
            return _entityParameters.getCurrentLayerClip();
        case "topography":
            return _topographicMap.getCurrentLayerClip();
        case "terrain":
            return _terrainList.getCurrentLayerClip();
        case "parallax":
            return _parallaxList.getCurrentLayerClip();
        case "collision":
            return _collisionList.getCurrentLayerClip();
        case "lighting":
            return _lightParameters.getCurrentLayerClip();
        default:
            return Vec4f.zero;
        }
    }

    void renderTool() {
        switch (_tabs.value()) {
        case "entity":
            _entityParameters.renderTool();
            break;
        case "topography":
            _topographicMap.renderTool();
            break;
        case "terrain":
            _terrainList.renderTool();
            break;
        case "parallax":
            _parallaxList.renderTool();
            break;
        case "collision":
            _collisionList.renderTool();
            break;
        case "lighting":
            _lightParameters.renderTool();
            break;
        default:
            break;
        }
    }

    void saveView() {
        view.tab = _tabs.value;

        switch (_tabs.value()) {
        case "entity":
            _entityParameters.saveView();
            break;
        case "topography":
            _topographicMap.saveView();
            break;
        case "terrain":
            _terrainList.saveView();
            break;
        case "parallax":
            _parallaxList.saveView();
            break;
        case "collision":
            _collisionList.saveView();
            break;
        case "lighting":
            _lightParameters.saveView();
            break;
        default:
            break;
        }
    }

    void loadView() {
        _tabs.selectTab(view.tab);

        switch (_tabs.value()) {
        case "entity":
            _entityParameters.loadView();
            break;
        case "topography":
            _topographicMap.loadView();
            break;
        case "terrain":
            _terrainList.loadView();
            break;
        case "parallax":
            _parallaxList.loadView();
            break;
        case "collision":
            _collisionList.loadView();
            break;
        case "lighting":
            _lightParameters.loadView();
            break;
        default:
            break;
        }
    }
}

private {
    struct EditorView {
        string tab;
    }

    EditorView view;
}
