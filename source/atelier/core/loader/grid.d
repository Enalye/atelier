module atelier.core.loader.grid;

import std.format;
import farfadet;
import atelier.common;
import atelier.render;
import atelier.core.runtime;

package void compileGrid(string path, const Farfadet ffd, OutStream stream) {
    const string rid = ffd.get!string(0);

    ffd.accept(["type", "size", "values"]);
    stream.write!string(rid);
    stream.write!Vec2u(ffd.getNode("size", 2).get!Vec2u(0));

    string typeStr = ffd.getNode("type", 1).get!string(0);
    switch (typeStr) {
    case "bool":
        stream.write!ubyte(0);
        if (ffd.hasNode("default")) {
            stream.write!bool(ffd.getNode("default", 1).get!bool(0));
        }
        else {
            stream.write!bool(false);
        }
        stream.write!(bool[])(ffd.getNode("values", 1).get!(bool[])(0));
        break;
    case "int":
        stream.write!ubyte(1);
        if (ffd.hasNode("default")) {
            stream.write!int(ffd.getNode("default", 1).get!int(0));
        }
        else {
            stream.write!int(false);
        }
        stream.write!(int[])(ffd.getNode("values", 1).get!(int[])(0));
        break;
    case "uint":
        stream.write!ubyte(2);
        if (ffd.hasNode("default")) {
            stream.write!uint(ffd.getNode("default", 1).get!uint(0));
        }
        else {
            stream.write!uint(false);
        }
        stream.write!(uint[])(ffd.getNode("values", 1).get!(uint[])(0));
        break;
    case "float":
        stream.write!ubyte(3);
        if (ffd.hasNode("default")) {
            stream.write!float(ffd.getNode("default", 1).get!float(0));
        }
        else {
            stream.write!float(false);
        }
        stream.write!(float[])(ffd.getNode("values", 1).get!(float[])(0));
        break;
    default:
        ffd.fail(format!"le nœud `type` n’accepte que les valeurs `bool`, `int`, `uint` et `float`: `%s` trouvé"(
                typeStr));
        break;
    }
}

package void loadGrid(InStream stream) {
    const string rid = stream.read!string();
    const Vec2u size = stream.read!Vec2u();
    switch (stream.read!ubyte()) {
    case 0:
        bool defaultValue = stream.read!bool();
        bool[][] values = stream.read!(bool[][]);
        Atelier.res.store(rid, {
            Grid!bool grid = new Grid!bool(size.x, size.y);
            grid.setValues(values);
            grid.defaultValue = defaultValue;
            return grid;
        });
        break;
    case 1:
        int defaultValue = stream.read!int();
        int[][] values = stream.read!(int[][]);
        Atelier.res.store(rid, {
            Grid!int grid = new Grid!int(size.x, size.y);
            grid.setValues(values);
            grid.defaultValue = defaultValue;
            return grid;
        });
        break;
    case 2:
        uint defaultValue = stream.read!uint();
        uint[][] values = stream.read!(uint[][]);
        Atelier.res.store(rid, {
            Grid!uint grid = new Grid!uint(size.x, size.y);
            grid.setValues(values);
            grid.defaultValue = defaultValue;
            return grid;
        });
        break;
    case 3:
        float defaultValue = stream.read!float();
        float[][] values = stream.read!(float[][]);
        Atelier.res.store(rid, {
            Grid!float grid = new Grid!float(size.x, size.y);
            grid.setValues(values);
            grid.defaultValue = defaultValue;
            return grid;
        });
        break;
    default:
        break;
    }
}
