module atelier.nav.system;

import atelier.common;
import atelier.core;
import atelier.world;

private struct NavEdge {
    Vec2i start, end;
    uint id;
    Dir dir;

    enum Dir {
        up,
        down,
        left,
        right
    }
}

final class NavSector {
    private {
        int _level;
        Vec2i _start, _end;
        NavEdge[] _edges;
    }

    void addEdge(uint id, uint start, uint end, NavEdge.Dir dir) {
        NavEdge edge;
        edge.id = id;
        edge.dir = dir;
        final switch (dir) with (NavEdge.Dir) {
        case up:
            edge.start = Vec2i(start, _start.y);
            edge.end = Vec2i(end, _start.y);
            break;
        case down:
            edge.start = Vec2i(start, _end.y);
            edge.end = Vec2i(end, _end.y);
            break;
        case left:
            edge.start = Vec2i(_start.x, start);
            edge.end = Vec2i(_start.x, end);
            break;
        case right:
            edge.start = Vec2i(_end.x, start);
            edge.end = Vec2i(_end.x, end);
            break;
        }
        _edges ~= edge;
    }

    void draw(Vec2f offset, Color color) {
        //if (_level != 0)
        //    return;

        Vec2f src = (16 * cast(Vec2f) _start) + Vec2f(-8f, -(8f + _level * 16f));
        Vec2f size = 16 * cast(Vec2f)(1 + (_end - _start));
        Atelier.renderer.drawRect(offset + src, size, color, 1f, false);

        for (uint i; i < _edges.length; ++i) {
            final switch (_edges[i].dir) with (NavEdge.Dir) {
            case up:
                src = (16 * cast(Vec2f) _edges[i].start) + Vec2f(-8f, 2f - (8f + _level * 16f));
                size = (16 * cast(Vec2f)(_edges[i].end + Vec2i(1, 0))) + Vec2f(-8f, 2f - (
                        8f + _level * 16f));
                Atelier.renderer.drawLine(offset + src, offset + size, color, 1f);
                break;
            case down:
                src = (16 * cast(Vec2f)(_edges[i].start + Vec2i(0, 1))) + Vec2f(-8f, -(
                        12f + _level * 16f));
                size = (16 * cast(Vec2f)(_edges[i].end + Vec2i(1, 1))) + Vec2f(-8f, -(
                        12f + _level * 16f));
                Atelier.renderer.drawLine(offset + src, offset + size, color, 1f);
                break;
            case left:
                src = (16 * cast(Vec2f) _edges[i].start) + Vec2f(-6f, -(8f + _level * 16f));
                size = (16 * cast(Vec2f)(_edges[i].end + Vec2i(0, 1))) + Vec2f(-6f, -(
                        8f + _level * 16f));
                Atelier.renderer.drawLine(offset + src, offset + size, color, 1f);
                break;
            case right:
                src = (16 * cast(Vec2f)(_edges[i].start + Vec2i(1, 0))) + Vec2f(-12f, 2f - (
                        8f + _level * 16f));
                size = (16 * cast(Vec2f)(_edges[i].end + Vec2i(1, 1))) + Vec2f(-12f, 2f - (
                        8f + _level * 16f));
                Atelier.renderer.drawLine(offset + src, offset + size, color, 1f);
                break;
            }
        }
    }
}

final class NavMesh {
    private {
        Grid!bool _markedTiles;
        NavSector[] _sectors;
    }

    this() {
        _markedTiles = new Grid!bool;
    }

    void clear() {
        _sectors.length = 0;
        _markedTiles.clear();
    }

    void generate() {
        _generateSectors();
        _connectSectors();
    }

    private void _generateSectors() {
        clear();

        _markedTiles.setDimensions(Atelier.world.scene.columns, Atelier.world.scene.lines);

        for (uint y; y < Atelier.world.scene.lines; ++y) {
            for (uint x; x < Atelier.world.scene.columns; ++x) {
                if (!_markedTiles.getValue(x, y)) {
                    NavSector sector = _createSector(x, y);
                    x = sector._end.x;

                    for (uint y2 = sector._start.y; y2 <= sector._end.y; ++y2) {
                        for (uint x2 = sector._start.x; x2 <= sector._end.x; ++x2) {
                            _markedTiles.setValue(x2, y2, true);
                        }
                    }

                    _sectors ~= sector;
                }
            }
        }
        Atelier.log("Généré ", _sectors.length, " secteurs");
    }

