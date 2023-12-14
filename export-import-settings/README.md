# Export / Import Capture One Settings

Created 13 December 2023 Walter Rowe walter.rowe@gmail.com

This AppleScript creates two scripts in the Capture One scripts menu. The scripts back up and restore the transportable contents of the folder ~/Library/Application Support/Capture One.

This folder contains custom presets for adjustment tools, custom aspect ratios, export recipes, styles, print presets, workspaces, keyboard maps, search presets, smart adjustments, etc.

Download and open the script in Script Editor and run it. It create two scripts in the Capture One Scripts folder. This lets you run them from the Scripts menu inside Capture One.

- settings-export will create CaptureOneSettings.zip on the Desktop from ~/Library/Application Support/Capture One
- settings-import will restore CaptureOneSettings.zip from the Desktop to ~/Library/Application Support/Capture One

There are some system specific subfolders that are skipped. If settings-import doesn't see CaptureOneSettings.zip on the Desktop will will display an error to that affect.