module atelier.console.system;

import std.format : format;
import std.conv : to;
import std.string : lineSplitter, indexOf;
import std.typecons : No;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.input;
import atelier.render;
import atelier.console.error;
import atelier.console.cmd;
import atelier.console.command;
import atelier.console.token;
import atelier.console.tokenizer;
import atelier.console.value;

final class Console {
    private {
        ConsoleUI _ui;
        bool _isDisplayed;
        ConsoleCommand[string] _commands;
    }

    @property {
        /*Cli cli() {
            return _console;
        }*/
    }

    this() {
        //_console = new Cli();
        console_registerCommands(this);

        _ui = new ConsoleUI(this);
    }

    void clear() {
        _isDisplayed = false;
    }

    void clearLog() {
        _ui.clearLog();
    }

    void warn(T...)(T args) {
        _ui.log("[red]Error: ", args);
    }

    void log(T...)(T args) {
        _ui.log(args);
    }

    void showHelp(string command) {
        //_ui.log(_console.getHelp(command));
    }

    void showHelp() {
        //_ui.log(_console.getHelp());
    }

    ConsoleCommand addCommand(string name) {
        ConsoleCommand command = new ConsoleCommand;
        _commands[name] = command;
        return command;
    }

    void run(string text) {
        ConsoleTokenizer tokenizer = new ConsoleTokenizer(text);
        ConsoleCommand command;
        ConsoleValue[] values;
        ConsoleCommand.Parameter[] parameters;
        ConsoleCommand.Option[] options;

        while (!tokenizer.isEndToken()) {
            ConsoleToken token = tokenizer.getToken();
            tokenizer.check(command || token.type == ConsoleToken.Type.key,
                format!"commande attendue, `%s` trouvé à la place"(token.toString()));
            tokenizer.advanceToken();

            final switch (token.type) with (ConsoleToken.Type) {
            case key:
                if (values.length) {
                    warn("Commande invalide après liste d’arguments");
                    return;
                }

                if (command) {
                    command = command.getCommand(token.strValue);
                }
                else {
                    command = getCommand(token.strValue);
                }

                if (command) {
                    parameters = command.getParameters();
                    options = command.getOptions();
                }
                else {
                    warn("Aucune commande `", token.strValue, "`");
                    return;
                }
                break;
            case int_:
                values ~= ConsoleValue(token.intValue);
                break;
            case uint_:
                values ~= ConsoleValue(token.uintValue);
                break;
            case char_:
                values ~= ConsoleValue(token.charValue);
                break;
            case float_:
                values ~= ConsoleValue(token.floatValue);
                break;
            case bool_:
                values ~= ConsoleValue(token.boolValue);
                break;
            case string_:
                values ~= ConsoleValue(token.strValue);
                break;
            }
        }

        if (!command)
            return;

        ConsoleCommand.Callback callback = command.getCallback();
        ConsoleCall call = new ConsoleCall(this);

        if (!callback) {
            warn("Aucun callback défini");
            return;
        }

        if (values.length > (parameters.length + options.length)) {
            warn("Trop d’arguments");
            return;
        }

        foreach (option; options) {
            call.setArgument(option.name, option.value);
        }

        uint argIndex;
        for (; argIndex < parameters.length; ++argIndex) {
            string name = parameters[argIndex].name;

            if (argIndex >= values.length) {
                warn("Arguments manquants");
                return;
            }

            call.setArgument(name, values[argIndex]);
        }
        for (uint i; i < options.length; ++i, ++argIndex) {
            string name = options[i].name;

            if (argIndex >= values.length)
                break;

            call.setArgument(name, values[argIndex]);
        }

        try {
            callback(call);
        }
        catch (ConsoleException e) {
            warn(e.msg);
        }
    }

