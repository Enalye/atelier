module atelier.etabli.media.res.terrain.brush;

import std.format : format;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.terrain.add_brush;
import atelier.etabli.media.res.terrain.edit_brush;
import atelier.etabli.media.res.terrain.remove_brush;

private immutable int[] brushSwapTable = [
    // Sol
    8, 10, 9, 13, 1, 15, 5, 4, 2, 6, 7, 3, 14, 11, 12, 0
];

package final class BrushList : UIElement {
    private {
        VBox _vbox;
        VList _brushList;
        DangerButton _remBtn;
        Tileset _tileset;
        uint _columns, _lines;

        class Brush {
            private {
                string _name;
                Tilemap _tilemap;
            }

            @property {
                string name() const {
                    return _name;
                }

                string name(string name_) {
                    return _name = name_;
                }

                Tilemap tilemap() {
                    return _tilemap;
                }
            }

            this(string name_) {
                _name = name_;
                _tilemap = new Tilemap(_tileset, _columns, _lines);
            }

            void moveUp() {
                for (size_t i = 1; i < _brushes.length; ++i) {
                    if (_brushes[i] == this) {
                        _brushes[i] = _brushes[i - 1];
                        _brushes[i - 1] = this;
                        break;
                    }
                }
            }

            void moveDown() {
                for (size_t i = 0; (i + 1) < _brushes.length; ++i) {
                    if (_brushes[i] == this) {
                        _brushes[i] = _brushes[i + 1];
                        _brushes[i + 1] = this;
                        break;
                    }
                }
            }

            void remove() {
                Brush[] brushes;
                foreach (brush; _brushes) {
                    if (brush != this) {
                        brushes ~= brush;
                    }
                }
                _brushes = brushes;
            }

            void setDimensions(uint columns_, uint lines_) {
                _tilemap.setDimensions(columns_, lines_);
            }
        }

        Brush[] _brushes;
        Brush _currentBrush;
    }

    this(uint columns_, uint height_) {
        _columns = columns_;
        _lines = height_;
        _tileset = Atelier.etabli.getTileset("editor:autotile");

        {
            _vbox = new VBox;
            addUI(_vbox);

            _vbox.addEventListener("size", { setSize(_vbox.getSize()); });
        }

        {
            _brushList = new VList;
            _brushList.setSize(Vec2f(300f, 250f));
            _vbox.addUI(_brushList);
        }

        {
            HBox hbox = new HBox;
            hbox.setSpacing(4f);
            _vbox.addUI(hbox);

            AccentButton addBtn = new AccentButton("Ajouter");
            addBtn.addEventListener("click", &_onAddItem);
            hbox.addUI(addBtn);

            _remBtn = new DangerButton("Supprimer");
            _remBtn.addEventListener("click", &_onRemoveItem);
            _remBtn.isEnabled = false;
            hbox.addUI(_remBtn);
        }

        _rebuildList();
    }

    private void _rebuildList() {
        _brushList.clearList();
        foreach (brush; _brushes) {
            BrushElement elt = new BrushElement(this, brush);
            _brushList.addList(elt);
        }
    }

    private void _select(Brush brush) {
        _currentBrush = brush;
        size_t i;
        foreach (item; cast(BrushElement[]) _brushList.getList()) {
            bool isSelected = item._brush == brush;
            if (isSelected) {
                _brushList.moveToElement(i);
            }
            item.updateSelection(isSelected);
            i++;
        }

        _remBtn.isEnabled = _currentBrush !is null;
    }

    private void _onAddItem() {
        auto modal = new AddBrushElement;
        modal.addEventListener("apply", {
            Brush brush = new Brush(modal.getName());
            _brushes ~= brush;
            _rebuildList();
            _select(brush);
        });
        Atelier.ui.pushModalUI(modal);
    }

    private void _onEditItem(Brush brush) {
        auto modal = new EditBrushElement(brush.name);
        modal.addEventListener("apply", {
            brush.name = modal.getName();
            _rebuildList();
            _select(brush);
        });
        Atelier.ui.pushModalUI(modal);
    }

    private void _onRemoveItem() {
        if (!_currentBrush)
            return;

        auto modal = new RemoveBrushElement(_currentBrush.name);
        modal.addEventListener("apply", {
            _currentBrush.remove();
            _currentBrush = null;
            _rebuildList();
        });
        Atelier.ui.pushModalUI(modal);
    }

    private void moveUp(Brush brush) {
        brush.moveUp();
        _rebuildList();
        _select(brush);
    }

    private void moveDown(Brush brush) {
        brush.moveDown();
        _rebuildList();
        _select(brush);
    }

    void setDimensions(uint columns_, uint lines_) {
        _columns = columns_;
        _lines = lines_;
        foreach (Brush brush; _brushes) {
            brush.setDimensions(columns_, lines_);
        }
    }

    Tilemap getCurrentTilemap() {
        if (!_currentBrush)
            return null;
        return _currentBrush.tilemap;
    }

    void save(Farfadet ffd) {
        foreach (Brush brush; _brushes) {
            Farfadet node = ffd.addNode("brush").add(brush.name);
            int[][TerrainMap.Brush.TilesSize] tiles;
            int[][TerrainMap.Brush.CliffsSize] cliffs;

            int tileId;
            foreach (int value; brush.tilemap.getRawTiles()) {
                if (value >= 0 && value < TerrainMap.Brush.TilesSize) {
                    tiles[value] ~= tileId;
                }
                else if (value >= TerrainMap.Brush.TilesSize &&
                    value < (TerrainMap.Brush.TilesSize + TerrainMap.Brush.CliffsSize)) {
                    cliffs[value - (cast(int) TerrainMap.Brush.TilesSize)] ~= tileId;
                }
                tileId++;
            }

            int brushId;
            foreach (int i; brushSwapTable) {
                node.addNode("tiles").add(brushId).add(tiles[i]);
                brushId++;
            }

            brushId = 0;
            for (int i; i < TerrainMap.Brush.CliffsSize; ++i) {
                node.addNode("cliffs").add(brushId).add(cliffs[i]);
                brushId++;
            }
        }
    }

    void load(Farfadet ffd) {
        _brushes.length = 0;
        foreach (Farfadet node; ffd.getNodes("brush")) {
            Brush brush = new Brush(node.get!string(0));

            foreach (tilesNode; node.getNodes("tiles")) {
                int brushId = tilesNode.get!int(0);
                int[] tiles = tilesNode.get!(int[])(1);

                if (brushId >= 0 && brushId < TerrainMap.Brush.TilesSize) {
                    int id = brushSwapTable[brushId];

                    foreach (int tile; tiles) {
                        brush.tilemap.setRawTile(tile, id);
                    }
                }
            }
            foreach (tilesNode; node.getNodes("cliffs")) {
                int brushId = tilesNode.get!int(0);
                int[] tiles = tilesNode.get!(int[])(1);

                if (brushId >= 0 && brushId < TerrainMap.Brush.CliffsSize) {
                    int id = brushId + TerrainMap.Brush.TilesSize;

                    foreach (int tile; tiles) {
                        brush.tilemap.setRawTile(tile, id);
                    }
                }
            }
            _brushes ~= brush;
        }
        _rebuildList();
    }
}

