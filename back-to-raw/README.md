# BACK To RAW

**Donations**: if you like to keep these scripts free please consider [buying me a coffee](https://buymeacoffee.com/walterrowe).

## Description

The purpose of this script is to synchronize all or a subset of adjustments, metadata, keywords, ratings, and labels from a chosen source file type to one or more chosen target file types. For example, a client could apply labels and star ratings to JPGs you provided as proofs. With this script you can synchronize these back to your original source raw files.

The genesis of this script was me finding thousands of camera native raw files on old disks that I had long ago converted to Adobe DNG format. I wanted to migrate all of the adjustments, metadata, keywords, ratings, and labels from the Adobe DNG files back to their original camera native raw files recovered from the old disk drive. Manually pairing up DNG and RAW files, and manually syncing all of these attributes would be an overwhelming task. It would be much faster if I could select a batch of picture sets and let a script pair them up and perform this synchronization. It would take a fraction of the time and I could let it run while I do other tasks.

## Special Note

Capture One appears to use the EXIF CreateDate tag value for image date in its metadata. Adobe DNG files derived from camera native raw files via Adobe DNG Converter or Adobe Photoshop Lightroom® may have the DNG file's create date stored in the CreateDate tag's value instead of the original camera native raw file's DateTimeOriginal value. Since Capture One provides no method of accessing DateTimeOriginal value the AppKit framework is used to get the value. The value is used to match source and target images by date/time/fraction of a second. Selected files that do not have the DateTimeOriginal metadata will be excluded from the process.

The date/time comparison used by this utility attempts to be accurate down to the fraction of a second ("YYYY:MM:DD HH:MM:SS.hh" where "hh" is hundredths of a second). Some image files may not include the ` Sub Sec Time Original ` tag. In that instance only the "YYYY:MM:DD HH:MM:SS" will be used to match source and target images. When no sub second data is available only the first of multiple target images with the same "YYYY:MM:DD HH:MM:SS" date/time stamp will be matched to a given source image.

## Prerequisites

This utility previously required ` exiftool ` to extract the DateTimeOriginal EXIF tag. Credit to [Shane Stanley on macscripter.net](https://www.macscripter.net/t/getting-exif-metadata-from-image-files/69297/6) for providing a native AppleScript method via the AppKit framework.

## Installation

The script self-installs in your Capture One Scripts folder.

1. Open the AppleScript file in macOS Script Editor.
1. Click the "Run this script" (&#9654;) button.
1. Open Capture One and choose Scripts > Update Script Menu.
1. You now can run the script from the Capture One Scripts menu.

## How To Use

Select a batch of pictures in Capture One and run the script. Choose the source file extension, choose one or more target file extensions, and choose what attributes you want to sychronize. After confirming your choices, the script will search the selection for matching pairs of files between source and target extensions. When matching pairs are found, it will copy your chosen attributes from the source file to the matching target file(s).

- Do not include 'Crop' when source and targets differ in dimensions or you get undesirable crops on the targets.
- Matched pairs of files will be added to a User Collection called "BACK-to-RAW Matched Variants".
- Skipped files will be added to a User Collection called "BACK-to-RAW Skipped Variants".

When the run is complete a status message will pop up showing how many variants were skipped and how many pairs were synchronized.

## Compatibility

The utility has been tested on:

- macOS Sonoma (Intel and M3 MacBook Pro)
- Capture One 16.4

## ChangeLog

- 13 Aug 2024 - enhanced installer and requirements checks
