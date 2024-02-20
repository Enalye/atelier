/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.core.logger;

import std.concurrency;
import std.conv : to;
import core.vararg;

version (AtelierDev) {
    import std.stdio : write;
}
version (AtelierRedist) {
    import std.file : append, remove;
}

private {
    enum Log_Size = 1024;
    enum Log_File = "log.txt";
    Tid _loggerTid;
}

void initLogger() {
    version (AtelierRedist) {
        remove(Log_File);
    }
    _loggerTid = spawn(&_logger);
    setMaxMailboxSize(_loggerTid, Log_Size, OnCrowding.ignore);
}

void log(T...)(T args) {
    string msg;
    static foreach (arg; args) {
        msg ~= to!string(arg);
    }
    msg ~= "\n";
    _loggerTid.send(msg);
}

version (AtelierDev) private void _logger() {
    for (bool isRunning = true; isRunning;) {
        receive((string msg) { //
            write(msg);
        }, (OwnerTerminated e) { //
            isRunning = false;
        });
    }
}

version (AtelierRedist) private void _logger() {
    for (bool isRunning = true; isRunning;) {
        receive((string msg) { //
            std.file.append(Log_File, msg);
        }, (OwnerTerminated e) { //
            isRunning = false;
        });
    }
}
