# Label Untitled Variants

Author: Eric Nepean (@EricNepean)

This script sets the color label to blue (5) for every variant with an empty iptc title.

```applescript
tell application "Capture One" to tell (every variant whose content headline is "") to set color tag to 5
```

# Installation

Installation is simple:

1. Open the AppleScript file in macOS Script Editor and run it.
2. The script self-installs in the Capture One Scripts folder.
3. Open Capture One and choose Script > Update Script Menu.
4. You now can run the script from the Capture One Scripts menu.
