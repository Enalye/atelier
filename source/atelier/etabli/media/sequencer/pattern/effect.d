module atelier.etabli.media.sequencer.pattern.effect;

import std.conv : to;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.media.sequencer.pattern.editor;

package final class Effect {
    private {
        PatternSequencerEditor _editor;
        RoundedRectangle _rect;
        uint _type, _startStep, _stepCount;
        bool _isSelected, _isTempSelected;
        Vec2i _tempMove;
        int _tempDeltaSize;

        int _startValue, _endValue;
        string _spline;
    }

    @property {
        int startValue() const {
            return _startValue;
        }

        int startValue(int value) {
            return _startValue = value;
        }

        int endValue() const {
            return _endValue;
        }

        int endValue(int value) {
            return _endValue = value;
        }

        string spline() const {
            return _spline;
        }

        string spline(string value) {
            return _spline = value;
        }

        uint duration() const {
            return _stepCount;
        }

        uint type() const {
            return _type;
        }

        uint start() const {
            return _startStep;
        }
    }

    this(PatternSequencerEditor editor, uint type_, uint startStep, uint stepCount) {
        _editor = editor;
        _type = type_;
        _startStep = startStep;
        _stepCount = max(1, stepCount);

        _rect = RoundedRectangle.outline(Vec2f(_stepCount * StepWidth, EffectHeight), 8f, 2f);
        _rect.anchor = Vec2f(0f, 1f);
        _rect.color = Atelier.theme.accent;

        _spline = to!string(Spline.linear);

        switch (_type) {
        case 6: // Expression
            _startValue = 127;
            _endValue = 127;
            break;
        case 4: // Volume
            _startValue = 100;
            _endValue = 100;
            break;
        default:
            _startValue = 0;
            _endValue = 0;
            break;
        }
    }

    this(PatternSequencerEditor editor, Farfadet ffd) {
        this(editor, ffd.get!uint(0), ffd.get!uint(1), ffd.get!uint(2));

        if (ffd.hasNode("start")) {
            _startValue = ffd.getNode("start").get!int(0);
        }

        if (ffd.hasNode("end")) {
            _endValue = ffd.getNode("end").get!int(0);
        }

        if (ffd.hasNode("spline")) {
            _spline = ffd.getNode("spline").get!string(0);
        }
    }

    void save(Farfadet ffd) {
        Farfadet node = ffd.addNode("effect").add(_type).add(_startStep).add(_stepCount);
        node.addNode("start").add(_startValue);
        node.addNode("end").add(_endValue);
        node.addNode("spline").add(_spline);
    }

    int getMinValue() const {
        switch (_type) {
        case 1: // Pitch Bend
            return -8192;
        case 5: // Panning
            return -64;
        default:
            return 0;
        }
    }

    int getMaxValue() const {
        switch (_type) {
        case 1: // Pitch Bend
            return 8191;
        case 5: // Panning
            return 63;
        default:
            return 127;
        }
    }

    int getRange() const {
        switch (_type) {
        case 1: // Pitch Bend
            return 16_384;
        default:
            return 128;
        }
    }

    string getTitle() const {
        immutable string[] titles = [
            "After Touch", "Pitch Bend", "Modulation", "Portamento Time",
            "Volume", "Panpot", "Expression", "Hold 1", "Portamento",
            "Sostenuto", "Soft", "Legato Foot Switch", "Resonance",
            "Release Time", "Attack Time", "Cutoff", "Decay Time",
            "Vibrato Rate", "Vibrato Depth", "Vibrato Delay",
            "Portamento Control", "Reverb", "Chorus",
        ];
        if (_type >= titles.length)
            return "???";
        return titles[_type];
    }

    void draw(Vec2f offset) {
        int startStep = _startStep;

        if (_isSelected) {
            startStep = (cast(int) _startStep) + _tempMove.x;
            startStep = clamp(startStep, 0, max(1, (cast(int) _editor.steps) - 1));

            int stepCount = clamp((cast(int) _stepCount) + _tempDeltaSize, 1,
                max(1, (cast(int) _editor.steps) - (cast(int) _startStep)));
            _rect.size = Vec2f(stepCount * StepWidth, EffectHeight);
        }

        Vec2f pos = offset + Vec2f(startStep * StepWidth, (_type + 1) * EffectHeight - StepHeight);
        _rect.draw(pos);

        float start = rlerp(cast(float) getMinValue(), cast(float) getMaxValue(),
            cast(float) _startValue);
        float end = rlerp(cast(float) getMinValue(), cast(float) getMaxValue(),
            cast(float) _endValue);

        for (float t = 0f; t <= 1f; t += 0.01f) {
            float value = lerp(start, end, getSplineFunc(to!Spline(_spline))(t));
            Vec2f linePos = pos + Vec2f(lerp(4f, _rect.size.x - 4f, t),
                lerp(-4f, -(_rect.size.y - 4f), value));
            Atelier.renderer.drawLine(linePos, Vec2f(linePos.x, pos.y - 4f),
                Atelier.theme.accent, 1f);
        }
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
        _startStep = clamp(startStep, 0, max(1, (cast(int) _editor.steps) - 1));
        _stepCount = clamp((cast(int) _stepCount), 1, max(1,
                (cast(int) _editor.steps) - (cast(int) _startStep)));
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
        return (_type >= startCoord.y && _type <= endCoord.y) &&
            (startCoord.x <= endStep && endCoord.x >= _startStep);
    }

    bool collideWith(Effect other) {
        return isInside(Vec2i(other._startStep, other._type),
            Vec2i(other._startStep + (other._stepCount - 1), other._type));
    }
}
