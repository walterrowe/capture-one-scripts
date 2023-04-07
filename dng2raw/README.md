# DNG2RAW

For the selected variants try to find matching pairs of DNG and camera native raw files. When matching pairs are found, copy all adjustments, metadata, keywords, ratings, labels from the DNG file back to the matching camera native raw file.

Requirements: exiftool

If this is saved as an AppleScript script file (.scpt) in `~/Library/Scripts/Capture One Scripts` then you can run it from the Capture One Scripts menu.

Capture One seems to use the CreateDate value for date in the metadata. Adobe DNG files may not have the DateTimeOriginal value in the CreateDate tag. This required using exiftool to get DateTimeOriginal value for comparison rather than using the Capture One date.

The genesis of this script was finding thousands of camera native raw files on old disks that had long ago been converted to Adobe DNG format.
