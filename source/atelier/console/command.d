module atelier.console.command;

import std.format : format;
import atelier.console.value;
import atelier.console.system;
import atelier.console.error;

enum ConsoleType {
    bool_,
    int_,
    uint_,
    float_,
    string_,
}

final class ConsoleResult {
    private {
        Console _console;
        ConsoleValue[string] _arguments;
    }

    @property {
        Console console() {
            return _console;
        }
    }

    @disable this();

    package this(Console console_) {
        _console = console_;
    }

    void setArgument(string name, ConsoleValue value) {
        _arguments[name] = value;
    }

    T getArgument(T)(string name) {
        auto p = name in _arguments;
        if (!p)
            throw new ConsoleException(format("Aucun argument de type `%s`", name));
        return p.get!T();
    }
}

final class ConsoleCommand {
    alias Callback = void function(ConsoleResult);

    struct Parameter {
        string name;
        ConsoleType type;
    }

    struct Option {
        string name;
        ConsoleType type;
        ConsoleValue value;
    }

    private {
        ConsoleCommand[string] _commands;
        Callback _callback;
        Parameter[] _parameters;
        Option[] _options;
        string _hint;
    }

    ConsoleCommand addCommand(string name) {
        ConsoleCommand command = new ConsoleCommand;
        _commands[name] = command;
        return command;
    }

    void setCallback(Callback callback) {
        _callback = callback;
    }

    Callback getCallback() const {
        return _callback;
    }

    void setHint(string hint) {
        _hint = hint;
    }

    string getHint() const {
        return _hint;
    }

    void addParameter(string name, ConsoleType type) {
        Parameter parameter;
        parameter.name = name;
        parameter.type = type;
        _parameters ~= parameter;
    }

    void addOption(string name, ConsoleType type, ConsoleValue value) {
        Option option;
        option.name = name;
        option.type = type;
        option.value = value;
        _options ~= option;
    }

    ConsoleCommand getCommand(string name) {
        auto p = name in _commands;
        return p ? *p : null;
    }

    Parameter[] getParameters() {
        return _parameters;
    }

    Option[] getOptions() {
        return _options;
    }
}
