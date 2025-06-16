# Find Variants In Common

This utility compares all the variants of two catalogs to determine which variants appear in both catalogs.

**Donations**: if you like to keep these scripts free please consider [buying me a coffee](https://buymeacoffee.com/walterrowe).

## Description

With two catalogs open this utility compares all the variants between the two. It can be useful for updating information between catalogs or for removing duplicates across catalogs.

When it finds common variants it adds them to one of two special user collections in BOTH catalogs:

In CATALOG A:

- Variant Files in Common with {CATALOG B}
- Variant Names in Common with {CATALOG B}

In CATALOG B:

- Variant Files in Common with {CATALOG A}
- Variant Names in Common with {CATALOG A}

If there are any variants in any of these collections that have adjustments applied to them, then the Adjusted filter is enabled for the collection to only show those what have adjustments. If there are no adjusted variants, then the Adjusted filter is disabled so that all variants are displayed.

The variants are compared by full path + filename. If that does not match, it then looks at name only in case you have two copies of the same file in different locations. It **does not** compare EXIF data such as capture time.

## Prerequisites

## Installation

The script self-installs in your Capture One Scripts folder.

1. Open the AppleScript file in macOS Script Editor.
1. Click the "Run this script" (&#9654;) button.
1. Open Capture One and choose Scripts > Update Script Menu.
1. You now can run the script from the Capture One Scripts menu.

## How To Use

1. Open two catalogs that might have images in common.
2. Select "Find Variants In Common" from the Capture One Scripts menu.

## Compatibility

The utility has been tested on:

- macOS 15 Sequoia
- Capture One 16.6

## ChangeLog

- 16 Jun 2025 - initial version
