# App Name

**Donations**: if you like to keep these scripts free please consider [buying me a coffee](https://buymeacoffee.com/walterrowe).

## Description

This utility lets you delete selected layers from multiple variants. It creates a list of layer names from the selected variants, presents the list, and you choose one or more layers to delete. It doesn't matter if some variants don't have a selected layer. This is the code from the script. It is pretty straight forward.

- Collect layer names from selected variants
- Sort the list of layer names alphabetically
- Select the names of the layers to delete
- Delete the chosen layers from selected variants


```applescript
	tell application "Capture One"
		set layerNames to {}
		set theVariants to selected variants

		-- collect names of layers from all selected variants
		repeat with theVariant in theVariants
			repeat with theLayer in every layer of theVariant
				if layerNames does not contain name of theLayer then
					set end of layerNames to name of theLayer
				end if
			end repeat
		end repeat

		-- sort layer names
		set layerNames to myLibrary's sortList(layerNames)

		-- choose names of layers to delete
		set layerNamesToDelete to choose from list layerNames with prompt "Choose One Or More Layer To Delete" with multiple selections allowed

		-- delete chosen layers from all selected variants
		if layerNamesToDelete is not false then
			repeat with theVariant in theVariants
				repeat with theLayerName in layerNamesToDelete
					delete (every layer of theVariant where name is theLayerName)
				end repeat
			end repeat
		end if
	end tell
```

## Prerequisites

None

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
