# Synchronize Layers

**Donations**: if you like to keep these scripts free please consider [buying me a coffee](https://buymeacoffee.com/walterrowe).

## Description

This utility provides two operations. It lets you sync adjustments between two layers across selected variants, or sync a single layer across selected variants.


- Sync Between Layers: Syncs adjustments between two layers of the same variant for a selection of variants. This simplifies syncing adjustments from existing adjustment layers to new dynamic masking layers. You can choose to disable the source layer after adjustments are copied. If a variant does not have either the source or target layer that variant is skipped.
- Sync Layer Across Images: Syncs adjustments of the selected layer of the primary variant to a layer with the same name across selected target variants. You choose which layer to sync. If a target variant doesn't have that layer the target variant is skipped.

If some target variants don't have a named layer they will be skipped. Each utility presents a results dialog showing synced and skipped counts.

## Prerequisites

Each layer of a variant must have a unique name. The name is used to uniquely identify source and target layers on each variant.

## Installation

The script self-installs in your Capture One Scripts folder.

1. Open the AppleScript file in macOS Script Editor.
1. Click the "Run this script" (&#9654;) button.
1. Open Capture One and choose Scripts > Update Script Menu.
1. You now can run the script from the Capture One Scripts menu.

## How To Use

Select variants in Capture One, then run the "Delete Selected Layers" from the Capture One Scripts menu.

## Compatibility

The utility has been tested on:

- macOS Sonoma (Intel and M3 MacBook Pro)
- Capture One 16.5

## ChangeLog

- 25 Oct 2024 - initial version
