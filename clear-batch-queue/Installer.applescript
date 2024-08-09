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

property appTesting : false

property queueParent : ((POSIX path of (path to home folder)) as string) & "Library/Application Support/Capture One/"

on run
	
	-- do install if not running under app name
	set appBase to my name as string
	set pathToMe to path to me
	if appNames does not contain appBase and not appTesting then
		installMe(appBase, pathToMe, installFolder, appType, appNames)
		return
	end if
	
	-- get contents of all batch queue folders
	set queueMessage to ""
	
	tell application "Finder"
		set queueAlias to (queueParent as POSIX file as alias)
		set queueFolders to ((every item of folder queueAlias where name starts with "Batch") sort by name)
		set queueSizes to {}
		set queueTotalSize to 0
		set queueTotalFile to 0
		set queueFiles to {}
		repeat with idx from 1 to count of queueFolders
			set aFolder to queueParent & name of item idx of queueFolders as POSIX file as alias
			set end of queueFiles to (count of every item of folder aFolder) as string
			
			set end of queueSizes to physical size of item idx of queueFolders
			
			set queueTotalSize to queueTotalSize + (physical size of item idx of queueFolders)
			set queueTotalFile to queueTotalFile + (item idx of queueFiles)
			
			set queueMessage to queueMessage & (((name of item idx of queueFolders & " (" & item idx of queueFiles as string) & " files, " & ((item idx of queueSizes) / 1024 / 1024 as integer) as string) & "MB)") & return
		end repeat
	end tell
	
	set queueMessage to (queueMessage & return & "Total Space: " & (queueTotalSize / 1024 / 1024 as integer) & "MB, " & queueTotalFile as string) & " files" & return
	
	-- inform user of what we plan to do and offer to cancel or continue
	try
		set alertResult to (display alert appBase message "This utility requires a Capture One session or catalog to be open." & return & return & "It stops the batch queue, removes all existing jobs from the queue, moves older batch queue folders to system trash, and moves the contents of the current batch queue folder to system trash." & return & return & queueMessage & return & "Do you wish to Cancel or Continue?" as informational buttons {"Cancel", "Continue"} cancel button "Cancel" giving up after 30)
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
			set aFolder to queueParent & name of item idx of queueFolders as POSIX file as alias
			if idx < folderCount then
				delete folder aFolder
			else
				delete every item of folder aFolder
			end if
		end repeat
	end tell
	
	set doneAlert to appBase & " Finished"
	set doneMessage to queueMessage
	set alertResult to (display alert doneAlert message doneMessage buttons {"Done"} default button "Done" as informational giving up after 10)
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