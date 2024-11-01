(*
	AUTHOR

	Author: Walter Rowe
	Contact: walter@walterrowe.com

	Created: 08-Apr-2023
	Updated: 25-Oct-2024

	DESCRIPTION

	Synchronize names, adjustments, labels, ratings, keywords, metadata
	for selected images use chosen sources to find matching targets.
	
	When name syncing is chosen, the source file will have "-synced"
	appended to its base name to avoid name collisions that result in
	target files having numbers added (e.g. "name 1", "name 2").

	User chooses source file type, target file types, and what to sync

	PREREQUISITES
	
	None

*)

property version : "3.1"

use AppleScript version "2.8"
use scripting additions
use framework "Foundation"
use framework "AppKit" -- for extracting EXIF from the image files

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

property syncableItems : {"Everything", "Name", "Adjustments", "Crop", "Keywords", "Labels", "Metadata", "Ratings"}

property collectionMatched : "BACK-to-RAW Matched Variants"
property collectionUnmatched : "BACK-to-RAW Unmatched Variants"
property collectionSkipped : "BACK-to-RAW Skipped Variants"

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
	
	-- if app testing and we have multiple install names choose what action to perform
	if appTesting is true then
		if (count of installNames) > 1 then
			set appName to choose from list installNames with prompt "Choose Target Layer To Sync"
			if appName is false then return
			set appName to first item of appName
		else
			set appName to item 1 of installNames
		end if
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
	
	-- filter source extensions out of target extension choices
	set targetExts to {}
	set srcExt to first item in sourceExts
	
	if srcExt is first item in rawExtensions then set targetExts to items 2 thru end of rawExtensions
	if srcExt is last item in rawExtensions then set targetExts to items 1 thru -2 of rawExtensions
	if targetExts is {} then
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
	
	display alert appName message "On the next dialog you will choose what to sychronize." & return & return & "If your source and target files are different sizes (dimensions) DO NOT select 'Everything' or 'Crop'." & return & return & "Including 'Crop' when syncing files of different sizes produces undesirable crops on the target images."
	
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
		set matchedCount to 0
		set skippedVariants to {}
		set skippedCount to 0
		set unmatchedVariants to {}
		set unmatchedCount to 0
		
		-- get all selected variants
		set selectedVariants to get selected variants
		
		tell me to myLibrary's progress_start(0, "Processing ...", "scanning")
		
		-- divide selected variants into potential sources and targets
		set startTime to current date
		repeat with thisVariant in selectedVariants
			set thisParent to thisVariant's parent image
			set thisFile to quoted form of POSIX path of (thisParent's file as alias)
			set thisFile to POSIX path of (thisParent's file as alias)
			set thisName to thisParent's name as string
			
			set thisExifData to my readEXIFFromImage(thisFile)
			set exifTags to my getExifTags(thisExifData)
			
			-- if DateTimeOriginal tag exists use it
			if exifTags contains "DateTimeOriginal" then
				set thisDate to (|DateTimeOriginal| of thisExifData)
				-- if SubsecTimeOriginal tag exists append it for more accuracy
				if exifTags contains "SubsecTimeOriginal" then
					(*
					if length of (|SubsecTimeOriginal| of thisExifData) > 1 then
						set thisDate to thisDate & "." & (|SubsecTimeOriginal| of thisExifData)
					else
						set thisDate to thisDate & ".0" & (|SubsecTimeOriginal| of thisExifData)
					end if
					*)
					set thisDate to thisDate & "." & (|SubsecTimeOriginal| of thisExifData)
				end if
				-- display dialog thisName & return & thisDate
				if thisParent's extension is in sourceExts then
					set end of sourceVariants to thisVariant
					set end of sourceDates to thisDate
				end if
				if thisParent's extension is in targetExts then
					set end of targetVariants to thisVariant
					set end of targetDates to thisDate
				end if
			else
				set end of skippedVariants to thisVariant
				set skippedCount to skippedCount + 1
			end if
		end repeat
		
		-- display dialog "Sources: " & (count of sourceVariants) & return & "Targets: " & (count of targetVariants) & return & "Skipped: " & (count of skippedVariants)
		
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
				set end of matchedVariants to sourceVariant
				set end of matchedVariants to targetVariant
				set matchedCount to matchedCount + 1
				
				-- display dialog sourceName & " => " & targetName buttons "Dismiss" with icon coIcon
				
				if syncedItems contains "Everything" or syncedItems contains "Name" then
					set sourceImage to parent image of sourceVariant
					set targetImage to parent image of targetVariant
					-- if the name was already synced don't do it again
					set theName to name of sourceImage
					if theName does not contain "-synced" then
						-- add "-synced" to source image name to avoid collisions that result in numeric suffixes (e.g. "name 1")
						set name of sourceImage to (theName & "-synced")
						set name of targetImage to theName
					end if
				end if
				
				if syncedItems contains "Everything" or syncedItems contains "Adjustments" then
					
					-- sync adjustments
					copy adjustments sourceVariant
					reset adjustments targetVariant
					apply adjustments targetVariant
					
					-- sync styles applied to background layer
					set sourceVariantstyles to styles of sourceVariant
					if (length of sourceVariantstyles) > 0 then
						repeat with theStyle in sourceVariantstyles
							-- display dialog "Applying style " & theStyle
							tell targetVariant to apply style first layer named theStyle
						end repeat
					end if
					
					-- sync LCC settings
					(*
					-- this code fails so comment it out for now
					if applied LCC name of sourceVariant is not missing value then
						apply LCC sourceVariant to targetVariant
						set LCC color cast of targetVariant to LCC color cast of sourceVariant
						set LCC dust removal of targetVariant to LCC dust removal of sourceVariant
						set LCC uniform light of targetVariant to LCC uniform light of sourceVariant
						set LCC uniform light amount of targetVariant to LCC uniform light amount of sourceVariant
					end if
					*)
					
					-- sync lens correction settings (raw files only -- need an 'if' clause here)
					(*
					set lens profile of lens correction of targetVariant to lens profile of lens correction of sourceVariant
					set chromatic aberration of lens correction of targetVariant to chromatic aberration of lens correction of sourceVariant
					set custom chromatic aberration of lens correction of targetVariant to custom chromatic aberration of lens correction of sourceVariant
					set diffraction correction of lens correction of targetVariant to diffraction correction of lens correction of sourceVariant
					set hide distorted areas of lens correction of targetVariant to hide distorted areas of lens correction of sourceVariant
					set distortion of lens correction of targetVariant to distortion of lens correction of sourceVariant
					set sharpness falloff of lens correction of targetVariant to sharpness falloff of lens correction of sourceVariant
					set light falloff of lens correction of targetVariant to light falloff of lens correction of sourceVariant
					set focal length of lens correction of targetVariant to focal length of lens correction of sourceVariant
					set aperture of lens correction of targetVariant to aperture of lens correction of sourceVariant
					set tilt of lens correction of targetVariant to tilt of lens correction of sourceVariant
					set tilt direction of lens correction of targetVariant to tilt direction of lens correction of sourceVariant
					set shift of lens correction of targetVariant to shift of lens correction of sourceVariant
					set shift direction of lens correction of targetVariant to shift direction of lens correction of sourceVariant
					set shift x of lens correction of targetVariant to shift x of lens correction of sourceVariant
					set shift y of lens correction of targetVariant to shift y of lens correction of sourceVariant
					*)
				end if
				
				if syncedItems contains "Everything" or syncedItems contains "Crop" then
					set targetVariant's crop to sourceVariant's crop
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
			else
				set end of unmatchedVariants to targetVariant
				set unmatchedCount to unmatchedCount + 1
			end if
			tell me to myLibrary's progress_step(targetItem)
		end repeat
		
		set endTime to current date
		
		set statusMessage to "Started: " & startTime & return & "Ended: " & endTime & return & return
		
		if (count of skippedVariants) > 0 then
			set statusMessage to statusMessage & "Skipped " & skippedCount & " variants." & return & "See " & collectionSkipped & " User Collection." & return
			tell current document
				try
					set skippedCollection to collection collectionSkipped
				on error
					set skippedCollection to make new collection with properties {kind:album, name:collectionSkipped}
				end try
				add inside skippedCollection variants skippedVariants
			end tell
		else
			set statusMessage to statusMessage & "No variants skipped." & return
		end if
		
		if (count of matchedVariants) > 0 then
			set statusMessage to statusMessage & "Synchronized " & (matchedCount) & " Variant Pairs." & return & "See " & collectionMatched & " User Collection." & return
			tell current document
				try
					set matchedCollection to collection collectionMatched
				on error
					set matchedCollection to make new collection with properties {kind:album, name:collectionMatched}
				end try
				add inside matchedCollection variants matchedVariants
			end tell
		else
			set statusMessage to statusMessage & "No variants synchronized." & return
		end if
		
		if (count of unmatchedVariants) > 0 then
			set statusMessage to statusMessage & "Umatched " & unmatchedCount & " Variants." & return & "See " & collectionUnmatched & " User Collection." & return
			tell current document
				try
					set unmatchedCollection to collection collectionUnmatched
				on error
					set unmatchedCollection to make new collection with properties {kind:album, name:collectionUnmatched}
				end try
				add inside unmatchedCollection variants unmatchedVariants
			end tell
		else
			set statusMessage to statusMessage & "No variants unmatched." & return
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

## return names of EXIF tags extracted from image file

on getExifTags(exifData)
	set thisExifDict to (current application's NSDictionary's dictionaryWithDictionary:exifData)
	set exifTags to thisExifDict's allKeys() as list
	return exifTags
end getExifTags

## use AppKit framework to extract exifdata from image file
## credit to "Shane_Stanley" on macscripter.net for this code
## https://www.macscripter.net/t/getting-exif-metadata-from-image-files/69297/7

on readEXIFFromImage(POSIXPath as string)
	set theImageRep to current application's NSBitmapImageRep's imageRepWithContentsOfFile:POSIXPath
	set theExifData to theImageRep's valueForProperty:(current application's NSImageEXIFData)
	try
		set theExifs to theExifData as record
	on error
		# Here if theExifDatas is missing value.
		set theExifs to {}
	end try
	return theExifs as record
end readEXIFFromImage

##
## perform recursive binary search on list for value
##

on binarySearchx(aValue, values, iLower, iUpper)
	
	set valueIndex to 0
	
	-- if search list is narrowed down to 10 items just brute force search
	if (iUpper - iLower) ² 4 then
		repeat with midIndex from iLower to iUpper
			set midValue to item midIndex of values
			if (aValue starts with midValue) or (midValue starts with aValue) then
				set valueIndex to midIndex
			end if
		end repeat
		return valueIndex
	end if
	
	set midIndex to (iLower + ((iUpper - iLower) div 2))
	set midValue to item midIndex of values
	
	if (midValue starts with aValue) or (aValue starts with midValue) then
		return midIndex
	else if midValue > aValue then
		return my binarySearch(aValue, values, iLower, midIndex)
	else if midValue < aValue then
		return my binarySearch(aValue, values, (midIndex + 1), iUpper)
	end if
	
end binarySearchx


on binarySearch(aValue, itemValues, iLower, iUpper)
	
	set valueIndex to 0
	set totalItems to count of itemValues
	
	repeat with itemIndex from 1 to totalItems
		set itemValue to item itemIndex of itemValues
		if (aValue starts with itemValue) or (itemValue starts with aValue) then
			return valueIndex
		end if
	end repeat
	
	return valueIndex
	
end binarySearch
