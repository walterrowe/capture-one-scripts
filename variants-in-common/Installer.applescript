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

property albumFilePrefix : "Variant Files in Common with "
property albumNamePrefix : "Variant Names in Common with "
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
	
	set startTime to current date
	
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
		
		-- set sourceDoc based on least number of variants
		set sourceCount to 10000000 -- arbitrary 10 million
		set sourceDoc to missing value
		repeat with thisDoc from 1 to (count of documentList)
			tell item thisDoc of documentList
				set current collection to collection named "All Images"
				set thisCount to (count of (get every variant))
				if thisCount < sourceCount then
					set sourceCount to thisCount
					copy item thisDoc of documentList to sourceDoc
				end if
			end tell
		end repeat
		log sourceDoc
		
		-- set targetDoc
		if first item of documentList is sourceDoc then
			set targetDoc to last item of documentList
		else
			set targetDoc to first item of documentList
		end if
		
		-- build albums to store found variants
		set sourceDocName to (name of sourceDoc) as text
		set targetDocName to (name of targetDoc) as text
		
		set sourceFileAlbum to albumFilePrefix & targetDocName
		set sourceNameAlbum to albumNamePrefix & targetDocName
		set targetFileAlbum to albumFilePrefix & sourceDocName
		set targetNameAlbum to albumNamePrefix & sourceDocName
		
		log "creating albums in " & sourceDocName & " and " & targetDocName
		
		-- create target albums in source doc
		set sourceFileAlbum to albumFilePrefix & targetDocName
		set sourceNameAlbum to albumNamePrefix & targetDocName
		log "creating albums " & sourceFileAlbum & " and " & sourceNameAlbum & " in " & sourceDocName
		set current document to sourceDoc
		tell sourceDoc
			repeat with theAlbum in {sourceFileAlbum, sourceNameAlbum}
				if exists collection named theAlbum then
					delete collection named theAlbum
					repeat until not (exists collection named theAlbum)
						delay 0.2
					end repeat
				end if
				make new collection with properties {kind:album, name:theAlbum}
				repeat until exists collection named theAlbum
					delay 0.2
				end repeat
			end repeat
		end tell
		
		-- create source albums in target doc
		set targetFileAlbum to albumFilePrefix & sourceDocName
		set targetNameAlbum to albumNamePrefix & sourceDocName
		log "creating albums " & targetFileAlbum & " and " & targetNameAlbum & " in " & targetDocName
		set current document to targetDoc
		tell targetDoc
			repeat with theAlbum in {targetFileAlbum, targetNameAlbum}
				if exists collection named theAlbum then
					delete collection named theAlbum
					repeat until not (exists collection named theAlbum)
						delay 0.2
					end repeat
				end if
				make new collection with properties {kind:album, name:theAlbum}
				repeat until exists collection named theAlbum
					delay 0.2
				end repeat
			end repeat
		end tell
		
		-- find names of common variants
		tell sourceDoc to set sourceVariants to (get name of every variant of collection named "All Images")
		tell targetDoc to set targetVariants to (get name of every variant of collection named "All Images")
		
		set sourceNames to {}
		repeat with theVariant in sourceVariants
			set end of sourceNames to (theVariant as text)
		end repeat
		
		set targetNames to {}
		repeat with theVariant in targetVariants
			set end of targetNames to (theVariant as text)
		end repeat
		
		tell me to myLibrary's progress_start(0, "Scanning ... ", count of sourceNames)
		set commonVariants to {}
		set searchCounter to 0
		repeat with sourceName in sourceNames
			set searchCounter to searchCounter + 1
			set progress to ((searchCounter as number) / ((count of sourceNames) as number) * 100) as integer
			tell me to myLibrary's progress_update(progress, 100, "")
			if targetNames contains sourceName then set end of commonVariants to sourceName
		end repeat
		
		-- set up progress status
		set searchCounter to 0
		set commonCount to (count of commonVariants)
		tell me to myLibrary's progress_start(searchCounter, "Comparing ... ", 100)
		
		-- cycle through smallest doc comparing to other open docs
		set current document to sourceDoc
		set foundFiles to 0
		set foundNames to 0
		tell sourceDoc
			repeat with sourceName in commonVariants
				set sourceVariant to first item of (get every variant of collection named "All Images" where its name is sourceName)
				set searchCounter to searchCounter + 1
				set progress to ((searchCounter as number) / (commonCount as number) * 100) as integer
				tell me to myLibrary's progress_update(progress, 100, "")
				set sourceFile to (file of sourceVariant) as text
				set sourceName to (name of sourceVariant) as text
				
				-- ask the target doc if it has a variant with this file or name
				tell targetDoc
					set theFiles to (get every variant of collection named "All Images" where its file is sourceFile)
					set theNames to (get every variant of collection named "All Images" where its name is sourceName)
				end tell
				if theFiles is not {} then
					tell targetDoc to add inside collection named targetFileAlbum variants theFiles
					tell sourceDoc to add inside collection named sourceFileAlbum variants {sourceVariant}
					set foundFiles to foundFiles + (count of theFiles)
				else if theNames is not {} then
					tell targetDoc to add inside collection named targetNameAlbum variants theNames
					tell sourceDoc to add inside collection named sourceNameAlbum variants {sourceVariant}
					set foundNames to foundNames + (count of theNames)
				end if
			end repeat
			tell me to myLibrary's progress_step(searchCounter)
			
		end tell
		
	end tell
	
	tell me to myLibrary's progress_end()
	
	set endTime to current date
	set timeTaken to (endTime - startTime)
	set timeTaken to ((timeTaken / 60 as integer) as string) & ":" & (text -1 thru -2 of ("0" & (timeTaken mod 60 as integer) as string)) & " (mm:ss)" 
	
	set fileMessage to (foundFiles as text) & " variant(s) with file(s) in common." & return
	set nameMessage to (foundNames as text) & " variant(s) with name(s) in common." & return
	set doneMessage to return & timeTaken& return & return & "This dialog will close in 30 secs" & return
	set alertMessage to fileMessage & nameMessage & doneMessage
	
	-- application code goes above here
	
	set alertTitle to appName & " Finished"
	
	set alertResult to (display alert alertTitle message alertMessage buttons {"OK"} giving up after 30)
	
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
