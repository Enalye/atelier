module atelier.console.system;

import std.format : format;
import std.conv : to;
import std.string : lineSplitter;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.input;
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
                    Atelier.log("Erreur: commande invalide après liste d’arguments");
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
                    log("Erreur: pas de commande ", token.strValue);
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
        ConsoleResult result = new ConsoleResult(this);

        if (!callback) {
            log("Erreur: aucun callback");
            return;
        }

        if (values.length > (parameters.length + options.length)) {
            log("Erreur: trop d’arguments");
            return;
        }

        foreach (option; options) {
            result.setArgument(option.name, option.value);
        }

        uint argIndex;
        for (; argIndex < parameters.length; ++argIndex) {
            string name = parameters[argIndex].name;

            if (argIndex >= values.length) {
                log("Erreur: pas assez d’arguments");
                return;
            }

            result.setArgument(name, values[argIndex]);
        }
        for (uint i; i < options.length; ++i, ++argIndex) {
            string name = options[i].name;

            if (argIndex >= values.length)
                break;

            result.setArgument(name, values[argIndex]);
        }

        try {
            callback(result);
        }
        catch (ConsoleException e) {
            log("Erreur: ", e.msg);
        }
    }

    ConsoleCommand getCommand(string name) {
        auto p = name in _commands;
        return p ? *p : null;
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

private final class ConsoleUI : UIElement {
    private {
        VBox _logBox;
        Console _console;
        TextField _inputField;
        bool _isTransitionning;
        string[] _history;
        size_t _historyPos;
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
            ColoredLabel label = new ColoredLabel(ctf.text, Atelier.theme.font);
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

        /*string[] command;
        bool inQuotes;
        string current;
        foreach (ch; value) {
            if (ch == '\"') {
                inQuotes = !inQuotes;
                continue;
            }
            if (!inQuotes && ch <= 0x20) {
                if (current.length) {
                    command ~= current;
                    current.length = 0;
                }
                continue;
            }
            current ~= ch;
        }
        if (current.length) {
            command ~= current;
        }*/
        try {
            _console.run(value);
        }
        catch (CliException e) {
            log("[red]Erreur:[white] " ~ e.msg);

            // if (e.command.length) {
            // log("\n", _console.getHelp(e.command));
            // }
            // else {
            // log("\n", _console.getHelp());
            // }
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
