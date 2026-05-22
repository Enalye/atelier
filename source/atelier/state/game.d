module atelier.state.game;

import farfadet;

abstract class BaseGameStateData {
    void clear();
    void loadDefault();
    void load(Farfadet);
    void save(Farfadet);
}
