module atelier.etabli.media.res.proxy.parameter;

import std.array : split, join;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.ui;
import atelier.render;
import atelier.world.entity : BaseEntityData;
import atelier.etabli.ui;
import atelier.etabli.media.res.entity_render;

package final class ParameterWindow : UIElement {
    private {
        VList _renderList;

        // Hurtbox
        HurtboxData _hurtbox;
        SelectButton _hurtTypeBtn, _hurtFactionBtn;
        IntegerField _hurtMinRadiusField, _hurtMaxRadiusField, _hurtHeightField;
        IntegerField _hurtAngleField, _hurtAngleDeltaField;
        IntegerField _hurtOffsetDistanceField, _hurtOffsetAngleField;

        // Base
        BaseEntityData _baseEntityData;
        TextField _controllerField;
        IntegerField _zOrderOffsetField;
        TextField _tagsField;

    }

    this(EntityRenderData[] renders, HurtboxData hurtbox_) {
        VList vlist = new VList;
        vlist.setPosition(Vec2f(8f, 8f));
        vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        vlist.setAlign(UIAlignX.left, UIAlignY.top);
        vlist.setColor(Atelier.theme.surface);
        vlist.setSpacing(8f);
        vlist.setChildAlign(UIAlignX.left);
        addUI(vlist);

        _hurtbox = hurtbox_;

        {
            LabelSeparator sep = new LabelSeparator("Rendu", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Rendus:", Atelier.theme.font));

            _renderList = new VList;
            _renderList.setSize(Vec2f(300f, 200f));

            AccentButton addBtn = new AccentButton("Ajouter");
            addBtn.addEventListener("click", {
                EntityEditRenderData modal = new EntityEditRenderData();
                modal.addEventListener("render.new", {
                    auto elt = new RenderElement(this, modal.getData());
                    _renderList.addList(elt);
                    elt.addEventListener("render", {
                        dispatchEvent("property_render", false);
                    });
                    dispatchEvent("property_render", false);
                    Atelier.ui.popModalUI();
                });
                Atelier.ui.pushModalUI(modal);
            });
            hlayout.addUI(addBtn);

            vlist.addList(_renderList);

            foreach (render; renders) {
                auto elt = new RenderElement(this, render);
                elt.addEventListener("render", {
                    dispatchEvent("property_render", false);
                });
                _renderList.addList(elt);
            }
        }

        {
            LabelSeparator sep = new LabelSeparator("Propriétés", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Contrôleur:", Atelier.theme.font));

            _controllerField = new TextField;
            _controllerField.value = _baseEntityData.controller;
            _controllerField.addEventListener("value", {
                _baseEntityData.controller = _controllerField.value;
                dispatchEvent("property_base");
            });
            hlayout.addUI(_controllerField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Ordre Z:", Atelier.theme.font));

            _zOrderOffsetField = new IntegerField;
            _zOrderOffsetField.value = _baseEntityData.zOrderOffset;
            _zOrderOffsetField.addEventListener("value", {
                _baseEntityData.zOrderOffset = _zOrderOffsetField.value;
                dispatchEvent("property_base");
            });
            hlayout.addUI(_zOrderOffsetField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Tags:", Atelier.theme.font));

            _tagsField = new TextField;
            _tagsField.value = _baseEntityData.tags.join(' ');
            _tagsField.addEventListener("value", {
                _baseEntityData.tags.length = 0;
                foreach (element; _tagsField.value.split(' ')) {
                    _baseEntityData.tags ~= element;
                }
                dispatchEvent("property_base");
            });
            hlayout.addUI(_tagsField);
        }

        {
            LabelSeparator sep = new LabelSeparator("Dégats", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Faction:", Atelier.theme.font));

            string[] hurtFactions = "none" ~ [
                __traits(allMembers, Hurtbox.Faction)
            ];
            _hurtFactionBtn = new SelectButton(hurtFactions, _hurtbox.faction);
            _hurtFactionBtn.addEventListener("value", {
                _hurtbox.faction = _hurtFactionBtn.value;
                dispatchEvent("property_hurtbox", false);
            });
            hlayout.addUI(_hurtFactionBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Type:", Atelier.theme.font));

            string[] hurtTypes = "none" ~ [__traits(allMembers, Hurtbox.Type)];
            _hurtTypeBtn = new SelectButton(hurtTypes, _hurtbox.type);
            _hurtTypeBtn.addEventListener("value", {
                _hurtbox.type = _hurtTypeBtn.value;
                dispatchEvent("property_hurtbox", false);
            });
            hlayout.addUI(_hurtTypeBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Rayon Min:", Atelier.theme.font));

            _hurtMinRadiusField = new IntegerField;
            _hurtMinRadiusField.value = _hurtbox.minRadius;
            _hurtMinRadiusField.isEnabled = (_hurtbox.type != "none");
            _hurtMinRadiusField.setMinValue(0);
            _hurtMinRadiusField.addEventListener("value", {
                _hurtbox.minRadius = _hurtMinRadiusField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtMinRadiusField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Rayon Max:", Atelier.theme.font));

            _hurtMaxRadiusField = new IntegerField;
            _hurtMaxRadiusField.value = _hurtbox.maxRadius;
            _hurtMaxRadiusField.isEnabled = (_hurtbox.type != "none");
            _hurtMaxRadiusField.setMinValue(0);
            _hurtMaxRadiusField.addEventListener("value", {
                _hurtbox.maxRadius = _hurtMaxRadiusField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtMaxRadiusField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Hauteur:", Atelier.theme.font));

            _hurtHeightField = new IntegerField;
            _hurtHeightField.value = _hurtbox.height;
            _hurtHeightField.isEnabled = (_hurtbox.type != "none");
            _hurtHeightField.setMinValue(0);
            _hurtHeightField.addEventListener("value", {
                _hurtbox.height = _hurtHeightField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtHeightField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Orientation:", Atelier.theme.font));

            _hurtAngleField = new IntegerField;
            _hurtAngleField.value = _hurtbox.angle;
            _hurtAngleField.isEnabled = (_hurtbox.type != "none");
            _hurtAngleField.setRange(0, 360);
            _hurtAngleField.addEventListener("value", {
                _hurtbox.angle = _hurtAngleField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtAngleField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Ouverture:", Atelier.theme.font));

            _hurtAngleDeltaField = new IntegerField;
            _hurtAngleDeltaField.value = _hurtbox.angleDelta;
            _hurtAngleDeltaField.isEnabled = (_hurtbox.type != "none");
            _hurtAngleDeltaField.setRange(0, 180);
            _hurtAngleDeltaField.addEventListener("value", {
                _hurtbox.angleDelta = _hurtAngleDeltaField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtAngleDeltaField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Décalage Distance:", Atelier.theme.font));

            _hurtOffsetDistanceField = new IntegerField;
            _hurtOffsetDistanceField.value = _hurtbox.offsetDist;
            _hurtOffsetDistanceField.isEnabled = (_hurtbox.type != "none");
            _hurtOffsetDistanceField.addEventListener("value", {
                _hurtbox.offsetDist = _hurtOffsetDistanceField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtOffsetDistanceField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Décalage Angle:", Atelier.theme.font));

            _hurtOffsetAngleField = new IntegerField;
            _hurtOffsetAngleField.value = _hurtbox.offsetAngle;
            _hurtOffsetAngleField.isEnabled = (_hurtbox.type != "none");
            _hurtOffsetAngleField.addEventListener("value", {
                _hurtbox.offsetAngle = _hurtOffsetAngleField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtOffsetAngleField);
        }

        {
            LabelSeparator sep = new LabelSeparator("Propriétés", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Tags:", Atelier.theme.font));
            hlayout.addUI(new TextField());

            hlayout.addUI(new Label("Bouge ?", Atelier.theme.font));
            hlayout.addUI(new Checkbox());
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });

        addEventListener("property_hurtbox", {
            bool isHurtboxEnabled = (_hurtbox.type != "none");
            _hurtMinRadiusField.isEnabled = isHurtboxEnabled;
            _hurtMaxRadiusField.isEnabled = isHurtboxEnabled;
            _hurtHeightField.isEnabled = isHurtboxEnabled;
            _hurtAngleField.isEnabled = isHurtboxEnabled;
            _hurtAngleDeltaField.isEnabled = isHurtboxEnabled;
            _hurtOffsetDistanceField.isEnabled = isHurtboxEnabled;
            _hurtOffsetAngleField.isEnabled = isHurtboxEnabled;
        });
    }

    EntityRenderData[] getRenders() {
        RenderElement[] elements = cast(RenderElement[]) _renderList.getList();
        EntityRenderData[] renders;
        foreach (RenderElement elt; elements) {
            renders ~= elt.getData();
        }
        return renders;
    }

    HurtboxData getHurtbox() {
        return _hurtbox;
    }

    private void moveUp(RenderElement item_) {
        RenderElement[] elements = cast(RenderElement[]) _renderList.getList();
        _renderList.clearList();

        for (size_t i = 1; i < elements.length; ++i) {
            if (elements[i] == item_) {
                elements[i] = elements[i - 1];
                elements[i - 1] = item_;
                break;
            }
        }

        foreach (RenderElement element; elements) {
            _renderList.addList(element);
        }
    }

    private void moveDown(RenderElement item_) {
        RenderElement[] elements = cast(RenderElement[]) _renderList.getList();
        _renderList.clearList();

        for (size_t i = 0; (i + 1) < elements.length; ++i) {
            if (elements[i] == item_) {
                elements[i] = elements[i + 1];
                elements[i + 1] = item_;
                break;
            }
        }

        foreach (RenderElement element; elements) {
            _renderList.addList(element);
        }
    }
}

private final class RenderElement : UIElement {
    private {
        ParameterWindow _param;
        EntityRenderData _data;
        Label _nameLabel, _typeLabel;
        Rectangle _rect;
        HBox _hbox;
        IconButton _upBtn, _downBtn;
        Icon _icon, _checkmark;
    }

    this(ParameterWindow param, EntityRenderData data) {
        _param = param;
        _data = new EntityRenderData(data);
        setSize(Vec2f(300f, 48f));

        _rect = Rectangle.fill(getSize());
        _rect.anchor = Vec2f.zero;
        _rect.color = Atelier.theme.foreground;
        _rect.isVisible = false;
        addImage(_rect);

        _nameLabel = new Label("", Atelier.theme.font);
        _nameLabel.setAlign(UIAlignX.left, UIAlignY.top);
        _nameLabel.setPosition(Vec2f(64f, 4f));
        _nameLabel.textColor = Atelier.theme.onNeutral;
        addUI(_nameLabel);

        _typeLabel = new Label("", Atelier.theme.font);
        _typeLabel.setAlign(UIAlignX.left, UIAlignY.bottom);
        _typeLabel.setPosition(Vec2f(64f, 4f));
        _typeLabel.textColor = Atelier.theme.neutral;
        addUI(_typeLabel);

        _icon = new Icon("editor:ffd-" ~ _data.type);
        _icon.setAlign(UIAlignX.left, UIAlignY.center);
        _icon.setPosition(Vec2f(16f, 0f));
        addUI(_icon);

        _checkmark = new Icon("editor:checkmark");
        _checkmark.setAlign(UIAlignX.left, UIAlignY.center);
        _checkmark.setPosition(Vec2f(40f, 0f));
        _checkmark.color = Atelier.theme.accent;
        _checkmark.isVisible = _data.isDefault;
        addUI(_checkmark);

        {
            _hbox = new HBox;
            _hbox.setAlign(UIAlignX.right, UIAlignY.center);
            _hbox.setPosition(Vec2f(12f, 0f));
            _hbox.setSpacing(2f);
            addUI(_hbox);

            _upBtn = new IconButton("editor:arrow-small-up");
            _upBtn.addEventListener("click", { _param.moveUp(this); });
            _hbox.addUI(_upBtn);

            _downBtn = new IconButton("editor:arrow-small-down");
            _downBtn.addEventListener("click", { _param.moveDown(this); });
            _hbox.addUI(_downBtn);

            _hbox.isVisible = false;
            _hbox.isEnabled = false;
        }

        _updateDisplay();

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
        addEventListener("click", &_onClick);
    }

    private void _onMouseEnter() {
        _rect.isVisible = true;
        _hbox.isVisible = true;
        _hbox.isEnabled = true;
    }

    private void _onMouseLeave() {
        _rect.isVisible = false;
        _hbox.isVisible = false;
        _hbox.isEnabled = false;
    }

    private void _updateDisplay() {
        _nameLabel.text = _data.name;
        _typeLabel.text = _data.type ~ ": " ~ _data.rid;
        _icon.setIcon("editor:ffd-" ~ _data.type);
        _checkmark.isVisible = _data.isDefault;
    }

    private void _onClick() {
        EntityEditRenderData modal = new EntityEditRenderData(_data);
        modal.addEventListener("render.apply", {
            _data = modal.getData();
            if (modal.isDirty()) {
                dispatchEvent("render", false);
            }
            _updateDisplay();
            Atelier.ui.popModalUI();
        });
        modal.addEventListener("render.remove", {
            dispatchEvent("render", false);
            Atelier.ui.popModalUI();
            removeUI();
        });
        Atelier.ui.pushModalUI(modal);
    }

    EntityRenderData getData() {
        return _data;
    }
}
