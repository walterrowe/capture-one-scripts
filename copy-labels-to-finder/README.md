# Copy Labels to Finder

**Donations**: if you like to keep these scripts free please consider [buying me a coffee](https://buymeacoffee.com/walterrowe).

## Description

This AppleScript script copies color tags (labels) from Capture One variants to their corresponding files in macOS Finder.

If you select more than one variant of an image then only the last variant's color tag will be reflected in macOS Finder. Every variant of an image in Capture One refers to the same image file on disk.

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

## Prerequisites

None

## Installation

The script self-installs into your local Capture One Scripts folder on first run.

1. Open `Auto Keyword.applescript` (or `.scpt`) in macOS **Script Editor**.
2. Make sure that ScriptEditor shows "AppleScript" (**NOT JavaScript**).
3. Click the **Run** button (&#9654;). The script will automatically download and compile the required `COscriptlibrary` library into `~/Library/Scripts/Capture One Scripts/`.
4. Open Capture One and navigate to **Scripts > Update Script Menu**.
5. You can now execute **Copy Labels To Finder** directly from Capture One's **Scripts** menu.

## How To Use

1. Open your Capture One session or catalog.
2. Select the images in Capture One you want to sync to Finder.
3. Choose "Copy Labels To Finder" from the Scripts menu.

## Compatibility

The utility has been tested on:

- macOS Sonoma (Intel and M3 MacBook Pro)
- Capture One 16.4

## ChangeLog

- 13 Aug 2024 - enhanced installer and requirements checks
