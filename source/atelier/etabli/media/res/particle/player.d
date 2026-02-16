module atelier.etabli.media.res.particle.player;

import std.format;

import farfadet;
import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.ui;
import atelier.world;
import atelier.etabli.ui;
import atelier.etabli.media.res.particle.editor;
import atelier.etabli.media.res.entity.data;

package final class MediaPlayer : UIElement {
    private {
        Particle _particle;
        Container _container;
        IconButton _playBtn, _repeatBtn;
        bool _isPlaying;
        bool _isRepeating;
        ResourceButton _textureSelect;
        VList _elementList, _sourceList;
        ParticleDataItem _selectedItem;

        NeutralButton _upBtn, _downBtn, _renameBtn, _duplicateBtn;
        DangerButton _removeBtn;
        Label _timeLabel;
    }

    @property {
        bool isRunning() const {
            return _isPlaying;
        }

        bool isRepeating() const {
            return _isRepeating;
        }
    }

    this(string textureRID, float width, Farfadet ffd, Particle particle) {
        _particle = particle;

        setSize(Vec2f(width, 250f));
        setAlign(UIAlignX.center, UIAlignY.bottom);

        _container = new Container;
        _container.setSize(getSize());
        addUI(_container);

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.left, UIAlignY.top);
            hbox.setPosition(Vec2f(32f, 32f));
            hbox.setSpacing(32f);
            addUI(hbox);

            {
                _playBtn = new IconButton("editor:play");
                _playBtn.addEventListener("click", &_onPlay);
                hbox.addUI(_playBtn);

                _repeatBtn = new IconButton("editor:play-once");
                _repeatBtn.addEventListener("click", &_onRepeat);
                hbox.addUI(_repeatBtn);
            }

            {
                _timeLabel = new Label("Étape: 0", Atelier.theme.font);
                hbox.addUI(_timeLabel);
            }
        }

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.right, UIAlignY.center);
            hbox.setPosition(Vec2f(32f, 0f));
            hbox.setSpacing(8f);
            hbox.setChildAlign(UIAlignY.top);
            addUI(hbox);

            {
                VBox vbox = new VBox;
                vbox.setChildAlign(UIAlignX.right);
                vbox.setSpacing(8f);
                hbox.addUI(vbox);

                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(284f, 0f));
                vbox.addUI(hlayout);

                hlayout.addUI(new Label("Texture:", Atelier.theme.font));

                _textureSelect = new ResourceButton(textureRID, "texture", [
                        "texture"
                    ]);
                _textureSelect.addEventListener("value", {
                    _particle.setTexture(_textureSelect.getName());
                });
                hlayout.addUI(_textureSelect);

                _upBtn = new NeutralButton("Haut");
                _upBtn.addEventListener("click", {
                    if (!_selectedItem)
                        return;

                    bool isSource = _selectedItem.isSource();
                    ParticleDataItem[] items;

                    if (isSource) {
                        items = cast(ParticleDataItem[]) _sourceList.getList();
                        _sourceList.clearList();
                    }
                    else {
                        items = cast(ParticleDataItem[]) _elementList.getList();
                        _elementList.clearList();
                    }

                    for (size_t i = 1; i < items.length; ++i) {
                        if (items[i] == _selectedItem) {
                            items[i] = items[i - 1];
                            items[i - 1] = _selectedItem;
                            break;
                        }
                    }

                    if (isSource) {
                        foreach (ParticleDataItem item; items) {
                            _sourceList.addList(item);
                        }
                    }
                    else {
                        foreach (ParticleDataItem item; items) {
                            _elementList.addList(item);
                        }
                    }

                    _updateFfd();
                });
                vbox.addUI(_upBtn);

                _downBtn = new NeutralButton("Bas");
                _downBtn.addEventListener("click", {
                    if (!_selectedItem)
                        return;

                    bool isSource = _selectedItem.isSource();
                    ParticleDataItem[] items;

                    if (isSource) {
                        items = cast(ParticleDataItem[]) _sourceList.getList();
                        _sourceList.clearList();
                    }
                    else {
                        items = cast(ParticleDataItem[]) _elementList.getList();
                        _elementList.clearList();
                    }

                    for (size_t i = 0; (i + 1) < items.length; ++i) {
                        if (items[i] == _selectedItem) {
                            items[i] = items[i + 1];
                            items[i + 1] = _selectedItem;
                            break;
                        }
                    }

                    if (isSource) {
                        foreach (ParticleDataItem element; items) {
                            _sourceList.addList(element);
                        }
                    }
                    else {
                        foreach (ParticleDataItem element; items) {
                            _elementList.addList(element);
                        }
                    }

                    _updateFfd();
                });
                vbox.addUI(_downBtn);

                _renameBtn = new NeutralButton("Renommer");
                _renameBtn.addEventListener("click", {
                    if (!_selectedItem)
                        return;

                    NewEntry modal = new NewEntry("Renommer", _selectedItem.getName());
                    modal.addEventListener("entry.apply", {
                        if (_selectedItem) {
                            _selectedItem.setName(modal.getName());
                            _updateFfd();
                        }

                        Atelier.ui.popModalUI();
                    });
                    Atelier.ui.pushModalUI(modal);
                });
                vbox.addUI(_renameBtn);

                _duplicateBtn = new NeutralButton("Dupliquer");
                _duplicateBtn.addEventListener("click", {
                    if (!_selectedItem)
                        return;

                    NewEntry modal = new NewEntry("Dupliquer", _selectedItem.getName());
                    modal.addEventListener("entry.apply", {
                        if (_selectedItem) {
                            bool isSource = _selectedItem.isSource();
                            ParticleDataItem[] items;

                            if (isSource) {
                                items = cast(ParticleDataItem[]) _sourceList.getList();
                                _sourceList.clearList();
                            }
                            else {
                                items = cast(ParticleDataItem[]) _elementList.getList();
                                _elementList.clearList();
                            }

                            int index;
                            for (int i = 0; i < items.length; ++i) {
                                if (items[i] == _selectedItem) {
                                    index = i;
                                    break;
                                }
                            }
                            items.length++;
                            for (int i = (cast(int) items.length) - 2; i > index;
                            --i) {
                                items[i + 1] = items[i];
                            }
                            items[index + 1] = new ParticleDataItem(_selectedItem);
                            items[index + 1].setName(modal.getName());
                            items[index + 1].addEventListener("value", &_updateFfd);

                            if (isSource) {
                                foreach (ParticleDataItem item; items) {
                                    _sourceList.addList(item);
                                }
                            }
                            else {
                                foreach (ParticleDataItem item; items) {
                                    _elementList.addList(item);
                                }
                            }
                        }
                        Atelier.ui.popModalUI();
                    });
                    Atelier.ui.pushModalUI(modal);
                });

                _duplicateBtn.addEventListener("click", {});
                vbox.addUI(_duplicateBtn);

                _removeBtn = new DangerButton("Supprimer");
                _removeBtn.addEventListener("click", {
                    if (!_selectedItem)
                        return;

                    bool isSource = _selectedItem.isSource();
                    ParticleDataItem[] items;

                    if (isSource) {
                        foreach (item; cast(ParticleDataItem[]) _sourceList.getList()) {
                            if (item == _selectedItem)
                                continue;

                            items ~= item;
                        }
                        _sourceList.clearList();
                    }
                    else {
                        foreach (item; cast(ParticleDataItem[]) _elementList.getList()) {
                            if (item == _selectedItem)
                                continue;

                            items ~= item;
                        }
                        _elementList.clearList();
                    }

                    if (isSource) {
                        foreach (ParticleDataItem item; items) {
                            _sourceList.addList(item);
                        }
                    }
                    else {
                        foreach (ParticleDataItem item; items) {
                            _elementList.addList(item);
                        }
                    }

                    _selectedItem = null;
                    _updateButtons();
                    _updateFfd();
                });
                vbox.addUI(_removeBtn);
            }

            { // Éléments
                VBox vbox = new VBox;
                vbox.setSpacing(4f);
                hbox.addUI(vbox);

                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(284f, 0f));
                vbox.addUI(hlayout);

                hlayout.addUI(new Label("Éléments:", Atelier.theme.font));

                _elementList = new VList;
                _elementList.setSize(Vec2f(300f, 200f));

                AccentButton addBtn = new AccentButton("Ajouter");
                addBtn.addEventListener("click", {
                    NewEntry modal = new NewEntry("Nouvel élément");
                    modal.addEventListener("entry.apply", {
                        auto item = new ParticleDataItem(this, false);
                        item.setName(modal.getName());
                        item.addEventListener("value", &_updateFfd);
                        _elementList.addList(item);
                        Atelier.ui.popModalUI();
                    });
                    Atelier.ui.pushModalUI(modal);
                });
                hlayout.addUI(addBtn);

                vbox.addUI(_elementList);

                foreach (node; ffd.getNodes("element")) {
                    auto item = new ParticleDataItem(this, false, node.getNodes());
                    item.setName(node.get!string(0));
                    item.addEventListener("value", &_updateFfd);
                    _elementList.addList(item);
                }
            }

            { // Sources
                VBox vbox = new VBox;
                vbox.setSpacing(4f);
                hbox.addUI(vbox);

                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(284f, 0f));
                vbox.addUI(hlayout);

                hlayout.addUI(new Label("Sources:", Atelier.theme.font));

                _sourceList = new VList;
                _sourceList.setSize(Vec2f(300f, 200f));

                AccentButton addBtn = new AccentButton("Ajouter");
                addBtn.addEventListener("click", {
                    NewEntry modal = new NewEntry("Nouvelle source");
                    modal.addEventListener("entry.apply", {
                        auto item = new ParticleDataItem(this, true);
                        item.setName(modal.getName());
                        item.addEventListener("value", &_updateFfd);
                        _sourceList.addList(item);
                        Atelier.ui.popModalUI();
                    });
                    Atelier.ui.pushModalUI(modal);
                });
                hlayout.addUI(addBtn);

                vbox.addUI(_sourceList);

                foreach (node; ffd.getNodes("source")) {
                    auto item = new ParticleDataItem(this, true, node.getNodes());
                    item.setName(node.get!string(0));
                    item.addEventListener("value", &_updateFfd);
                    _sourceList.addList(item);
                }
            }
        }

        addEventListener("size", &_onSize);
        addEventListener("update", &_onUpdate);

        _updateButtons();
    }

    string getTextureID() const {
        return _textureSelect.getName();
    }

    private void _onSize() {
        _container.setSize(getSize());
    }

    private void _onUpdate() {
        if (Atelier.input.isDown(InputEvent.KeyButton.Button.space)) {
            _onPlay();
        }
    }

    private void _updateFfd() {
        Farfadet ffd = new Farfadet;
        ffd.addNode("texture").add(_textureSelect.getName());

        foreach (item; cast(ParticleDataItem[]) _elementList.getList()) {
            Farfadet node = ffd.addNode("element").add(item.getName());

            foreach (step; item.getSteps()) {
                node.addNode(step);
            }
        }

        foreach (item; cast(ParticleDataItem[]) _sourceList.getList()) {
            Farfadet node = ffd.addNode("source").add(item.getName());

            foreach (step; item.getSteps()) {
                node.addNode(step);
            }
        }

        _particle.load(ffd);

        dispatchEvent("property");
    }

    private void _updateButtons() {
        bool hasSelected = _selectedItem !is null;

        _upBtn.isEnabled = hasSelected;
        _downBtn.isEnabled = hasSelected;
        _renameBtn.isEnabled = hasSelected;
        _duplicateBtn.isEnabled = hasSelected;
        _removeBtn.isEnabled = hasSelected;
    }

    protected void select(ParticleDataItem item_) {
        size_t i;
        foreach (ParticleDataItem item; cast(ParticleDataItem[]) _elementList.getList()) {
            if (item == item_) {
                _elementList.moveToElement(i);
            }
            item.updateSelection(item == item_);
            i++;
        }
        i = 0;
        foreach (ParticleDataItem item; cast(ParticleDataItem[]) _sourceList.getList()) {
            if (item == item_) {
                _sourceList.moveToElement(i);
            }
            item.updateSelection(item == item_);
            i++;
        }

        _selectedItem = item_;
        _updateButtons();
        dispatchEvent("item.select", false);
    }

    ParticleDataItem getSelectedItem() {
        return _selectedItem;
    }

    void setTime(int time) {
        _timeLabel.text = format("Étape: %d", time);
    }

    void stop() {
        if (_isPlaying) {
            _isPlaying = false;
            _playBtn.setIcon("editor:play");
        }
    }

    private void _onPlay() {
        if (_isPlaying) {
            _isPlaying = false;
            _playBtn.setIcon("editor:play");
            dispatchEvent("particle_stop", false);
        }
        else {
            _isPlaying = true;
            _playBtn.setIcon("editor:pause");
            dispatchEvent("particle_start", false);
        }
    }

    private void _onRepeat() {
        if (_isRepeating) {
            _isRepeating = false;
            _repeatBtn.setIcon("editor:play-once");
        }
        else {
            _isRepeating = true;
            _repeatBtn.setIcon("editor:play-repeat");
        }
    }
}

