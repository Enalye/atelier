/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.warning;

import atelier;

void showWarning(string title, string msg) {
    Atelier.ui.pushModalUI(new WarningModal(title, msg));
    log("[STUDIO] ", title, " - ", msg);
}

private final class WarningModal : Modal {
    this(string title, string msg) {
        setAlign(UIAlignX.center, UIAlignY.center);

        {
            Label titleLabel = new Label(title, Atelier.theme.font);
            titleLabel.setAlign(UIAlignX.center, UIAlignY.top);
            titleLabel.setPosition(Vec2f(0f, 4f));
            addUI(titleLabel);
        }

        {
            Label msgLabel = new Label(msg, Atelier.theme.font);
            msgLabel.setAlign(UIAlignX.center, UIAlignY.center);
            addUI(msgLabel);

            setSize(Vec2f(msgLabel.getWidth() + 32f, msgLabel.getHeight() + 96f));
        }

        {
            IconButton exitBtn = new IconButton("editor:exit");
            exitBtn.setAlign(UIAlignX.right, UIAlignY.top);
            exitBtn.setPosition(Vec2f(4f, 4f));
            exitBtn.addEventListener("click", &removeUI);
            addUI(exitBtn);
        }

        {
            NeutralButton okBtn = new NeutralButton("OK");
            okBtn.setAlign(UIAlignX.center, UIAlignY.bottom);
            okBtn.setPosition(Vec2f(0f, 10f));
            okBtn.addEventListener("click", &removeUI);
            addUI(okBtn);
        }
    }
}
