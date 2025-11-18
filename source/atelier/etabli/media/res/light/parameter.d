module atelier.etabli.media.res.light.parameter;

import std.array : split, join;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.ui;
import atelier.render;
import atelier.world;
import atelier.etabli.ui;

package final class ParameterWindow : UIElement {
    private {
        // Base
        BaseLightData _data;
        IntegerField[] _clipFields;
        NumberField[] _anchorFields;
    }

    this(BaseLightData data) {
        VList vlist = new VList;
        vlist.setPosition(Vec2f(8f, 8f));
        vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        vlist.setAlign(UIAlignX.left, UIAlignY.top);
        vlist.setColor(Atelier.theme.surface);
        vlist.setSpacing(8f);
        vlist.setChildAlign(UIAlignX.left);
        addUI(vlist);

        _data = data;

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

            hlayout.addUI(new Label("Texture:", Atelier.theme.font));

            ResourceButton texSelect = new ResourceButton(_data.shadedtexture, "shadedtexture", [
                    "shadedtexture"
                ]);
            texSelect.addEventListener("value", {
                _data.shadedtexture = texSelect.getName();
                dispatchEvent("property_tex", false);
            });
            hlayout.addUI(texSelect);
        }

        {
            foreach (field; ["Position X", "Position Y", "Largeur", "Hauteur"]) {
                IntegerField numField = new IntegerField();
                numField.setMinValue(0);
                numField.addEventListener("value", {
                    _data.clip.x = _clipFields[0].value;
                    _data.clip.y = _clipFields[1].value;
                    _data.clip.z = _clipFields[2].value;
                    _data.clip.w = _clipFields[3].value;
                    dispatchEvent("property_data", false);
                });
                _clipFields ~= numField;

                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(284f, 0f));
                vlist.addList(hlayout);

                hlayout.addUI(new Label(field ~ ":", Atelier.theme.font));
                hlayout.addUI(numField);
            }

            _clipFields[0].value = data.clip.x;
            _clipFields[1].value = data.clip.y;
            _clipFields[2].value = data.clip.z;
            _clipFields[3].value = data.clip.w;
        }

        {
            foreach (field; ["Ancre X", "Ancre Y"]) {
                NumberField numField = new NumberField();
                numField.setRange(0f, 1f);
                numField.setStep(0.25f);
                numField.addEventListener("value", {
                    _data.anchor.x = _anchorFields[0].value;
                    _data.anchor.y = _anchorFields[1].value;
                    dispatchEvent("property_data", false);
                });
                _anchorFields ~= numField;

                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(284f, 0f));
                vlist.addList(hlayout);

                hlayout.addUI(new Label(field ~ ":", Atelier.theme.font));
                hlayout.addUI(numField);
            }

            _anchorFields[0].value = data.anchor.x;
            _anchorFields[1].value = data.anchor.y;
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

            hlayout.addUI(new Label("Icône:", Atelier.theme.font));

            ResourceButton iconSelect = new ResourceButton(_data.icon, "sprite", [
                    "sprite"
                ]);
            iconSelect.addEventListener("value", {
                _data.icon = iconSelect.getName();
                dispatchEvent("property_data", false);
            });
            hlayout.addUI(iconSelect);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Tags:", Atelier.theme.font));

            TextField tagsField = new TextField;
            tagsField.value = _data.tags.join(' ');
            tagsField.addEventListener("value", {
                _data.tags.length = 0;
                foreach (element; tagsField.value.split(' ')) {
                    _data.tags ~= element;
                }
                dispatchEvent("property_data", false);
            });
            hlayout.addUI(tagsField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Contrôleur:", Atelier.theme.font));

            TextField controllerField = new TextField;
            controllerField.value = _data.controller;
            controllerField.addEventListener("value", {
                _data.controller = controllerField.value;
                dispatchEvent("property_data", false);
            });
            hlayout.addUI(controllerField);
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });
    }

    BaseLightData getData() {
        return _data;
    }

    void setClip(Vec4u clip) {
        _data.clip = clip;
        _clipFields[0].value = _data.clip.x;
        _clipFields[1].value = _data.clip.y;
        _clipFields[2].value = _data.clip.z;
        _clipFields[3].value = _data.clip.w;
    }

    void setAnchor(Vec2f anchor) {
        _data.anchor = anchor;
        _anchorFields[0].value = _data.anchor.x;
        _anchorFields[1].value = _data.anchor.y;
    }
}
