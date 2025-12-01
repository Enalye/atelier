module atelier.etabli.ui.hurtbox_layers;

import std.format : format;
import std.file;
import std.path;

import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui.studio;

private final class HurtboxLayerData {
    Physics.HurtboxLayer data;
}

final class HurtboxLayersManager : Modal {
    private {
        HurtboxLayerData[32] _layers;
    }

    this() {
        setSize(Vec2f(700f, 500f));

        Label titleLabel = new Label("Calques de Hurtbox", Atelier.theme.font);
        titleLabel.setAlign(UIAlignX.center, UIAlignY.top);
        titleLabel.setPosition(Vec2f(0f, 4f));
        addUI(titleLabel);

        VList vlist = new VList;
        vlist.setPosition(Vec2f(0f, 80f));
        vlist.setSize(getSize() - Vec2f(8f, 128f));
        vlist.setAlign(UIAlignX.center, UIAlignY.top);
        vlist.setChildAlign(UIAlignX.center);
        vlist.setSpacing(8f);
        addUI(vlist);

        for (uint layer; layer < 32; ++layer) {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(500f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label(format("%d", layer + 1), Atelier.theme.font));

            _layers[layer] = new HurtboxLayerData;
            _layers[layer].data = Atelier.physics.getHurtboxLayer(layer);

            () {
                // On delegate sinon layer est mal capturé (merci dlang…)
                uint layerId = layer;

                {
                    TextField nameField = new TextField;
                    nameField.value = _layers[layer].data.name;
                    nameField.addEventListener("value", {
                        _layers[layerId].data.name = nameField.value;
                    });
                    hlayout.addUI(nameField);
                }

                {
                    hlayout.addUI(new Label("I-Frames:", Atelier.theme.font));
                }

                {
                    IntegerField iframesField = new IntegerField;
                    iframesField.setMinValue(0);
                    iframesField.value = _layers[layer].data.iframes;
                    iframesField.addEventListener("value", {
                        _layers[layerId].data.iframes = iframesField.value;
                    });
                    hlayout.addUI(iframesField);
                }

                {
                    NeutralButton editBtn = new NeutralButton("Configurer");
                    editBtn.addEventListener("click", {
                        auto modal = new EditHurtboxLayer(layerId, _layers[layerId].data, _layers);
                        modal.addEventListener("apply", {
                            _layers[layerId].data = modal.getData();
                        });
                        Atelier.ui.pushModalUI(modal);
                    });
                    hlayout.addUI(editBtn);
                }
            }();
        }

        { // Validation
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.right, UIAlignY.bottom);
            hbox.setPosition(Vec2f(4f, 4f));
            hbox.setSpacing(8f);
            addUI(hbox);

            NeutralButton cancelBtn = new NeutralButton("Annuler");
            cancelBtn.addEventListener("click", &removeUI);
            hbox.addUI(cancelBtn);

            AccentButton applyBtn = new AccentButton("Appliquer");
            applyBtn.addEventListener("click", &_onApply);
            hbox.addUI(applyBtn);
        }
    }

    private void _onApply() {
        for (uint layer; layer < 32; ++layer) {
            Atelier.physics.setHurtboxLayer(layer, _layers[layer].data);
        }
        dispatchEvent("apply", false);
        removeUI();
    }
}

final class EditHurtboxLayer : Modal {
    private {
        uint _layer;
        Physics.HurtboxLayer _data;
    }

    this(uint layer, Physics.HurtboxLayer data, HurtboxLayerData[32] layers) {
        _layer = layer;
        _data = data;
        setSize(Vec2f(800f, 500f));

        Label titleLabel = new Label(
            format("Calque %d - \"%s\"",
                layer + 1,
                _data.name),
            Atelier.theme.font);

        titleLabel.setAlign(UIAlignX.center, UIAlignY.top);
        titleLabel.setPosition(Vec2f(0f, 4f));
        addUI(titleLabel);

        VList vlist = new VList;
        vlist.setPosition(Vec2f(0f, 48f));
        vlist.setSize(getSize() - Vec2f(8f, 64f));
        vlist.setAlign(UIAlignX.center, UIAlignY.top);
        vlist.setChildAlign(UIAlignX.center);
        vlist.setSpacing(8f);
        addUI(vlist);

        for (uint otherLayer; otherLayer < 32; ++otherLayer) {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(500f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label(
                    format("%d - \"%s\"",
                    otherLayer + 1,
                    layers[otherLayer].data.name),
                    Atelier.theme.font));

            () {
                // On delegate sinon layer est mal capturé (merci dlang…)
                uint otherLayerId = otherLayer;

                {
                    uint ivalue = 0;
                    if (!_data.getCollision(otherLayer)) {
                        ivalue = 0;
                    }
                    else if (_data.getRemove(otherLayer)) {
                        ivalue = 3;
                    }
                    else if (_data.getRepeat(otherLayer)) {
                        ivalue = 2;
                    }
                    else {
                        ivalue = 1;
                    }
                    CarouselButton collisionBtn = new CarouselButton(
                        [
                        "Ignorée", "Une seule fois par élément",
                        "Répétée pour chaque élément",
                        "Unique (puis détruit)"
                    ], "");
                    collisionBtn.ivalue = ivalue;
                    collisionBtn.addEventListener("value", {
                        bool collisionValue;
                        bool repeatValue;
                        bool removeValue;
                        switch (collisionBtn.ivalue) {
                        case 0:
                        default:
                            break;
                        case 1:
                            collisionValue = true;
                            break;
                        case 2:
                            collisionValue = true;
                            repeatValue = true;
                            break;
                        case 3:
                            collisionValue = true;
                            removeValue = true;
                            break;
                        }
                        _data.setCollision(otherLayerId, collisionValue);
                        _data.setRepeat(otherLayerId, repeatValue);
                        _data.setRemove(otherLayerId, removeValue);

                    });
                    hlayout.addUI(collisionBtn);
                }
            }();
        }

        { // Validation
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.right, UIAlignY.bottom);
            hbox.setPosition(Vec2f(4f, 4f));
            hbox.setSpacing(8f);
            addUI(hbox);

            NeutralButton cancelBtn = new NeutralButton("Annuler");
            cancelBtn.addEventListener("click", &removeUI);
            hbox.addUI(cancelBtn);

            AccentButton applyBtn = new AccentButton("Appliquer");
            applyBtn.addEventListener("click", {
                dispatchEvent("apply", false);
                removeUI();
            });
            hbox.addUI(applyBtn);
        }
    }

    Physics.HurtboxLayer getData() {
        return _data;
    }
}
