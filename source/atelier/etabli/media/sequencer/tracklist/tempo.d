module atelier.etabli.media.sequencer.tracklist.tempo;

import std.conv : to;
import atelier;
import farfadet;
import atelier.etabli.media.sequencer.tracklist.editor;

package final class Tempo {
    private {
        TracklistSequencerEditor _editor;
        RoundedRectangle _rect;
        uint _startStep, _stepCount;
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

        uint start() const {
            return _startStep;
        }
    }

    this(TracklistSequencerEditor editor, uint startStep, uint stepCount) {
        _editor = editor;
        _startStep = startStep;
        _stepCount = max(1, stepCount);

        _rect = RoundedRectangle.outline(Vec2f(_stepCount * BlockWidth, BlockHeight), 8f, 2f);
        _rect.anchor = Vec2f(0f, 1f);
        _rect.color = Atelier.theme.accent;

        _spline = to!string(Spline.linear);

        _startValue = 120;
        _endValue = 120;
    }

    this(TracklistSequencerEditor editor, Farfadet ffd) {
        this(editor, ffd.get!uint(0), ffd.get!uint(1));

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
        Farfadet node = ffd.addNode("tempo").add(_startStep).add(_stepCount);
        node.addNode("start").add(_startValue);
        node.addNode("end").add(_endValue);
        node.addNode("spline").add(_spline);
    }

    void draw(Vec2f offset) {
        int startStep = _startStep;

        if (_isSelected) {
            startStep = (cast(int) _startStep) + _tempMove.x;
            startStep = clamp(startStep, 0, max(1, (cast(int) _editor.blocks) - 1));

            int stepCount = clamp((cast(int) _stepCount) + _tempDeltaSize, 1,
                max(1, (cast(int) _editor.blocks) - (cast(int) _startStep)));
            _rect.size = Vec2f(stepCount * BlockWidth, BlockHeight);
        }

        Vec2f pos = offset + Vec2f(startStep * BlockWidth, 0f);
        _rect.draw(pos);

        float start = rlerp(0f, 500f, cast(float) _startValue);
        float end = rlerp(0f, 500f, cast(float) _endValue);

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
        _startStep = clamp(startStep, 0, max(1, (cast(int) _editor.blocks) - 1));
        _stepCount = clamp((cast(int) _stepCount), 1, max(1,
                (cast(int) _editor.blocks) - (cast(int) _startStep)));
        _tempMove = Vec2i.zero;
    }

    void setTempResize(int deltaSize) {
        _tempDeltaSize = deltaSize;
    }

    void applyResize() {
        _stepCount = clamp((cast(int) _stepCount) + _tempDeltaSize, 1, _editor.blocks - _startStep);
        _tempDeltaSize = 0;
    }

    bool isInside(Vec2i startCoord, Vec2i endCoord) const {
        int endStep = _startStep + (_stepCount - 1);
        return (0 >= startCoord.y && 0 <= endCoord.y) &&
            (startCoord.x <= endStep && endCoord.x >= _startStep);
    }

    bool collideWith(Tempo other) {
        return isInside(Vec2i(other._startStep, 0),
            Vec2i(other._startStep + (other._stepCount - 1), 0));
    }
}
