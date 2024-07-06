/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editor.res.tilemap.toolbox;

import std.file;
import std.path;
import std.math : abs;
import atelier;
import farfadet;
import studio.project;
import studio.ui;
import studio.editor.res.base;
import studio.editor.res.tilemap.picker;
import studio.editor.res.tilemap.selection;

package class Toolbox : Modal {
    private {
        ToolGroup _toolGroup;
        int _tool;
        TilePicker _tilePicker;
    }

    this() {
        setSize(Vec2f(300f, 600f));
        setAlign(UIAlignX.left, UIAlignY.top);
        setPosition(Vec2f(258f, 75f));

        {
            Label title = new Label("Outils", Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 8f));
            addUI(title);
        }

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.center, UIAlignY.top);
            hbox.setPosition(Vec2f(0f, 32f));
            hbox.setSpacing(4f);
            addUI(hbox);

            _toolGroup = new ToolGroup;
            foreach (key; ["selection", "brush", "eraser", "bucket"]) {
                ToolButton btn = new ToolButton(_toolGroup,
                    "editor:" ~ key ~ "-button", key == "selection");
                btn.setSize(Vec2f(32f, 32f));
                hbox.addUI(btn);
            }
        }

        addEventListener("update", {
            if (_toolGroup.value != _tool) {
                _tool = _toolGroup.value;
                _onToolChange();
            }
        });

        _tilePicker = new TilePicker;
        _tilePicker.setAlign(UIAlignX.center, UIAlignY.bottom);
        _tilePicker.setPosition(Vec2f(0f, 8f));
        _tilePicker.addEventListener("value", { dispatchEvent("tool", false); });

        _onToolChange();
    }

    private void _onToolChange() {
        _tilePicker.remove();

        switch (_toolGroup.value()) {
        case 0:
            addUI(_tilePicker);
            _tilePicker.setRectMode(true);
            break;
        default:
            break;
        }

        dispatchEvent("tool", false);
    }

    int getTool() const {
        return _toolGroup.value();
    }

    TilesSelection getSelection() {
        return _tilePicker.selection;
    }

    void setTileset(Tileset tileset) {
        _tilePicker.setTileset(tileset);
    }
}
