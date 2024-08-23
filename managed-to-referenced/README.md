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

The script self-installs in your Capture One Scripts folder.

1. Open the AppleScript file in macOS Script Editor.
1. Click the "Run this script" (&#9654;) button.
1. Open Capture One and choose Scripts > Update Script Menu.
1. You now can run the script from the Capture One Scripts menu.

## Compatibility

The utility has been tested on:

- macOS Sonoma (Intel and M3 MacBook Pro)
- Capture One 16.4
- Moving to internal and external storage

## ChangeLog

- 13 Aug 2024 - enhanced installer and requirements checks
- 03 Aug 2024 - initial version