    ColoredLabel[] getSuggestions(string text, Font font) {
        try {
            ConsoleTokenizer tokenizer = new ConsoleTokenizer(text);
            ConsoleCommand command, lastCommand;
            string validCommands;
            string partialCommand;

            while (!tokenizer.isEndToken()) {
                ConsoleToken token = tokenizer.getToken();
                tokenizer.advanceToken();

                if (token.type == ConsoleToken.Type.key) {
                    command = command ? command.getCommand(
                        token.strValue) : getCommand(token.strValue);

                    if (command) {
                        lastCommand = command;

                        if (validCommands.length) {
                            validCommands ~= " ";
                        }
                        validCommands ~= token.strValue;
                    }
                    else {
                        partialCommand = token.strValue;
                        break;
                    }
                }
                else {
                    break;
                }
            }

            string _getType(ConsoleType type) {
                final switch (type) with (ConsoleType) {
                case bool_:
                    return "B";
                case int_:
                    return "I";
                case uint_:
                    return "U";
                case float_:
                    return "F";
                case string_:
                    return "S";
                }
            }

            ColoredLabel[] labels;
            if (lastCommand) {
                if (!partialCommand.length) {
                    ColoredLabel label = new ColoredLabel(font);

                    string line = validCommands;

                    ColoredLabel.Token token;
                    token.index = 0;
                    token.textColor = Atelier.theme.onNeutral;
                    label.tokens ~= token;

                    token.index = line.length;
                    token.textColor = Color.fromHex(0xbbd4e2);
                    label.tokens ~= token;

                    foreach (param; lastCommand.getParameters()) {
                        line ~= " <" ~ _getType(param.type) ~ ":" ~ param.name ~ ">";
                    }

                    foreach (option; lastCommand.getOptions()) {
                        line ~= " [" ~ _getType(option.type) ~ ":" ~ option.name ~ "]";
                    }

                    token.index = line.length;
                    token.textColor = Color.fromHex(0x7a8f6d);
                    label.tokens ~= token;

                    line ~= " " ~ lastCommand.getHint();

                    label.text = line;
                    labels ~= label;
                }

                foreach (subCommandName, subCommand; lastCommand.getCommands()) {
                    ColoredLabel label = new ColoredLabel(font);

                    string line = validCommands ~ " " ~ subCommandName;

                    size_t startSearch = (validCommands.length + 1);
                    ptrdiff_t index = indexOf(line[startSearch .. $], partialCommand, No
                            .caseSentitive);

                    ColoredLabel.Token token;
                    token.index = 0;
                    token.textColor = Atelier.theme.onNeutral;
                    label.tokens ~= token;

                    if (index == 0) {
                        token.index = validCommands.length + 1;
                        token.textColor = Color.fromHex(0xe5eba9);
                        label.tokens ~= token;

                        startSearch += partialCommand.length;
                    }

                    token.index = startSearch;
                    token.textColor = Atelier.theme.neutral;
                    label.tokens ~= token;

                    token.index = line.length;
                    token.textColor = Color.fromHex(0xbbd4e2);
                    label.tokens ~= token;

                    foreach (param; subCommand.getParameters()) {
                        line ~= " <" ~ _getType(param.type) ~ ":" ~ param.name ~ ">";
                    }

                    foreach (option; subCommand.getOptions()) {
                        line ~= " [" ~ _getType(option.type) ~ ":" ~ option.name ~ "]";
                    }

                    token.index = line.length;
                    token.textColor = Color.fromHex(0x7a8f6d);
                    label.tokens ~= token;

                    line ~= " " ~ subCommand.getHint();

                    label.text = line;
                    labels ~= label;
                }
            }
            else if (text.length) {
                foreach (subCommandName, subCommand; _commands) {
                    ColoredLabel label = new ColoredLabel(font);

                    string line = subCommandName;
                    ptrdiff_t index = indexOf(line, partialCommand, No
                            .caseSentitive);

                    size_t startSearch = 0;
                    ColoredLabel.Token token;
                    if (index == 0) {
                        token.index = index;
                        token.textColor = Color.fromHex(0xe5eba9);
                        label.tokens ~= token;

                        startSearch += partialCommand.length;
                    }

                    token.index = startSearch;
                    token.textColor = Atelier.theme.neutral;
                    label.tokens ~= token;

                    token.index = line.length;
                    token.textColor = Color.fromHex(0xbbd4e2);
                    label.tokens ~= token;

                    foreach (param; subCommand.getParameters()) {
                        line ~= " <" ~ _getType(param.type) ~ ":" ~ param.name ~ ">";
                    }

                    foreach (option; subCommand.getOptions()) {
                        line ~= " [" ~ _getType(option.type) ~ ":" ~ option.name ~ "]";
                    }

                    token.index = line.length;
                    token.textColor = Color.fromHex(0x7a8f6d);
                    label.tokens ~= token;

                    line ~= " " ~ subCommand.getHint();

                    label.text = line;
                    labels ~= label;
                }
            }

            return labels;
        }
        catch (Exception e) {
            return [];
        }
    }

