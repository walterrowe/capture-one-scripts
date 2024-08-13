(*

	Clear Batch Queue

	Author: Walter Rowe <walter@walterrowe.com>
	Create: 08 Aug 2024
	
	Clear the batch queue and clean up the batch queue folder(s)

*)

use AppleScript version "2.8"
use scripting additions

property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property appType : ".scpt"
property appNames : {"Clear Batch Queue"}

property appIcon : false -- if true there must be a droplet.icns icon file in the source folder
property appTesting : false -- if true, run in script editor, and if false install the script
property requiresCOrunning : true -- true if capture one is required to be running
property requiresCOdocument : true -- true if capture one is required to have an open document

property queueParent : ((POSIX path of (path to home folder)) as string) & "Library/Application Support/Capture One/"

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
	
	-- get contents of all batch queue folders
	tell application "Capture One" to tell current document to set batchEnabled to processing queue enabled
	tell application "Capture One" to tell current document to set batchCount to count of every job
	if batchEnabled is true then
		set batchEnabled to "Started"
	else
		set batchEnabled to "Stopped"
	end if
	
	set queueMessage to ""
	
	tell application "Finder"
		set queueAlias to (queueParent as POSIX file as alias)
		set queueFolders to ((every item of folder queueAlias where name starts with "Batch") sort by name)
		set queueFiles to {}
		set queueSizes to {}
		set queueTotalFiles to 0
		set queueTotalSizes to 0
		repeat with idx from 1 to count of queueFolders
			
			set theFolder to queueParent & name of item idx of queueFolders as POSIX file as alias
			
			set end of queueFiles to (count of every item of folder theFolder) as string
			
			set theFiles to size of every item of folder theFolder
			
			set folderSize to 0
			repeat with fileIndex from 1 to count of theFiles
				set folderSize to folderSize + (item fileIndex of theFiles)
			end repeat
			
			set queueTotalFiles to queueTotalFiles + (count of theFiles)
			set queueTotalSizes to queueTotalSizes + folderSize
			
			set end of queueFiles to (count of theFiles) as string
			set end of queueSizes to folderSize
			
			set queueMessage to (queueMessage & (((name of item idx of queueFolders & " (" & item idx of queueFiles as string) & " files, " & ((item idx of queueSizes) / 1024 / 1024 as integer) as string) & "MB)") & return)
			
		end repeat
	end tell
	
	set alertMessage to ((queueMessage & return & "Total Space: " & queueTotalFiles as string) & " files, " & (queueTotalSizes / 1024 / 1024 as integer) & "MB" & return & return & "Batch Queue: " & batchEnabled & " (" & batchCount as string) & " jobs)" & return
	
	-- inform user of what we plan to do and offer to cancel or continue
	try
		set alertResult to (display alert appBase message "This utility requires a Capture One session or catalog to be open." & return & return & "It stops the batch queue, removes all existing jobs from the queue, moves older batch queue folders to system trash, and moves the contents of the current batch queue folder to system trash." & return & return & alertMessage & return & "Do you wish to Cancel or Continue?" as informational buttons {"Cancel", "Continue"} cancel button "Cancel" giving up after 30)
		if (gave up of alertResult) or (button returned of alertResult is "Cancel") then return
	on error
		-- graceful exit when user presses Cancel
		return
	end try
	
	-- the user has agreed to continue
	
	-- delete all existing jobs in the batch queue
	tell application "Capture One"
		tell current document
			set queueEnabled to processing queue enabled
			set processing queue enabled to false
			delete every job
			set processing queue enabled to queueEnabled
		end tell
	end tell -- Capture One
	
	-- delete older queue folders and current queue folder contents
	tell application "Finder"
		set folderCount to count of queueFolders
		repeat with idx from 1 to folderCount
			set theFolder to queueParent & name of item idx of queueFolders as POSIX file as alias
			if idx < folderCount then
				delete folder theFolder
			else
				delete every item of folder theFolder
			end if
		end repeat
	end tell
	
	set doneAlert to appBase & " Finished"
	tell application "Capture One" to tell current document to set batchCount to count of every job
	set alertMessage to ((queueMessage & return & "Total Space: " & queueTotalFiles as string) & " files, " & (queueTotalSizes / 1024 / 1024 as integer) & "MB" & return & return & "Batch Queue: " & batchEnabled & " (" & batchCount as string) & " jobs)" & return
	set alertResult to (display alert doneAlert message alertMessage buttons {"Done"} default button "Done" as informational giving up after 10)
	
end run

##
## applescript self-installer function
##

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

##
## confirm if capture one is running and has an open document (if required)
##

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
