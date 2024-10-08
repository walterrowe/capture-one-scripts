# Clear Batch Queue

**Donations**: if you like to keep these scripts free please consider [buying me a coffee](https://buymeacoffee.com/walterrowe).

## Description

This AppleScript utility helps keep the batch queue and its corresponding folder clean.

- deletes all the jobs in the current batch job queue
- moves batch queue folders from prior versions to System Trash
- moves contents of the current batch queue folder to System Trash

When run from Capture One's Script menu this utility first displays the names, number of files, and size in MB of each batch queue folder found. It may take some time for this screen to appear because it examines every file in every batch queue folder to ensure it gets an accurate space consumed for each folder.

It then asks the user for confirmation to continue or to exit.

- If the user continues, the above actions are taken.
- If the user chooses to exit, no action is taken.

Some items to note:

- The batch history will not reflect being empty until Capture One is restarted.
- You may have to enable Extensions in System Settings.

## Prerequisites

None

# Installation

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

- 13 Aug 2024 - enhanced installer and requirements checks
- 08 Aug 2024 - initial version
