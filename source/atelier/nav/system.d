module atelier.nav.system;

import atelier.common;
import atelier.core;
import atelier.world;

private struct NavEdge {
    Vec2i start, end;
    Vec3i center;
    uint sectorId, edgeId;
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

    float distanceFromSquared(Vec3i position) {
        Vec3i start = Vec3i(_start * 16 - 8, _level * 16);
        Vec3i end = Vec3i((_end + 1) * 16 - 8, (_level + 1) * 16);

        if (position.isBetween(start, end))
            return 0f;

        Vec3i nearestPoint;
        nearestPoint.x = (position.x - end.x) < (position.x - start.x) ? end.x : start.x;
        nearestPoint.y = (position.y - end.y) < (position.y - start.y) ? end.y : start.y;
        nearestPoint.z = (position.z - end.z) < (position.z - start.z) ? end.z : start.z;

        return nearestPoint.distanceSquared(position);
    }

    void addEdge(uint sectorId, uint edgeId, uint start, uint end, NavEdge.Dir dir) {
        NavEdge edge;
        edge.sectorId = sectorId;
        edge.edgeId = edgeId;
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
        edge.center = Vec3i((edge.start + edge.end) * 8 - 4, _level * 16);
        _edges ~= edge;
    }

    void draw(Vec2f offset, Color color) {
        if (_level != 0)
            return;

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

struct NavPath {
    uint srcSectorID, dstSectorID;
    Vec3i[] path;
    bool isValid;
}

final class NavMesh {
    private {
        Grid!bool _markedTiles;
        NavSector[] _sectors;
        Vec3i[] _debugPath;
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

    // Retourne le secteur dans lequel le point se situe
    uint getSectorID(Vec3i position) {
        uint sectorID;
        float nearest = _sectors[0].distanceFromSquared(position);

        for (uint id = 1; id < _sectors.length; ++id) {
            float dist = _sectors[id].distanceFromSquared(position);
            if (dist < nearest) {
                nearest = dist;
                sectorID = id;
            }
        }
        return sectorID;
    }

    /// Calcule le chemin le plus court du départ à l’arrivé.
    NavPath getPath(Vec3i from, Vec3i to) {
        NavPath result;

        if (!_sectors.length)
            return result;

        // On détermine dans quel secteur les points se situent
        uint srcId, dstId;
        float nearestSrc = _sectors[0].distanceFromSquared(from);
        float nearestDst = _sectors[0].distanceFromSquared(to);

        for (uint id = 1; id < _sectors.length; ++id) {
            float dist = _sectors[id].distanceFromSquared(from);
            if (dist < nearestSrc) {
                nearestSrc = dist;
                srcId = id;
            }
            dist = _sectors[id].distanceFromSquared(to);
            if (dist < nearestDst) {
                nearestDst = dist;
                dstId = id;
            }
        }

        result.srcSectorID = srcId;
        result.dstSectorID = dstId;

        final class NavNode {
            Vec3i position;
            uint sectorId;
            uint edgeId;
            float priority;

            int opCmp(ref const NavNode rhs) const {
                if (priority == rhs.priority)
                    return 0;
                return priority > rhs.priority ? 1 : -1;
            }

            this(Vec3i position_, uint sectorId_, uint edgeId_, float priority_) {
                position = position_;
                sectorId = sectorId_;
                edgeId = edgeId_;
                priority = priority_;
            }
        }

        import std.container.binaryheap;

        auto frontiers = heapify!"a > b"([
                new NavNode(from, srcId, uint.max, 0)
            ]);
        Vec3i[Vec3i] cameFrom;
        float[Vec3i] costSoFar;
        cameFrom[from] = from;
        costSoFar[from] = 0f;

        while (!frontiers.empty) {
            NavNode node = frontiers.front;
            frontiers.removeFront();

            if (node.sectorId == dstId) {
                cameFrom[to] = node.position;
                Atelier.log("Got there ", to, " after ", node.position);
                result.isValid = true;
                break;
            }

            NavSector currentSector = _sectors[node.sectorId];

            for (uint i; i < currentSector._edges.length; ++i) {
                if (i == node.edgeId)
                    continue;

                Vec3i position = currentSector._edges[i].center;

                float newCost = costSoFar[node.position] + position.distanceSquared(
                    node.position);

                auto p = currentSector._edges[i].center in costSoFar;

                if (!p || newCost < *p) {
                    costSoFar[position] = newCost;
                    float priority = newCost + position.distanceSquared(to);
                    frontiers.insert(new NavNode(
                            currentSector._edges[i].center,
                            currentSector._edges[i].sectorId,
                            currentSector._edges[i].edgeId,
                            priority));
                    cameFrom[position] = node.position;
                }

                /*for (uint y = i + 1; y < currentSector._edges.length; ++y) {
                    float dist = currentSector._edges[i].center.distanceSquared(
                        currentSector._edges[y].center);

                    currentSector._edges[i].
                    }*/
            }
        }

        if (result.isValid) {
            Vec3i[] path;
            Vec3i current = to;
            while (current != from) {
                path ~= current;
                current = cameFrom[current];
            }
            result.path = path;
            _debugPath = result.path ~ from;
        }

        return result;
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
        for (uint sectorId; (sectorId + 1) < _sectors.length; ++sectorId) {
            NavSector currentSector = _sectors[sectorId];

            for (uint neightborId = sectorId + 1; neightborId < _sectors.length; ++neightborId) {
                NavSector neighborSector = _sectors[neightborId];

                if (currentSector._level != neighborSector._level) // Temporaire
                    continue;

                if (currentSector._start.y == neighborSector._end.y + 1) {
                    uint startX = max(currentSector._start.x, neighborSector._start.x);
                    uint endX = min(currentSector._end.x, neighborSector._end.x);

                    if (endX >= startX) {
                        uint edgeId1 = cast(uint) currentSector._edges.length;
                        uint edgeId2 = cast(uint) neighborSector._edges.length;
                        currentSector.addEdge(neightborId, edgeId2, startX, endX, NavEdge.Dir.up);
                        neighborSector.addEdge(sectorId, edgeId1, startX, endX, NavEdge.Dir.down);
                    }
                }
                else if (neighborSector._start.y == currentSector._end.y + 1) {
                    uint startX = max(currentSector._start.x, neighborSector._start.x);
                    uint endX = min(currentSector._end.x, neighborSector._end.x);

                    if (endX >= startX) {
                        uint edgeId1 = cast(uint) currentSector._edges.length;
                        uint edgeId2 = cast(uint) neighborSector._edges.length;
                        currentSector.addEdge(neightborId, edgeId2, startX, endX, NavEdge.Dir.down);
                        neighborSector.addEdge(sectorId, edgeId1, startX, endX, NavEdge.Dir.up);
                    }
                }

                if (currentSector._start.x == neighborSector._end.x + 1) {
                    uint startY = max(currentSector._start.y, neighborSector._start.y);
                    uint endY = min(currentSector._end.y, neighborSector._end.y);

                    if (endY >= startY) {
                        uint edgeId1 = cast(uint) currentSector._edges.length;
                        uint edgeId2 = cast(uint) neighborSector._edges.length;
                        currentSector.addEdge(neightborId, edgeId2, startY, endY, NavEdge.Dir.left);
                        neighborSector.addEdge(sectorId, edgeId1, startY, endY, NavEdge.Dir.right);
                    }
                }
                else if (neighborSector._start.x == currentSector._end.x + 1) {
                    uint startY = max(currentSector._start.y, neighborSector._start.y);
                    uint endY = min(currentSector._end.y, neighborSector._end.y);

                    if (endY >= startY) {
                        uint edgeId1 = cast(uint) currentSector._edges.length;
                        uint edgeId2 = cast(uint) neighborSector._edges.length;
                        currentSector.addEdge(neightborId, edgeId2, startY, endY, NavEdge.Dir.right);
                        neighborSector.addEdge(sectorId, edgeId1, startY, endY, NavEdge.Dir.left);
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

            if (_markedTiles.getValue(x, y) || Atelier.world.scene.getLevel(x, y) != sector
                ._level) {
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
                    x, sector._start.y - 1) && Atelier.world.scene.getLevel(x, sector._start.y - 2) == sector
                    ._level && !_markedTiles
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

        if (_debugPath.length >= 2) {
            Vec2f startPos = offset + cast(Vec2f) _debugPath[0].xy;
            startPos.y -= _debugPath[0].z;
            i = 1;

            while (i < _debugPath.length) {
                Vec2f endPos = offset + cast(Vec2f) _debugPath[i].xy;
                endPos.y -= _debugPath[i].z;
                Atelier.renderer.drawLine(startPos, endPos, Color.white, 1f);
                startPos = endPos;
                i++;
            }
        }
    }
}
