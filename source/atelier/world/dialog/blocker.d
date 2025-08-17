module atelier.world.dialog.blocker;

import grimoire;

final class DialogBlocker : GrBlocker {
    private {
        bool _hasEnded;
    }

    void unlock() {
        _hasEnded = true;
    }

    override bool run() {
        return _hasEnded;
    }
}
