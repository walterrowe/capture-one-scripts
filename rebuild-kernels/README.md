# Rebuild Kernels

**Donations**: if you like to keep these scripts free please consider [buying me a coffee](https://buymeacoffee.com/walterrowe).

## Description

At times Capture One can include artifacts in exports or present them on-screen when the hardware acceleration kernels are not current, or when there are many versions of them on disk.

This utility deletes all Capture One hardware acceleration kernels and ImageCore acceleration libraries it finds, then restarts Capture One which forces a rebuild for the version you are running.


## Prerequisites

None

## Installation

The script self-installs in your Capture One Scripts folder.

1. Open the AppleScript file in macOS Script Editor.
1. Click the "Run this script" (&#9654;) button.
1. Open Capture One and choose Scripts > Update Script Menu.
1. You now can run the script from the Capture One Scripts menu.

## How To Use

After installation you run the utility from the Capture One Scripts folder. The utility will pop-up a dialog letting you know what found and whether or not it needs to restart Capture One. If you don't press the OK button the pop-up dialog will automatically go away after 10 seconds and will restart Capture One if needed. There is no way to avoid restarting Capture One if it found kernels to be deleted and cannot run without a restart.

## Compatibility

The utility has been tested on:

- macOS Sequoia and Tahoe on Apple M3 and M4 hardware
- Capture One 16.6, 16.7

## ChangeLog

- 08 Oct 2025 - initial version