private final class NewEntry : Modal {
    private {
        TextField _nameField;
    }

    this(string title_, string oldName = "") {
        setAlign(UIAlignX.center, UIAlignY.center);
        setSize(Vec2f(300f, 150f));

        {
            Label title = new Label(title_, Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 4f));
            addUI(title);
        }

        {
            IconButton exitBtn = new IconButton("editor:exit");
            exitBtn.setAlign(UIAlignX.right, UIAlignY.top);
            exitBtn.setPosition(Vec2f(4f, 4f));
            exitBtn.addEventListener("click", &removeUI);
            addUI(exitBtn);
        }

        VBox vbox;
        vbox = new VBox;
        vbox.setAlign(UIAlignX.center, UIAlignY.center);
        vbox.setChildAlign(UIAlignX.left);
        vbox.setSpacing(8f);
        addUI(vbox);

        {
            HBox hbox = new HBox;
            vbox.addUI(hbox);

            hbox.addUI(new Label("Nom: ", Atelier.theme.font));

            _nameField = new TextField;
            _nameField.value = oldName;
            hbox.addUI(_nameField);
        }

        {
            HBox validationBox = new HBox;
            validationBox.setAlign(UIAlignX.right, UIAlignY.bottom);
            validationBox.setPosition(Vec2f(10f, 10f));
            validationBox.setSpacing(8f);
            addUI(validationBox);

            NeutralButton cancelBtn = new NeutralButton("Annuler");
            cancelBtn.addEventListener("click", &removeUI);
            validationBox.addUI(cancelBtn);

            AccentButton createBtn = new AccentButton("Appliquer");
            createBtn.addEventListener("click", {
                dispatchEvent("entry.apply", false);
            });
            validationBox.addUI(createBtn);
        }
    }

    string getName() const {
        return _nameField.value;
    }
}

