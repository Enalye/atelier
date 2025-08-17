module atelier.etabli.core.midi.device;

import minuit;

import atelier.common;
import atelier.etabli.core.midi.player;

private {
    __gshared MnOutput _midiOut;
    __gshared MnInput _midiIn;
}

void initializeMidiDevices() {
    _midiOut = new MnOutput;
    _midiIn = new MnInput;

    //Atelier.log("Inputs: ", mnFetchInputsName());
    //Atelier.log("Outputs: ", mnFetchOutputsName());
    _midiOut.open("2- SD-90 PART A");
}

void closeMidiDevices() {
    midiStop();

    if (_midiOut)
        _midiOut.close();
    _midiOut = null;

    if (_midiIn)
        _midiIn.close();
    _midiIn = null;
}

void selectMidiOutDevice(MnOutputPort port) {
    if (!_midiOut)
        return;
    if (!port) {
        _midiOut.close();
        _midiOut.port = null;
        //saveConfig();
        return;
    }
    _midiOut.close();
    _midiOut.port = port;
    if (port)
        _midiOut.open(port);
    //saveConfig();
}

void selectMidiInDevice(MnInputPort port) {
    if (!_midiIn)
        return;
    if (!port) {
        _midiIn.close();
        _midiIn.port = null;
        //saveConfig();
        return;
    }
    _midiIn.close();
    _midiIn.port = port;
    if (port)
        _midiIn.open();
    //saveConfig();
}

MnOutput getMidiOut() {
    return _midiOut;
}

MnInput getMidiIn() {
    return _midiIn;
}
