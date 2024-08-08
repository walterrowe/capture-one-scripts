# Clear Batch Queue

**Donations**: if you like these scripts and want to support them [buy me a coffee](https://buymeacoffee.com/walterrowe).

This AppleScript utility helps keep the batch queue and its corresponding folder clean.

- deletes all the jobs in the current batch job queue
- moves batch queue folders from prior versions to System Trash
- moves contents of the current batch queue folder to System Trash

**NOTE:** The batch history will not reflect being empty until Capture One is restarted.

When run from Capture One's Script menu this utility first displays the names, number of files, and size in MB of each batch queue folder found. It then asks the user for confirmation to continue or to exit.

- If the user continues, the above actions are taken.
- If the user chooses to exit, no action is taken.

The utility has been tested on:

- macOS Sonoma (Intel and M3 MacBook Pro)
- Capture One 16.4

# Installation

The script self-installs in your Capture One Scripts folder.

1. Open the AppleScript file in macOS Script Editor.
1. Click the "Run this script" (&#9654;) button.
1. Open Capture One and choose Script > Update Script Menu.
1. You now can run the script from the Capture One Scripts menu.


## Author

| Author | Updated | Description |
| --- | --- | --- |
| Walter Rowe | 2024-08-03 | Initial version written |
