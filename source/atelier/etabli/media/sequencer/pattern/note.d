module atelier.etabli.media.sequencer.pattern.note;

import std.conv : to;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.media.sequencer.pattern.editor;

package final class Note {
    private {
        PatternSequencerEditor _editor;
        RoundedRectangle _rect;
        uint _note, _startStep, _stepCount;
        bool _isSelected, _isTempSelected;
        Vec2i _tempMove;
        int _tempDeltaSize;
        uint _velocity = 100;
    }

    @property {
        uint velocity() const {
            return _velocity;
        }

        uint velocity(uint vel) {
            return _velocity = clamp(vel, 0, 127);
        }

        uint duration() const {
            return _stepCount;
        }

        uint note() const {
            return _note;
        }

        uint tempNote() const {
            return clamp(_note - _tempMove.y, 0, 127);
        }

        uint start() const {
            return _startStep;
        }
    }

    this(PatternSequencerEditor editor, uint note, uint startStep, uint stepCount) {
        _editor = editor;
        _note = note;
        _startStep = startStep;
        _stepCount = max(1, stepCount);

        _rect = RoundedRectangle.fill(Vec2f(_stepCount * StepWidth, StepHeight), 8f);
        _rect.anchor = Vec2f(0f, 1f);
        _rect.color = Atelier.theme.accent;
    }

    this(PatternSequencerEditor editor, Farfadet ffd) {
        this(editor, ffd.get!uint(0), ffd.get!uint(1), ffd.get!uint(2));
        velocity(ffd.get!uint(3));
    }

    void save(Farfadet ffd) {
        ffd.addNode("note").add(_note).add(_startStep).add(_stepCount).add(_velocity);
    }

    void draw(Vec2f offset) {
        int startStep = _startStep;
        int note = _note;

        if (_isSelected) {
            startStep = (cast(int) _startStep) + _tempMove.x;
            startStep = clamp(startStep, 0, max(1, (cast(int) _editor.steps) - 1));

            note = (cast(int) _note) - _tempMove.y;
            note = clamp(note, 0, 127);

            int stepCount = clamp((cast(int) _stepCount) + _tempDeltaSize, 1,
                max(1, (cast(int) _editor.steps) - (cast(int) _startStep)));
            _rect.size = Vec2f(stepCount * StepWidth, StepHeight);
        }

        Vec2f pos = offset + Vec2f(startStep * StepWidth, (127f - note) * StepHeight);
        _rect.alpha = _editor.isEffectMode ? 0.05f : lerp(0.1f, 1f, _velocity / 127f);
        _rect.draw(pos);

        drawText(pos + Vec2f(2f, -5f), _getNoteName(),
            Atelier.res.get!TrueTypeFont("editor:small-font"), Color.white, Color.black, 1f);
    }

    private dstring _getNoteName() {
        uint noteInOctave = (_note % 12);
        int octave = _note / 12;

        dstring[12] table = [
            "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"
        ];
        dstring result = table[noteInOctave];
        result ~= to!dstring(octave - 1);
        return result;
    }

    void setSelected(bool value) {
        _isSelected = value;
        _rect.color = (_isSelected || _isTempSelected) ? Atelier.theme.danger : Atelier
            .theme.accent;
    }

    bool getSelected() const {
        return _isSelected;
    }

    void setTempSelected(bool value) {
        _isTempSelected = value;
        _rect.color = (_isSelected || _isTempSelected) ? Atelier.theme.danger : Atelier
            .theme.accent;
    }

    bool getTempSelected() const {
        return _isTempSelected;
    }

    void setTempMove(Vec2i move) {
        _tempMove = move;
    }

    void applyMove() {
        int startStep = (cast(int) _startStep) + _tempMove.x;
        int note = (cast(int) _note) - _tempMove.y;
        _startStep = clamp(startStep, 0, max(1, (cast(int) _editor.steps) - 1));
        _stepCount = clamp((cast(int) _stepCount), 1, max(1,
                (cast(int) _editor.steps) - (cast(int) _startStep)));
        _note = clamp(note, 0, 127);
        _tempMove = Vec2i.zero;
    }

    void setTempResize(int deltaSize) {
        _tempDeltaSize = deltaSize;
    }

    void applyResize() {
        _stepCount = clamp((cast(int) _stepCount) + _tempDeltaSize, 1, _editor.steps - _startStep);
        _tempDeltaSize = 0;
    }

    bool isInside(Vec2i startCoord, Vec2i endCoord) const {
        int endStep = _startStep + (_stepCount - 1);
        return (_note >= startCoord.y && _note <= endCoord.y) &&
            (startCoord.x <= endStep && endCoord.x >= _startStep);
    }

    bool collideWith(Note other) {
        return isInside(Vec2i(other._startStep, other._note),
            Vec2i(other._startStep + (other._stepCount - 1), other._note));
    }
}
