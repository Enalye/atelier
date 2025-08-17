module atelier.world.dialog.bubble;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;
import atelier.world.world;
import atelier.world.entity;
import atelier.world.dialog.choice;
import atelier.world.dialog.system;

bool getDialogChoiceLock() {
    return false;
}

abstract class BaseDialogBubble : UIElement {
    @property {
        Entity target();
    }

    void setDialogChoices(string[] choices, bool isCancellable);
    int getDialogChoice() const;

    void setDialogMode(Dialog.BubbleMode mode);
    void setDialogText(string text);
}
