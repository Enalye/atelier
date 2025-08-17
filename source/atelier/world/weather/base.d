module atelier.world.weather.base;

import atelier.common;

interface BaseWeather {
    void setAlpha(float);
    void update();
    void draw(Vec2f);
}
