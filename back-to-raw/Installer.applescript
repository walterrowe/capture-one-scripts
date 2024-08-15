--
-- BACK-2-RAW
--
-- synchronize adjustments, labels, ratings, keywords, metadata
-- for selected images use chosen sources to find matching targets
--
-- user chooses source extension type, target extension types, what to sync
--
-- Requirements: exiftool
--
-- Author: Walter Rowe
-- Created: 08-Apr-2023
--

use AppleScript version "2.8"
use scripting additions

property appNames : {"Back To RAW"}
property appType : ".scpt"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property appIcon : false				-- true, false
property appTesting : false				-- true, false
property requiresCOrunning : true		-- true, false
property requiresCOdocument : true		-- true, false, "catalog", "session"

-- candidate source and target file name extensions
-- https://www.file-extensions.org/filetype/extension/name/digital-camera-raw-files
property rawExtensions : {"ARW", "ARF", "ARQ", "CR3", "CR2", "CRW", "DCR", "DNG", "FPX", "IIQ", "JPG", "JPEG", "MRW", "NEF", "ORF", "PEF", "PSD", "PTX", "RAF", "RAW", "RW2", "RWL", "SRF", "SR2", "TIFF"}

property syncableItems : {"Everything", "Adjustments", "Keywords", "Labels", "Metadata", "Ratings"}

