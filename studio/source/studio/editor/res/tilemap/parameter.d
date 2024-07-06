/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editor.res.tilemap.parameter;

import std.file;
import std.path;
import std.math : abs;
import atelier;
import farfadet;
import studio.editor.res.base;
import studio.project;
import studio.ui;

package final class ParameterWindow : UIElement {
    private {
        SelectButton _tilesetSelect;
        IntegerField[] _sizeFields;
    }

    this(string tilesetRID, Vec2u gridSize) {
        VList vlist = new VList;
        vlist.setPosition(Vec2f(8f, 8f));
        vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        vlist.setAlign(UIAlignX.left, UIAlignY.top);
        vlist.setColor(Atelier.theme.surface);
        vlist.setSpacing(8f);
        vlist.setChildAlign(UIAlignX.left);
        addUI(vlist);

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

            hlayout.addUI(new Label("Tileset:", Atelier.theme.font));

            _tilesetSelect = new SelectButton(Studio.getResourceList("tileset"), tilesetRID);
            _tilesetSelect.setWidth(200f);
            _tilesetSelect.addEventListener("value", {
                dispatchEvent("property_tilesetRID", false);
            });
            hlayout.addUI(_tilesetSelect);
        }

        {
            LabelSeparator sep = new LabelSeparator("Grille", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            foreach (field; ["Largeur", "Hauteur"]) {
                IntegerField numField = new IntegerField();
                numField.setMinValue(0);
                numField.addEventListener("value", {
                    dispatchEvent("property_size", false);
                });
                _sizeFields ~= numField;

                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(284f, 0f));
                vlist.addList(hlayout);

                hlayout.addUI(new Label(field ~ ":", Atelier.theme.font));
                hlayout.addUI(numField);
            }

            _sizeFields[0].value = gridSize.x;
            _sizeFields[1].value = gridSize.y;
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });
    }

    string getTilesetRID() const {
        return _tilesetSelect.value();
    }

    Vec2u getGridSize() const {
        return Vec2u(_sizeFields[0].value(), _sizeFields[1].value());
    }

    void setGridSize(Vec2u size_) {
        Atelier.ui.blockEvents = true;
        _sizeFields[0].value = size_.x;
        _sizeFields[1].value = size_.y;
        Atelier.ui.blockEvents = false;
    }
}
