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
        MIDIportIndex = this.options[this.selectedIndex].value;
        updatePort(MIDIportIndex);
        ipc.send('save-setting', {setting: "port", value: MIDIportIndex});
    });

    channelList.addEventListener("change", function(e) {
        ipc.send('save-setting', {setting: "channel", value: this.options[this.selectedIndex].value});
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
    ipc.send('open-csv', '');
});

openLive.addEventListener('click', function(e) {
    let loc = bigName.getAttribute("location");
    if(loc && loc !="") ipc.send('open-set', loc);
});

showBigName.addEventListener('click', function(e) {
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
    console.log("changing " + message.key + " to " + message.data);
    if(message.key == "setlist") {
        console.log("Setlist loaded...");
        parseCsv(message.data);
    }
    else if (message.key == "port") {
        document.getElementById("select-midi-in").value = message.data;
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
    var newLoc = row.getElementsByTagName('td')[2].innerText;
    bigName.innerHTML = newSet;
    bigName.setAttribute("location", newLoc);
    document.querySelectorAll(".set-row").forEach( elem => {
        elem.classList.remove("selected-row");
    });
    row.classList.add("selected-row");
}

function scrollTable(direction) {
    const table = document.getElementById("set-list-body");
    let rows = table.getElementsByTagName('tr');
    let selectedRow = -1;
    let nextIndex = -1;
    for(let i=0; i<rows.length; i++) {
        if(rows[i].classList.contains("selected-row")) {
            selectedRow = i;
            break;
        }
    }
    if(direction == 'next') nextIndex = selectedRow + 1;
    else nextIndex = selectedRow - 1;
    if(nextIndex >= 0 && nextIndex < rows.length) {
        selectRow(rows[nextIndex]);
    }
    console.log(nextIndex);
}

// Keyboard input:


document.addEventListener("keydown", (e) => {
    switch (e.key) {
        case 'Enter':
            e.preventDefault();
            console.log("entr clicked")
            openLive.click();
            break;
        case 'Escape':
            e.preventDefault();
            showBigName.click();
            break;
        case 'ArrowUp':
            e.preventDefault();
            scrollTable('prev');
            break;
        case 'ArrowDown':
            e.preventDefault();
            scrollTable('next');
            break;
    }
})