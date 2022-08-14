const { app, BrowserWindow, dialog } = require('electron');
const electron = require('electron');
const storage = require('electron-json-storage');
const ipc = require('electron').ipcMain;
const shell = require('electron').shell;
const nativeTheme = electron.nativeTheme;
const path = require('path');
const csv = require('csv-parser');
const fs = require('fs');
const setList = [];
const reset = false;

//shell.openExternal('file://' + "/Users/jp/Desktop/01 Project/01.als");

app.whenReady().then(() => {

  if(reset) {
    storage.clear(function(error) {
      if (error) throw error;
    });
  }

  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
      //preload: path.join(__dirname, 'renderer.js')
    }
  })

  win.loadFile('index.html')
  win.webContents.openDevTools()

  storage.has('setList', function(error, hasKey) {
    if (error) throw error;
    if (hasKey) {
      storage.get('setList', function(error, data) {
        if (error) throw error;
        if (typeof data !== undefined) {
          console.log("Previously: " + data.length);
          win.webContents.on('did-finish-load', function () {
            win.webContents.send('csv-data', data);
          });
        }
        else console.log("No list previously stored!");
      });
    }
  });

})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit()
})

ipc.on('ping', (event, args) => {
  //do something with args
  event.returnValue = 'Hi, sync reply';
  console.log(args)
 });
 
ipc.on('open-csv', (event, args) => {
  dialog.showOpenDialog({ properties: ['openFile'],
                          filters: [{ name: 'CSV dile',
                          extensions: ['csv'] }]
  }).then(result => {
    fs.createReadStream(result.filePaths[0])
    .pipe(csv())
    .on('data', (data) => setList.push(data))
    .on('end', () => {
      console.log(setList.length + " sets in list");
      event.sender.send('csv-data', setList);
      storage.set('setList', setList, function(error) {
        if (error) throw error;
      });

    });
    //console.log(result.canceled)
    //console.log(result.filePaths)
  }).catch(err => {
    console.log(err)
  })
});
