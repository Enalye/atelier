module atelier.script.core.rng;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibCore_rng(GrModule library) {
    library.setModule("core.rng");
    library.setModuleInfo(GrLocale.fr_FR, "Gestion de l’aléatoire");

    GrType rngType = library.addNative("Rng");

    library.setDescription(GrLocale.fr_FR, "Retourne un nombre aléatoire entre 0 (inclu) et 1 (exclu)");
    library.setParameters();
    library.addStatic(&_rand01, rngType, "rand01", [], [grDouble]);

    library.setDescription(GrLocale.fr_FR, "Retourne un nombre gaussien");
    library.setParameters();
    library.addStatic(&_randn, rngType, "randn", [], [grDouble]);

    library.setDescription(GrLocale.fr_FR, "Génère un nombre gaussien");
    library.setParameters(["mean", "deviation"]);
    library.addStatic(&_generateGaussian, rngType, "generateGaussian", [
            grDouble, grDouble
        ], [grDouble]);

    static foreach (type; ["Float", "Double", "Int", "UInt"]) {
        library.setDescription(GrLocale.fr_FR, "Retourne un nombre aléatoire de 0 (inclu) jusqu’à `maxValue` (exclue)");
        library.setParameters(["maxValue"]);
        mixin("library.addStatic(&_rand_1!(type), rngType, \"rand\", [gr", type, "], [gr", type, "]);");

        library.setDescription(GrLocale.fr_FR, "Retourne un nombre aléatoire entre `minValue` (inclue) jusqu’à `maxValue` (exclue)");
        library.setParameters(["minValue", "maxValue"]);
        mixin("library.addStatic(&_rand_2!(type), rngType, \"rand\", [gr", type, ", gr", type, "], [gr", type, "]);");

        library.setDescription(GrLocale.fr_FR, "Retourne un nombre aléatoire autour de `value` éloigné au maximum de `variance`");
        library.setParameters(["value", "variance"]);
        mixin("library.addStatic(&_randVariance!(type), rngType, \"randVariance\", [gr", type, ", gr", type, "], [gr", type, "]);");

        library.setDescription(GrLocale.fr_FR, "Fait la moyenne de plusieurs lancés");
        library.setParameters(["maxValue", "times"]);
        mixin("library.addStatic(&_roll_1!(type), rngType, \"roll\", [gr", type, ", gr", type, "], [gr", type, "]);");

        library.setDescription(GrLocale.fr_FR, "Fait la moyenne de plusieurs lancés");
        library.setParameters(["minValue", "maxValue", "times"]);
        mixin("library.addStatic(&_roll_2!(type), rngType, \"roll\", [gr", type, ", gr", type, ", gr", type, "], [gr", type, "]);");
    }
}

private void _rand01(GrCall call) {
    call.setDouble(Atelier.rng.rand01());
}

private void _rand_1(string type)(GrCall call) {
    mixin("Gr", type, " maxValue = call.get", type, "(0);");
    mixin("call.set", type, "(Atelier.rng.rand!Gr", type, "(maxValue));");
}

private void _rand_2(string type)(GrCall call) {
    mixin("Gr", type, " minValue = call.get", type, "(0);");
    mixin("Gr", type, " maxValue = call.get", type, "(1);");
    mixin("call.set", type, "(Atelier.rng.rand!Gr", type, "(minValue, maxValue));");
}

private void _randVariance(string type)(GrCall call) {
    mixin("Gr", type, " value = call.get", type, "(0);");
    mixin("Gr", type, " variance = call.get", type, "(1);");
    mixin("call.set", type, "(Atelier.rng.randVariance!Gr", type, "(value, variance));");
}

private void _randn(GrCall call) {
    call.setDouble(Atelier.rng.randn!double());
}

private void _generateGaussian(GrCall call) {
    GrDouble mean = call.getDouble(0);
    GrDouble deviation = call.getDouble(1);
    call.setDouble(Atelier.rng.generateGaussian!GrDouble(mean, deviation));
}

private void _roll_1(string type)(GrCall call) {
    mixin("Gr", type, " maxValue = call.get", type, "(0);");
    GrUInt times = call.getUInt(1);
    mixin("call.set", type, "(Atelier.rng.roll!Gr", type, "(maxValue, times));");
}

private void _roll_2(string type)(GrCall call) {
    mixin("Gr", type, " minValue = call.get", type, "(0);");
    mixin("Gr", type, " maxValue = call.get", type, "(1);");
    GrUInt times = call.getUInt(2);
    mixin("call.set", type, "(Atelier.rng.roll!Gr", type, "(minValue, maxValue, times));");
}
