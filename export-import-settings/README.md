# Export / Import Capture One Settings

**Donations**: if you like these scripts and want to support them [buy me a coffee](https://buymeacoffee.com/walterrowe).

This AppleScript creates two scripts in the Capture One scripts menu. The scripts back up and restore the transportable contents of these folders under ~/Library:

- Application Support/Capture One: tool presets, styles, keyboard maps, workspaces, export recipes, etc
- Scripts/Capture One Scripts: scripts listed under the Scripts menu inside Capture One

If you are viewing this in GitLab click the script name to see the source of the script. The press the download button at the top right of the script view panel. Double-click the downloaded script to open it in Script Editor, then run it. It creates two scripts in the Capture One Scripts folder. Placing them there lets you run them from the Scripts menu inside Capture One.

- settings-export creates CaptureOneSettings.zip from ~/Library/ in the folder you choose
- settings-import restores CaptureOneSettings.zip to ~/Library/ from the backup you choose

They DO NOT back up and restore application preferences as it includes non-transportable content. Sadly this also means they do not back up and restore naming templates, current tool tab configuration, navigation bar settings, and other items stored in application preferences.

## Notes

- System specific subfolders are skipped.
- Application Preferences is NOT backed up and restored - it contains non-transportable information.
- settings-import will display an error if it does not find CaptureOneSettings.zip on the Desktop.
- You must quit and restart Capture One after running settings-import for the application to see your restored tool presets, styles, keyboard maps, workspaces, export recipes, scripts, etc.

## Author

| Author | Updated | Description |
| --- | --- | --- |
| Walter Rowe | 2023-12-15 | Added ~/Library/Scripts/Capture One Scripts to backup and restore |
| Walter Rowe | 2023-12-13 | Backup and restore ~/Library/Application Support/Capture One |
