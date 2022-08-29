# Ableton Live Set Switcher

You'll find two versions in this repository:
- macOS (Requires MacOs 12 / Monterey)
- Electron (WIP, eventually compatible con macOS and Windows)

This app will listen to MIDI Program Change (PC) messages coming in through the specified Port and MIDI channel and will open Ableton Live sets from a playlist, according to incoming PC values.

Create a CSV file with columns `pc,name,location`, where:
- `pc`: MIDI Program Change value
- `name`: Display name for the set
- `location`: location of the .als file

Then import it in the app.

Additional feature: big screen to read the name of the currently selected Live set from afar.

## How to deal with "Save?" or "Stop?" dialogs

When you have unsaved changes and you instruct Live to open a different set, it will show a dialog asking if you want to save the current one. Similarly, if your current set is playing, it will ask if you want to stop first. While these are great mechanisms to prevent you from disaster, they break the flow of a live situation, as you are forced to divert your attention to your computer screen and keyboard.

[Chapelier Fou](https://chapelierfou.bandcamp.com/), an amazing French musician, came up with an interesting solution. He created a Max For Live device that detects the "Save" dialog and choses the "Do not save" option automatically. I modified it to also detect the "Stop" dialog and automatically stop the set. It is in the Max4Live directory in this repo.

To use the device, drop it anywhere in your Live set (I usually drop it in the master bus so I can easily find it later). For a full performance without interruptions, you should import the device into _every set_ that you include in your playlist.

## I like this! How can I show appreciation / contribute?

- Give it a try, report issues or contact me with your comments
- Contribute to the repository
- Listen to my music: [Spacebarman on Bandcamp](https://spacebarman.bandcamp.com/)
- Also check [Chapelier Fou's music on Bandcamp!](https://chapelierfou.bandcamp.com/)

