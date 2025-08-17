module atelier.etabli.media.sequencer.tracklist.pattern;

import std.conv : to;
import atelier;
import farfadet;
import atelier.etabli.media.sequencer.tracklist.editor;
import atelier.etabli.media.sequencer.tracklist.pattern_image;

package final class Pattern {
    private {
        TracklistSequencerEditor _editor;
        PatternImage _image;
        uint _channel, _startStep, _stepCount;
        bool _isSelected, _isTempSelected;
        Vec2i _tempMove;
        int _tempDeltaSize;
        string _name;
    }

    @property {
        string name() const {
            return _name;
        }

        string name(string name_) {
            if (name_ != _name) {
                _name = name_;
                updatePreview();
            }
            return _name;
        }

        uint duration() const {
            return _stepCount;
        }

        uint channel() const {
            return _channel;
        }

        uint start() const {
            return _startStep;
        }
    }

    this(TracklistSequencerEditor editor, uint channel, string name_, uint startStep, uint stepCount) {
        _editor = editor;
        _channel = channel;
        _name = name_;
        _startStep = startStep;
        _stepCount = max(1, stepCount);

        _image = new PatternImage(Vec2f(_stepCount * BlockWidth, BlockHeight), 8f);
        _image.anchor = Vec2f(0f, 1f);
        _image.color = Atelier.theme.accent;
        updatePreview();
    }

    this(TracklistSequencerEditor editor, Farfadet ffd) {
        this(editor, ffd.get!uint(0), ffd.get!string(1), ffd.get!uint(2), ffd.get!uint(3));
    }

    void save(Farfadet ffd) {
        ffd.addNode("pattern").add(_channel).add(_name).add(_startStep).add(_stepCount);
    }

    void updatePreview() {
        Farfadet ffd = _editor.getPattern(_name);

        if (ffd.hasNode("steps")) {
            _image.setSteps(ffd.getNode("steps").get!uint(0));
        }

        _image.clearNotes();
        foreach (node; ffd.getNodes("note")) {
            uint note = node.get!uint(0);
            uint start = node.get!uint(1);
            uint end = start + node.get!uint(2);
            uint velocity = node.get!uint(3);

            _image.addNote(note, start, end, velocity);
        }
    }

    void draw(Vec2f offset) {
        int startStep = _startStep;
        int channel = _channel;

        if (_isSelected) {
            startStep = (cast(int) _startStep) + _tempMove.x;
            startStep = clamp(startStep, 0, max(1, (cast(int) _editor.blocks) - 1));

            channel = (cast(int) _channel) + _tempMove.y;
            channel = clamp(channel, 1, 16);

            int stepCount = clamp((cast(int) _stepCount) + _tempDeltaSize, 1,
                max(1, (cast(int) _editor.blocks) - (cast(int) _startStep)));
            _image.size = Vec2f(stepCount * BlockWidth, BlockHeight);
        }

        Vec2f pos = offset + Vec2f(startStep * BlockWidth, channel * BlockHeight);
        _image.draw(pos);

        drawText(pos + Vec2f(2f, -5f), to!dstring(_name),
            Atelier.res.get!TrueTypeFont("editor:small-font"), Color.white, Color.black, 1f);
    }

    void setSelected(bool value) {
        _isSelected = value;
        _image.color = (_isSelected || _isTempSelected) ? Atelier.theme.danger
            : Atelier.theme.accent;
    }

    bool getSelected() const {
        return _isSelected;
    }

    void setTempSelected(bool value) {
        _isTempSelected = value;
        _image.color = (_isSelected || _isTempSelected) ? Atelier.theme.danger
            : Atelier.theme.accent;
    }

    bool getTempSelected() const {
        return _isTempSelected;
    }

    void setTempMove(Vec2i move) {
        _tempMove = move;
    }

    void applyMove() {
        int startStep = (cast(int) _startStep) + _tempMove.x;
        int channel = (cast(int) _channel) + _tempMove.y;
        _startStep = clamp(startStep, 0, max(1, (cast(int) _editor.blocks) - 1));
        _stepCount = clamp((cast(int) _stepCount), 1, max(1,
                (cast(int) _editor.blocks) - (cast(int) _startStep)));
        _channel = clamp(channel, 1, 16);
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
        return (_channel >= startCoord.y && _channel <= endCoord.y) &&
            (startCoord.x <= endStep && endCoord.x >= _startStep);
    }

    bool collideWith(Pattern other) {
        return isInside(Vec2i(other._startStep, other._channel),
            Vec2i(other._startStep + (other._stepCount - 1), other._channel));
    }

    void getEvents() {
        import std.algorithm : sort;

        struct MidiPattern {

        }

        Farfadet ffd = _editor.getPattern(_name);

        if (ffd.hasNode("instrument")) {
            string instrumentRid = ffd.getNode("instrument").get!string(0);
        }

        if (ffd.hasNode("steps")) {
            uint steps = ffd.getNode("steps").get!uint(0);
        }

        if (ffd.hasNode("bars")) {
            uint bars = ffd.getNode("bars").get!uint(0);
        }

        if (ffd.hasNode("blocks")) {
            uint blocks = ffd.getNode("blocks").get!uint(0);
        }

        struct Note {
            uint start, end;
            uint value, velocity;
        }

        Note[] notes;
        foreach (node; ffd.getNodes("note")) {
            Note note;
            note.value = node.get!uint(0);
            note.start = node.get!uint(1);
            note.end = note.start + node.get!uint(2);
            note.velocity = node.get!uint(3);
            notes ~= note;
        }
        sort!((a, b) => (a.start < b.start))(notes);

        foreach (node; ffd.getNodes("effect")) {
            //_effects ~= new Effect(this, node);
            uint type = node.get!uint(0);
            uint startStep = node.get!uint(1);
            uint stepCount = node.get!uint(2);

            if (node.hasNode("start")) {
                uint startValue = node.getNode("start").get!int(0);
            }

            if (node.hasNode("end")) {
                uint endValue = node.getNode("end").get!int(0);
            }

            if (node.hasNode("spline")) {
                string spline = node.getNode("spline").get!string(0);
            }

        }
        //Pattern[] patterns = _patterns.array.dup;
        //sort!((a, b) => (a.start < b.start))(patterns);

    }
}
