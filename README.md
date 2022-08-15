# Ableton Live Set Switcher

You'll find two versions in this repository:
- macOS (Requires MacOs 12 / Monterey)
- Electron (WIP, eventually compatible con macOS and Windows)

This app will listen to MIDI Program Change (PC) messages coming in through the specified Port and MIDI channel and will open Ableton Live sets from a list, according to incoming PC values.

Create a CSV file with columns `pc,name,location`, where:
- `pc`: MIDI Program Change value
- `name`: Display name for the set
- `location`: location of the .als file

Then import it in the app.

Additional feature: big screen to read the name of the currently selected Live set from afar.

## Useful complement

Best if used in combination with this Max For Live device: https://maxforlive.com/library/device/4153/do-not-save
