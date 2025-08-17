module atelier.etabli.ui.warning;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

final class WarningModal : Modal {
    static {
        void warn(string title, string msg, string action = "OK") {
            Atelier.ui.pushModalUI(new WarningModal(title, msg, false, action, false, {
                }, "", false, {}));
            Atelier.log("[editor] ", title, " - ", msg);
        }

        void ask(string title, string msg, string action = "Valider", bool isDanger, void delegate() onValidate) {
            Atelier.ui.pushModalUI(new WarningModal(title, msg, true, action, isDanger, onValidate, "", false, {
                }));
            Atelier.log("[editor] ", title, " - ", msg);
        }

        void choice(string title, string msg, string choice1, bool isDanger1, void delegate() onChoice1, string choice2, bool isDanger2, void delegate() onChoice2) {
            Atelier.ui.pushModalUI(new WarningModal(title, msg, true, choice1, isDanger1, onChoice1, choice2, isDanger2, onChoice2));
            Atelier.log("[editor] ", title, " - ", msg);
        }
    }

    private this(string title, string msg, bool hasCancel, string choice1, bool isDanger1, void delegate() onChoice1, string choice2, bool isDanger2, void delegate() onChoice2) {
        setAlign(UIAlignX.center, UIAlignY.center);

        Vec2f size_ = Vec2f.one * 32f;

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

            size_ = msgLabel.getSize();
        }

        {
            IconButton exitBtn = new IconButton("editor:exit");
            exitBtn.setAlign(UIAlignX.right, UIAlignY.top);
            exitBtn.setPosition(Vec2f(4f, 4f));
            exitBtn.addEventListener("click", &removeUI);
            addUI(exitBtn);
        }

        {
            HBox validationBox = new HBox;
            validationBox.setAlign(UIAlignX.center, UIAlignY.bottom);
            validationBox.setPosition(Vec2f(0f, 10f));
            validationBox.setSpacing(8f);
            addUI(validationBox);

            if (hasCancel) {
                NeutralButton cancelBtn = new NeutralButton("Annuler");
                cancelBtn.addEventListener("click", &removeUI);
                validationBox.addUI(cancelBtn);
            }

            if (choice1.length) {
                TextButton!RoundedRectangle validateBtn = isDanger1 ? new DangerButton(choice1) : new AccentButton(
                    choice1);
                validateBtn.addEventListener("click", { removeUI(); onChoice1(); });
                validationBox.addUI(validateBtn);
            }

            if (choice2.length) {
                TextButton!RoundedRectangle validateBtn = isDanger2 ? new DangerButton(choice2) : new AccentButton(
                    choice2);
                validateBtn.addEventListener("click", { removeUI(); onChoice2(); });
                validationBox.addUI(validateBtn);
            }

            size_.x = max(size_.x, validationBox.getWidth());

            validationBox.addEventListener("size", {
                Vec2f nSize_ = Vec2f(max(size_.x, validationBox.getWidth()), size_.y);
                setSize(nSize_ + Vec2f(32f, 96f));
            });
        }

        setSize(size_ + Vec2f(32f, 96f));
    }
}
