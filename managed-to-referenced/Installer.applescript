(*

	Moved Managed to Referenced

	Author: Walter Rowe <walter@walterrowe.com>
	Create: 02 Aug 2024
	
	This script moves managed catalog images to referenced EXIF date based folders (YYY/MM/DD)

*)

use AppleScript version "2.8"
use scripting additions

property appNames : {"Move Managed to Referenced"}
property appType : ".scpt"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"
property docType : "catalog" as text

property appTesting : false
property requiresCOrunning : true
property requiresCOdocument : true

on run
	
	-- do install if not running under app name
	set appBase to my name as string
	set pathToMe to path to me
	if appNames does not contain appBase and not appTesting then
		installMe(appBase, pathToMe, installFolder, appType, appNames)
		return
	end if
	
		-- verify Capture One is running and has a document open
	if not meetsRequirements(appBase, requiresCOrunning, requiresCOdocument) then return
	
	-- only continue if we are working in a catalog
	tell application "Capture One"
		tell current document
			set docKind to kind
			set docPath to (path as text) & name
		end tell
	end tell
	
	if convertKindList(docKind) is not docType then
		set alertResult to (display alert "Incorrect Document Type" message "Document Type: " & (docKind as string) & return & return & "This utility only works with Capture One catalogs." as critical buttons {"Exit"})
		return
	end if
	
	
	-- inform user of what we plan to do and offer to cancel or continue
	try
		set alertResult to (display alert "What To Expect" message "This utility relocates images stored inside a Capture One catalog to a referenced folder of your choice outside the catalog. Any selected files that are already referenced will be skipped." & return & return & "You will choose the parent referenced folder. The script will create dated (YYYY/MM/DD) subfolders based on the EXIF image date of the selected images." & return & return & "Do you wish to Cancel or Continue?" as informational buttons {"Cancel", "Continue"} cancel button "Cancel" giving up after 10)
		if (gave up of alertResult) or (button returned of alertResult is "Cancel") then return
	on error
		-- graceful exit when user presses Cancel
		return
	end try
	
	tell application "Capture One"
		
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
		
		tell me to progress_start(0, "Moving ...", ((count of variantsToMove) as string))
		
		set imagesMoved to {}
		set movedTotal to count of variantsToMove
		set movedCount to 0
		set skippedCount to 0
		
		repeat with thisVariant in variantsToMove
			set movedCount to movedCount + 1
			tell me to progress_update(movedCount, movedTotal, "")
			
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
					-- display dialog "Skipping referenced image " & managedName buttons {"Skip"} with icon caution with title "-- ALERT --"
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
			tell me to progress_step(movedCount)
			
		end repeat -- with selected variants
		
	end tell -- Capture One
	
	tell me to progress_end()
	
	set doneMessage to "Moved " & ((count of imagesMoved) - skippedCount) & " files." & return & return & "Skipped " & skippedCount & " referenced images."
	set alertResult to (display alert "Move Complete" message doneMessage buttons {"Done"} default button "Done" as informational giving up after 10)
end run

on installMe(appBase, pathToMe, installFolder, appType, appNames)
	repeat with appName in appNames
		set scriptSource to quoted form of POSIX path of pathToMe
		set scriptTarget to quoted form of (installFolder & appName & appType)
		set installCommand to "osacompile -x -o " & scriptTarget & " " & scriptSource
		-- execute the shell command to install script
		try
			do shell script installCommand
		on error errStr number errorNumber
			set alertResult to (display alert "Install Error" message errStr & ": " & (errorNumber as text) & "on file " & scriptSource buttons {"Stop"} default button "Stop" as critical giving up after 10)
		end try
	end repeat
	set alertResult to (display alert "Installation Complete" buttons {"OK"} default button "OK")
end installMe


on meetsRequirements(appBase, requiresCOrunning, requiresCOdocument)
	set requirementsMet to true
	
	if requiresCOrunning then
		
		tell application "Capture One" to set isRunning to running
		if not isRunning then
			display alert "Alert" message "Capture One must be running." buttons {"Quit"}
			set requirementsMet to false
		end if
		
		if requiresCOdocument then
			tell application "Capture One" to set documentOpen to exists current document
			if not documentOpen then
				display alert appBase message "A Capture One Session or Catalog must be open." buttons {"Quit"}
				set requirementsMet to false
			end if
		end if
		
	end if
	
	return requirementsMet
	
end meetsRequirements

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


on convertKindList(theKind)
	
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General Purpose Handler for scripts using Capture One Pro
	## Capture One returns the chevron form of the "kind" property when AppleScript is run as an Application
	## Unless care is taken to avoid text conversion of this property, this bug breaks script decisions based on "kind"
	## This script converts text strings with the chevron form to strings with the expected text form
	## The input may be a single string, a single enum, a list of strings or a list of enums
	## The code is not compact but runs very fast, between 60us and 210us per item 
	
	local kind_sl, theItem, kindItem_s, code_start, kindItem_s, kind_code, kind_type
	
	if list = (class of theKind) then
		set kind_sl to {}
		repeat with theItem in theKind
			set the end of kind_sl to convertKindList(theItem)
		end repeat
		return kind_sl
	else if text = (class of theKind) then
		if "Ç" ­ (get text 1 of theKind) then return theKind
		set kindItem_s to theKind
	else
		tell application "Capture One" to set kindItem_s to (get theKind as text)
		if "Ç" ­ (get text 1 of kindItem_s) then return kindItem_s
	end if
	
	set code_start to -5
	if ("È" ­ (get text -1 of kindItem_s)) or (16 > (count of kindItem_s)) then Â
		error "convertKindList received an unexpected Kind string: " & kindItem_s
	
	set kind_code to get (text code_start thru (code_start + 3) of kindItem_s)
	set kind_type to get (text code_start thru (code_start + 1) of kindItem_s)
	
	if kind_type = "CC" then ## Collection Kinds
		if kind_code = "CCpj" then
			return "project"
		else if kind_code = "CCgp" then
			return "group"
		else if kind_code = "CCal" then
			return "album"
		else if kind_code = "CCsm" then
			return "smart album"
		else if kind_code = "CCfv" then
			return "favorite"
		else if kind_code = "CCff" then
			return "catalog folder"
		end if
		
	else if kind_type = "CL" then ## Layer Kinds
		if kind_code = "CLbg" then
			return "background"
		else if kind_code = "CLnm" then
			return "adjustment"
		else if kind_code = "CLcl" then
			return "clone"
		else if kind_code = "CLhl" then
			return "heal"
		end if
		
	else if kind_type = "CR" then ## Watermark Kinds
		if kind_code = "CRWn" then
			return "none"
		else if kind_code = "CRWt" then
			return "textual"
		else if kind_code = "CRWi" then
			return "imagery"
		end if
		
	else if kind_type = "CO" then ## Document Kinds
		if kind_code = "COct" then
			return "catalog"
		else if kind_code = "COsd" then
			return "session"
		end if
	end if
	
	error "convertKindList received an unexpected Kind string: " & kindItem_s
	
end convertKindList