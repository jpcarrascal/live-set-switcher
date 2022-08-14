var MIDIout = null;
var MIDIin = null;
var MIDIinIndex = 0;
var MIDIch = 10;
var openCsv = document.getElementById("open-csv");

const ipc = require('electron').ipcRenderer; 
let reply = ipc.sendSync('ping','a string', 10);

if (navigator.requestMIDIAccess) {
    console.log('Browser supports MIDI. Yay!');
    navigator.requestMIDIAccess().then(success, failure);
}

function success(midi) {

    var inList  = document.getElementById("select-midi-in");
    var chList  = document.getElementById("select-midi-channel");
    var inputs  = midi.inputs.values();
    var numIns  = 0;
    // outputs is an Iterator
    if(MIDIch) chList.value = MIDIch;
    console.log("finding input ports")

    for (var input = inputs.next(); input && !input.done; input = inputs.next()) {
        var option = document.createElement("option");
        option.value = input.value.id;
        option.text = input.value.name;
        //if(selectedIn == input.value.id) option.selected = true;
        inList.appendChild(option);
        numIns++;
        console.log(input.value.name)
    }

    inList.addEventListener("change", function(e) {
        ipc.sendSync('ping', ("MIDI in: " + this.options[this.selectedIndex].text + " selected."), 10);
        if(this.value != 0) {
            console.log("MIDI in: " + this.options[this.selectedIndex].text + " selected.");
        } else {
            console.log("Internal clock selected.");
        }
    });

    if(MIDIinIndex != 0 && MIDIinIndex != null) {
        console.log("MIDI clock in: " + MIDIin.name);
        MIDIin.onmidimessage = processMIDIin;
    } else {
        console.log("Using internal clock.");
    }
}


function processMIDIin(midiMsg) {
    // altStartMessage: used to sync when playback has already started
    // in clock source device
    // 0xB0 & 0x07 = CC, channel 8.
    // PC: 0xC0 - 0xCF
    // Responding to altStartMessage regardless of channels
    var altStartMessage = (midiMsg.data[0] & 240) == 176 &&
                         midiMsg.data[1] == 16 &&
                         midiMsg.data[2] > 63;
    if(midiMsg.data[0] == 250 || altStartMessage) { // 0xFA Start (Sys Realtime)

    } else if(midiMsg.data[0] == 252) { // 0xFC Stop (Sys Realtime)

    } else if(midiMsg.data[0] == 248) { // 0xF8 Timing Clock (Sys Realtime)

    } else if((midiMsg.data[0] & 240) == 176 && (midiMsg.data[0] & 15) == MIDIch) { //CC, right channel
 
    }
     else {
        console.log(midiMsg.data)
    }
}

function failure(){ console.log("MIDI not supported :(")};

openCsv.addEventListener('click', function(e) {
    ipc.sendSync('open-csv', '', 10);
});

ipc.on('csv-data', function (evt, message) {
    console.log("Received from main:")
    console.log(message); // Returns: {'SAVED': 'File Saved'}
    parseCsv(message)
});

function parseCsv(data) {
    const table = document.getElementById("set-list-body");
    table.innerHTML = '';
    var i = 0;
    data.forEach( item => {
        if(item.location && item.location != "" &&
            item.pc && item.pc != "") {
            let row = table.insertRow();
            if(i%2) row.classList.add("grey-row")
            let pc = row.insertCell(0);
            pc.innerHTML = item.pc;
            let name = row.insertCell(1);
            name.innerHTML = item.name;
            let location = row.insertCell(2);
            location.innerHTML = item.location;
            i++;
        }
    });
}
