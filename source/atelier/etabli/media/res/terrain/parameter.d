module atelier.etabli.media.res.terrain.parameter;

import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.media.res.base;
import atelier.etabli.media.res.terrain.brush;

import atelier.etabli.ui;

package final class ParameterWindow : UIElement {
    private {
        VBox _vbox;
        RessourceButton _tilesetSelect;
        BrushList _brushList;
    }

    this(string tilesetRID, uint width_, uint height_) {
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

            _tilesetSelect = new RessourceButton(tilesetRID, "tileset", [
                    "tileset"
                ]);
            _tilesetSelect.addEventListener("value", {
                dispatchEvent("property_tilesetRID", false);
            });
            hlayout.addUI(_tilesetSelect);
        }

        {
            LabelSeparator sep = new LabelSeparator("Pinceaux", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            _brushList = new BrushList(width_, height_);
            vlist.addList(_brushList);
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });
    }

    void setDimensions(uint columns, uint lines) {
        _brushList.setDimensions(columns, lines);
    }

    string getTilesetRID() const {
        return _tilesetSelect.getName();
    }

    Tilemap getBrushTilemap() {
        return _brushList.getCurrentTilemap();
    }

    void save(Farfadet ffd) {
        _brushList.save(ffd);
    }

    void load(Farfadet ffd) {
        _brushList.load(ffd);
    }
}
