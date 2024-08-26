(*
	AUTHOR

	Author: Walter Rowe
	Contact: walter@walterrowe.com

	Created: 02-Aug-2024
	Updated: 20-Aug-2024

	DESCRIPTION

	This script moves managed catalog images to referenced EXIF date based folders (YYYY/MM/DD)

	PREREQUISITES

	None
*)

use AppleScript version "2.8"
use scripting additions

property libraryFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property installNames : {"Move Managed to Referenced"}
property installType : ".scpt" -- ".scpt" for script, ".app" for script app
property installIcon : false -- if true must have a droplet.icns icon file in the source folder and ".app" installType

property requiresCOrunning : true -- true if capture one is required to be running
property requiresCOdocument : "catalog" -- true, false, "catalog", "session"

property appTesting : false -- if true, run in script editor, and if false install the script

-- application specific properties below

-- application specific properties above

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
	
	-- inform user of what we plan to do and offer to cancel or continue
	try
		set alertResult to (display alert "What To Expect" message "This utility relocates images stored inside a Capture One catalog to a referenced folder of your choice outside the catalog. Any selected files that are already referenced will be skipped." & return & return & "You will choose the parent referenced folder. The script will create dated (YYYY/MM/DD) subfolders based on the EXIF image date of the selected images." & return & return & "Do you wish to Cancel or Continue?" as informational buttons {"Cancel", "Continue"} cancel button "Cancel" giving up after 10)
		if (gave up of alertResult) or (button returned of alertResult is "Cancel") then return
	on error
		-- graceful exit when user presses Cancel
		return
	end try
	
	tell application "Capture One"
		
		tell current document to set docPath to its path

		-- get all selected variants user wants to move
		set variantsToMove to get selected variants
		if (count of variantsToMove) < 1 then
			set alertResult to (display alert "No Selection" message "No images are selected to move." buttons {"Stop"} default button "Stop" as critical giving up after 10)
			return
		end if
		
		-- ask user to choose the parent folder for new folder tree
		tell application "Finder"
			activate
			set targetFolderParent to POSIX path of (choose folder with prompt "Choose PARENT Folder for Moved Images:")
		end tell
		activate
		
		-- create a list of image IDs we have already moved
		-- multiple variants will have the same image ID
		
		tell me to myLibrary's progress_start(0, "Moving ...", ((count of variantsToMove) as string))
		
		set imagesMoved to {}
		set movedTotal to count of variantsToMove
		set movedCount to 0
		set skippedCount to 0
		
		repeat with thisVariant in variantsToMove
			set movedCount to movedCount + 1
			tell me to myLibrary's progress_update(movedCount, movedTotal, "")
			
			-- get image for this variant
			set thisImage to get parent image of thisVariant
			
			-- if we have not already moved this image file
			if imagesMoved does not contain id of thisImage then
				
				-- remember we moved this image ID
				set end of imagesMoved to id of thisImage
				
				-- extract date strings from image date
				set thisDate to EXIF capture date of thisImage
				
				set thisYear to year of thisDate as string
				
				set thisMonth to (month of thisDate as number) as string
				if length of thisMonth < 2 then set thisMonth to "0" & thisMonth
				
				set thisDay to day of thisDate as string
				if length of thisDay < 2 then set thisDay to "0" & thisDay
				
				-- construct source folder and file paths
				set managedPath to POSIX file (path of thisImage) as alias
				set managedPathStr to managedPath as string
				set managedName to name of thisImage
				
				-- don't move images that are already referenced
				if managedPathStr does not start with docPath then
					set skippedCount to skippedCount + 1
					-- display dialog "Skipping referenced image " & managedName buttons {"Skip"} with icon coIcon with title "-- ALERT --"
				else
					
					-- construct target folder and file paths
					set targetFolder to targetFolderParent & thisYear & "/" & thisMonth & "/" & thisDay & "/"
					set targetFile to targetFolder & managedName
					
					-- tell Finder to move the file
					tell application "Finder"
						
						-- create target folder if it doesn't exist
						if not (exists targetFolder) then
							do shell script "mkdir -p " & (quoted form of targetFolder)
						end if
						
						-- move image to target folder (requires string for file name and aliases for folders)
						set managedParent to container of managedPath
						set destFolder to ((targetFolder as POSIX file) as alias)
						move file managedName of managedParent to folder destFolder
						
					end tell -- Finder
					
					-- tell Capture One to relink ("locate") the image at new location
					relink thisImage to path targetFile
				end if
			end if
			tell me to myLibrary's progress_step(movedCount)
			
		end repeat -- with selected variants
		
	end tell -- Capture One
	
	tell me to myLibrary's progress_end()
	
	set alertMessage to "Moved " & ((count of imagesMoved) - skippedCount) & " files." & return & return & "Skipped " & skippedCount & " referenced images."
	
	-- application code goes above here
	
	set alertTitle to appName & " Finished"
	
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
