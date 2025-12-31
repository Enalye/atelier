module atelier.nav.system;

import std.datetime, std.conv;
import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.world;

private struct NavEdge {
    Vec2i start, end;
    Vec3i center, borderA, borderB;
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
        int _upHeight;
        int _downHeight;
        int _leftHeight;
        int _rightHeight;
        bool _isUpConnectable;
        bool _isDownConnectable;
        bool _isLeftConnectable;
        bool _isRightConnectable;
        Vec2i _start, _end;
        NavEdge[] _edges;
    }

    bool canConnectUp(NavSector other) {
        return _isUpConnectable &&
            other._isDownConnectable &&
            (_upHeight == other._downHeight) &&
            (_start.y == other._end.y + 1);
    }

    bool canConnectDown(NavSector other) {
        return _isDownConnectable &&
            other._isUpConnectable &&
            (_downHeight == other._upHeight) &&
            (other._start.y == _end.y + 1);
    }

    bool canConnectLeft(NavSector other) {
        return _isLeftConnectable &&
            other._isRightConnectable &&
            (_leftHeight == other._rightHeight) &&
            (_start.x == other._end.x + 1);
    }

    bool canConnectRight(NavSector other) {
        return _isRightConnectable &&
            other._isLeftConnectable &&
            (_rightHeight == other._leftHeight) &&
            (other._start.x == _end.x + 1);
    }

    float distanceFromSquared(Vec3i position) {
        Vec3i start = Vec3i(_start * 8, _level * 16);
        Vec3i end = Vec3i((_end + 1) * 8, (_level + 1) * 16);

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
        edge.borderA = Vec3i(edge.start * 8, _level * 16);
        edge.borderB = Vec3i(edge.end * 8, _level * 16);
        edge.center = (edge.borderA + edge.borderB) / 2;
        _edges ~= edge;
    }

    void draw(Vec2f offset, Color color) {
        Vec2f src = (8 * cast(Vec2f) _start) + Vec2f(0f, _level * -16f);
        Vec2f size = 8 * cast(Vec2f)(1 + (_end - _start));
        Atelier.renderer.drawRect(offset + src, size, color, 1f, false);

        for (uint i; i < _edges.length; ++i) {
            final switch (_edges[i].dir) with (NavEdge.Dir) {
            case up:
                src = (8 * cast(Vec2f) _edges[i].start) +
                    Vec2f(0f, 2f - _level * 16f);
                size = (8 * cast(Vec2f)(_edges[i].end + Vec2i(1, 0))) +
                    Vec2f(0f, 2f - _level * 16f);
                Atelier.renderer.drawLine(offset + src, offset + size, color, 1f);
                break;
            case down:
                src = (8 * cast(Vec2f)(_edges[i].start + Vec2i(0, 1))) +
                    Vec2f(0f, -(4f + _level * 16f));
                size = (8 * cast(Vec2f)(_edges[i].end + Vec2i(1, 1))) +
                    Vec2f(0f, -(4f + _level * 16f));
                Atelier.renderer.drawLine(offset + src, offset + size, color, 1f);
                break;
            case left:
                src = (8 * cast(Vec2f) _edges[i].start) +
                    Vec2f(2f, _level * -16f);
                size = (8 * cast(Vec2f)(_edges[i].end + Vec2i(0, 1))) +
                    Vec2f(2f, _level * -16f);
                Atelier.renderer.drawLine(offset + src, offset + size, color, 1f);
                break;
            case right:
                src = (8 * cast(Vec2f)(_edges[i].start + Vec2i(1, 0))) +
                    Vec2f(-4f, 2f - (_level * 16f));
                size = (8 * cast(Vec2f)(_edges[i].end + Vec2i(1, 1))) +
                    Vec2f(-4f, 2f - (_level * 16f));
                Atelier.renderer.drawLine(offset + src, offset + size, color, 1f);
                break;
            }
        }
    }
}

struct NavPath {
    struct Node {
        Vec3i center, start, end;

