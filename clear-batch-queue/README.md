# Clear Batch Queue

**Donations**: if you like these scripts and want to support them [buy me a coffee](https://buymeacoffee.com/walterrowe).

This AppleScript utility deletes old batch queue folders and cleans out the current batch queue folder for Capture One on macOS.

When the script is run from Capture One's Script menu it displays the names of the batch queue folders found, number of files per folder, and size of each folder in MB. It then asks the user for confirmation to continue or to exit.

- If the user chooses to continue, older batch folders and contents of current batch folder are moved to System Trash
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
