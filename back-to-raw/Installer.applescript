(*
	AUTHOR

	Author: Walter Rowe
	Contact: walter@walterrowe.com

	Created: 08-Apr-2023
	Updated: 30-Aug-2024

	DESCRIPTION

	Synchronize adjustments, labels, ratings, keywords, metadata
	for selected images use chosen sources to find matching targets

	User chooses source file type, target file types, and what to sync

	PREREQUISITES
	
	* exiftool must be installed

*)

property version : "2.0"

use AppleScript version "2.8"
use scripting additions

property libraryFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property installNames : {"Back To RAW"}
property installType : ".scpt"
property installIcon : false -- true, false

property requiresCOrunning : true -- true, false
property requiresCOdocument : true -- true, false, "catalog", "session"

property appTesting : false -- true, false

-- application specific properties below

-- candidate source and target file name extensions
-- https://www.file-extensions.org/filetype/extension/name/digital-camera-raw-files
property rawExtensions : {"ARW", "ARF", "ARQ", "CR3", "CR2", "CRW", "DCR", "DNG", "FPX", "IIQ", "JPG", "JPEG", "MRW", "NEF", "ORF", "PEF", "PSD", "PTX", "RAF", "RAW", "RW2", "RWL", "SRF", "SR2", "TIFF"}

property syncableItems : {"Everything", "Adjustments", "Keywords", "Labels", "Metadata", "Ratings"}

-- application specific properties above

##
## use this to handle typical running from Capture One Scripts menu
##

on run
	
	-- set required base variables
	set appName to my name
	set appPath to path to me
	
	-- make sure the CO script library is loaded
	set myLibrary to loadLibrary(appName)
	if myLibrary is missing value then return
	
	-- do install if not running under app name
	if installNames does not contain appName and not appTesting then
		myLibrary's installMe(appName, appPath, installFolder, installType, installNames, installIcon)
		return
	end if
	
	-- verify Capture One is running and has a document open
	set readyToRun to myLibrary's meetsRequirements(appName, requiresCOrunning, requiresCOdocument)
	if not readyToRun then return
	
	-- get path to Capture One's app icon
	set coIcon to path to resource "AppIcon.icns" in bundle (path to application "Capture One")
	
	-- ensure we have permission to interact with other apps
	myLibrary's activateUIScripting()
	
	-- application code goes below here
	
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
		repeat with thisExt in rawExtensions
			if srcExt is not thisExt then
				set end of targetExts to thisExt
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
		set selectedVariants to get selected variants
		
		tell me to myLibrary's progress_start(0, "Processing ...", "scanning")
		
		-- divide selected variants into potential sources and targets
		repeat with thisVariant in selectedVariants
			set thisParent to thisVariant's parent image
			set thisFile to quoted form of POSIX path of (thisParent's file as alias)
			set thisName to thisParent's name as string
			set thisDate to do shell script "eval $(/usr/libexec/path_helper -s); exiftool -DateTimeOriginal " & thisFile & " |  cut -c35-"
			-- display dialog "Date: [" & thisDate & "]" & return & thisFile
			if thisDate is "" then
				set skippedVariants to skippedVariants & {thisVariant}
			else
				-- display dialog thisParent's name & return & thisParent's extension
				if thisParent's extension is in sourceExts then
					set end of sourceVariants to thisVariant
					set end of sourceDates to thisDate
				end if
				if thisParent's extension is in targetExts then
					set end of targetVariants to thisVariant
					set end of targetDates to thisDate
				end if
			end if
		end repeat
		
		-- display dialog "Sources (" & myLibrary's joinText(sourceExts, ",") & "): " & (count of sourceVariants) & return & "Targets (" & myLibrary's joinText(targetExts, ",") & "): " & (count of targetVariants)
		
		-- synchronize adjustments and metadata for matching sources and targets
		set targetCount to length of targetVariants
		repeat with targetItem from 1 to targetCount
			tell me to myLibrary's progress_update(targetItem, targetCount, "")
			
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
					copy adjustments sourceVariant
					reset adjustments targetVariant
					apply adjustments targetVariant
					-- these are not included in adjustments
					set targetVariant's crop to sourceVariant's crop
					-- set targetVariant's crop outside image to sourceVariant's crop outside image
					-- set targetVariant's styles to sourceVariant's styles
					-- set targetVariant's lens correction to sourceVariant's lens correction
					-- set targetVariant's LCC color cast to sourceVariant's LCC color cast
					-- set targetVariant's LCC dust removal to sourceVariant's LCC dust removal
					-- set targetVariant's LCC uniform light to sourceVariant's LCC uniform light
					-- set targetVariant's LCC uniform light amount to sourceVariant's LCC uniform light amount
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
			tell me to myLibrary's progress_step(targetItem)
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
		tell me to myLibrary's progress_end()
	end tell
	
	set alertTitle to appName & " Finished"
	set alertMessage to "Synchronization Complete" & return & return & statusMessage
	
	-- application code goes above here
	
	set alertResult to (display alert alertTitle message alertMessage buttons {"OK"} giving up after 10)
end run

##
## download and install the latest CO script library
##

on loadLibrary(appName as string)
	
	set myLibrary to libraryFolder & "COscriptlibrary.scpt"
	
	tell application "Finder"
		set libraryDownload to "curl -s -f https://raw.githubusercontent.com/walterrowe/capture-one-scripts/master/library/COscriptlibrary.applescript -o COscriptlibrary.applescript --output-dir " & libraryFolder
		set libraryCompile to "osacompile -x -o " & (quoted form of myLibrary) & " " & libraryFolder & "COscriptlibrary.applescript"
		try
			do shell script libraryDownload
			do shell script libraryCompile
		on error errorText
			-- failed to download and compile the latest library
			-- if we have a copy of the library installed then use it
			try
				exists (POSIX file myLibrary as alias)
			on error
				set myLibrary to POSIX path of myLibrary
				set alertResult to (display alert appName message "Unable to download and compile script library " & myLibrary & return & return & libraryDownload & return & return & libraryCompile & return & return & errorText buttons {"Quit"} giving up after 30)
				return missing value
			end try
		end try
	end tell
	
	try
		set myLibrary to load script myLibrary
		return myLibrary
	on error
		set myLibrary to POSIX path of myLibrary
		set alertResult to (display alert appName message "Unable to load script library " & myLibrary buttons {"Quit"} giving up after 30)
		return missing value
	end try
	
end loadLibrary

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
