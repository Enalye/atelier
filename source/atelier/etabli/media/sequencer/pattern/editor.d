module atelier.etabli.media.sequencer.pattern.editor;

import std.conv : to;
import std.math : floor;

import farfadet;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.render;

import atelier.etabli.core;
import atelier.etabli.ui;
import atelier.etabli.media.sequencer.base;
import atelier.etabli.media.sequencer.editor;
import atelier.etabli.media.sequencer.pattern.effect;
import atelier.etabli.media.sequencer.pattern.effect_data;
import atelier.etabli.media.sequencer.pattern.note;
import atelier.etabli.media.sequencer.pattern.parameter;
import atelier.etabli.media.sequencer.pattern.toolbox;
import atelier.etabli.media.sequencer.pattern.velocity;

package {
    immutable dstring[] effectList = [
        "After Touch", "Pitch Bend", "Modulation", "Portamento", "Volume",
        "Panpot", "Expression", "Hold 1", "Portamento", "Sostenuto", "Soft",
        "Legato", "Resonance", "Release", "Attack", "Cutoff", "Decay",
        "Vibrato", "Vibrato", "Vibrato", "Portamento", "Reverb", "Chorus"
    ];
    immutable dstring[] effectListLine2 = [
        "", "", "", "Time", "", "", "", "", "", "", "", "Foot Switch", "",
        "Time", "Time", "", "Time", "Rate", "Depth", "Delay", "Control", "", ""
    ];
    enum StepWidth = 28f;
    enum StepHeight = 18f;
    enum EffectHeight = (StepHeight * 128f) / effectList.length;
}

