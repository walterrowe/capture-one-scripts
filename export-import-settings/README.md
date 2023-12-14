# Export / Import Capture One Settings

Created 13 December 2023 Walter Rowe walter.rowe@gmail.com

This AppleScript creates a ZIP backup or restores the contents of ~/Library/Application Support/Capture One.

This folder contains custom presets for adjustment tools, custom aspect ratios, export recipes, styles, print presets, workspaces, keyboard maps, search presets, smart adjustments, etc.

Open the script in Script Editor and run it to create two scripts in the Capture One Scripts folder. This will allow you to run them from the Capture One Scripts menu.

- settings-export will create CaptureOneSettings.zip on the Desktop from ~/Library/Application Support/Capture One
- settings-import will restore CaptureOneSettings.zip from the Desktop to ~/Library/Application Support/Capture One

There are some system specific subfolders that are skipped. If settings-import doesn't see CaptureOneSettings.zip on the Desktop will will display an error to that affect.