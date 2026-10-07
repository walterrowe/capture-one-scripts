# Auto Keyword

**Donations**: if you like to keep these scripts free please consider [buying me a coffee](https://buymeacoffee.com/walterrowe).

## DISCLAIMER

This most valuable functionality of this script was written largely with assistance from Google
Gemini. It wrote the bits that call the Vision ML methods and processes the returned values.

## PRIVACY STATEMENT

* Your images NEVER leave your machine.
* Your images are not used to train Apple's models.

See https://www.apple.com/legal/ai-regulations/training-data/ on Apple's website.

## Description

This script uses Apple's Vision machine learning model to classify the content of selected images. The Vision model analyzes an image, returns keywords, and the script applies them.

- Each keyword returned has a confidence rating (in percent).
- Only keywords rating 20% or higher are applied.
- A maximum of 50 keywords per image are applied.
- Testing has shown there is usually under a dozen per image.
- The script applies known keywords first and only creates new keywords when necessary.
- The script prioritizes hierarchical keywords over top-level keywords.<br>
  **Example**: Baseball and Sport|Baseball both exist, only Sport|Baseball is applied.

Each image is analyzed and keywords are applied individually including multiple variants of the
same image.

## Prerequisites

macOS 15 (Sequoia) or later

## Installation

The script self-installs in your Capture One Scripts folder.

1. Open the AppleScript file in macOS Script Editor.
1. Click the "Run this script" (&#9654;) button.
1. Open Capture One and choose Scripts > Update Script Menu.
1. You now can run the script from the Capture One Scripts menu.

## How To Use

Select images in your Capture One session or catalog, open the Scripts menu, and select "Auto Keyword".

When the script is running there will be a gear icon in the macOS top right menu bar. Clicking that icon
will show progress by image count (e.g. "Keywording (3 of 30)").

## Compatibility

The utility has been tested on:

- macOS 26 (Tahoe)
- macOS 27 (Golden Gate)
- Capture One 16.8

## ChangeLog

- 06 Oct 2026 - initial version
