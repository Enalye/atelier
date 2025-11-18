module atelier.etabli.media.res.shadow.parameter;

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
        ShadowData _data;
        IntegerField[] _clipFields;
        NumberField[] _anchorFields;
    }

    this(ShadowData data) {
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

            hlayout.addUI(new Label("Altitude Max:", Atelier.theme.font));

            IntegerField maxAltitudeField = new IntegerField;
            maxAltitudeField.value = _data.maxAltitude;
            maxAltitudeField.addEventListener("value", {
                _data.maxAltitude = maxAltitudeField.value;
                dispatchEvent("property_data", false);
            });
            hlayout.addUI(maxAltitudeField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Alpha Sol:", Atelier.theme.font));

            NumberField groundAlphaField = new NumberField;
            groundAlphaField.value = _data.groundAlpha;
            groundAlphaField.addEventListener("value", {
                _data.groundAlpha = groundAlphaField.value;
                dispatchEvent("property_data", false);
            });
            hlayout.addUI(groundAlphaField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Alpha Hauteur:", Atelier.theme.font));

            NumberField highAlphaField = new NumberField;
            highAlphaField.value = _data.highAlpha;
            highAlphaField.addEventListener("value", {
                _data.highAlpha = highAlphaField.value;
                dispatchEvent("property_data", false);
            });
            hlayout.addUI(highAlphaField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Taille Sol:", Atelier.theme.font));

            NumberField groundScaleField = new NumberField;
            groundScaleField.value = _data.groundScale;
            groundScaleField.addEventListener("value", {
                _data.groundScale = groundScaleField.value;
                dispatchEvent("property_data", false);
            });
            hlayout.addUI(groundScaleField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Taille Hauteur:", Atelier.theme.font));

            NumberField highScaleField = new NumberField;
            highScaleField.value = _data.highScale;
            highScaleField.addEventListener("value", {
                _data.highScale = highScaleField.value;
                dispatchEvent("property_data", false);
            });
            hlayout.addUI(highScaleField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Tourne:", Atelier.theme.font));

            Checkbox isTurningCheck = new Checkbox(_data.isTurning);
            isTurningCheck.addEventListener("value", {
                _data.isTurning = isTurningCheck.value;
                dispatchEvent("property_data", false);
            });
            hlayout.addUI(isTurningCheck);
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });
    }

    ShadowData getData() {
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
