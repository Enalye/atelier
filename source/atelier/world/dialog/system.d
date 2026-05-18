module atelier.world.dialog.system;

import grimoire;
import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.world.entity;
import atelier.world.system;
import atelier.world.dialog.blocker;
import atelier.world.dialog.bubble;
import atelier.world.dialog.choice;

final class Dialog {
    private {
        /* À faire:
            - Bulles
            - Annonces
            - Choix
            
        */

        enum Type {
            none,
            box,
            bubble
        }

        Type _type = Type.none;
        Array!BaseDialogBubble _bubbles;
        BaseDialogBubble _currentBubble;
        bool _isCompleted;
        bool _isCancellable;
        bool _isChoosing;
        DialogBlocker _blocker;
        GrChannel _channel;

        alias BubbleFunc = BaseDialogBubble function(Entity, bool isBlocking);
        BubbleFunc _bubbleFunc;

        string _previousEvent;
        string _nextEvent;
        string _validateEvent;
        string _cancelEvent;
    }

    @property {
        bool isRunning() const {
            return _type != Type.none;
        }
    }

    this() {
        _bubbles = new Array!BaseDialogBubble;
    }

    void setup(BubbleFunc bubbleFunc, string previousEvent, string nextEvent, string validateEvent, string cancelEvent) {
        _bubbleFunc = bubbleFunc;
        _previousEvent = previousEvent;
        _nextEvent = nextEvent;
        _validateEvent = validateEvent;
        _cancelEvent = cancelEvent;

        _bubbles.clear();
    }

    void update() {
        if (_isChoosing && _currentBubble) {
            if (Atelier.input.isActionEcho(_nextEvent)) {
                _currentBubble.dispatchEvent("dialog.next", false);
            }
            else if (Atelier.input.isActionEcho(_previousEvent)) {
                _currentBubble.dispatchEvent("dialog.previous", false);
            }
            else if (Atelier.input.isActionActivated(_validateEvent)) {
                _currentBubble.dispatchEvent("dialog.validate", false);
                _isChoosing = false;
                if (_channel) {
                    _channel.send(GrValue(_currentBubble.getDialogChoice()));
                }
            }
            else if (_isCancellable) {
                if (Atelier.input.isActionActivated(_cancelEvent)) {
                    _currentBubble.dispatchEvent("dialog.cancel", false);
                }
            }
        }
        else if (_isCompleted) {
            if (Atelier.input.isActionActivated(_validateEvent) ||
                Atelier.input.isActionActivated(_cancelEvent)) {
                if (_blocker)
                    _blocker.unlock();
                _isCompleted = false;
                foreach (BaseDialogBubble bubble; _bubbles) {
                    bubble.dispatchEvent("dialog.finished", false);
                }
            }
        }
        else if (_type != Type.none || !_isChoosing) {
            if (Atelier.input.isActionActivated(_validateEvent) ||
                Atelier.input.isActionActivated(_cancelEvent)) {
                foreach (BaseDialogBubble bubble; _bubbles) {
                    bubble.dispatchEvent("dialog.skip", false);
                }
                //if (_box)
                //    _box.skip();
            }
        }

        foreach (i, bubble; _bubbles) {
            if (!bubble.isPlaying())
                _bubbles.mark(i);
        }
        _bubbles.sweep();
    }

    void close(bool closeAll = true) {
        final switch (_type) with (Type) {
        case box:
            //_dialogGui.clearPortraits(Side.left);
            //_dialogGui.clearPortraits(Side.right);
            //setDialogLock(false);
            //_box.close();
            //_box = null;
            break;
        case bubble:
            foreach (bubble; _bubbles) {
                bubble.dispatchEvent("dialog.close", false);
            }
            _bubbles.clear();
            _currentBubble = null;
            break;
        case none:
            break;
        }

        if (closeAll) {
            _type = Type.none;
            //setPlayerControl(_hadPlayerControl);
            //setDialogLock(false);
        }
    }

    void say(Entity entity, string text, DialogBlocker blocker) {
        _blocker = blocker;
        _setCurrentBubble(entity, text);
    }

    void say(Entity entity, string text, int timeOut) {
        _addBubble(entity, text, timeOut);
    }

    private void _addBubble(Entity entity, string text, int timeOut) {
        foreach (bubble; _bubbles) {
            if (bubble.isPlaying() && bubble.target == entity) {
                bubble.setDialogText(text);
                bubble.setDialogTimeout(timeOut);
                return;
            }
        }

        if (_bubbleFunc is null) {
            Atelier.log("[ATELIER] Aucune bulle de dialogue définie");
        }
        else {
            BaseDialogBubble bubble = _bubbleFunc(entity, false);
            bubble.setDialogText(text);
            bubble.setDialogTimeout(timeOut);
            Atelier.world.addUI(bubble);
            _bubbles ~= bubble;
        }
    }

    private void _setCurrentBubble(Entity entity, string text) {
        //setDialogLock(true);

        if (_type == Type.box) {
            close(false);
        }
        else if (_type == Type.none) {
            //_hadPlayerControl = getPlayerControl();
            //setPlayerControl(false);
        }

        _type = Type.bubble;
        _isCompleted = false;

        if (_currentBubble) {
            if (_currentBubble.target == entity) {
                _currentBubble.setDialogText(text);
            }
            else {
                _currentBubble.dispatchEvent("dialog.close", false);
                _currentBubble = null;
            }
        }

        if (!_currentBubble) {
            if (_bubbleFunc is null) {
                Atelier.log("[ATELIER] Aucune bulle de dialogue définie");
            }
            else {
                _currentBubble = _bubbleFunc(entity, true);
                _currentBubble.setDialogText(text);
                _currentBubble.addEventListener("dialog.end", {
                    _isCompleted = true;
                });
                Atelier.world.addUI(_currentBubble);
            }
        }
    }

