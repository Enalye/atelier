module atelier.common.math;

import std.math;
import std.traits;
public import std.algorithm.comparison : clamp, min, max;

/// Interpolation, retourne une valeur entre a et b. \
/// If t == 0, retourne a. \
/// If t == 1, retourne b.
T lerp(T)(T a, T b, float t) {
    return cast(T)(t * b + (1f - t) * a);
}

/// Lerp inversé, retourne une valeur entre 0 et 1. \
/// 0 si v == a. \
/// 1 si v == b.
double rlerp(double a, double b, double v) {
    return (v - a) / (b - a);
}

float clampDeg(float angle) {
    if (angle < 0f) {
        angle += 360f * (1 + (cast(int) angle) / -360);
    }
    if (angle >= 360f) {
        angle += 360f * ((cast(int) angle) / -360);
    }
    return angle;
}

float clampRad(float angle) {
    return degToRad(clampDeg(radToDeg(angle)));
}

/// L’angle minimal (en degrés) entre deux angles.
float angleBetweenDeg(float a, float b) {
    for (;;) {
        float delta = b - a;
        if (abs(delta) <= 180f)
            return delta;

        b += (b < a) ? 360f : -360f;
    }
}

/// L’angle minimal (en radians) entre deux angles.
float angleBetweenRad(float a, float b) {
    for (;;) {
        float delta = b - a;
        if (abs(delta) <= PI_2)
            return delta;

        b += (b < a) ? PI : -PI;
    }
}

/// Interpolation entre un angle a et b. \
/// If t == 0, retourne a. \
/// If t == 1, retourne b.
float slerpDeg(float a, float b, float t) {
    return clampDeg(a + angleBetweenDeg(a, b) * t);
}

/// Interpolation entre un angle a et b. \
/// If t == 0, retourne a. \
/// If t == 1, retourne b.
float slerpRad(float a, float b, float t) {
    return clampRad(a + angleBetweenRad(a, b) * t);
}

/// Met un vecteur à l’échelle pour s’adapter au vecteur spécifier en conservant son ratio.
Vec2!T scaleToFit(T)(Vec2!T src, Vec2!T dst) {
    float scale;
    if (dst.x / dst.y > src.x / src.y) {
        scale = dst.y / src.y;
    }
    else {
        scale = dst.x / src.x;
    }

    return src * scale;
}

/// Interpolation linéaire pour s’approcher d’une valeur cible
T approach(T)(T value, T target, T step) if (isScalarType!T) {
    return value > target ? max(value - step, target) : min(value + step, target);
}

/// Interpolation linéaire pour s’approcher d’un angle
float sapproachDeg(float value, float target, float step) {
    float delta = angleBetweenDeg(value, target);
    if (abs(delta) <= step) {
        return target;
    }
    return delta >= 0f ? (value + step) : (value - step);
}

/// Interpolation linéaire pour s’approcher d’un angle
float sapproachRad(float value, float target, float step) {
    float delta = angleBetweenRad(value, target);
    if (abs(delta) <= step) {
        return target;
    }
    return delta >= 0f ? (value + step) : (value - step);
}

private enum DegToRadFactor = PI / 180.0;
private enum RadToDegFactor = 180.0 / PI;

/// Convertit un angle en degrés en radians
T degToRad(T)(T deg) {
    return deg * DegToRadFactor;
}

/// Convertit un angle en radians en degrées
T radToDeg(T)(T rad) {
    return rad * RadToDegFactor;
}

/// Convertit un gain en décibels en amplitude
T dbToVol(T)(T db) {
    return pow(10.0, 0.05 * db);
}

/// Convertit un gain en amplitude en décibels
T volToDb(T)(T vol) {
    return 20.0 * log10(vol);
}

T volToNonLinear(T)(T vol) {
    return vol * vol * vol;
}
