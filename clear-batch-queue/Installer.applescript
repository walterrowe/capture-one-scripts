(*
	AUTHOR

	Author: Walter Rowe
	Contact: walter@walterrowe.com

	Created: 08-Aug-2024
	Updated: 20-Aug-2024

	DESCRIPTION

	Clear the batch queue and clean up the batch queue folder(s)

	PREREQUISITES

*)

use AppleScript version "2.8"
use scripting additions

property libraryFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property installNames : {"Clear Batch Queue"}
property installType : ".scpt"
property installIcon : false -- if true there must be a droplet.icns icon file in the source folder

property requiresCOrunning : true -- true if capture one is required to be running
property requiresCOdocument : true -- true if capture one is required to have an open document

property appTesting : false -- if true, run in script editor, and if false install the script

-- application specific properties below

property queueParent : ((POSIX path of (path to home folder)) as string) & "Library/Application Support/Capture One/"

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
		set alertResult to (display alert appName message "This utility requires a Capture One session or catalog to be open." & return & return & "It stops the batch queue, removes all existing jobs from the queue, moves older batch queue folders to system trash, and moves the contents of the current batch queue folder to system trash." & return & return & alertMessage & return & "Do you wish to Cancel or Continue?" as informational buttons {"Cancel", "Continue"} cancel button "Cancel" giving up after 30)
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
	
	tell application "Capture One" to tell current document to set batchCount to count of every job
	
	set alertTitle to appName & " Finished"
	set alertMessage to ((queueMessage & return & "Total Space: " & queueTotalFiles as string) & " files, " & (queueTotalSizes / 1024 / 1024 as integer) & "MB" & return & return & "Batch Queue: " & batchEnabled & " (" & batchCount as string) & " jobs)" & return
	
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