package(atelier.etabli.media.sequencer) final class PatternSequencerEditor : SequencerBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        string _instrument, _scale, _tonic;
        uint _steps = 128;
        uint _bars = 4;
        uint _blocks = 1;
        uint _bpm = 120;
        int[] _initializationValues;
        PatternSequencerToolbox _toolbox;
        PatternSequencerParameterWindow _parameterWindow;
        int _tool;

        Array!Note _notes;
        Note[] _selectedNotes, _tempSelectedNotes, _previewedNotes;

        Array!Effect _effects;
        Effect[] _selectedEffects, _tempSelectedEffects;

        Vec2f _viewPosition = Vec2f.zero;
        Vec2f _startMousePosition = Vec2f.zero;
        Vec2f _endMousePosition = Vec2f.zero;
        bool _isApplyingTool;

        uint _lastNoteDuration = 1;
        uint _lastNoteVelocity = 100;
        uint _currentOctave = 4;

        Sprite[7] _pianoNoteOffSprites, _pianoNoteOnSprites;
        Sprite _pianoSharpNoteOffSprite, _pianoSharpNoteOnSprite;
        int[12] _pianoNoteOffsets = [
            0, 18, 32, 54, 63, 90, 108, 120, 144, 153, 180, 186
        ];
        bool[12] _isNoteSharp = [
            false, true, false, true, false, false, true, false, true, false, true,
            false
        ];
        int[12] _noteDegrees = [0, 0, 1, 1, 2, 3, 3, 4, 4, 5, 5, 6];
        bool[128] _noteStates;

        bool _isEffectMode;
    }

    @property {
        uint steps() const {
            return _steps;
        }

        bool isEffectMode() const {
            return _isEffectMode;
        }
    }

    this(SequencerEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _notes = new Array!Note;
        _effects = new Array!Effect;

        _name = _ffd.get!string(0);

        if (_ffd.hasNode("instrument")) {
            _instrument = ffd.getNode("instrument").get!string(0);
        }

        if (_ffd.hasNode("init")) {
            _initializationValues = ffd.getNode("init").get!(int[])(0);
        }

        if (_ffd.hasNode("steps")) {
            _steps = ffd.getNode("steps").get!uint(0);
        }

        if (_ffd.hasNode("bars")) {
            _bars = ffd.getNode("bars").get!uint(0);
        }

        if (_ffd.hasNode("bpm")) {
            _bpm = ffd.getNode("bpm").get!uint(0);
        }

        if (_ffd.hasNode("blocks")) {
            _blocks = ffd.getNode("blocks").get!uint(0);
        }

        if (_ffd.hasNode("scale")) {
            _scale = ffd.getNode("scale").get!string(0);
        }

        if (_ffd.hasNode("tonic")) {
            _tonic = ffd.getNode("tonic").get!string(0);
        }

        foreach (node; ffd.getNodes("note")) {
            _notes ~= new Note(this, node);
        }

        foreach (node; ffd.getNodes("effect")) {
            _effects ~= new Effect(this, node);
        }

        _toolbox = new PatternSequencerToolbox();
        Atelier.ui.addUI(_toolbox);

        _openAudio();

        _parameterWindow = new PatternSequencerParameterWindow(_instrument,
            _steps, _bars, _bpm, _blocks, _scale, _tonic, _initializationValues);

        _toolbox.addEventListener("tool", {
            _tool = _toolbox.getTool();
            _isEffectMode = _toolbox.getMode();
        });
        addEventListener("register", { _openAudio(); Atelier.ui.addUI(_toolbox); });
        addEventListener("unregister", {
            Atelier.audio.closeInput();
            _toolbox.removeUI();
        });
        addEventListener("draw", &_onDraw);
        addEventListener("wheel", &_onWheel);
        addEventListener("mousedown", &_onMouseDown);
        addEventListener("mouseup", &_onMouseUp);
        addEventListener("mouseleave", &_onMouseLeave);
        addEventListener("clickoutside", &_onMouseLeave);
        addEventListener("size", &_clampView);
        addEventListener("globalkey", &_onKey);

        _parameterWindow.addEventListener("property", {
            _instrument = _parameterWindow.getInstrument();
            _steps = _parameterWindow.getSteps();
            _bars = _parameterWindow.getBars();
            _bpm = _parameterWindow.getBPM();
            _blocks = _parameterWindow.getBlocks();
            _scale = _parameterWindow.getScale();
            _tonic = _parameterWindow.getTonic();
            _initializationValues = _parameterWindow.getInitializationValues();
        });

        _parameterWindow.addEventListener("property_play", &_onPlay);

        _viewPosition = Vec2f(0f, 64f * StepHeight);

        foreach (size_t i, string note; ["c", "d", "e", "f", "g", "a", "b"]) {
            _pianoNoteOffSprites[i] = Atelier.res.get!Sprite("editor:pianoroll-" ~ note ~ "-off");
            _pianoNoteOffSprites[i].anchor = Vec2f(0f, 1f);

            _pianoNoteOnSprites[i] = Atelier.res.get!Sprite("editor:pianoroll-" ~ note ~ "-on");
            _pianoNoteOnSprites[i].anchor = Vec2f(0f, 1f);
        }

        _pianoSharpNoteOffSprite = Atelier.res.get!Sprite("editor:pianoroll-sharp-off");
        _pianoSharpNoteOffSprite.anchor = Vec2f(0f, 1f);

        _pianoSharpNoteOnSprite = Atelier.res.get!Sprite("editor:pianoroll-sharp-on");
        _pianoSharpNoteOnSprite.anchor = Vec2f(0f, 1f);

        _clampView();
    }

    private void _openAudio() {
        Atelier.audio.openInput("IN (2- SD-90)");

        AudioInputRecorder recorder = new AudioInputRecorder();
        Atelier.audio.record(recorder);

        RecorderPlayer player = new RecorderPlayer(recorder);
        Atelier.audio.play(player);
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("pattern").add(_name);
        node.addNode("instrument").add(_instrument);
        node.addNode("init").add(_initializationValues);
        node.addNode("steps").add(_steps);
        node.addNode("bars").add(_bars);
        node.addNode("blocks").add(_blocks);
        node.addNode("scale").add(_scale);
        node.addNode("tonic").add(_tonic);

        foreach (note; _notes) {
            note.save(node);
        }

        foreach (effect; _effects) {
            effect.save(node);
        }

        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    private void _onPlay() {
        if (midiIsPlaying()) {
            midiStop();
            return;
        }

        midiStartSession();
        bool hasInstrument;
        uint pc, msb, lsb;
        if (Atelier.etabli.hasResource("instrument", _instrument)) {
            Atelier.etabli.ResourceInfo data = Atelier.etabli.getResource("instrument", _instrument);

            hasInstrument = true;
            if (data.farfadet.hasNode("pc")) {
                pc = data.farfadet.getNode("pc").get!uint(0);
            }

            if (data.farfadet.hasNode("msb")) {
                msb = data.farfadet.getNode("msb").get!uint(0);
            }

            if (data.farfadet.hasNode("lsb")) {
                lsb = data.farfadet.getNode("lsb").get!uint(0);
            }
        }

        midiOpenPattern(0, 0, _blocks, _steps);

        if (hasInstrument) {
            midiSetPatternInstrument(pc, msb, lsb);
        }
        midiSetPatternInitialState(_initializationValues);
        foreach (note; _notes) {
            midiAddNoteEvent(note.start, note.duration, note.note, note.velocity);
        }
        foreach (effect; _effects) {
            midiAddEffectEvent(effect.start, effect.duration, effect.type,
                effect.startValue, effect.endValue, effect.spline);
        }
        midiClosePattern();
        midiEndSession();
        midiProcess(_blocks, _bpm);
        midiPlay();

        addEventListener("update", &_onPlaying);
    }

    private void _onPlaying() {
        if (!midiIsPlaying() || midiIsFinished()) {
            removeEventListener("update", &_onPlaying);
            midiStop();
        }
    }

    bool hasControlModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightControl);
    }

    private void _onMouseLeave() {
        removeEventListener("mousemove", &_onDrag);

        _isApplyingTool = false;
        removeEventListener("mousemove", &_onMouseMove);
    }

    private void _onMouseDown() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case right:
            addEventListener("mousemove", &_onDrag);
            break;
        case left:
            _startMousePosition = (_viewPosition + getMousePosition()) - getCenter();
            _endMousePosition = _startMousePosition;
            _isApplyingTool = true;
            addEventListener("mousemove", &_onMouseMove);
            switch (_tool) {
            case 0:
                if (!hasControlModifier()) {
                    foreach (note; _selectedNotes) {
                        note.setSelected(false);
                    }
                    _selectedNotes.length = 0;

                    foreach (effect; _selectedEffects) {
                        effect.setSelected(false);
                    }
                    _selectedEffects.length = 0;
                }
                _captureSelection(false);
                break;
            case 1:
            case 3:
                if (_isEffectMode) {
                    if (_selectedEffects.length == 0) {
                        _captureSelection(true);
                    }
                }
                else {
                    if (_selectedNotes.length == 0) {
                        _captureSelection(true);
                    }
                }
                break;
            case 2:
                _createNote();
                break;
            case 4:
                foreach (effect; _selectedEffects) {
                    effect.setSelected(false);
                }
                _selectedEffects.length = 0;

                foreach (note; _selectedNotes) {
                    note.setSelected(false);
                }
                _selectedNotes.length = 0;

                _captureSelection(false);
                break;
            case 6:
                _previewNotes(true);
                break;
            default:
                break;
            }
            break;
        default:
            break;
        }
    }

    private void _onMouseMove() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        _endMousePosition = (_viewPosition + getMousePosition()) - getCenter();

        switch (_tool) {
        case 0:
            _captureSelection(false);
            break;
        case 1:
            _moveSelection(false);
            break;
        case 2:
            _moveSelection(false);
            break;
        case 3:
            _resizeSelection(false);
            break;
        case 4:
            _captureSelection(false);
            break;
        case 6:
            _previewNotes(true);
            break;
        default:
            break;
        }
    }

    private void _onMouseUp() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case right:
            removeEventListener("mousemove", &_onDrag);
            break;
        case left:
            _endMousePosition = (_viewPosition + getMousePosition()) - getCenter();
            _isApplyingTool = false;
            removeEventListener("mousemove", &_onMouseMove);

            switch (_tool) {
            case 0:
                _captureSelection(true);
                break;
            case 1:
                _moveSelection(true);
                break;
            case 2:
                _moveSelection(true);
                break;
            case 3:
                _resizeSelection(true);
                break;
            case 4:
                _captureSelection(true);
                _removeNote();
                break;
            case 5:
                _openVelocityWindow();
                break;
            case 6:
                _previewNotes(false);
                break;
            default:
                break;
            }
            break;
        default:
            break;
        }
    }

    private void _onDrag() {
        UIManager manager = getManager();
        InputEvent.MouseMotion ev = manager.input.asMouseMotion();
        _viewPosition -= ev.deltaPosition;

        _clampView();
    }

    private void _onWheel() {
        UIManager manager = getManager();
        InputEvent.MouseWheel ev = manager.input.asMouseWheel();

        if (hasControlModifier()) {
            _viewPosition.x -= ev.wheel.sum() * StepWidth;
        }
        else {
            _viewPosition.y -= ev.wheel.sum() * StepHeight;
        }

        _clampView();
    }

    private void _clampView() {
        Vec2f center = getCenter();
        _viewPosition.x = clamp(_viewPosition.x, center.x - 80f, 130f * StepWidth);
        _viewPosition.y = clamp(_viewPosition.y, center.y - StepHeight, 128f * StepHeight - center
                .y);
    }

    private void _createNote() {
        if (_isEffectMode) {
            foreach (effect; _selectedEffects) {
                effect.setSelected(false);
            }
            _selectedEffects.length = 0;

            Vec2i coord = _convertToGrid(_startMousePosition);
            Effect effect = new Effect(this, coord.y, coord.x, _lastNoteDuration);
            _effects ~= effect;
            _selectedEffects ~= effect;
            effect.setSelected(true);
        }
        else {
            foreach (note; _selectedNotes) {
                note.setSelected(false);
            }
            _selectedNotes.length = 0;

            Vec2i coord = _convertToGrid(_startMousePosition);
            Note note = new Note(this, coord.y, coord.x, _lastNoteDuration);
            note.velocity = _lastNoteVelocity;
            _notes ~= note;
            _selectedNotes ~= note;
            note.setSelected(true);

            playNote(note.note, true, note.velocity);
        }
    }

    private void _removeNote() {
        if (_isEffectMode) {
            foreach (selectedEffect; _selectedEffects) {
                foreach (i, effect; _effects) {
                    if (selectedEffect == effect) {
                        _effects.mark(i);
                        break;
                    }
                }
            }
            _effects.sweep();
            _selectedEffects.length = 0;
        }
        else {
            foreach (selectedNote; _selectedNotes) {
                foreach (i, note; _notes) {
                    if (selectedNote == note) {
                        _notes.mark(i);
                        break;
                    }
                }
            }
            _notes.sweep();
            _selectedNotes.length = 0;
        }
    }

    private void _openVelocityWindow() {
        Vec2i coord = _convertToGrid(_startMousePosition);

        if (_isEffectMode) {
            foreach (i, effect; _effects) {
                if (effect.isInside(coord, coord)) {
                    PatternSequencerEffectDataWindow window = new PatternSequencerEffectDataWindow(
                        effect);
                    Vec2f pos = getCenter() - _viewPosition;
                    pos += Vec2f(effect.start * StepWidth,
                        (effect.type + 1) * EffectHeight - StepHeight);
                    window.setPosition(pos);
                    Atelier.ui.addUI(window);
                    break;
                }
            }
        }
        else {
            foreach (i, note; _notes) {
                if (note.isInside(coord, coord)) {
                    PatternSequencerVelocityWindow window = new PatternSequencerVelocityWindow(note);
                    Vec2f pos = getCenter() - _viewPosition;
                    pos += Vec2f(note.start * StepWidth, (127f - note.note) * StepHeight);
                    window.setPosition(pos);
                    Atelier.ui.addUI(window);

                    window.addEventListener("value", {
                        _lastNoteVelocity = note.velocity;
                    });
                    break;
                }
            }
        }
    }

    private void _previewNotes(bool play) {
        Vec2i coord1 = _convertToGrid(_endMousePosition);
        Vec2i coord2 = coord1;

        coord1.y = 0;
        coord2.y = 127;

        Vec2i minCoord = coord1.min(coord2);
        Vec2i maxCoord = coord1.max(coord2);

        if (play) {
            Note[] tempNotes;
            foreach (Note previewedNote; _previewedNotes) {
                if (!previewedNote.isInside(minCoord, maxCoord)) {
                    playNote(previewedNote.note, false, previewedNote.velocity);
                }
                else {
                    tempNotes ~= previewedNote;
                }
            }
            _previewedNotes = tempNotes;

            foreach (note; _notes) {
                if (note.isInside(minCoord, maxCoord)) {
                    bool isAlreadyPlayed;
                    foreach (Note previewedNote; _previewedNotes) {
                        if (note == previewedNote) {
                            isAlreadyPlayed = true;
                            break;
                        }
                    }
                    if (!isAlreadyPlayed) {
                        _previewedNotes ~= note;
                        playNote(note.note, true, note.velocity);
                    }
                }
            }
        }
        else {
            foreach (Note previewedNote; _previewedNotes) {
                playNote(previewedNote.note, false, previewedNote.velocity);
            }
            _previewedNotes.length = 0;
        }
    }

    private void _captureSelection(bool apply) {
        Vec2i coord1 = _convertToGrid(_startMousePosition);
        Vec2i coord2 = _convertToGrid(_endMousePosition);

        Vec2i minCoord = coord1.min(coord2);
        Vec2i maxCoord = coord1.max(coord2);

        if (_isEffectMode) {
            foreach (effect; _tempSelectedEffects) {
                effect.setTempSelected(false);
            }
            _tempSelectedEffects.length = 0;

            foreach (effect; _effects) {
                if (!effect.getTempSelected() && !effect.getSelected() &&
                    effect.isInside(minCoord, maxCoord)) {
                    effect.setTempSelected(true);
                    _tempSelectedEffects ~= effect;
                }
            }
        }
        else {
            foreach (note; _tempSelectedNotes) {
                note.setTempSelected(false);
            }
            _tempSelectedNotes.length = 0;

            foreach (note; _notes) {
                if (!note.getTempSelected() && !note.getSelected() &&
                    note.isInside(minCoord, maxCoord)) {
                    note.setTempSelected(true);
                    _tempSelectedNotes ~= note;
                }
            }
        }

        if (apply) {
            if (_isEffectMode) {
                foreach (effect; _tempSelectedEffects) {
                    effect.setTempSelected(false);
                    effect.setSelected(true);
                }
                _selectedEffects ~= _tempSelectedEffects;
                _tempSelectedEffects.length = 0;

                if (_selectedEffects.length == 1) {
                    _lastNoteDuration = _selectedEffects[0].duration;
                }
            }
            else {
                foreach (note; _tempSelectedNotes) {
                    note.setTempSelected(false);
                    note.setSelected(true);
                }
                _selectedNotes ~= _tempSelectedNotes;
                _tempSelectedNotes.length = 0;

                if (_selectedNotes.length == 1) {
                    _lastNoteDuration = _selectedNotes[0].duration;
                    _lastNoteVelocity = _selectedNotes[0].velocity;
                }
            }
        }
    }

    private void _moveSelection(bool apply) {
        if (_isEffectMode) {
            Vec2i deltaGrid = cast(Vec2i)((_endMousePosition - _startMousePosition) / Vec2f(StepWidth,
                    EffectHeight));

            foreach (effect; _selectedEffects) {
                effect.setTempMove(deltaGrid);
            }

            if (apply) {
                foreach (effect; _selectedEffects) {
                    effect.applyMove();
                }
                _solveCollisions();
            }
        }
        else {
            Vec2i deltaGrid = cast(Vec2i)((_endMousePosition - _startMousePosition) / Vec2f(StepWidth,
                    StepHeight));

            uint tempNote = 128;
            if (_selectedNotes.length == 1) {
                tempNote = _selectedNotes[0].tempNote;
            }

            foreach (note; _selectedNotes) {
                note.setTempMove(deltaGrid);
            }

            if (apply) {
                foreach (note; _selectedNotes) {
                    note.applyMove();
                }
                _solveCollisions();

                if (_selectedNotes.length == 1) {
                    playNote(tempNote, false, _selectedNotes[0].velocity);
                }
            }
            else if (_selectedNotes.length == 1 && tempNote != _selectedNotes[0].tempNote) {
                playNote(tempNote, false, _selectedNotes[0].velocity);
                playNote(_selectedNotes[0].tempNote, true, _selectedNotes[0].velocity);
            }
        }
    }

    private void _resizeSelection(bool apply) {
        int delta = cast(int)((_endMousePosition.x - _startMousePosition.x) / StepWidth);

        if (_isEffectMode) {
            foreach (effect; _selectedEffects) {
                effect.setTempResize(delta);
            }

            if (apply) {
                foreach (effect; _selectedEffects) {
                    effect.applyResize();
                }
                if (_selectedEffects.length == 1) {
                    _lastNoteDuration = _selectedEffects[0].duration;
                }
                _solveCollisions();
            }
        }
        else {
            foreach (note; _selectedNotes) {
                note.setTempResize(delta);
            }

            if (apply) {
                foreach (note; _selectedNotes) {
                    note.applyResize();
                }
                if (_selectedNotes.length == 1) {
                    _lastNoteDuration = _selectedNotes[0].duration;
                }
                _solveCollisions();
            }
        }
    }

    private Vec2i _convertToGrid(Vec2f pos) {
        if (_isEffectMode) {
            Vec2i coord = Vec2i(cast(int)(pos.x / StepWidth),
                cast(int) floor((pos.y + StepHeight) / EffectHeight));
            coord = coord.clamp(Vec2i.zero, Vec2i(_steps, (cast(int) effectList.length)) - 1);
            return coord;
        }
        else {
            Vec2i coord = Vec2i(cast(int)(pos.x / StepWidth),
                126 - cast(int) floor(pos.y / StepHeight));
            coord = coord.clamp(Vec2i.zero, Vec2i(_steps, 127));
            return coord;
        }
    }

    private void _solveCollisions() {
        if (_isEffectMode) {
            foreach (selectedEffect; _selectedEffects) {
                foreach (i, otherEffect; _effects) {
                    if (otherEffect.getSelected())
                        continue;

                    if (selectedEffect.collideWith(otherEffect)) {
                        _effects.mark(i);
                    }
                }
                _effects.sweep();
            }
        }
        else {
            foreach (selectedNote; _selectedNotes) {
                foreach (i, otherNote; _notes) {
                    if (otherNote.getSelected())
                        continue;

                    if (selectedNote.collideWith(otherNote)) {
                        _notes.mark(i);
                    }
                }
                _notes.sweep();
            }
        }
    }

    private void _onKey() {
        InputEvent.KeyButton event = getManager().input.asKeyButton();

        if (hasControlModifier() || event.echo)
            return;

        if (event.isPressed()) {
            switch (event.button) with (InputEvent.KeyButton.Button) {
            case space:
                _parameterWindow.play();
                _onPlay();
                break;
            case backspace:
            case remove:
                if (_isEffectMode) {
                    foreach (selectedEffect; _selectedEffects) {
                        foreach (i, otherEffect; _effects) {
                            if (otherEffect == selectedEffect) {
                                _effects.mark(i);
                            }
                        }
                        _effects.sweep();
                    }
                    _selectedEffects.length = 0;
                }
                else {
                    foreach (selectedNote; _selectedNotes) {
                        foreach (i, otherNote; _notes) {
                            if (otherNote == selectedNote) {
                                _notes.mark(i);
                            }
                        }
                        _notes.sweep();
                    }
                    _selectedNotes.length = 0;
                }
                break;
            case a:
                if (_currentOctave > 0) {
                    for (uint i; i < 12; ++i) {
                        playNote(_currentOctave * 12 + i, false);
                    }
                    _currentOctave--;
                }
                break;
            case k:
                if (_currentOctave < 10) {
                    for (uint i; i < 12; ++i) {
                        playNote(_currentOctave * 12 + i, false);
                    }
                    _currentOctave++;
                }
                break;
            default:
                break;
            }
        }

        switch (event.button) with (InputEvent.KeyButton.Button) {
        case z:
            uint note = _currentOctave * 12;
            if (note < 128) {
                playNote(note, event.isPressed());
            }
            break;
        case s:
            uint note = _currentOctave * 12 + 1;
            if (note < 128) {
                playNote(note, event.isPressed());
            }
            break;
        case x:
            uint note = _currentOctave * 12 + 2;
            if (note < 128) {
                playNote(note, event.isPressed());
            }
            break;
        case d:
            uint note = _currentOctave * 12 + 3;
            if (note < 128) {
                playNote(note, event.isPressed());
            }
            break;
        case c:
            uint note = _currentOctave * 12 + 4;
            if (note < 128) {
                playNote(note, event.isPressed());
            }
            break;
        case v:
            uint note = _currentOctave * 12 + 5;
            if (note < 128) {
                playNote(note, event.isPressed());
            }
            break;
        case g:
            uint note = _currentOctave * 12 + 6;
            if (note < 128) {
                playNote(note, event.isPressed());
            }
            break;
        case b:
            uint note = _currentOctave * 12 + 7;
            if (note < 128) {
                playNote(note, event.isPressed());
            }
            break;
        case h:
            uint note = _currentOctave * 12 + 8;
            if (note < 128) {
                playNote(note, event.isPressed());
            }
            break;
        case n:
            uint note = _currentOctave * 12 + 9;
            if (note < 128) {
                playNote(note, event.isPressed());
            }
            break;
        case j:
            uint note = _currentOctave * 12 + 10;
            if (note < 128) {
                playNote(note, event.isPressed());
            }
            break;
        case m:
            uint note = _currentOctave * 12 + 11;
            if (note < 128) {
                playNote(note, event.isPressed());
            }
            break;
        default:
            break;
        }
    }

    void playNote(uint note, bool state, uint velocity = 100) {
        if (_noteStates[note] == state) {
            return;
        }
        _noteStates[note] = state;
        if (state) {
            midiPlayNote(note, velocity);
        }
        else {
            midiStopNote(note);
        }
    }

    private void _onDraw() {
        Vec2f offset = getCenter() - _viewPosition;

        for (uint i; i < 128; ++i) {
            uint noteInOctave = (i % 12);
            bool isSharp = _isNoteSharp[noteInOctave];
            Vec2f pos = Vec2f(0f, offset.y + (126f - i) * StepHeight);

            Atelier.renderer.drawRect(pos, Vec2f(getWidth(), StepHeight),
                isSharp ? Color.black : Color.white, 0.1f, true);
        }

        for (uint i; i < _steps; i += _bars) {
            Vec2f pos = Vec2f(offset.x + i * StepWidth, 0f);
            Atelier.renderer.drawLine(pos, Vec2f(pos.x, getHeight()), Color.gray, 1f);

            dstring text = to!dstring(i);
            drawText(pos + Vec2f(2f, 12f), text, Atelier.theme.font, Atelier.theme.onNeutral);
            drawText(pos + Vec2f(2f, getHeight()), text, Atelier.theme.font,
                Atelier.theme.onNeutral);
        }

        Atelier.renderer.drawRect(Vec2f(offset.x + _steps * StepWidth, 0f),
            Vec2f(getWidth(), getHeight()), Color.black, 1f, true);

        for (uint i = 12; i < 128; i += 12) {
            float y = offset.y + (127f - i) * StepHeight;
            Atelier.renderer.drawLine(Vec2f(0f, y), Vec2f(getWidth(), y), Color.white, 0.5f);
        }

        foreach (note; _notes) {
            note.draw(offset);
        }

        if (_isEffectMode) {
            foreach (effect; _effects) {
                effect.draw(offset);
            }
        }

        if (_isApplyingTool) {
            switch (_tool) {
            case 0:
            case 4:
                Vec2f startPos = offset + _startMousePosition;
                Vec2f endPos = offset + _endMousePosition;
                Atelier.renderer.drawRect(startPos, endPos - startPos,
                    Atelier.theme.danger, 1f, false);
                break;
            case 6:
                float posX = offset.x + _endMousePosition.x;
                Atelier.renderer.drawLine(Vec2f(posX, 0f), Vec2f(posX,
                        getHeight()), Atelier.theme.danger, 1f);
                break;
            default:
                break;
            }
        }

        if (midiIsPlaying()) {
            double bpms = _bpm / 60_000.0;
            double time = midiGetTime() * bpms;
            double sz = _steps * StepWidth;
            time = (time * sz) / _blocks;
            Vec2f pos = Vec2f(offset.x + time, 0f);
            Atelier.renderer.drawLine(pos, Vec2f(pos.x, getHeight()), Atelier.theme.accent, 1f);
        }

        if (_isEffectMode) {
            for (uint effect; effect < effectList.length; ++effect) {
                Vec2f pos = Vec2f(0f, offset.y + (effect + 1) * EffectHeight - StepHeight);
                Vec2f sz = Vec2f(80f, EffectHeight);

                Atelier.renderer.drawRect(pos - Vec2f(0f, EffectHeight), sz,
                    (effect & 0b1) ? Atelier.theme.surface : Atelier.theme.container, 1f, true);

                if (effectListLine2[effect].length) {
                    drawText(pos + Vec2f(4f, (-EffectHeight / 2f) - 8f),
                        effectList[effect], Atelier.theme.font, Color.white);

                    drawText(pos + Vec2f(4f, (-EffectHeight / 2f) + 8f),
                        effectListLine2[effect], Atelier.theme.font, Color.white);
                }
                else {
                    drawText(pos + Vec2f(4f, -EffectHeight / 2f),
                        effectList[effect], Atelier.theme.font, Color.white);
                }
            }
        }
        else {
            uint i;
            for (uint octave; octave < 11; ++octave) {
                Vec2f pos = Vec2f(0f, offset.y + (127f - (octave * 12)) * StepHeight);

                for (uint note; note < 12; ++note) {
                    bool isSharp = _isNoteSharp[note];

                    if (!isSharp) {
                        Vec2f notePos = pos + Vec2f(0f, -_pianoNoteOffsets[note]);
                        if (_noteStates[i]) {
                            _pianoNoteOnSprites[_noteDegrees[note]].draw(notePos);
                        }
                        else {
                            _pianoNoteOffSprites[_noteDegrees[note]].draw(notePos);
                        }
                    }

                    i++;
                    if (i >= 128) {
                        break;
                    }
                }

                i = octave * 12;

                for (uint note; note < 12; ++note) {
                    bool isSharp = _isNoteSharp[note];

                    if (isSharp) {
                        Vec2f notePos = pos + Vec2f(0f, -_pianoNoteOffsets[note]);
                        if (_noteStates[i]) {
                            _pianoSharpNoteOnSprite.draw(notePos);
                        }
                        else {
                            _pianoSharpNoteOffSprite.draw(notePos);
                        }
                    }

                    i++;
                    if (i >= 128) {
                        break;
                    }
                }
            }
        }
    }
}