        this(Vec3i center_) {
            center = center_;
            start = center;
            end = center;
        }

        this(Vec3i center_, Vec3i start_, Vec3i end_) {
            center = center_;
            start = start_;
            end = end_;
        }
    }

    uint srcSectorID, dstSectorID;
    Node[] path;
    bool isValid;
}

final class NavMesh {
    private {
        Grid!bool _tiles;
        NavSector[] _sectors;
        NavPath.Node[] _debugPath;
    }

    int levelToDraw = -1;
    bool isDebug;

    this() {
        _tiles = new Grid!bool;
        _tiles.defaultValue = true;
    }

    void clear() {
        _sectors.length = 0;
        _debugPath.length = 0;
        _tiles.clear(false);
    }

    void generate() {
        clear();

        _generateSectors();
        _connectSectors();
    }

    /// Retourne le secteur dans lequel le point se situe
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
    NavPath getPath(Vec3i from, Vec3i to, uint maxIterations = 1024) {
        // On détermine dans quel secteur les points se situent
        uint srcId = getSectorID(from);
        uint dstId = getSectorID(to);

        return getPath(from, to, srcId, dstId, maxIterations);
    }

    /// Ditto
    NavPath getPath(Vec3i from, Vec3i to, uint fromSectorID, uint toSectorID, uint maxIterations = 1024) {
        NavPath result;

        if (!_sectors.length)
            return result;

        result.srcSectorID = fromSectorID;
        result.dstSectorID = toSectorID;

        final class NavNode {
            Vec3i position, start, end;
            uint sectorId;
            uint edgeId;
            float priority;

            int opCmp(ref const NavNode rhs) const {
                if (priority == rhs.priority)
                    return 0;
                return priority > rhs.priority ? 1 : -1;
            }

            this(Vec3i position_, Vec3i start_, Vec3i end_, uint sectorId_, uint edgeId_, float priority_) {
                position = position_;
                start = start_;
                end = end_;
                sectorId = sectorId_;
                edgeId = edgeId_;
                priority = priority_;
            }
        }

        import std.container.binaryheap;

        auto frontiers = heapify!"a > b"([
            new NavNode(from, from, from, fromSectorID, uint.max, 0)
        ]);
        NavPath.Node[Vec3i] cameFrom;
        float[Vec3i] costSoFar;
        cameFrom[from] = NavPath.Node(from);
        costSoFar[from] = 0f;

        int iteration;

        while (!frontiers.empty && iteration < maxIterations) {
            NavNode node = frontiers.front;
            frontiers.removeFront();

            if (node.sectorId == toSectorID) {
                if (to != node.position) {
                    cameFrom[to] = NavPath.Node(node.position, node.start, node.end);
                }
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
                            currentSector._edges[i].borderA,
                            currentSector._edges[i].borderB,
                            currentSector._edges[i].sectorId,
                            currentSector._edges[i].edgeId,
                            priority));
                    cameFrom[position] = NavPath.Node(node.position, node.start, node.end);
                }
            }

            iteration++;
        }

        if (result.isValid) {
            NavPath.Node[] path;
            NavPath.Node current = NavPath.Node(to);
            while (current.center != from) {
                path ~= current;
                current = cameFrom[current.center];
            }
            result.path = path;
        }

        return result;
    }

    private void _generateSectors() {
        _tiles.setup(Atelier.world.scene.columns << 1, Atelier.world.scene.lines << 1, false);

        for (uint z; z < Atelier.world.scene.levels; ++z) {
            _tiles.clear(false);

            for (uint y; y < Atelier.world.scene.lines << 1; ++y) {
                for (uint x; x < Atelier.world.scene.columns << 1; ++x) {
                    if (_tiles.getValue(x, y))
                        continue;

                    NavSector sector;
                    foreach_reverse (layer; Atelier.world.scene.collisionLayers) {
                        if (layer.level != z)
                            continue;

                        int id = layer.getId(x >> 1, y >> 1);
                        if (!_tiles.getValue(x, y) && id > 0xf) {
                            Physics.Shape shape = cast(Physics.Shape)(id & 0xf);
                            sector = _createSector(x, y, layer.level, shape);
                        }
                    }
                    if (!sector && _canWalk(x, y, z)) {
                        sector = _createSector(x, y, z, Physics.Shape.box);
                    }

                    if (sector) {
                        x = sector._end.x;

                        for (uint y2 = sector._start.y; y2 <= sector._end.y; ++y2) {
                            for (uint x2 = sector._start.x; x2 <= sector._end.x; ++x2) {
                                _tiles.setValue(x2, y2, true);
                            }
                        }

                        _sectors ~= sector;
                    }
                }
            }
        }
    }

    private void _connectSectors() {
        for (uint sectorId; (sectorId + 1) < _sectors.length; ++sectorId) {
            NavSector currentSector = _sectors[sectorId];

            for (uint neightborId = sectorId + 1; neightborId < _sectors.length; ++neightborId) {
                NavSector neighborSector = _sectors[neightborId];

                if (currentSector.canConnectUp(neighborSector)) {
                    uint startX = max(currentSector._start.x, neighborSector._start.x);
                    uint endX = min(currentSector._end.x, neighborSector._end.x);

                    if (endX >= startX) {
                        uint edgeId1 = cast(uint) currentSector._edges.length;
                        uint edgeId2 = cast(uint) neighborSector._edges.length;
                        currentSector.addEdge(neightborId, edgeId2, startX, endX, NavEdge.Dir.up);
                        neighborSector.addEdge(sectorId, edgeId1, startX, endX, NavEdge.Dir.down);
                    }
                }
                else if (currentSector.canConnectDown(neighborSector)) {
                    uint startX = max(currentSector._start.x, neighborSector._start.x);
                    uint endX = min(currentSector._end.x, neighborSector._end.x);

                    if (endX >= startX) {
                        uint edgeId1 = cast(uint) currentSector._edges.length;
                        uint edgeId2 = cast(uint) neighborSector._edges.length;
                        currentSector.addEdge(neightborId, edgeId2, startX, endX, NavEdge.Dir.down);
                        neighborSector.addEdge(sectorId, edgeId1, startX, endX, NavEdge.Dir.up);
                    }
                }

                if (currentSector.canConnectLeft(neighborSector)) {
                    uint startY = max(currentSector._start.y, neighborSector._start.y);
                    uint endY = min(currentSector._end.y, neighborSector._end.y);

                    if (endY >= startY) {
                        uint edgeId1 = cast(uint) currentSector._edges.length;
                        uint edgeId2 = cast(uint) neighborSector._edges.length;
                        currentSector.addEdge(neightborId, edgeId2, startY, endY, NavEdge.Dir.left);
                        neighborSector.addEdge(sectorId, edgeId1, startY, endY, NavEdge.Dir.right);
                    }
                }
                else if (currentSector.canConnectRight(neighborSector)) {
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

    private bool _canWalk(int x, int y, int level) {
        if (x < 0 || y < 0)
            return false;

        int groundLevel = Atelier.world.scene.getLevel((x + 1) >> 1, (y + 1) >> 1);

        if (level < groundLevel)
            return false;

        bool hasLevel = false;

        Vec2i subCoords = Vec2i(x, y) & 0x1;
        x >>= 1;
        y >>= 1;
        foreach_reverse (layer; Atelier.world.scene.collisionLayers) {
            if (layer.level + 1 == level) {
                int id = layer.getId(x, y);
                switch (id) {
                case 0b1111: // Zone pleine
                    hasLevel = true;
                    break;
                case 0b1001: // Coin gauche
                    if (subCoords.x == 0)
                        hasLevel = true;
                    break;
                case 0b0110: // Coin droite
                    if (subCoords.x == 1)
                        hasLevel = true;
                    break;
                case 0b0011: // Coin haut
                    if (subCoords.y == 0)
                        hasLevel = true;
                    break;
                case 0b1100: // Coin bas
                    if (subCoords.y == 1)
                        hasLevel = true;
                    break;
                case 0b1011: // Coin 3/4 haut-gauche
                    if (subCoords.x == 0 || subCoords.y == 0)
                        hasLevel = true;
                    break;
                case 0b1110: // Coin 3/4 bas-droite
                    if (subCoords.x == 1 || subCoords.y == 1)
                        hasLevel = true;
                    break;
                case 0b0111: // Coin 3/4 haut-droite
                    if (subCoords.x == 1 || subCoords.y == 0)
                        hasLevel = true;
                    break;
                case 0b1101: // Coin 3/4 bas-gauche
                    if (subCoords.x == 0 || subCoords.y == 1)
                        hasLevel = true;
                    break;
                case 0b0001: // Coin 1/4 haut-gauche
                    if (subCoords.x == 0 && subCoords.y == 0)
                        hasLevel = true;
                    break;
                case 0b0100: // Coin 1/4 bas-droite
                    if (subCoords.x == 1 && subCoords.y == 1)
                        hasLevel = true;
                    break;
                case 0b0010: // Coin 1/4 haut-droite
                    if (subCoords.x == 1 && subCoords.y == 0)
                        hasLevel = true;
                    break;
                case 0b1000: // Coin 1/4 bas-gauche
                    if (subCoords.x == 0 && subCoords.y == 1)
                        hasLevel = true;
                    break;
                case 0b0101: // Diagonale haut-gauche / bas-droite
                    if ((subCoords.x == 0 && subCoords.y == 0) || (subCoords.x == 1 && subCoords.y == 1))
                        hasLevel = true;
                    break;
                case 0b1010: // Diagonale haut-droite / bas-gauche
                    if ((subCoords.x == 1 && subCoords.y == 0) || (subCoords.x == 0 && subCoords.y == 1))
                        hasLevel = true;
                    break;
                default:
                    break;
                }
            }
            else if (layer.level == level) {
                int id = layer.getId(x, y);
                if (id > 0xf)
                    return false;
                switch (id) {
                case 0b1111: // Zone pleine
                    return false;
                case 0b1001: // Coin gauche
                    if (subCoords.x == 0)
                        return false;
                    break;
                case 0b0110: // Coin droite
                    if (subCoords.x == 1)
                        return false;
                    break;
                case 0b0011: // Coin haut
                    if (subCoords.y == 0)
                        return false;
                    break;
                case 0b1100: // Coin bas
                    if (subCoords.y == 1)
                        return false;
                    break;
                case 0b1011: // Coin 3/4 haut-gauche
                    if (subCoords.x == 0 || subCoords.y == 0)
                        return false;
                    break;
                case 0b1110: // Coin 3/4 bas-droite
                    if (subCoords.x == 1 || subCoords.y == 1)
                        return false;
                    break;
                case 0b0111: // Coin 3/4 haut-droite
                    if (subCoords.x == 1 || subCoords.y == 0)
                        return false;
                    break;
                case 0b1101: // Coin 3/4 bas-gauche
                    if (subCoords.x == 0 || subCoords.y == 1)
                        return false;
                    break;
                case 0b0001: // Coin 1/4 haut-gauche
                    if (subCoords.x == 0 && subCoords.y == 0)
                        return false;
                    break;
                case 0b0100: // Coin 1/4 bas-droite
                    if (subCoords.x == 1 && subCoords.y == 1)
                        return false;
                    break;
                case 0b0010: // Coin 1/4 haut-droite
                    if (subCoords.x == 1 && subCoords.y == 0)
                        return false;
                    break;
                case 0b1000: // Coin 1/4 bas-gauche
                    if (subCoords.x == 0 && subCoords.y == 1)
                        return false;
                    break;
                case 0b0101: // Diagonale haut-gauche / bas-droite
                    if ((subCoords.x == 0 && subCoords.y == 0) || (subCoords.x == 1 && subCoords.y == 1))
                        return false;
                    break;
                case 0b1010: // Diagonale haut-droite / bas-gauche
                    if ((subCoords.x == 1 && subCoords.y == 0) || (subCoords.x == 0 && subCoords.y == 1))
                        return false;
                    break;
                default:
                    break;
                }
            }
        }

        return (level == groundLevel || hasLevel);
    }

    private NavSector _createSector(uint x, uint y, uint z, Physics.Shape shape) {
        NavSector sector = new NavSector;
        sector._start = Vec2i(x, y);
        sector._end = sector._start;
        sector._level = z;
        Vec2i subCoords = Vec2i(x, y) & 0x1;

        final switch (shape) with (Physics.Shape) {
        case box:
            sector._upHeight = z * 16;
            sector._downHeight = z * 16;
            sector._rightHeight = z * 16;
            sector._leftHeight = z * 16;
            sector._isUpConnectable = true;
            sector._isDownConnectable = true;
            sector._isRightConnectable = true;
            sector._isLeftConnectable = true;
            break;
        case slopeUp:
            sector._upHeight = z * 16 + (2 - subCoords.y) * 8;
            sector._downHeight = z * 16 + (1 - subCoords.y) * 8;
            sector._isUpConnectable = true;
            sector._isDownConnectable = true;
            sector._isRightConnectable = false;
            sector._isLeftConnectable = false;
            break;
        case slopeDown:
            sector._downHeight = z * 16 + (1 + subCoords.y) * 8;
            sector._upHeight = z * 16 + subCoords.y * 8;
            sector._isUpConnectable = true;
            sector._isDownConnectable = true;
            sector._isRightConnectable = false;
            sector._isLeftConnectable = false;
            break;
        case slopeRight:
            sector._rightHeight = z * 16 + (1 + subCoords.x) * 8;
            sector._leftHeight = z * 16 + subCoords.x * 8;
            sector._isUpConnectable = false;
            sector._isDownConnectable = false;
            sector._isRightConnectable = true;
            sector._isLeftConnectable = true;
            break;
        case slopeLeft:
            sector._leftHeight = z * 16 + (2 - subCoords.x) * 8;
            sector._rightHeight = z * 16 + (1 - subCoords.x) * 8;
            sector._isUpConnectable = false;
            sector._isDownConnectable = false;
            sector._isRightConnectable = true;
            sector._isLeftConnectable = true;
            break;
        case startSlopeUp:
            sector._upHeight = z * 16 + (1 - subCoords.y) * 8;
            sector._downHeight = z * 16;
            sector._isUpConnectable = true;
            sector._isDownConnectable = true;
            sector._isRightConnectable = false;
            sector._isLeftConnectable = false;
            break;
        case middleSlopeUp:
            sector._upHeight = z * 16 + (3 - subCoords.y) * 8;
            sector._downHeight = z * 16 + (2 - subCoords.y) * 8;
            sector._isUpConnectable = true;
            sector._isDownConnectable = true;
            sector._isRightConnectable = false;
            sector._isLeftConnectable = false;
            break;
        case endSlopeUp:
            sector._upHeight = z * 16 + 16;
            sector._downHeight = z * 16 + (2 - subCoords.y) * 8;
            sector._isUpConnectable = true;
            sector._isDownConnectable = true;
            sector._isRightConnectable = false;
            sector._isLeftConnectable = false;
            break;
        case startSlopeDown:
            sector._downHeight = z * 16 + subCoords.y * 8;
            sector._upHeight = z * 16;
            sector._isUpConnectable = true;
            sector._isDownConnectable = true;
            sector._isRightConnectable = false;
            sector._isLeftConnectable = false;
            break;
        case middleSlopeDown:
            sector._downHeight = z * 16 + (2 + subCoords.y) * 8;
            sector._upHeight = z * 16 + (1 + subCoords.y) * 8;
            sector._isUpConnectable = true;
            sector._isDownConnectable = true;
            sector._isRightConnectable = false;
            sector._isLeftConnectable = false;
            break;
        case endSlopeDown:
            sector._downHeight = z * 16 + 16;
            sector._upHeight = z * 16 + (1 + subCoords.y) * 8;
            sector._isUpConnectable = true;
            sector._isDownConnectable = true;
            sector._isRightConnectable = false;
            sector._isLeftConnectable = false;
            break;
        case startSlopeRight:
            sector._rightHeight = z * 16 + subCoords.x * 8;
            sector._leftHeight = z * 16;
            sector._isUpConnectable = false;
            sector._isDownConnectable = false;
            sector._isRightConnectable = true;
            sector._isLeftConnectable = true;
            break;
        case middleSlopeRight:
            sector._rightHeight = z * 16 + (2 + subCoords.x) * 8;
            sector._leftHeight = z * 16 + (1 + subCoords.x) * 8;
            sector._isUpConnectable = false;
            sector._isDownConnectable = false;
            sector._isRightConnectable = true;
            sector._isLeftConnectable = true;
            break;
        case endSlopeRight:
            sector._rightHeight = z * 16 + 16;
            sector._leftHeight = z * 16 + (1 + subCoords.x) * 8;
            sector._isUpConnectable = false;
            sector._isDownConnectable = false;
            sector._isRightConnectable = true;
            sector._isLeftConnectable = true;
            break;
        case startSlopeLeft:
            sector._leftHeight = z * 16 + (1 - subCoords.x) * 8;
            sector._rightHeight = z * 16;
            sector._isUpConnectable = false;
            sector._isDownConnectable = false;
            sector._isRightConnectable = true;
            sector._isLeftConnectable = true;
            break;
        case middleSlopeLeft:
            sector._leftHeight = z * 16 + (3 - subCoords.x) * 8;
            sector._rightHeight = z * 16 + (2 - subCoords.x) * 8;
            sector._isUpConnectable = false;
            sector._isDownConnectable = false;
            sector._isRightConnectable = true;
            sector._isLeftConnectable = true;
            break;
        case endSlopeLeft:
            sector._leftHeight = z * 16 + 16;
            sector._rightHeight = z * 16 + (2 - subCoords.x) * 8;
            sector._isUpConnectable = false;
            sector._isDownConnectable = false;
            sector._isRightConnectable = true;
            sector._isLeftConnectable = true;
            break;
        }

        _extendSector(sector, shape);

        return sector;
    }

    void _extendSector(NavSector sector, Physics.Shape shape) {
        final switch (shape) with (Physics.Shape) {
        case box:
            _extendSectorDiagonally(sector);
            break;
        case slopeUp:
        case slopeDown:
        case startSlopeUp:
        case middleSlopeUp:
        case endSlopeUp:
        case startSlopeDown:
        case middleSlopeDown:
        case endSlopeDown:
            _extendSlopedSectorHorizontally(sector, shape);
            break;
        case slopeRight:
        case slopeLeft:
        case startSlopeRight:
        case middleSlopeRight:
        case endSlopeRight:
        case startSlopeLeft:
        case middleSlopeLeft:
        case endSlopeLeft:
            _extendSlopedSectorVertically(sector, shape);
            break;
        }
    }

    void _extendSlopedSectorVertically(NavSector sector, Physics.Shape shape) {
        uint y = sector._end.y;

        for (;;) {
            y++;

            bool canContinue = false;

            for (uint x = sector._start.x; x <= sector._end.x; ++x) {
                if (_tiles.getValue(x, y)) {
                    return;
                }

                foreach_reverse (layer; Atelier.world.scene.collisionLayers) {
                    if (layer.level != sector._level)
                        continue;

                    int id = layer.getId(x >> 1, y >> 1);
                    if (id > 0xf) {
                        Physics.Shape otherShape = cast(Physics.Shape)(id & 0xf);
                        if (otherShape == shape) {
                            canContinue = true;
                            break;
                        }
                    }
                }
            }

            if (!canContinue) {
                break;
            }

            sector._end.y = y;
        }
    }

    void _extendSlopedSectorHorizontally(NavSector sector, Physics.Shape shape) {
        uint x = sector._end.x;

        for (;;) {
            x++;

            bool canContinue = false;

            for (uint y = sector._start.y; y <= sector._end.y; ++y) {
                if (_tiles.getValue(x, y)) {
                    return;
                }

                foreach_reverse (layer; Atelier.world.scene.collisionLayers) {
                    if (layer.level != sector._level)
                        continue;

                    int id = layer.getId(x >> 1, y >> 1);
                    if (id > 0xf) {
                        Physics.Shape otherShape = cast(Physics.Shape)(id & 0xf);
                        if (otherShape == shape) {
                            canContinue = true;
                            break;
                        }
                    }
                }
            }

            if (!canContinue) {
                break;
            }

            sector._end.x = x;
        }
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
                if (_tiles.getValue(x2, y) || !_canWalk(x2, y, sector._level)) {
                    isDownAvailable = false;
                    break;
                }
            }

            for (uint y2 = sector._start.y; y2 < y; ++y2) {
                if (_tiles.getValue(x, y2) || !_canWalk(x, y2, sector._level)) {
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

            if (_tiles.getValue(x, y) || !_canWalk(x, y, sector._level)) {
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
            if ((_canWalk(sector._start.x - 1, y, sector._level) &&
                    !_tiles.getValue(sector._start.x - 1, y) &&
                    _canWalk(sector._start.x - 2, y, sector._level) &&
                    !_tiles.getValue(sector._start.x - 2, y)) ||
                (_canWalk(sector._end.x + 1, y, sector._level) &&
                    !_tiles.getValue(sector._end.x + 1, y) &&
                    _canWalk(sector._end.x + 2, y, sector._level) &&
                    !_tiles.getValue(sector._end.x + 2, y))) {
                return;
            }

            for (uint x = sector._start.x; x <= sector._end.x; ++x) {
                if (_tiles.getValue(x, y) || !_canWalk(x, y, sector._level)) {
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
            if ((_canWalk(x, sector._start.y - 1, sector._level) &&
                    !_tiles.getValue(x, sector._start.y - 1) &&
                    _canWalk(x, sector._start.y - 2, sector._level) &&
                    !_tiles.getValue(x, sector._start.y - 2)) ||
                (_canWalk(x, sector._end.y + 1, sector._level) &&
                    !_tiles.getValue(x, sector._end.y + 1) &&
                    _canWalk(x, sector._end.y + 2, sector._level) &&
                    !_tiles.getValue(x, sector._end.y + 2))) {
                return;
            }

            for (uint y = sector._start.y; y <= sector._end.y; ++y) {
                if (_tiles.getValue(x, y) || !_canWalk(x, y, sector._level)) {
                    return;
                }
            }

            sector._end.x = x;
        }
    }

    void setDebugPath(NavPath path) {
        _debugPath = path.path;
    }

    void draw(Vec2f offset) {
        if (!isDebug)
            return;

        Color[] colors = [
            Color.blue, Color.green, Color.red, Color.cyan, Color.lime,
            Color.magenta, Color.olive, Color.orange, Color.navy, Color.gray
        ];

        uint i;

        foreach (sector; _sectors) {
            if (levelToDraw >= 0 && sector._level != levelToDraw)
                continue;

            sector.draw(offset, colors[i]);
            i++;
            if (i >= colors.length)
                i = 0;
        }

        if (_debugPath.length >= 2) {
            Vec2f startPos = offset + cast(Vec2f) _debugPath[0].center.xy;
            startPos.y -= _debugPath[0].center.z;
            i = 1;

            while (i < _debugPath.length) {
                Vec2f endPos = offset + cast(Vec2f) _debugPath[i].center.xy;
                endPos.y -= _debugPath[i].center.z;
                Atelier.renderer.drawLine(startPos, endPos, Color.white, 1f);
                startPos = endPos;
                i++;
            }
        }
    }
}
