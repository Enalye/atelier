module atelier.state.game;

import farfadet;

import atelier.state.data;

abstract class BaseGameStateData {
    void clear();
    void loadDefault(StateData);
    void load(Farfadet);
    void save(Farfadet);
}
