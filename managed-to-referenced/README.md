# Managed to Referenced

**Donations**: if you like to keep these scripts free please consider [buying me a coffee](https://buymeacoffee.com/walterrowe).

## Description

This AppleScript utility moves image files from inside a managed Capture One catalog to a referenced location outside the catalog. The files are moved into folders based on the image EXIF date. The utility does not use the date folders from the managed folders inside the catalog because the managed folder dates are based on import date.

- Select the images to move from your Capture One catalog.
- Choose the top level folder where the files will be moved.
- The utility creates YYYY/MM/DD subfolders based on the EXIF date of the files moved.

## Prerequisites

None

## Installation

The script self-installs into your local Capture One Scripts folder on first run.

1. Open `Installer.applescript` (or `.scpt`) in macOS **Script Editor**.
2. Make sure that ScriptEditor shows "AppleScript" (**NOT JavaScript**).
    
    <img width=300px border=1 src="../assets/script-editor-applescript.png">

3. Click the **Run** button (&#9654;). The script will automatically download and compile the required `COscriptlibrary` library into `~/Library/Scripts/Capture One Scripts/`.
4. Open Capture One and navigate to **Scripts > Update Script Menu**.
5. You can now execute **Move Managed To Referenced** directly from Capture One's **Scripts** menu.

## Compatibility

The utility has been tested on:

- macOS Sonoma (Intel and M3 MacBook Pro)
- Capture One 16.4
- Moving to internal and external storage

## ChangeLog

- 13 Aug 2024 - enhanced installer and requirements checks
- 03 Aug 2024 - initial version