    void close(Entity entity) {
        if (_type != Type.bubble)
            return;

        if (_currentBubble) {
            _currentBubble.dispatchEvent("dialog.close", false);
            _currentBubble = null;
        }

        foreach (i, bubble; _bubbles) {
            if (bubble.target == entity) {
                bubble.dispatchEvent("dialog.close", false);
                _bubbles.mark(i);
            }
        }
        _bubbles.sweep();

        if (!_bubbles.length) {
            _type = Type.none;
        }
    }

    void choice(Entity entity, string[] choices, bool isCancellable, GrChannel channel) {
        _isChoosing = false;
        _channel = channel;

        /*if (_currentBubble.target == entity) {
            //_currentBubble.dispatchEvent("dialog.focus", false);
            _currentBubble = _bubbles[i];
        }
        else {
            //_bubbles[i].dispatchEvent("dialog.unfocus", false);
        }*/

        if (!_currentBubble || _currentBubble.target != entity) {
            // Au cas où
            _setCurrentBubble(entity, "");
        }

        //setDialogChoiceLock(true);
        if (_currentBubble) {
            _currentBubble.setDialogChoices(choices, isCancellable);
            _isCancellable = isCancellable;
            _isChoosing = true;
        }
    }

    /*

    private DialogPortrait pop(Side side, int index) {
        DialogPortrait portrait;
        final switch (side) with (Side) {
        case left:
            if (!_leftPortraits.length || index >= _leftPortraits.length)
                return null;
            portrait = _leftPortraits[index];
            if ((index + 1) == _leftPortraits.length)
                _leftPortraits.length--;
            else if (index == 0)
                _leftPortraits = _leftPortraits[1 .. $];
            else
                _leftPortraits = _leftPortraits[0 .. index] ~ _leftPortraits[(index + 1) .. $];
            break;
        case right:
            if (!_rightPortraits.length || index >= _rightPortraits.length)
                return null;
            portrait = _leftPortraits[index];
            if ((index + 1) == _rightPortraits.length)
                _rightPortraits.length--;
            else if (index == 0)
                _rightPortraits = _rightPortraits[1 .. $];
            else
                _rightPortraits = _rightPortraits[0 .. index] ~ _rightPortraits[(index + 1) .. $];
            break;
        }
        return portrait;
    }

    private void push(DialogPortrait portrait, Side side, int index) {
        final switch (side) with (Side) {
        case left:
            if (index >= _leftPortraits.length)
                _leftPortraits ~= portrait;
            else if (index <= 0)
                _leftPortraits = portrait ~ _leftPortraits;
            else
                _leftPortraits = _leftPortraits[0 .. index] ~ portrait ~ _leftPortraits[index .. $];
            break;
        case right:
            if (index >= _rightPortraits.length)
                _rightPortraits ~= portrait;
            else if (index <= 0)
                _rightPortraits = portrait ~ _rightPortraits;
            else
                _rightPortraits = _rightPortraits[0 .. index] ~ portrait
                    ~ _rightPortraits[index .. $];
            break;
        }
    }

    void addPortrait(string id, Side side, int index) {
        int count;
        final switch (side) with (Side) {
        case left:
            count = cast(int) _leftPortraits.length + 1;
            break;
        case right:
            count = cast(int) _rightPortraits.length + 1;
            break;
        }
        DialogPortrait portrait = new DialogPortrait(id, side, index, count);
        prependChild(portrait);
        push(portrait, side, index);
        updatePortraits();
    }

    void setPortrait(string id, Side side, int index) {
        final switch (side) with (Side) {
        case left:
            if (index < _leftPortraits.length)
                _leftPortraits[index].setAnimation(id);
            break;
        case right:
            if (index < _rightPortraits.length)
                _rightPortraits[index].setAnimation(id);
            break;
        }
    }

    void movePortrait(Side side, int index, Side endSide, int endIndex) {
        DialogPortrait portrait = pop(side, index);
        if (portrait)
            push(portrait, endSide, endIndex);
        updatePortraits();
    }

    void removePortrait(Side side, int index) {
        pop(side, index);
        updatePortraits();
    }

    void clearPortraits(Side side) {
        final switch (side) with (Side) {
        case left:
            foreach (DialogPortrait portrait; _leftPortraits)
                portrait.fadeOut();
            _leftPortraits.length = 0;
            break;
        case right:
            foreach (DialogPortrait portrait; _rightPortraits)
                portrait.fadeOut();
            _rightPortraits.length = 0;
            break;
        }
    }

    void setChoices(string[] choices, bool isCancellable, GrIntChannel channel) {
        setDialogChoiceLock(true);
        _choice = new DialogChoiceMenu(choices, isCancellable, channel);
        _choice.setCallback(this, "choice");
        appendChild(_choice);
    }

    private void updatePortraits() {
        foreach (size_t index, DialogPortrait portrait; _leftPortraits) {
            portrait.setIndex(Side.left, cast(int) index, cast(int) _leftPortraits.length);
        }
        foreach (size_t index, DialogPortrait portrait; _rightPortraits) {
            portrait.setIndex(Side.right, cast(int) index, cast(int) _rightPortraits.length);
        }
    }
    */
}