    ConsoleCommand getCommand(string name) {
        auto p = name in _commands;
        return p ? *p : null;
    }

    void setFont(Font font) {
        _ui.setFont(font);
    }

    bool dispatch(InputEvent input) {
        if (input.type == InputEvent.Type.keyButton) {
            InputEvent.KeyButton keyEvent = input.asKeyButton();

            if (keyEvent.state.down && keyEvent.button == InputEvent.KeyButton.Button.grave) {
                _toggleConsole();
            }

            if (keyEvent.button == InputEvent.KeyButton.Button.grave) {
                return true;
            }
        }
        return false;
    }

    private void _toggleConsole() {
        if (_ui.isTransitionning)
            return;

        if (!_isDisplayed) {
            Atelier.ui.pushModalUI(_ui);
            _ui.activate();
        }
        else {
            _ui.deactivate();
        }
        _isDisplayed = !_isDisplayed;
    }

    void runCommand(string command) {
        _ui._runCommand(command);
    }
}

private final class ConsoleSuggestions : Modal {
    private {
        VBox _vbox;
    }

    this(float width) {
        setSize(Vec2f(width, 16f));
        isEnabled = false;

        _vbox = new VBox;
        _vbox.setAlign(UIAlignX.left, UIAlignY.center);
        _vbox.setPosition(Vec2f(16f, 0f));
        _vbox.setChildAlign(UIAlignX.left);
        _vbox.setSpacing(4f);
        addUI(_vbox);

        _vbox.addEventListener("size", { setHeight(_vbox.getHeight() + 16f); });
    }

    void setList(ColoredLabel[] list) {
        _vbox.clearUI();

        foreach (line; list) {
            /*ColoredTextFormat ctf = formatColoredText(line);
            ColoredLabel label = new ColoredLabel(ctf.text, font);
            label.tokens = ctf.tokens;*/
            _vbox.addUI(line);
        }
    }
}

private final class ConsoleUI : UIElement {
    private {
        VBox _logBox;
        Console _console;
        TextField _inputField;
        bool _isTransitionning;
        string[] _history;
        size_t _historyPos;
        Font _font;
        ConsoleSuggestions _suggestions;
    }

    @property {
        bool isTransitionning() const {
            return _isTransitionning;
        }
    }

    this(Console console) {
        _console = console;
        setSize(Vec2f(Atelier.window.width, 300));
        setAlign(UIAlignX.left, UIAlignY.top);

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.left, UIAlignY.bottom);
        vbox.setChildAlign(UIAlignX.left);
        vbox.setSpacing(4f);
        addUI(vbox);

        _logBox = new VBox;
        _logBox.setChildAlign(UIAlignX.left);
        _logBox.setMargin(Vec2f(4f, 0f));
        vbox.addUI(_logBox);

        _inputField = new TextField;
        _inputField.setWidth(getWidth());
        _inputField.hasBackground = false;
        _inputField.limit = 300;
        vbox.addUI(_inputField);

