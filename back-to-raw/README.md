# BACK-to-RAW

For the selected variants try to find matching pairs of files. The user chooses the source file extension, one or more target file extensions, and what to sychronize. When matching pairs of source and target are found, copy one or more of adjustments, metadata, keywords, ratings, labels from the souce file to the matching target file(s).

Requirements: exiftool

If this is saved as an AppleScript script file (.scpt) in `~/Library/Scripts/Capture One Scripts` then you can run it from the Capture One Scripts menu.

Capture One seems to use the CreateDate value for date in the metadata. Adobe DNG files may not have the DateTimeOriginal value in the CreateDate tag. This required using exiftool to get DateTimeOriginal value for comparison rather than using the Capture One date.

The genesis of this script was finding thousands of camera native raw files on old disks that had long ago been converted to Adobe DNG format.
