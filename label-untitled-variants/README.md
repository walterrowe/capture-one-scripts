# Label Untitled Variants

Author: Eric Nepean (@EricNepean)

This script sets the color label to blue (5) for every variant with an empty iptc title.

```applescript
tell application "Capture One" to tell (every variant whose content headline is "") to set color tag to 5
```

# Installation

The script self-installs in your Capture One Scripts folder.

1. Open the AppleScript file in macOS Script Editor.
1. Click the "Run this script" (&#9654;) button.
1. Open Capture One and choose Scripts > Update Script Menu.
1. You now can run the script from the Capture One Scripts menu.

## UPDATEs

- 13 Aug 2024 - enhanced installer and requirements checks
