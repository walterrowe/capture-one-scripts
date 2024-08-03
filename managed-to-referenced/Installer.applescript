(*

	Moved Managed to Referenced

	Author: Walter Rowe <walter@walterrowe.com>
	Create: 02 Aug 2024
	
	This script moves managed catalog images to referenced EXIF date based folders (YYY/MM/DD)

*)

use AppleScript version "2.7"
use scripting additions

property appNames : {"Move Managed to Referenced"}
property appType : ".scpt"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"
property docType : "catalog" as string

on run
	
	set appBase to my name as string
	set pathToMe to path to me
	
	-- do install if not running under app name
	if appNames does not contain appBase then
		repeat with appName in appNames
			set scriptSource to quoted form of POSIX path of (path to me)
			set scriptTarget to quoted form of (installFolder & appName & appType)
			set installCommand to "osacompile -x -o " & scriptTarget & " " & scriptSource
			-- execute the shell command to install script
			try
				do shell script installCommand
			on error errStr number errorNumber
				display dialog "Install ERROR: " & errStr & ": " & (errorNumber as text) & "on file " & scriptSource
			end try
		end repeat
		display dialog "Installation complete." buttons {"OK"}
		return
	end if
	
	-- only continue if we are working in a catalog
	tell application "Capture One"
		tell current document
			set docKind to kind as string
			set docPath to (path as string) & name
		end tell
	end tell
	(*
	-- BUG -- docKind should say "catalog" or "session" but doesn't
	if docKind is not docType then
		display dialog "Document Kind: " & (docKind as string) & return & return & "This utility only works with Capture One catalogs." buttons {"Exit"} with icon caution with title "-- ALERT --"
		return
	end if
	*)
	
	-- inform user of what we plan to do and offer to cancel or continue
	try
		display dialog "This utility relocates images stored inside a Capture One catalog to a referenced folder of your choice outside the catalog." & return & return & "You will choose the parent referenced folder. The script will create dated (YYYY/MM/DD) subfolders based on the EXIF image date of the selected images." & return & return & "Do you wish to Cancel or Continue?" buttons {"Cancel", "Continue"} with title "INSTRUCTIONS"
	on error
		-- graceful exit when user presses Cancel
		return
	end try
	
	tell application "Capture One"
		
		-- get all selected variants user wants to move
		set variantsToMove to get selected variants
		if (count of variantsToMove) < 1 then
			display dialog "No images were selected to move." buttons {"OK"} with icon caution with title "-- ALERT --"
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
	display dialog doneMessage buttons {"Done"} with title "-- MOVED " & (count of imagesMoved) & " FILES --"
	
end run

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
