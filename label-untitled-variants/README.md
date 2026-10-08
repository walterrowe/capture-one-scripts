# Label Untitled Variants

Author: Eric Nepean (@EricNepean)

This script sets the color label to blue (5) for every variant with an empty iptc title.

```applescript
tell application "Capture One" to tell (every variant whose content headline is "") to set color tag to 5
```

## Installation

The script self-installs into your local Capture One Scripts folder on first run.

1. Open `Auto Keyword.applescript` (or `.scpt`) in macOS **Script Editor**.
2. Make sure that ScriptEditor shows "AppleScript" (**NOT JavaScript**).
3. Click the **Run** button (&#9654;). The script will automatically download and compile the required `COscriptlibrary` library into `~/Library/Scripts/Capture One Scripts/`.
4. Open Capture One and navigate to **Scripts > Update Script Menu**.
5. You can now execute **Label Untitled Variants** directly from Capture One's **Scripts** menu.

## UPDATEs

- 13 Aug 2024 - enhanced installer and requirements checks
