# Copy Labels to Finder

This AppleScript script copies color tags (labels) from Capture One variants to their corresponding files in macOS Finder.

If you select more than one variant of an image then only the last variant's color tag will be reflected in macOS Finder. Every variant of an image in Capture One represent the same file on disk.

The Capture One color tag PINK is mapped to the macOS Finder color tag GRAY.

| Color Tag Name | Capture One Color Tag Index | macOS Finder Color Tag Index |
| ---: | :--: | :--: |
| None | 0 | 0 |
| Red | 1 | 2 |
| Orange | 2 | 1 |
| Yellow | 3 | 3 |
| Green | 4 | 6 |
| Blue | 5 | 4 |
| Pink<br>(GRAY in Finder) | 6 | 7 |
| Purple | 7 | 5 |

## Run from Script Editor

Use these instructions to run the script directly in Script Editor.

1. Download the script to your system.
2. Open your Capture One session or catalog.
3. Select the images in Capture One you want to sync to Finder.
4. Open the script in Script Editor.
5. Press the grey "Run" button in Script Editor.

## Run from Scripts Menu in Capture One

Use these instructions to install the script in the Capture One scripts folder. This makes the script available in the Scripts menu in Capture One.

1. Download the script to your system.
2. Open the script in Script Editor.
3. In Script Editor choose File > Export.
4. Navigate to the folder Library/Script/Capture One.
5. Change the File Format field to Script.
6. Press the Save button.

Use these insructions to synchronize Capture One color tags to macOS Finder.

1. Open your Capture One session or catalog.
2. Select the images in Capture One you want to sync to Finder.
3. Choose "copy-labels-to-finder" from the Scripts menu.