    private void _connectSectors() {
        for (uint sectorId; sectorId < _sectors.length; ++sectorId) {
            NavSector currentSector = _sectors[sectorId];

            for (uint neightborId = sectorId + 1; neightborId < _sectors.length; ++neightborId) {
                NavSector neighborSector = _sectors[neightborId];

                if (currentSector._level != neighborSector._level) // Temporaire
                    continue;

                if (currentSector._start.y == neighborSector._end.y + 1) {
                    uint startX = max(currentSector._start.x, neighborSector._start.x);
                    uint endX = min(currentSector._end.x, neighborSector._end.x);

                    if (endX >= startX) {
                        currentSector.addEdge(neightborId, startX, endX, NavEdge.Dir.up);
                        neighborSector.addEdge(sectorId, startX, endX, NavEdge.Dir.down);
                    }
                }
                else if (neighborSector._start.y == currentSector._end.y + 1) {
                    uint startX = max(currentSector._start.x, neighborSector._start.x);
                    uint endX = min(currentSector._end.x, neighborSector._end.x);

                    if (endX >= startX) {
                        currentSector.addEdge(neightborId, startX, endX, NavEdge.Dir.down);
                        neighborSector.addEdge(sectorId, startX, endX, NavEdge.Dir.up);
                    }
                }

                if (currentSector._start.x == neighborSector._end.x + 1) {
                    uint startY = max(currentSector._start.y, neighborSector._start.y);
                    uint endY = min(currentSector._end.y, neighborSector._end.y);

                    if (endY >= startY) {
                        currentSector.addEdge(neightborId, startY, endY, NavEdge.Dir.left);
                        neighborSector.addEdge(sectorId, startY, endY, NavEdge.Dir.right);
                    }
                }
                else if (neighborSector._start.x == currentSector._end.x + 1) {
                    uint startY = max(currentSector._start.y, neighborSector._start.y);
                    uint endY = min(currentSector._end.y, neighborSector._end.y);

                    if (endY >= startY) {
                        currentSector.addEdge(neightborId, startY, endY, NavEdge.Dir.right);
                        neighborSector.addEdge(sectorId, startY, endY, NavEdge.Dir.left);
                    }
                }
            }
        }
    }

    private NavSector _createSector(uint x, uint y) {
        NavSector sector = new NavSector;
        sector._start = Vec2i(x, y);
        sector._end = sector._start;
        sector._level = Atelier.world.scene.getLevel(sector._start.x, sector._start.y);
        ;

        _extendSectorDiagonally(sector);

        return sector;
    }

    void _extendSectorDiagonally(NavSector sector) {
        uint x = sector._end.x;
        uint y = sector._end.y;

        for (;;) {
            x++;
            y++;

            bool isDownAvailable = true;
            bool isRightAvailable = true;

            for (uint x2 = sector._start.x; x2 < x; ++x2) {
                if (_markedTiles.getValue(x2, y) || Atelier.world.scene.getLevel(x2, y) != sector
                    ._level) {
                    isDownAvailable = false;
                    break;
                }
            }

            for (uint y2 = sector._start.y; y2 < y; ++y2) {
                if (_markedTiles.getValue(x, y2) || Atelier.world.scene.getLevel(x, y2) != sector
                    ._level) {
                    isRightAvailable = false;
                    break;
                }
            }

            if (!isDownAvailable && !isRightAvailable)
                return;

            if (isDownAvailable && !isRightAvailable) {
                _extendSectorVertically(sector);
                return;
            }

            if (!isDownAvailable && isRightAvailable) {
                _extendSectorHorizontally(sector);
                return;
            }

            if (_markedTiles.getValue(x, y) || Atelier.world.scene.getLevel(x, y) != sector._level) {
                // Au pif ?
                _extendSectorHorizontally(sector);
                _extendSectorVertically(sector);
                return;
            }

            sector._end.x = x;
            sector._end.y = y;
        }
    }

    private void _extendSectorVertically(NavSector sector) {
        uint y = sector._end.y;

        for (;;) {
            y++;

            // Opti: on s’arrête si la zone s’agrandit
            if ((Atelier.world.scene.getLevel(sector._start.x - 1, y) == sector._level && !_markedTiles.getValue(
                    sector._start.x - 1, y) && Atelier.world.scene.getLevel(
                    sector._start.x - 2, y) == sector._level && !_markedTiles.getValue(sector._start.x - 2, y)) ||
                (Atelier.world.scene.getLevel(sector._end.x + 1, y) == sector._level && !_markedTiles.getValue(
                    sector._end.x + 1, y) && Atelier.world.scene.getLevel(
                    sector._end.x + 2, y) == sector._level) && !_markedTiles.getValue(sector._end.x + 2, y)) {
                return;
            }

            for (uint x = sector._start.x; x <= sector._end.x; ++x) {
                if (_markedTiles.getValue(x, y) || Atelier.world.scene.getLevel(x, y) != sector
                    ._level) {
                    return;
                }
            }

            sector._end.y = y;
        }
    }

    private void _extendSectorHorizontally(NavSector sector) {
        uint x = sector._end.x;

        for (;;) {
            x++;

            // Opti: on s’arrête si la zone s’agrandit
            if ((Atelier.world.scene.getLevel(x, sector._start.y - 1) == sector._level && !_markedTiles.getValue(
                    x, sector._start.y - 1) && Atelier.world.scene.getLevel(x, sector._start.y - 2) == sector._level && !_markedTiles
                    .getValue(x, sector._start.y - 2)) ||
                (Atelier.world.scene.getLevel(x, sector._end.y + 1) == sector._level && !_markedTiles.getValue(
                    x, sector._end.y + 1) && Atelier.world.scene.getLevel(x, sector._end.y + 2) == sector._level && !_markedTiles
                    .getValue(x, sector._end.y + 2))) {
                return;
            }

            for (uint y = sector._start.y; y <= sector._end.y; ++y) {
                if (_markedTiles.getValue(x, y) || Atelier.world.scene.getLevel(x, y) != sector
                    ._level) {
                    return;
                }
            }

            sector._end.x = x;
        }
    }

    void draw(Vec2f offset) {
        Color[] colors = [
            Color.blue, Color.green, Color.red, Color.cyan, Color.lime,
            Color.magenta, Color.olive, Color.orange, Color.navy, Color.gray
        ];

        uint i;

        foreach (sector; _sectors) {
            sector.draw(offset, colors[i]);
            i++;
            if (i >= colors.length)
                i = 0;
        }
    }
}
