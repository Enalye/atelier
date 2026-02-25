module atelier.console.cmd.weather;

import atelier.common;
import atelier.core;
import atelier.world;
import atelier.console.command;
import atelier.console.value;
import atelier.console.system;

package void _weatherCmd(Console console) {
    // weather
    ConsoleCommand weather = console.addCommand("weather");
    weather.setHint("Affiche la météo actuelle");
    weather.setCallback(&_weather);

    // weather list
    ConsoleCommand weather_list = weather.addCommand("list");
    weather_list.setHint("Liste les météo disponibles");
    weather_list.setCallback(&_weather_list);

    // weather change
    ConsoleCommand weather_change = weather.addCommand("change");
    weather_change.addParameter("type", ConsoleType.string_);
    weather_change.addOption("strength", ConsoleType.float_, ConsoleValue(1f));
    weather_change.addOption("duration", ConsoleType.uint_, ConsoleValue(0));
    weather_change.setHint("Change la météo en cours");
    weather_change.setCallback(&_weather_change);

    // weather set
    ConsoleCommand weather_set = weather.addCommand("set");
    weather_set.addParameter("type", ConsoleType.string_);
    weather_set.addOption("strength", ConsoleType.float_, ConsoleValue(1f));
    weather_set.setHint("Change la météo en cours");
    weather_set.setCallback(&_weather_change);
}

private void _weather(ConsoleResult result) {
    Atelier.console.log("Météo actuelle ", Atelier.world.weather.getType(),
        " d’intensité ", Atelier.world.weather.getIntensity());
}

private void _weather_list(ConsoleResult result) {
    Atelier.console.log("Météos disponibles: ", Atelier.world.weather.getList());
}

private void _weather_change(ConsoleResult result) {
    string type = result.getArgument!string("type");
    float strength = result.getArgument!float("strength");
    uint duration = result.getArgument!uint("duration");

    Atelier.world.weather.run(type, strength, duration);
    Atelier.console.log("Météo changée en ", type, " d’intensité ", strength, " pour ", duration, " frames");
}

private void _weather_set(ConsoleResult result) {
    string type = result.getArgument!string("type");
    float strength = result.getArgument!float("strength");

    Atelier.world.weather.set(type, strength);
    Atelier.console.log("Météo changée en ", type, " d’intensité ", strength);
}
