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
        IntegerField _maxAltitudeField;
        NumberField _groundAlphaField, _highAlphaField;
        NumberField _groundScaleField, _highScaleField;
        Checkbox _isTurningCheck;
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

            hlayout.addUI(new Label("Animation:", Atelier.theme.font));

            ResourceButton animSelect = new ResourceButton(_data.anim, "animation", [
                    "animation"
                ]);
            animSelect.addEventListener("value", {
                _data.anim = animSelect.getName();
                dispatchEvent("property_anim", false);
            });
            hlayout.addUI(animSelect);
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
}
