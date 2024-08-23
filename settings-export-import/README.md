# Export / Import Capture One Settings

**Donations**: if you like these scripts and want to support them [buy me a coffee](https://buymeacoffee.com/walterrowe).

## Description

This AppleScript creates two scripts in the Capture One scripts menu. The scripts back up and restore the transportable contents of these folders under ~/Library:

- Application Support/Capture One: tool presets, styles, keyboard maps, workspaces, export recipes, etc
- Scripts/Capture One Scripts: scripts listed under the Scripts menu inside Capture One

If you are viewing this in GitLab click the script name to see the source of the script. The press the download button at the top right of the script view panel. Double-click the downloaded script to open it in Script Editor, then run it. It creates two scripts in the Capture One Scripts folder. Placing them there lets you run them from the Scripts menu inside Capture One.

- settings-export backs up ~/Library/ folders to CaptureOneSettings.zip in the folder you choose
- settings-import restores ~/Library/ folders from the CaptureOneSettings.zip backup you choose

They DO NOT back up and restore application preferences as it includes non-transportable content. Sadly this also means they do not back up and restore naming templates, current tool tab configuration, navigation bar settings, and other items stored in application preferences.

## Prerequisites

None

## Installation

The script self-installs in your Capture One Scripts folder.

1. Open the AppleScript file in macOS Script Editor.
1. Click the "Run this script" (&#9654;) button.
1. Open Capture One and choose Scripts > Update Script Menu.
1. You now can run the script from the Capture One Scripts menu.

## Compatibility

The utility has been tested on:

- macOS Sonoma (Intel and M3 MacBook Pro)
- Capture One 16.4

## ChangeLog

- 21 Aug 2024 - converted to use COscriptlibrary handler library
- 13 Aug 2024 - enhanced installer and requirements checks
- 26 Jun 2024 - Updated this README.md
- 16 Dec 2023 - Added folder and file choosers
- 15 Dec 2023 - Include ~/Library/Scripts/Capture One Scripts to backup and restore
- 13 Dec 2023 - initial version backs up and restores ~/Library/Application Support/Capture One