        addEventListener("draw", &_onDraw);
        addEventListener("state", &_onState);
        addEventListener("key", &_onKey);

        State visibleState = new State("visible");
        visibleState.spline = Spline.sineOut;
        visibleState.time = 10;
        addState(visibleState);

        State hiddenState = new State("hidden");
        hiddenState.scale = Vec2f(1f, 0f);
        hiddenState.spline = Spline.sineOut;
        hiddenState.alpha = 0f;
        hiddenState.time = 10;
        addState(hiddenState);

        setState("hidden");
        setFont(null);
    }

    void setSuggestions(ColoredLabel[] list) {
        if (list.length) {
            if (!_suggestions) {
                _suggestions = new ConsoleSuggestions(getWidth());
                _suggestions.setAlign(UIAlignX.left, UIAlignY.bottom);
                _suggestions.setPosition(Vec2f(0f, _inputField.getHeight() + 2f));
                addUI(_suggestions);
            }
            _suggestions.setList(list);
        }
        else if (_suggestions) {
            _suggestions.removeUI();
            _suggestions = null;
        }
    }

    void setFont(Font font) {
        _font = font;

        if (!_font) {
            _font = Atelier.theme.font;
        }

        if (_font) {
            _inputField.setFont(_font);

            foreach (label; cast(ColoredLabel[]) _logBox.getChildren().array) {
                label.font = _font;
            }
        }
    }

    void activate() {
        runState("visible");
        _isTransitionning = true;
        Atelier.input.setLock(true);
    }

    void deactivate() {
        runState("hidden");
        _isTransitionning = true;
        _inputField.value = "";
        Atelier.ui.setFocus(null);
        Atelier.input.setLock(false);
    }

    void log(T...)(T args) {
        string msg;
        static foreach (arg; args) {
            msg ~= to!string(arg);
        }

        foreach (line; msg.lineSplitter) {
            ColoredTextFormat ctf = formatColoredText(line);
            ColoredLabel label = new ColoredLabel(ctf.text, _font);
            label.tokens = ctf.tokens;
            _logBox.addUI(label);
        }

        if ((_logBox.getHeight() + _inputField.getHeight()) >= getHeight()) {
            Array!UIElement children = _logBox.getChildren();
            if (!children.length)
                return;
            children[0].removeUI();
        }
    }

    void clearLog() {
        _logBox.clearUI();
    }

    void _runCommand(string value) {
        _history ~= value;
        if (_history.length > 10) {
            _history = _history[1 .. $];
        }
        _historyPos = _history.length;

        try {
            _console.run(value);
        }
        catch (CliException e) {
            log("[red]Erreur: " ~ e.msg);
        }
    }

    private void _onKey() {
        if (Atelier.ui.input.type == InputEvent.Type.keyButton) {
            InputEvent.KeyButton keyEvent = Atelier.ui.input.asKeyButton();

            if (keyEvent.state.down) {
                switch (keyEvent.button) with (InputEvent.KeyButton.Button) {
                case enter:
                    _runCommand(_inputField.value);
                    _inputField.value = "";
                    break;
                case up:
                    if (_historyPos > 0) {
                        _historyPos--;
                    }
                    if (_historyPos < _history.length) {
                        _inputField.value = _history[_historyPos];
                    }
                    break;
                case down:
                    if (_historyPos < _history.length) {
                        _historyPos++;
                    }
                    if (_historyPos < _history.length) {
                        _inputField.value = _history[_historyPos];
                    }
                    break;
                default:
                    break;
                }
            }
        }

        setSuggestions(_console.getSuggestions(_inputField.value, _font));
    }

    private void _onState() {
        _isTransitionning = false;
        switch (getState()) {
        case "hidden":
            removeUI();
            break;
        case "visible":
            _inputField.focus();
            break;
        default:
            break;
        }
    }

    private void _onDraw() {
        Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.background, 0.8f, true);
    }
}
