module atelier.etabli.media.sequencer.tracklist.editor;

import std.algorithm : sort;
import std.conv : to;
import std.math : floor;
import std.path : setExtension, buildNormalizedPath, dirName;

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
import atelier.etabli.media.sequencer.tracklist.parameter;
import atelier.etabli.media.sequencer.tracklist.pattern;
import atelier.etabli.media.sequencer.tracklist.pattern_data;
import atelier.etabli.media.sequencer.tracklist.tempo;
import atelier.etabli.media.sequencer.tracklist.tempo_data;
import atelier.etabli.media.sequencer.tracklist.toolbox;

package {
    enum BlockWidth = 28f;
    enum BlockHeight = 64f;
    immutable dstring[] trackList = [
        "Tempo", "Piste 1", "Piste 2", "Piste 3", "Piste 4", "Piste 5", "Piste 6",
        "Piste 7", "Piste 8", "Piste 9", "Piste 10", "Piste 11", "Piste 12",
        "Piste 13", "Piste 14", "Piste 15", "Piste 16"
    ];
}

package(atelier.etabli.media.sequencer) final class TracklistSequencerEditor : SequencerBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        uint _blocks = 64;
        TracklistSequencerToolbox _toolbox;
        TracklistSequencerParameterWindow _parameterWindow;
        int _tool;

        int _currentBlock;
        double[] _blocksTime;
        bool _isRecording;
        AudioRecorder _recorder;

        Array!Tempo _tempos;
        Tempo[] _selectedTempos, _tempSelectedTempos;

        string _patternName;
        Array!Pattern _patterns;
        Pattern[] _selectedPatterns, _tempSelectedPatterns;

        Vec2f _viewPosition = Vec2f.zero;
        Vec2f _startMousePosition = Vec2f.zero;
        Vec2f _endMousePosition = Vec2f.zero;
        bool _isApplyingTool;

        uint _lastTempoDuration = 1;

        bool _isTempoMode;
    }

    @property {
        uint blocks() const {
            return _blocks;
        }

        bool isTempoMode() const {
            return _isTempoMode;
        }
    }

    this(SequencerEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _tempos = new Array!Tempo;
        _patterns = new Array!Pattern;

        _name = _ffd.get!string(0);

        if (_ffd.hasNode("blocks")) {
            _blocks = _ffd.getNode("blocks").get!uint(0);
        }

        foreach (node; _ffd.getNodes("tempo")) {
            _tempos ~= new Tempo(this, node);
        }

        foreach (node; _ffd.getNodes("pattern")) {
            _patterns ~= new Pattern(this, node);
        }

        _openAudio();

        _toolbox = new TracklistSequencerToolbox(this);
        Atelier.ui.addUI(_toolbox);
        _patternName = _toolbox.getPatternName();

        _parameterWindow = new TracklistSequencerParameterWindow(_blocks);

        _toolbox.addEventListener("tool", {
            _tool = _toolbox.getTool();
            _isTempoMode = _toolbox.getMode();
            _patternName = _toolbox.getPatternName();
        });
        addEventListener("register", {
            _openAudio();
            Atelier.ui.addUI(_toolbox);
            foreach (Pattern pattern; _patterns) {
                pattern.updatePreview();
            }
        });
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
            _blocks = _parameterWindow.getBlocks();
        });

        _parameterWindow.addEventListener("property_play", &_onPlay);
        _parameterWindow.addEventListener("property_record", &_onRecord);

        _viewPosition = Vec2f.zero;

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
        Farfadet node = ffd.addNode("tracklist").add(_name);
        node.addNode("blocks").add(_blocks);

        foreach (tempo; _tempos) {
            tempo.save(node);
        }

        foreach (pattern; _patterns) {
            pattern.save(node);
        }

        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    private void _play() {
        midiStartSession();
        foreach (tempo; _tempos) {
            midiAddTempoEvent(tempo.start, tempo.start + tempo.duration,
                tempo.startValue, tempo.endValue, tempo.spline);
        }
        foreach (pattern; _patterns) {
            Farfadet ffd = getPattern(pattern.name);

            if (!ffd) {
                Atelier.log("Le motif `", pattern.name, "` est introuvable");
                continue;
            }

            uint steps = 1;
            bool hasInstrument;
            uint pc, msb, lsb;

            if (ffd.hasNode("instrument")) {
                string instrumentRid = ffd.getNode("instrument").get!string(0);
                if (Atelier.etabli.hasResource("instrument", instrumentRid)) {
                    Atelier.etabli.ResourceInfo data = Atelier.etabli.getResource("instrument", instrumentRid);

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
            }

            if (ffd.hasNode("steps")) {
                steps = ffd.getNode("steps").get!uint(0);
            }

            midiOpenPattern(pattern.channel - 1, pattern.start, pattern.duration, steps);
            if (hasInstrument) {
                midiSetPatternInstrument(pc, msb, lsb);
            }
            if (ffd.hasNode("init")) {
                midiSetPatternInitialState(ffd.getNode("init").get!(int[])(0));
            }
            else {
                midiSetPatternInitialState([]);
            }
            foreach (noteNode; ffd.getNodes("note")) {
                midiAddNoteEvent(noteNode.get!uint(1), noteNode.get!uint(2),
                    noteNode.get!uint(0), noteNode.get!uint(3));
            }
            foreach (effectNode; ffd.getNodes("effect")) {
                uint type = effectNode.get!uint(0);
                uint startBlock = effectNode.get!uint(1);
                uint duration = effectNode.get!uint(2);
                int startValue, endValue;
                string spline;

                if (effectNode.hasNode("start")) {
                    startValue = effectNode.getNode("start").get!int(0);
                }

                if (effectNode.hasNode("end")) {
                    endValue = effectNode.getNode("end").get!int(0);
                }

                if (effectNode.hasNode("spline")) {
                    spline = effectNode.getNode("spline").get!string(0);
                }

                midiAddEffectEvent(startBlock, duration, type, startValue, endValue, spline);
            }
            midiClosePattern();
        }
        midiEndSession();
        _blocksTime = midiProcess(_blocks, 120.0);
        midiPlay();
        _currentBlock = 0;
    }

    private void _onPlay() {
        if (midiIsPlaying()) {
            midiStop();
            _currentBlock = -1;
            return;
        }

        addEventListener("update", &_onPlaying);
        _play();
    }

    private void _onRecord() {
        if (midiIsPlaying()) {
            midiStop();
            _currentBlock = -1;
            _isRecording = false;
            return;
        }

        string filePath = buildNormalizedPath(dirName(path()), setExtension(_name, ".wav"));

        _recorder = new AudioFileRecorder(filePath);
        Atelier.audio.record(_recorder);

        addEventListener("update", &_onRecording);

        _play();
        _isRecording = true;
    }

    private void _onPlaying() {
        if (!midiIsPlaying() || midiIsFinished()) {
            removeEventListener("update", &_onPlaying);
            midiStop();
        }
    }

    private void _onRecording() {
        if (!midiIsPlaying() || midiIsFinished()) {
            removeEventListener("update", &_onRecording);
            midiStop();

            if (_recorder) {
                _recorder.remove();
                _recorder = null;
            }
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
                    foreach (note; _selectedTempos) {
                        note.setSelected(false);
                    }
                    _selectedTempos.length = 0;

                    foreach (effect; _selectedPatterns) {
                        effect.setSelected(false);
                    }
                    _selectedPatterns.length = 0;
                }
                _captureSelection(false);
                break;
            case 1:
            case 3:
                if (_isTempoMode) {
                    if (_selectedTempos.length == 0) {
                        _captureSelection(true);
                    }
                }
                else {
                    if (_selectedPatterns.length == 0) {
                        _captureSelection(true);
                    }
                }
                break;
            case 2:
                _createBlock();
                break;
            case 4:
                foreach (pattern; _selectedPatterns) {
                    pattern.setSelected(false);
                }
                _selectedPatterns.length = 0;

                foreach (tempo; _selectedTempos) {
                    tempo.setSelected(false);
                }
                _selectedTempos.length = 0;

                _captureSelection(false);
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
                _removeBlock();
                break;
            case 5:
                _openPropertyWindow();
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
            _viewPosition.x -= ev.wheel.sum() * BlockWidth;
        }
        else {
            _viewPosition.y -= ev.wheel.sum() * BlockHeight;
        }

        _clampView();
    }

    private void _clampView() {
        Vec2f center = getCenter();
        _viewPosition.x = clamp(_viewPosition.x, center.x - 80f, 130f * BlockWidth);
        _viewPosition.y = clamp(_viewPosition.y, center.y - BlockHeight,
            ((cast(int) trackList.length) - 1) * BlockHeight - center.y);
    }

    private void _createBlock() {
        if (_isTempoMode) {
            foreach (tempo; _selectedTempos) {
                tempo.setSelected(false);
            }
            _selectedTempos.length = 0;

            Vec2i coord = _convertToGrid(_startMousePosition);
            Tempo tempo = new Tempo(this, coord.x, _lastTempoDuration);
            _tempos ~= tempo;
            _selectedTempos ~= tempo;
            tempo.setSelected(true);
        }
        else {
            foreach (pattern; _selectedPatterns) {
                pattern.setSelected(false);
            }
            _selectedPatterns.length = 0;

            Vec2i coord = _convertToGrid(_startMousePosition);
            Pattern pattern = new Pattern(this, coord.y, _patternName,
                coord.x, _lastTempoDuration);
            _patterns ~= pattern;
            _selectedPatterns ~= pattern;
            pattern.setSelected(true);
        }
    }

    private void _removeBlock() {
        if (_isTempoMode) {

            Tempo removedTempo;
            foreach (selectedTempo; _selectedTempos) {
                foreach (i, tempo; _tempos) {
                    if (selectedTempo == tempo) {
                        _tempos.mark(i);
                        removedTempo = tempo;
                        break;
                    }
                }
            }
            _tempos.sweep();
            _selectedTempos.length = 0;
        }
        else {
            Pattern removedPattern;
            foreach (selectedPattern; _selectedPatterns) {
                foreach (i, pattern; _patterns) {
                    if (selectedPattern == pattern) {
                        _patterns.mark(i);
                        removedPattern = pattern;
                        break;
                    }
                }
            }
            _patterns.sweep();
            _selectedPatterns.length = 0;
        }
    }

    private void _openPropertyWindow() {
        Vec2i coord = _convertToGrid(_startMousePosition);

        if (_isTempoMode) {
            foreach (i, tempo; _tempos) {
                if (tempo.isInside(coord, coord)) {
                    TracklistSequencerTempoDataWindow window = new TracklistSequencerTempoDataWindow(
                        tempo);
                    Vec2f pos = getCenter() - _viewPosition;
                    pos += Vec2f(tempo.start * BlockWidth, 0f);
                    window.setPosition(pos);
                    Atelier.ui.addUI(window);
                    break;
                }
            }
        }
        else {
            foreach (i, pattern; _patterns) {
                if (pattern.isInside(coord, coord)) {
                    TracklistSequencerPatternDataWindow window = new TracklistSequencerPatternDataWindow(pattern,
                        this);
                    Vec2f pos = getCenter() - _viewPosition;
                    pos += Vec2f(pattern.start * BlockWidth, pattern.channel * BlockHeight);
                    window.setPosition(pos);
                    Atelier.ui.addUI(window);
                    break;
                }
            }
        }
    }

    private void _captureSelection(bool apply) {
        Vec2i coord1 = _convertToGrid(_startMousePosition);
        Vec2i coord2 = _convertToGrid(_endMousePosition);

        Vec2i minCoord = coord1.min(coord2);
        Vec2i maxCoord = coord1.max(coord2);

        if (_isTempoMode) {
            foreach (tempo; _tempSelectedTempos) {
                tempo.setTempSelected(false);
            }
            _tempSelectedTempos.length = 0;

            foreach (tempo; _tempos) {
                if (!tempo.getTempSelected() && !tempo.getSelected() &&
                    tempo.isInside(minCoord, maxCoord)) {
                    tempo.setTempSelected(true);
                    _tempSelectedTempos ~= tempo;
                }
            }
        }
        else {
            foreach (pattern; _tempSelectedPatterns) {
                pattern.setTempSelected(false);
            }
            _tempSelectedPatterns.length = 0;

            foreach (pattern; _patterns) {
                if (!pattern.getTempSelected() && !pattern.getSelected() &&
                    pattern.isInside(minCoord, maxCoord)) {
                    pattern.setTempSelected(true);
                    _tempSelectedPatterns ~= pattern;
                }
            }
        }

        if (apply) {
            if (_isTempoMode) {
                foreach (tempo; _tempSelectedTempos) {
                    tempo.setTempSelected(false);
                    tempo.setSelected(true);
                }
                _selectedTempos ~= _tempSelectedTempos;
                _tempSelectedTempos.length = 0;

                if (_selectedTempos.length == 1) {
                    _lastTempoDuration = _selectedTempos[0].duration;
                }
            }
            else {
                foreach (pattern; _tempSelectedPatterns) {
                    pattern.setTempSelected(false);
                    pattern.setSelected(true);
                }
                _selectedPatterns ~= _tempSelectedPatterns;
                _tempSelectedPatterns.length = 0;
            }
        }
    }

    private void _moveSelection(bool apply) {
        if (_isTempoMode) {
            Vec2i deltaGrid = cast(Vec2i)((_endMousePosition - _startMousePosition) / Vec2f(BlockWidth,
                    BlockHeight));

            foreach (tempo; _selectedTempos) {
                tempo.setTempMove(deltaGrid);
            }

            if (apply) {
                foreach (tempo; _selectedTempos) {
                    tempo.applyMove();
                }
                _solveCollisions();
            }
        }
        else {
            Vec2i deltaGrid = cast(Vec2i)((_endMousePosition - _startMousePosition) / Vec2f(BlockWidth,
                    BlockHeight));

            foreach (pattern; _selectedPatterns) {
                pattern.setTempMove(deltaGrid);
            }

            if (apply) {
                foreach (pattern; _selectedPatterns) {
                    pattern.applyMove();
                }
                _solveCollisions();
            }
        }
    }

    private void _resizeSelection(bool apply) {
        int delta = cast(int)((_endMousePosition.x - _startMousePosition.x) / BlockWidth);

        if (_isTempoMode) {
            foreach (tempo; _selectedTempos) {
                tempo.setTempResize(delta);
            }

            if (apply) {
                foreach (tempo; _selectedTempos) {
                    tempo.applyResize();
                }
                if (_selectedTempos.length == 1) {
                    _lastTempoDuration = _selectedTempos[0].duration;
                }
                _solveCollisions();
            }
        }
        else {
            foreach (pattern; _selectedPatterns) {
                pattern.setTempResize(delta);
            }

            if (apply) {
                foreach (pattern; _selectedPatterns) {
                    pattern.applyResize();
                }
                if (_selectedPatterns.length == 1) {
                    _lastTempoDuration = _selectedPatterns[0].duration;
                }
                _solveCollisions();
            }
        }
    }

    private Vec2i _convertToGrid(Vec2f pos) {
        if (_isTempoMode) {
            Vec2i coord = Vec2i(cast(int)(pos.x / BlockWidth),
                cast(int) floor((pos.y + BlockHeight) / BlockHeight));
            coord = coord.clamp(Vec2i.zero, Vec2i(_blocks, 0));
            return coord;
        }
        else {
            Vec2i coord = Vec2i(cast(int)(pos.x / BlockWidth),
                cast(int) floor((pos.y + BlockHeight) / BlockHeight));
            coord = coord.clamp(Vec2i(0, 1), Vec2i(_blocks, 16));
            return coord;
        }
    }

    private void _solveCollisions() {
        if (_isTempoMode) {
            foreach (selectedTempo; _selectedTempos) {
                foreach (i, otherTempo; _tempos) {
                    if (otherTempo.getSelected())
                        continue;

                    if (selectedTempo.collideWith(otherTempo)) {
                        _tempos.mark(i);
                    }
                }
                _tempos.sweep();
            }
        }
        else {
            foreach (selectedPattern; _selectedPatterns) {
                foreach (i, otherPattern; _patterns) {
                    if (otherPattern.getSelected())
                        continue;

                    if (selectedPattern.collideWith(otherPattern)) {
                        _patterns.mark(i);
                    }
                }
                _patterns.sweep();
            }
        }
    }

    private void _onKey() {
        InputEvent.KeyButton event = getManager().input.asKeyButton();

        if (hasControlModifier())
            return;

        if (event.isPressed()) {
            switch (event.button) with (InputEvent.KeyButton.Button) {
            case space:
                _parameterWindow.play();
                _onPlay();
                break;
            case backspace:
            case remove:
                if (_isTempoMode) {
                    foreach (selectedTempo; _selectedTempos) {
                        foreach (i, otherTempo; _tempos) {
                            if (otherTempo == selectedTempo) {
                                _tempos.mark(i);
                            }
                        }
                        _tempos.sweep();
                    }
                    _selectedTempos.length = 0;
                }
                else {
                    foreach (selectedPattern; _selectedPatterns) {
                        foreach (i, otherPattern; _patterns) {
                            if (otherPattern == selectedPattern) {
                                _patterns.mark(i);
                            }
                        }
                        _patterns.sweep();
                    }
                    _selectedPatterns.length = 0;
                }
                break;
            default:
                break;
            }
        }
    }

    private void _onDraw() {
        Vec2f offset = getCenter() - _viewPosition;

        for (uint i; i < _blocks; i += 4) {
            Vec2f pos = Vec2f(offset.x + i * BlockWidth, 0f);
            Atelier.renderer.drawLine(pos, Vec2f(pos.x, getHeight()), Color.gray, 1f);

            dstring text = to!dstring(i);
            drawText(pos + Vec2f(2f, 12f), text, Atelier.theme.font, Atelier.theme.onNeutral);
            drawText(pos + Vec2f(2f, getHeight()), text, Atelier.theme.font,
                Atelier.theme.onNeutral);
        }

        Atelier.renderer.drawRect(Vec2f(offset.x + _blocks * BlockWidth, 0f),
            Vec2f(getWidth(), getHeight()), Color.black, 1f, true);

        for (uint i; i < trackList.length; ++i) {
            float y = offset.y + i * BlockHeight;
            Atelier.renderer.drawLine(Vec2f(0f, y), Vec2f(getWidth(), y), Color.white, 0.5f);
        }

        foreach (tempo; _tempos) {
            tempo.draw(offset);
        }

        foreach (pattern; _patterns) {
            pattern.draw(offset);
        }

        if (midiIsPlaying() && _currentBlock >= 0 && _currentBlock < _blocksTime.length) {
            double time = midiGetTime();
            if (time >= _blocksTime[_currentBlock]) {
                _currentBlock++;
            }
            float pos = offset.x + _currentBlock * BlockWidth;
            Atelier.renderer.drawRect(Vec2f(pos, 0f), Vec2f(BlockWidth,
                    getHeight()), _isRecording ? Atelier.theme.danger
                    : Atelier.theme.accent, 0.5f, true);
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
            default:
                break;
            }
        }

        for (uint i; i < trackList.length; ++i) {
            Vec2f pos = Vec2f(0f, offset.y + i * BlockHeight);
            Vec2f sz = Vec2f(80f, BlockHeight);

            Atelier.renderer.drawRect(pos - Vec2f(0f, BlockHeight), sz,
                (i & 0b1) ? Atelier.theme.surface : Atelier.theme.container, 1f, true);

            drawText(pos + Vec2f(4f, -BlockHeight / 2f), trackList[i],
                Atelier.theme.font, Color.white);
        }
    }
}
