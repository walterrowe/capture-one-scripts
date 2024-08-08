# Clear Batch Queue

**Donations**: if you like these scripts and want to support them [buy me a coffee](https://buymeacoffee.com/walterrowe).

This AppleScript utility helps keep the batch queue and its corresponding folder clean.

- deletes all the jobs in the current batch job queue
- moves batch queue folders from prior versions to System Trash
- moves contents of the current batch queue folder to System Trash

When the script is run from Capture One's Script menu it displays the names of the batch queue folders found, number of files per folder, and size of each folder in MB. It then asks the user for confirmation to continue or to exit.

- If the user chooses to continue, older batch folders and contents of current batch folder are moved to System Trash, and the current batch queue is emptied. The batch history will not reflect being empty until Capture One is restarted.
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
