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

## Installation

The script self-installs into your local Capture One Scripts folder on first run.

1. Open `Auto Keyword.applescript` (or `.scpt`) in macOS **Script Editor**.
2. Make sure that ScriptEditor shows "AppleScript" (**NOT JavaScript**).
3. Click the **Run** button (&#9654;). The script will automatically download and compile the required `COscriptlibrary` library into `~/Library/Scripts/Capture One Scripts/`.
4. Open Capture One and navigate to **Scripts > Update Script Menu**.
5. You can now execute **Clear Batch Queue** directly from Capture One's **Scripts** menu.

## Compatibility

The utility has been tested on:

- macOS Sonoma (Intel and M3 MacBook Pro)
- Capture One 16.4

## ChangeLog

- 13 Aug 2024 - enhanced installer and requirements checks
- 08 Aug 2024 - initial version