package final class BrushElement : UIElement {
    private {
        BrushList _list;
        BrushList.Brush _brush;
        Rectangle _rect;
        Label _label;
        bool _isSelected;
        HBox _hbox;
        IconButton _editBtn, _upBtn, _downBtn;
    }

    this(BrushList rlist, BrushList.Brush brush) {
        _list = rlist;
        _brush = brush;
        setSize(Vec2f(284f, 32f));

        _rect = Rectangle.fill(getSize());
        _rect.anchor = Vec2f.zero;
        _rect.color = Atelier.theme.foreground;
        _rect.isVisible = false;
        addImage(_rect);

        _label = new Label(_brush.name, Atelier.theme.font);
        _label.setAlign(UIAlignX.left, UIAlignY.center);
        _label.setPosition(Vec2f(64f, 0f));
        addUI(_label);

        {
            _hbox = new HBox;
            _hbox.setAlign(UIAlignX.right, UIAlignY.center);
            _hbox.setSpacing(2f);
            addUI(_hbox);

            _editBtn = new IconButton("editor:gear");
            _editBtn.addEventListener("click", { _list._onEditItem(_brush); });
            _hbox.addUI(_editBtn);

            _upBtn = new IconButton("editor:arrow-small-up");
            _upBtn.addEventListener("click", { _list.moveUp(_brush); });
            _hbox.addUI(_upBtn);

            _downBtn = new IconButton("editor:arrow-small-down");
            _downBtn.addEventListener("click", { _list.moveDown(_brush); });
            _hbox.addUI(_downBtn);

            _hbox.isVisible = false;
            _hbox.isEnabled = false;
        }

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
        addEventListener("click", &_onClick);
    }

    private void _onMouseEnter() {
        if (_isSelected) {
            _rect.color = Atelier.theme.accent;
            _label.textColor = Atelier.theme.onAccent;
        }
        else {
            _rect.color = Atelier.theme.foreground;
            _label.textColor = Atelier.theme.onNeutral;
        }
        _rect.isVisible = true;
        _hbox.isVisible = true;
        _hbox.isEnabled = true;
    }

    private void _onMouseLeave() {
        if (_isSelected) {
            _rect.color = Atelier.theme.accent;
            _label.textColor = Atelier.theme.onAccent;
        }
        else {
            _rect.color = Atelier.theme.foreground;
            _label.textColor = Atelier.theme.onNeutral;
        }
        _rect.isVisible = _isSelected;
        _hbox.isVisible = false;
        _hbox.isEnabled = false;
    }

    private void _onClick() {
        _list._select(_brush);
    }

    protected void updateSelection(bool select_) {
        if (_isSelected == select_)
            return;

        _isSelected = select_;

        if (isHovered) {
            _onMouseEnter();
        }
        else {
            _onMouseLeave();
        }
    }
}
