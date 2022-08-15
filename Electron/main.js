const { app, BrowserWindow, dialog } = require('electron');
const electron = require('electron');
const storage = require('electron-json-storage');
const ipc = require('electron').ipcMain;
const shell = require('electron').shell;
const nativeTheme = electron.nativeTheme;
const path = require('path');
const csv = require('csv-parser');
const fs = require('fs');
const reset = false;
let win;

app.whenReady().then(() => {

  if(reset) {
    storage.clear(function(error) {
      if (error) throw error;
    });
  }

  win = new BrowserWindow({
    width: 800,
    height: 625,
    minWidth: 400,
    minHeight: 625,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
      //preload: path.join(__dirname, 'renderer.js')
    }
  })

  win.loadFile('index.html')
  win.webContents.openDevTools()

  win.webContents.on('did-finish-load', function () {
    recoverSetting('setlist', win);
    recoverSetting('port', win);
    recoverSetting('channel', win);
  });

})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit()
})

ipc.on('save-setting', (event, args) => {
  //do something with args
  event.returnValue = 'Hi, sync reply';

  storage.set(args.setting, args.value, function(error) {
    if (error) throw error;
    storage.get(args.setting, function(error, data) {
      if (error) throw error;
      console.log(args.setting + " saved as " + data)
    });
  });
  
});
 
ipc.on('open-csv', (event, args) => {
  let setList = [];
  dialog.showOpenDialog({ properties: ['openFile'],
                          filters: [{ name: 'CSV dile',
                          extensions: ['csv'] }]
  }).then(result => {
    fs.createReadStream(result.filePaths[0])
      .pipe(csv())
      .on('data', (data) => setList.push(data))
      .on('end', () => {
        console.log(setList.length + " sets in list");
        event.sender.send("recover-setting", {key: "setlist", data: setList});
        storage.set('setList', setList, function(error) {
          console.log("good saving")
          if (error) throw error;
        });
        console.log("good here");
    });
    //console.log(result.canceled)
    console.log(result.filePaths[0])
  }).catch(err => {
    console.log(err)
  })
});

ipc.on('open-set', (event, args) => {
  var result = "";
  shell.openExternal('file://' + args); 
  event.sender.send('open-set-result',result); 
});

ipc.on('on-top', (event, args) => {
  win.setAlwaysOnTop(args);
});

function recoverSetting(key, win) {
  storage.has(key, function(error, hasKey) {
    if (error) throw error;
    if (hasKey) {
      storage.get(key, function(error, data) {
        if (error) throw error;
        if (typeof data !== undefined) {
          console.log("Stored " + key + ": " + data);
          win.webContents.send('recover-setting', {key: key, data: data});
        }
        else console.log(`No ${key} previously stored!`);
      });
    }
  });
}