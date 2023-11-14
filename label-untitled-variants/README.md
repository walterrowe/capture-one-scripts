# Label Untitled Variants

Author: Eric NePean (@ericnepean)

This script sets the color label to blue (5) for every variant with an empty iptc title.

```applescript
tell application "Capture One" to tell (every variant whose content headline is "") to set color tag to 5
```
