# Rebuild Kernels

**Donations**: if you like to keep these scripts free please consider [buying me a coffee](https://buymeacoffee.com/walterrowe).

## Description

At times Capture One can include artifacts in exports or present them on-screen when the hardware acceleration kernels are not current, or when there are many versions of them on disk.

This utility deletes all Capture One hardware acceleration kernels and ImageCore acceleration libraries it finds, then restarts Capture One which forces a rebuild for the version you are running.


## Prerequisites

None

## Installation

The script self-installs into your local Capture One Scripts folder on first run.

1. Open `Installer.applescript` (or `.scpt`) in macOS **Script Editor**.
2. Make sure that ScriptEditor shows "AppleScript" (**NOT JavaScript**).
    
    <img width=300px border=1 src="../assets/script-editor-applescript.png">

3. Click the **Run** button (&#9654;). The script will automatically download and compile the required `COscriptlibrary` library into `~/Library/Scripts/Capture One Scripts/`.
4. Open Capture One and navigate to **Scripts > Update Script Menu**.
5. You can now execute **Rebuild Kernels** directly from Capture One's **Scripts** menu.

## How To Use

After installation you run the utility from the Capture One Scripts folder. The utility will pop-up a dialog letting you know what it found and whether or not it needs to restart Capture One. If you don't press the OK button the pop-up dialog will automatically go away after 10 seconds and will restart Capture One if needed. There is no way to avoid restarting Capture One if it found kernels to be deleted and cannot run without a restart.

The utility uses Finder to delete the found kernel folders. This moves them to the Trash.

## Compatibility

The utility has been tested on:

- macOS Sequoia and Tahoe on Apple M3 and M4 hardware
- Capture One 16.6, 16.7

## ChangeLog

- 08 Oct 2025 - initial version
