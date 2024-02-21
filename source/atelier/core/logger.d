/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.core.logger;

import std.concurrency;
import std.conv : to;
import std.file : append, remove;
import core.vararg;
import std.stdio;
import std.stdio : fflush, stderr, write;

private {
    enum Log_Size = 1024;
    enum Log_File = "log.txt";
    Tid _loggerTid;
    bool _isInit, _isRedist;
}

void initLogger(bool isRedist) {
    if (_isInit)
        return;
    _isRedist = isRedist;
    _isInit = true;

    if (_isRedist) {
        remove(Log_File);
        _loggerTid = spawn(&_fileLogger);
    }
    else {
        version (Windows) {
            import core.sys.windows.windows : SetConsoleOutputCP;

            SetConsoleOutputCP(65_001);
        }
        _loggerTid = spawn(&_cmdLogger);
    }
    setMaxMailboxSize(_loggerTid, Log_Size, OnCrowding.ignore);
}

void log(T...)(T args) {
    string msg;
    static foreach (arg; args) {
        msg ~= to!string(arg);
    }
    msg ~= "\n";
    if (_isRedist) {
        _loggerTid.send(msg);
    }
    else {
        write(msg);
    }
}

private void _cmdLogger() {
    for (bool isRunning = true; isRunning;) {
        receive((string msg) { //
            stdout.write(msg);
        }, (OwnerTerminated e) { //
            isRunning = false;
        });
    }
}

private void _fileLogger() {
    for (bool isRunning = true; isRunning;) {
        receive((string msg) { //
            append(Log_File, msg);
        }, (OwnerTerminated e) { //
            isRunning = false;
        });
    }
}