package final class ParticleDataItem : UIElement {
    private {
        string _name;
        Label _nameLabel, _stepsCountLabel;
        Rectangle _rect;
        HBox _hbox;
        IconButton _upBtn, _downBtn;
        bool _isSelected;
        MediaPlayer _player;
        Farfadet[] _steps;
        bool _isSource;
    }

    @property {
        bool isSource() const {
            return _isSource;
        }
    }

    this(ParticleDataItem other) {
        _player = other._player;
        _isSource = other._isSource;

        foreach (Farfadet ffd; other._steps) {
            _steps ~= new Farfadet(ffd);
        }

        _setup();
    }

    this(MediaPlayer player, bool isSource_, Farfadet[] steps = []) {
        _player = player;
        _isSource = isSource_;
        _steps = steps;

        _setup();
    }

    private void _setup() {
        setSize(Vec2f(300f, 48f));

        _rect = Rectangle.fill(getSize());
        _rect.anchor = Vec2f.zero;
        _rect.color = Atelier.theme.surface;
        addImage(_rect);

        _nameLabel = new Label("", Atelier.theme.font);
        _nameLabel.setAlign(UIAlignX.left, UIAlignY.center);
        _nameLabel.setPosition(Vec2f(16f, 0f));
        _nameLabel.textColor = Atelier.theme.onNeutral;
        addUI(_nameLabel);

        _stepsCountLabel = new Label("", Atelier.theme.font);
        _stepsCountLabel.setAlign(UIAlignX.right, UIAlignY.center);
        _stepsCountLabel.setPosition(Vec2f(16f, 0f));
        _stepsCountLabel.textColor = Atelier.theme.neutral;
        addUI(_stepsCountLabel);

        /*{
            _hbox = new HBox;
            _hbox.setAlign(UIAlignX.right, UIAlignY.center);
            _hbox.setPosition(Vec2f(12f, 0f));
            _hbox.setSpacing(2f);
            addUI(_hbox);

            _upBtn = new IconButton("editor:arrow-small-up");
            _upBtn.addEventListener("click", { this.outer.moveUpGraphic(this); });
            _hbox.addUI(_upBtn);

            _downBtn = new IconButton("editor:arrow-small-down");
            _downBtn.addEventListener("click", {
                this.outer.moveDownGraphic(this);
            });
            _hbox.addUI(_downBtn);

            _hbox.isVisible = false;
            _hbox.isEnabled = false;
        }*/

        _updateDisplay();

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
        addEventListener("click", &_onClick);
    }

    private void _onMouseEnter() {
        if (_isSelected) {
            _rect.color = Atelier.theme.accent;
            _nameLabel.textColor = Atelier.theme.onAccent;
            _stepsCountLabel.textColor = Atelier.theme.onAccent;
        }
        else {
            _rect.color = Atelier.theme.foreground;
            _nameLabel.textColor = Atelier.theme.onNeutral;
            _stepsCountLabel.textColor = Atelier.theme.neutral;
        }
    }

    private void _onMouseLeave() {
        if (_isSelected) {
            _rect.color = Atelier.theme.accent;
            _nameLabel.textColor = Atelier.theme.onAccent;
            _stepsCountLabel.textColor = Atelier.theme.onAccent;
        }
        else {
            _rect.color = Atelier.theme.surface;
            _nameLabel.textColor = Atelier.theme.onNeutral;
            _stepsCountLabel.textColor = Atelier.theme.neutral;
        }
    }

    private void _updateDisplay() {
        _nameLabel.text = _name;
        _stepsCountLabel.text = "(0)";
    }

    protected void updateSelection(bool select_) {
        if (_isSelected == select_)
            return;

        _isSelected = select_;

        if (isHovered) {
            _onMouseEnter();
        }
        else {
            _onMouseLeave();
        }
    }

    private void _onClick() {
        _player.select(this);
    }

    void setName(string name) {
        _name = name;
        _updateDisplay();
    }

    string getName() {
        return _name;
    }

    Farfadet[] getSteps() {
        return _steps;
    }

    void setSteps(Farfadet[] steps) {
        _steps = steps;
        dispatchEvent("value", false);
    }
}
