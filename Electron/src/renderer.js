var MIDIport = null;
var MIDIportIndex = 0;
var MIDIch = 1;
var openCsv = document.getElementById("open-csv");
var showBigName = document.getElementById("show-big-name");
var bigName = document.getElementById("big-name-text");
var openLive = document.getElementById("open-live");

const ipc = require('electron').ipcRenderer; 

if (navigator.requestMIDIAccess) {
    console.log('Browser supports MIDI. Yay!');
    navigator.requestMIDIAccess().then(success, failure);
}

function success(midi) {

    var portList  = document.getElementById("select-midi-in");
    var channelList  = document.getElementById("select-midi-channel");
    var inputs  = midi.inputs.values();
    var numIns  = 0;
    // outputs is an Iterator
    for (var input = inputs.next(); input && !input.done; input = inputs.next()) {
        var option = document.createElement("option");
        option.value = input.value.id;
        option.text = input.value.name;
        portList.appendChild(option);
        numIns++;
        console.log(input.value.name)
    }

    portList.addEventListener("change", function(e) {
        ipc.send('save-setting', {setting: "port", value: this.options[this.selectedIndex].value}, 10);
        MIDIportIndex = this.options[this.selectedIndex].value;
        updatePort(MIDIportIndex);
    });

    channelList.addEventListener("change", function(e) {
        ipc.send('save-setting', {setting: "channel", value: this.options[this.selectedIndex].value}, 10);
    });

}

function updatePort (MIDIportIndex) {
    navigator.requestMIDIAccess().then( (midi) => {
        MIDIport = midi.inputs.get(MIDIportIndex);
        if(MIDIportIndex != 0 && MIDIportIndex != null) {
            MIDIport.onmidimessage = processMIDIin;
        }
    },
    failure
    );
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

    } else if((midiMsg.data[0] & 240) == 176 &&
              (midiMsg.data[0] & 15) == MIDIch) { //CC, correct channel
 
    } else if((midiMsg.data[0] & 240) == 192 &&
              (midiMsg.data[0] & 15) == MIDIch) { //PC, correct channel
        document.querySelectorAll(".set-row").forEach(row => {
            var pc = parseInt(row.firstChild.innerText);
            if(pc == midiMsg.data[1]) {
                selectRow(row);
                var location = row.getElementsByTagName('td')[2].innerText;
                console.log("Opening " + location)
                ipc.send('open-set', location);
            }
        })

    }
     else {
        
    }
}

function failure(){ console.log("MIDI not supported (or error accessing midi) :(")};

openCsv.addEventListener('click', function(e) {
    ipc.send('open-csv', '', 10);
});

showBigName.addEventListener('click', function(e) {
    console.log("toggling")
    var bn = document.getElementById("big-name");
    var tp = document.getElementById("top");
    if(bn.style.display == "none" || bn.style.display == "") {
        bn.style.display = "flex";
        tp.style.display = "none";
        showBigName.innerHTML = "Hide Big Name";
        ipc.send('on-top',true);
    } else {
        bn.style.display = "none";
        tp.style.display = "flex";
        showBigName.innerHTML = "Show Big Name";
        ipc.send('on-top',false);
    }
});


ipc.on('recover-setting', function (evt, message) {
    if(message.key == "setlist") {
        console.log("Setlist loaded...");
        parseCsv(message.data);
    }
    else if (message.key == "port") {
        document.getElementById("select-midi-in").value = message.data;
        console.log("changing port to " + message.data);
        MIDIportIndex = message.data;
        updatePort(MIDIportIndex);
    } else if (message.key == "channel") {
        document.getElementById("select-midi-channel").value = message.data;
        MIDIch = message.data;
    }
});

function parseCsv(data) {
    const table = document.getElementById("set-list-body");
    table.innerHTML = '';
    var i = 0;
    data.forEach( item => {
        if(item.location && item.location != "" &&
            item.pc && item.pc != "") {
            let row = table.insertRow();
            row.classList.add("set-row");
            if(i%2) row.classList.add("grey-row")
            let pc = row.insertCell(0);
            pc.classList.add("pc-col")
            pc.innerHTML = item.pc;
            let name = row.insertCell(1);
            name.classList.add("name-col")
            name.innerHTML = item.name;
            let location = row.insertCell(2);
            location.classList.add("location-col")
            location.innerHTML = item.location;
            row.addEventListener('click', function(e) {
                selectRow(row);
                openLive.classList.add("button-active");
            });
            i++;
        }
    });
    //scrollTable();
}

function selectRow(row) {
    var newSet = row.getElementsByTagName('td')[1].innerText;
    bigName.innerHTML = newSet;
    document.querySelectorAll(".set-row").forEach( elem => {
        elem.classList.remove("selected-row");
    });
    row.classList.add("selected-row");
}

function scrollTable() {
    const table = document.getElementById("set-list-body");
    var rows = table.getElementsByTagName('td');
    document.addEventListener("keydown", (e) => {
        e.preventDefault();
        switch (e.key) {
        case "ArrowUp": // UP

            break;
        case "ArrowDown": // DOWN
            break;
        }
    })
  }