on run

	-- do install if not running under app name
	set appBase to my name as string
	set pathToMe to path to me
	if appNames does not contain appBase and not appTesting then
		installMe(appBase, pathToMe, installFolder, appType, appNames, appIcon)
		return
	end if

	-- verify Capture One is running and has a document open
	if not meetsRequirements(appBase, requiresCOrunning, requiresCOdocument) then return

	-- get path to Capture One's app icon
	set coIcon to path to resource "AppIcon.icns" in bundle (path to application "Capture One")

	-- select source file format
	set sourceExts to choose from list rawExtensions with title "Choose a Source File Format"
	if sourceExts is false then
		display alert "Source Format" message "You must choose a source file format."
		return
	end if
	set targetExts to {}

	set srcExt to first item in sourceExts

	if srcExt is first item in rawExtensions then set targetExts to items 2 thru end of rawExtensions
	if srcExt is last item in rawExtensions then set targetExts to items 1 thru -2 of rawExtensions
	if (count of targetExts) is 0 then
		repeat with i from 1 to count of rawExtensions
			if srcExt is item i of rawExtensions then
				set targetExts to (items 1 thru (i - 1) of rawExtensions) & (items (i + 1) thru end of rawExtensions) as list
			end if
		end repeat
	end if

	set targetExts to choose from list targetExts with title "Choose One or More Target File Format(s)" with multiple selections allowed
	if targetExts is false then
		display alert "Target Format" message "You must choose at least one target file format."
		return
	end if

	set syncedItems to choose from list syncableItems with title "Choose What Items to Synchronize" with multiple selections allowed
	if syncedItems is false then
		display alert "Items to Synchronize" message "You must choose what items to synchronize."
		return
	end if

	set AppleScript's text item delimiters to ","
	set alertResults to (display alert "Confirmation" message "Synchronizing " & (syncedItems as string) & " (" & sourceExts & " to " & targetExts & ")" buttons {"Cancel", "Continue"} default button "Continue" cancel button "Cancel" giving up after 10)

	if (gave up of alertResults) or (button returned of alertResults is "Cancel") then return

	set AppleScript's text item delimiters to ""

	tell application "Capture One"
		-- initialize source and target lists
		set sourceVariants to {}
		set sourceDates to {}
		set targetVariants to {}
		set targetDates to {}
		set matchedVariants to {}
		set skippedVariants to {}

		-- get all selected variants
		set selectedVariants to variants where selected is true

		tell me to progress_start(0, "Processing ...", "scanning")

		-- divide selected variants into potential sources and targets
		repeat with thisVariant in selectedVariants
			set thisParent to thisVariant's parent image
			set thisFile to quoted form of POSIX path of (thisParent's file as alias)
			set thisName to thisParent's name as string
			set thisDate to do shell script "eval $(/usr/libexec/path_helper -s); exiftool -DateTimeOriginal " & thisFile & "|  cut -c35-"
			if thisDate is "" then
				set skippedVariants to skippedVariants & {thisVariant}
			else
				if thisVariant's parent image's extension is in sourceExts then
					set sourceVariants to sourceVariants & {thisVariant}
					set sourceDates to sourceDates & {thisDate}
				end if
				if thisVariant's parent image's extension is in targetExts then
					set targetVariants to targetVariants & {thisVariant}
					set targetDates to targetDates & {thisDate}
				end if
			end if
		end repeat

		-- synchronize adjustments and metadata for matching sources and targets
		set targetCount to length of targetVariants
		repeat with targetItem from 1 to targetCount
			tell me to progress_update(targetItem, targetCount, "")

			set targetDate to item targetItem of targetDates
			set targetVariant to item targetItem of targetVariants

			-- look for target date in source dates
			set sourceItem to my binarySearch(targetDate, sourceDates, 1, length of sourceDates)
			-- display dialog (sourceItem as string) buttons {"Cancel", "Continue"} with icon coIcon
			if sourceItem > 0 then
				set sourceVariant to item sourceItem of sourceVariants
				set matchedVariants to matchedVariants & {sourceVariant, targetVariant}
				-- display dialog sourceName & " => " & targetName buttons "Dismiss" with icon coIcon
				if syncedItems contains "Everything" or syncedItems contains "Adjustments" then
					set targetVariant's crop to sourceVariant's crop
					copy adjustments sourceVariant
					reset adjustments targetVariant
					apply adjustments targetVariant
				end if
				if syncedItems contains "Everything" or syncedItems contains "Keywords" then
					repeat with sourceKeyword in sourceVariant's keywords
						apply keyword sourceKeyword to {targetVariant}
					end repeat
				end if
				if syncedItems contains "Everything" or syncedItems contains "Labels" then
					set targetVariant's color tag to sourceVariant's color tag
				end if
				if syncedItems contains "Everything" or syncedItems contains "Ratings" then
					set targetVariant's rating to sourceVariant's rating
				end if
				if syncedItems contains "Everything" or syncedItems contains "Metadata" then
					set targetVariant's contact creator to sourceVariant's contact creator
					set targetVariant's contact creator job title to sourceVariant's contact creator job title
					set targetVariant's contact address to sourceVariant's contact address
					set targetVariant's contact city to sourceVariant's contact city
					set targetVariant's contact state to sourceVariant's contact state
					set targetVariant's contact postal code to sourceVariant's contact postal code
					set targetVariant's contact country to sourceVariant's contact country
					set targetVariant's contact phone to sourceVariant's contact phone
					set targetVariant's contact email to sourceVariant's contact email
					set targetVariant's contact website to sourceVariant's contact website
					set targetVariant's content headline to sourceVariant's content headline
					set targetVariant's content description to sourceVariant's content description
					set targetVariant's content category to sourceVariant's content category
					set targetVariant's content supplemental categories to sourceVariant's content supplemental categories
					set targetVariant's content subject codes to sourceVariant's content subject codes
					set targetVariant's content description writer to sourceVariant's content description writer
					set targetVariant's image intellectual genre to sourceVariant's image intellectual genre
					set targetVariant's image scenes to sourceVariant's image scenes
					set targetVariant's image location to sourceVariant's image location
					set targetVariant's image city to sourceVariant's image city
					set targetVariant's image state to sourceVariant's image state
					set targetVariant's image country to sourceVariant's image country
					set targetVariant's image country code to sourceVariant's image country code
					set targetVariant's status title to sourceVariant's status title
					set targetVariant's status job identifier to sourceVariant's status job identifier
					set targetVariant's status instructions to sourceVariant's status instructions
					set targetVariant's status provider to sourceVariant's status provider
					set targetVariant's status source to sourceVariant's status source
					set targetVariant's status copyright notice to sourceVariant's status copyright notice
					set targetVariant's status rights usage terms to sourceVariant's status rights usage terms
					set targetVariant's Getty personalities to sourceVariant's Getty personalities
					set targetVariant's Getty original filename to sourceVariant's Getty original filename
					set targetVariant's Getty parent MEID to sourceVariant's Getty parent MEID
				end if
			end if
			tell me to progress_step(targetItem)
		end repeat

		set statusMessage to ""

		if (count of skippedVariants) > 0 then
			set statusMessage to statusMessage & "Skipped " & (count of skippedVariants) & " variants.
See \"BACK-to-RAW Skipped Variants\" User Collection.

"
			tell current document
				if exists collection "BACK-to-RAW Skipped Variants" then
					set skippedCollection to collection "BACK-to-RAW Skipped Variants"
				else
					set skippedCollection to make new collection with properties {kind:album, name:"BACK-to-RAW Skipped Variants"}
				end if
				add inside skippedCollection variants skippedVariants
			end tell
		end if

		if (count of matchedVariants) > 0 then
			set statusMessage to statusMessage & "Synchronized " & ((count of matchedVariants) / 2 as integer) & " Variant Pairs.
See \"BACK-to-RAW Matched Variants\" User Collection.

"
			tell current document
				if exists collection "BACK-to-RAW Matched Variants" then
					set matchedCollection to collection "BACK-to-RAW Matched Variants"
				else
					set matchedCollection to make new collection with properties {kind:album, name:"BACK-to-RAW Matched Variants"}
				end if
				add inside matchedCollection variants matchedVariants
			end tell
		else
			set statusMessage to "No variants synchronized."
		end if
		tell me to progress_end()
		set alertResults to (display alert "Synchronization Complete" message statusMessage buttons {"OK"} giving up after 10)
	end tell
end run


on installMe(appBase, pathToMe, installFolder, appType, appNames, appIcon)

	## Copyright 2024 Walter Rowe, Maryland, USA		No Warranty
	## General purpose AppleScript Self-Installer
	##
	## Compiles and installs an AppleScript via osacompile as a type and list of names in a target folder
	##
	## Displays an error when it cannot install the script
	## Displays an alert when installation is successful

	repeat with appName in appNames
		set scriptSource to quoted form of POSIX path of pathToMe
		set scriptTarget to quoted form of (installFolder & appName & appType)
		set installCommand to "osacompile -x -o " & scriptTarget & " " & scriptSource
		-- execute the shell command to install script
		try
			do shell script installCommand
		on error errStr number errorNumber
			set alertResult to (display alert "Install Script Error" message errStr & ": " & (errorNumber as text) & "on file " & scriptSource buttons {"Stop"} default button "Stop" as critical giving up after 10)
		end try

		if appIcon is true then
			tell application "Finder" to set myFolder to (folder of (pathToMe)) as alias as string
			set iconSource to POSIX path of (myFolder & "droplet.icns")
			set iconTarget to scriptTarget & "/Contents/Resources/"
			set copyIcon to "/bin/cp " & (quoted form of iconSource) & " " & (quoted form of iconTarget)
			try
				do shell script copyIcon
			on error errStr number errorNumber
				set alertResult to (display alert "Install Icon Error" message errStr & ": " & (errorNumber as text) & "on file " & scriptSource buttons {"Stop"} default button "Stop" as critical giving up after 10)
			end try
		end if
	end repeat
	set alertResult to (display alert "Installation Complete" buttons {"OK"} default button "OK")

end installMe

on meetsRequirements(appBase, requiresCOrunning, requiresCOdocument)
	set requirementsMet to true

	set requiresDoc to false
	if class of requiresCOdocument is string then set requiresDoc to true
	if class of requiresCOdocument is boolean and requiresCOdocument then set requiresDoc to true

	if requiresCOrunning then

		tell application "Capture One" to set isRunning to running
		if not isRunning then
			display alert "Alert" message "Capture One must be running." buttons {"Quit"}
			set requirementsMet to false
		end if

		if requiresDoc and requirementsMet then
			tell application "Capture One" to set documentOpen to exists current document
			if not documentOpen then
				display alert appBase message "A Capture One Session or Catalog must be open." buttons {"Quit"}
				set requirementsMet to false
			end if

			if class of requiresCOdocument is string then
				tell application "Capture One"
					tell current document
						if kind is catalog then set docKind to "catalog"
						if kind is session then set docKind to "session"
					end tell
				end tell
				if docKind is not requiresCOdocument then
					display alert appBase message "You must be working in a Capture One " & requiresCOdocument & "." buttons {"Quit"}
					set requirementsMet to false
				end if
			end if
		end if
	end if

	return requirementsMet

end meetsRequirements

-- --------------------
-- FUNCTIONS
-- --------------------
-- The example above shows the raw method for implementing progress bars.
-- The functions below are convenience wrappers for the same code to keep
-- your overall code much cleaner and less repetitive.

-- Create the initial progress bar.
-- @param {int} 	 steps  			The number of steps for the process
-- @param {string} descript		The initial text for the progress bar
-- @param {string} descript_add 	Additional text for the progress bar
-- @returns void
on progress_start(steps, descript, descript_add)
	set progress total steps to steps
	set progress completed steps to 0
	set progress description to descript
	set progress additional description to descript_add
end progress_start

-- Update the progress bar. This goes inside your loop.
-- @param {int} 	 n  			The current step number in the iteration
-- @param {int} 	 steps  		The number of steps for the process
-- @param {string} message   The progress update message
-- @returns void
on progress_update(n, steps, message)
	set progress additional description to message & n & " of " & steps
end progress_update

-- Increment the step number of the progress bar.
-- @param {int} 	 n            The current step number in the iteration
-- @returns void
on progress_step(n)
	set progress completed steps to n
end progress_step

-- Clear the progress bar values
-- @returns void
on progress_end()
	-- Reset the progress information
	set progress total steps to 0
	set progress completed steps to 0
	set progress description to ""
	set progress additional description to ""
end progress_end


-- A binary search that always use the complete values list and call itself
-- recursively with different lower and upper indexes. It returns the index
-- of the found item or 0 if not found.
-- credit: https://gist.github.com/mk2/9949533

-- @param	aValue		The value to find
-- @param	values		The full values list to search
-- @param	iLower		The lower index (intially 1)
-- @param	iUpper		The upper index (initially count of values)
-- @returns	0 or index	Return 0 for not found, index when found

on binarySearch(aValue, values, iLower, iUpper)

	set valueIndex to 0

	-- if search list is narrowed down to only 1 item
	if (iUpper - iLower) ² 4 then
		repeat with midIndex from iLower to iUpper
			if aValue = (item midIndex of values) then
				set valueIndex to midIndex
			end if
		end repeat
		return valueIndex
	end if

	set midIndex to (iLower + ((iUpper - iLower) div 2))
	set midValue to item midIndex of values

	if midValue = aValue then
		return midIndex
	else if midValue > aValue then
		return my binarySearch(aValue, values, iLower, midIndex)
	else if midValue < aValue then
		return my binarySearch(aValue, values, (midIndex + 1), iUpper)
	end if

end binarySearch
