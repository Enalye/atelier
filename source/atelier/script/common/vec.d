/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.common.vec;

import grimoire;

import atelier.common;

import atelier.script.util;

package void loadLibCommon_vec(GrLibDefinition library) {
    library.setModule("common.vec");
    library.setModuleInfo(GrLocale.fr_FR, "Calcul vectoriel");

    static foreach (dimension; [2, 3, 4]) {
        _loadVec!dimension(library);
    }
}

private void _loadVec(int dimension)(GrLibDefinition library) {
    mixin("GrType vecType = library.addNative(\"Vec", dimension, "\", [\"T\"]);");

    mixin("GrType vecFloatType = library.addAlias(\"Vec", dimension,
        "f\", grGetNativeType(\"Vec", dimension, "\", [grFloat]));");
    mixin("GrType vecDoubleType = library.addAlias(\"Vec", dimension,
        "d\", grGetNativeType(\"Vec", dimension, "\", [grDouble]));");
    mixin("GrType vecIntType = library.addAlias(\"Vec", dimension,
        "i\", grGetNativeType(\"Vec", dimension, "\", [grInt]));");
    mixin("GrType vecUIntType = library.addAlias(\"Vec", dimension,
        "u\", grGetNativeType(\"Vec", dimension, "\", [grUInt]));");

    static if (dimension == 4) {
        static immutable fields = ["x", "y", "z", "w"];
    }
    else static if (dimension == 3) {
        static immutable fields = ["x", "y", "z"];
    }
    else static if (dimension == 2) {
        static immutable fields = ["x", "y"];
    }
    else {
        assert(false, "unsupported vec dimension: " ~ to!string(dimension));
    }

    static foreach (type; ["Float", "Double", "Int", "UInt"]) {
        // Constructeurs
        static if (dimension == 4) {
            mixin("library.addConstructor(&_ctor!(dimension, type, fields), vec", type,
                "Type, [gr", type, ", gr", type, ", gr", type, ", gr", type, "]);");
        }
        else static if (dimension == 3) {
            mixin("library.addConstructor(&_ctor!(dimension, type, fields), vec",
                type, "Type, [gr", type, ", gr", type, ", gr", type, "]);");
        }
        else static if (dimension == 2) {
            mixin("library.addConstructor(&_ctor!(dimension, type, fields), vec",
                type, "Type, [gr", type, ", gr", type, "]);");
        }

        // Champs
        static foreach (field; fields) {
            mixin("library.addProperty(
                &_property!(dimension, \"", field, "\", \"get\", type),
                &_property!(dimension, \"", field, "\", \"set\", type),
                \"", field, "\", vec", type, "Type, gr", type, ");");
        }

        // Opérateurs unaires
        static foreach (op; ["+", "-"]) {
            mixin("library.addOperator(&_unaryOp!(dimension, op, type), op, [vec",
                type, "Type], vec", type, "Type);");
        }

        // Opérateurs binaires
        static foreach (op; ["+", "-", "*", "/", "%"]) {
            // Vectoriels
            mixin("library.addOperator(&_binaryOp!(dimension, op, type), op, [vec",
                type, "Type, vec", type, "Type], vec", type, "Type);");

            // Scalaires
            mixin("library.addOperator(&_scalarRightOp!(dimension, op, type), op, [vec",
                type, "Type, gr", type, "], vec", type, "Type);");
            mixin("library.addOperator(&_scalarLeftOp!(dimension, op, type), op, [gr",
                type, ", vec", type, "Type], vec", type, "Type);");
        }

        // Angle
        /*static if (dimension == 2 || dimension == 3) {
            mixin("library.addFunction(&_angle!(dimension, type), \"angle\", [vec",
                type, "Type, vec", type, "Type], [grFloat]);");
        }*/

        // Rotate
        static if (dimension == 2) {
            /*mixin("library.addFunction(&_rotate2!(type), \"rotate\", [vec",
                type, "Type, "Type, grFloat], [grFloat]);");*/
        }
        /*else static if (dimension == 3) {
            mixin("library.addFunction(&_rotate3!(type), \"rotate\", [vec",
                type, "Type, vec", type, "Type, grFloat], [vecFloatType]);");
        }*/
    }
}

private void _ctor(int dimension, string type, string[] fields)(GrCall call) {
    mixin("SVec", dimension, "!Gr", type, " vec = new SVec", dimension, "!Gr", type, ";");
    static foreach (idx, field; fields) {
        mixin("vec.", field, " = call.get", type, "(", idx, ");");
    }
    call.setNative(vec);
}

private void _property(int dimension, string field, string op, string type)(GrCall call) {
    mixin("SVec", dimension, "!Gr", type, " vec = call.getNative!(SVec",
        dimension, "!Gr", type, ")(0);");
    static if (op == "set") {
        mixin("vec.", field, " = call.get", type, "(1);");
    }
    mixin("call.set", type, "(vec.", field, ");");
}

private void _unaryOp(int dimension, string op, string type)(GrCall call) {
    mixin("SVec", dimension, "!Gr", type, " veca = call.getNative!(SVec",
        dimension, "!Gr", type, ")(0);");
    mixin("SVec", dimension, "!Gr", type, " vec = new SVec", dimension, "!Gr", type, ";");
    mixin("vec._vector = ", op, " veca._vector;");
    call.setNative(vec);
}

private void _binaryOp(int dimension, string op, string type)(GrCall call) {
    mixin("SVec", dimension, "!Gr", type, " veca = call.getNative!(SVec",
        dimension, "!Gr", type, ")(0);");
    mixin("SVec", dimension, "!Gr", type, " vecb = call.getNative!(SVec",
        dimension, "!Gr", type, ")(1);");
    mixin("SVec", dimension, "!Gr", type, " vec = new SVec", dimension, "!Gr", type, ";");
    mixin("vec._vector = veca._vector ", op, " vecb._vector;");
    call.setNative(vec);
}

private void _scalarRightOp(int dimension, string op, string type)(GrCall call) {
    mixin("SVec", dimension, "!Gr", type, " veca = call.getNative!(SVec",
        dimension, "!Gr", type, ")(0);");
    mixin("Gr", type, " scalar = call.get", type, "(1);");
    mixin("SVec", dimension, "!Gr", type, " vec = new SVec", dimension, "!Gr", type, ";");
    mixin("vec._vector = veca._vector ", op, " scalar;");
    call.setNative(vec);
}

private void _scalarLeftOp(int dimension, string op, string type)(GrCall call) {
    mixin("Gr", type, " scalar = call.get", type, "(0);");
    mixin("SVec", dimension, "!Gr", type, " veca = call.getNative!(SVec",
        dimension, "!Gr", type, ")(1);");
    mixin("SVec", dimension, "!Gr", type, " vec = new SVec", dimension, "!Gr", type, ";");
    mixin("vec._vector = scalar ", op, " veca._vector;");
    call.setNative(vec);
}
/*
private void _angle(int dimension, string type)(GrCall call) {
    mixin("SVec", dimension, "!Gr", type, " v1 = call.getNative!(SVec",
        dimension, "!Gr", type, ")(1);");
    mixin("SVec", dimension, "!Gr", type, " v2 = call.getNative!(SVec",
        dimension, "!Gr", type, ")(1);");
    call.setFloat(v1.angle(v2));
}

private void _rotate3(string type)(GrCall call) {
    mixin("vec3 v1 = cast(vec3) call.getNative!(SVec3!Gr", type, ")(0);");
    mixin("vec3 v2 = cast(vec3) call.getNative!(SVec3!Gr", type, ")(1);");
    call.setNative(sVec3(rotate(v1, v2, call.getFloat(2))));
}
*/
