# BACK-to-RAW

The purpose of this script is to synchronize all or a subset of adjustments, metadata, keywords, ratings, and labels from a chosen source file type to one or more chosen target file types. For example, a client could apply labels and star ratings to JPGs you provided as proofs. With this script you can synchronize these back to your original source raw files.

The genesis of this script was me finding thousands of camera native raw files on old disks that I had long ago been converted to Adobe DNG format. I wanted to migrate all of the adjustments, metadata, keywords, ratings, and labels from the Adobe DNG files back to their original camera native raw files recovered from the old disk drive. Manually pairing up DNG and RAW files, and manually syncing all of these attributes would be an overwhelming task. I would be much faster if I could select a batch of picture sets and let a script pair them up and perform this synchronization. It would take a fraction of the time.

# How To Use

Select a batch of pictures in Capture One and run the script. Choose the source file extension, one or more target file extensions, and what attributes you want to sychronize. The script will search for matching pairs of files between source and target extensions. When matching pairs are found, it will copy your chosen attributes from the source file to the matching target file(s).

# Requirements

You need to install `exiftool`. Capture One appears to use the EXIF CreateDate tag value for image date in its metadata. Adobe DNG files created from camera native raw files may have the the DNG file's create date stored in the CreateDate tag's value instead of the raw file's DateTimeOriginal tag value. Since Capture One provides no method of accessing DateTimeOriginal the script requires the use of `exiftool` to get this value. This value is how the script determines if two images are paired.

# Installation

Open the AppleScript file in Script Editor. Then use File > Export and save as an AppleScript Script file (.scpt) in `~/Library/Scripts/Capture One Scripts`. Open Capture One and choose Script > Update Script Menu. You then can run it from the Capture One Scripts menu.
