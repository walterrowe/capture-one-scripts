(*
	AUTHOR

	Author: Walter Rowe
	Contact: walter@walterrowe.com

	Copyright: © 2025 Walter Rowe

	Created: 16 June 2025
	Updated: 16 June 2025

	1. Set installNames
	2. Develop code
	3. Provide app icon (optional, set installIcon to true)
	4. Test code in Script Editor
	5. Change appTesting to false
	6. Test code in Capture One

	DESCRIPTION
	
	This utility will find the common variants in two Capture One catalogs.
	The common variants in each catalog will be placed in a new album.

	The new album will have the "Adjusted|YES" filter enabled to show
	which of the common variants in each catalog have adjustments. This
	will aid the user in determining in which catalog it is safest to remove
	a variant to eliminate a conflict between the catalogs before merging.

	PREREQUISITES

	None
*)

property version : "1.0"

use AppleScript version "2.8"
use scripting additions

property libraryFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property installNames : {"Find Variants in Common"}
property installType : ".scpt" -- ".scpt" for script, ".app" for script app
property installIcon : false -- if true must have a droplet.icns icon file in the source folder and ".app" installType

property requiresCOrunning : true -- true if capture one is required to be running
property requiresCOdocument : true -- true, false, "catalog", "session"

property appTesting : false -- if true, run in script editor, and if false install the script

-- application specific properties below

property albumFilesPrefix : "Variant Files in Common with "
property albumNamesPrefix : "Variant Names in Common with "
property adjustedFilterYes : "Adjusted|YES"
property adjustedFilterNo : "Adjusted|NO"

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
	
	tell application "Capture One"
		set docKind to myLibrary's getCOtype(current document)
		tell current document to set docName to name
		tell current document to set docPath to POSIX path of (path as alias) as string
		
		-- get document list and kind of documents
		set documentList to (get every document)
		set documentKinds to (kind of every document)
		
		-- we can only compare two documents
		if (count of documentList) is not 2 then
			set alertMessage to "You must have exactly two catalogs open."
			
			set alertTitle to appName & " ERROR"
			
			set alertResult to (display alert alertTitle message alertMessage buttons {"OK"} giving up after 10)
			return
		end if
		
		-- album name that will contain common variants
		set c1FilesAlbum to albumFilesPrefix & name of document 2
		set c1NamesAlbum to albumNamesPrefix & name of document 2
		set c2FilesAlbum to albumFilesPrefix & name of document 1
		set c2NamesAlbum to albumNamesPrefix & name of document 1
		
		-- get all the variants in both catalogs and prep catalogs for comparison
		tell document 1
			set c1current to current collection
			set current collection to collection named "All Images"
			set variants1 to (get every variant)
			-- delete any prior instance of collections of common variants
			repeat with theAlbum in {c1FilesAlbum, c1NamesAlbum}
				if exists collection named theAlbum then
					delete collection named theAlbum
					repeat until not (exists collection named theAlbum)
						delay 0.2
					end repeat
				end if
			end repeat
		end tell
		
		tell document 2
			set c1current to current collection
			set current collection to collection named "All Images"
			set variants2 to (get every variant)
			-- delete any prior instance of collections of common variants
			repeat with theAlbum in {c2FilesAlbum, c2NamesAlbum}
				if exists collection named theAlbum then
					delete collection named theAlbum
					repeat until not (exists collection named theAlbum)
						delay 0.2
					end repeat
				end if
			end repeat
		end tell
		
		-- list of variants in common
		set c1FileVariants to {}
		set c1NameVariants to {}
		set c2FileVariants to {}
		set c2NameVariants to {}
		
		-- brute force find all variants common between catalogs
		repeat with v1 in variants1
			repeat with v2 in variants2
				if (file of v1) is (file of v2) then
					set end of c1FileVariants to v1
					set end of c2FileVariants to v2
				else if (name of v1) is (name of v2) then
					set end of c1NameVariants to v1
					set end of c2NameVariants to v2
				end if
			end repeat
		end repeat
		
		-- create common variants album in catalog 1
		repeat with theValues in {{c1FileVariants, c1FilesAlbum}, {c1NameVariants, c1NamesAlbum}}
			set theVariants to first item of theValues
			set albumName to last item of theValues
			if (count of theVariants) > 0 then
				set current document to document 1
				select document 1
				tell document 1
					
					-- create common variants album
					if exists collection named albumName then
						set theAlbum to collection named albumName
					else
						set theAlbum to make new collection with properties {kind:album, name:albumName}
					end if
					
					-- wait for common variants album to be created
					repeat until exists collection named albumName
						delay 0.2
					end repeat
					
					-- add common variants to album
					add inside theAlbum variants theVariants
					
					-- select common variants album
					set current collection to collection id (id of theAlbum)
					repeat until (id of current collection) is (id of theAlbum)
						delay 0.2
					end repeat
					
					-- clear all filters
					set filters to {}
					repeat until filters is {}
						delay 0.2
					end repeat
					
					-- enable filter for variants with adjustments
					-- have to wait for the filter to become available
					repeat until (available filters contains adjustedFilterYes) or (available filters contains adjustedFilterNo)
						delay 0.2
					end repeat
					if available filters contains adjustedFilterYes then
						set filters to adjustedFilterYes
					end if
				end tell
			end if
		end repeat
		
		-- create common variants album in catalog 2
		repeat with theValues in {{c2FileVariants, c2FilesAlbum}, {c2NameVariants, c2NamesAlbum}}
			set theVariants to first item of theValues
			set albumName to last item of theValues
			if (count of theVariants) > 0 then
				set current document to document 2
				select document 2
				tell document 2
					
					-- create common variants album
					if exists collection named albumName then
						set theAlbum to collection named albumName
					else
						set theAlbum to make new collection with properties {kind:album, name:albumName}
					end if
					
					-- wait for common variants album to be created
					repeat until exists collection named albumName
						delay 0.2
					end repeat
					
					-- add common variants to album
					add inside theAlbum variants theVariants
					
					-- select common variants album
					set current collection to collection id (id of theAlbum)
					repeat until (id of current collection) is (id of theAlbum)
						delay 0.2
					end repeat
					
					-- clear all filters
					set filters to {}
					repeat until filters is {}
						delay 0.2
					end repeat
					
					-- enable filter for variants with adjustments
					-- have to wait for the filter to become available
					repeat until (available filters contains adjustedFilterYes) or (available filters contains adjustedFilterNo)
						delay 0.2
					end repeat
					if available filters contains adjustedFilterYes then
						set filters to adjustedFilterYes
					end if
				end tell
			end if
		end repeat
		
	end tell
	
	set fileMessage to ((count of c1FileVariants) as text) & " variant file(s) in common." & return
	set nameMessage to ((count of c1NameVariants) as text) & " variant name(s) in common." & return
	set alertMessage to fileMessage & nameMessage
	
	-- application code goes above here
	
	set alertTitle to appName & " Finished"
	
	set alertResult to (display alert alertTitle message alertMessage buttons {"OK"} giving up after 10)
	
end run

##
## use this to handle scripts that accept drag-n-drop
##

on open droppedItems
end open

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
