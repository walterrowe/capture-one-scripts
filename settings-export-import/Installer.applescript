(*
	AUTHOR

	Author: Walter Rowe
	Contact: walter@walterrowe.com

	Created: 13-Dec-2023
	Updated: 20-Aug-2024

	DESCRIPTION

	This script creates or restores a ZIP of the transportable parts of these folders under ~/Library related to Capture One

		- Application Support/Capture One
		- Scripts/Capture One Scripts

	When restoring you must restart Capture One afterward for the app to see the restored settings.

	PREREQUISITES

	None
*)

use AppleScript version "2.8"
use scripting additions

property libraryFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property installNames : {"Settings Export", "Settings Import"}
property installType : ".scpt" -- ".scpt" for script, ".app" for script app
property installIcon : false -- if true must have a droplet.icns icon file in the source folder and ".app" installType

property requiresCOrunning : true -- true if capture one is required to be running
property requiresCOdocument : true -- true, false, "catalog", "session"

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
	
	set whereAmI to quoted form of POSIX path of appPath
	
	set settingsRoot to "~/Library/"
	set settingsFolders to "Application\\ Support/Capture\\ One/ Scripts/Capture\\ One\\ Scripts/"
	set settingsBackup to POSIX path of (path to desktop) & "CaptureOneSettings.zip"
	set settingsExclude to "-x '**Batch**' '**CaptureCore**' '**Diagnostics**' '**[Ee]rror**' '**IPCamera**' '**Plug-ins**' '**Sync**' '**/.DS_Store' '**Disabled**'"
	
	-- if we are running as the name "settings-export", create CaptureOneSettings.zip on the desktop
	if appName ends with "Export" then
		-- ask user to choose where to create the backup file
		set backupFolder to POSIX path of (choose folder with prompt "Select the folder place your backup file:" default location POSIX path of (path to desktop))
		set settingsBackup to POSIX path of backupFolder & "CaptureOneSettings.zip"
		
		-- command to export settings to desktop
		set exportCmd to "eval $(/usr/libexec/path_helper -s); cd " & settingsRoot & ";zip -r " & settingsBackup & " " & settingsFolders & " " & settingsExclude
		
		try
			do shell script exportCmd
		on error errStr number errorNumber
			display dialog "ERROR: " & appBase & ": " & errStr & ": " & (errorNumber as text) with icon coIcon
		end try
		
		set alertMessage to "Exported settings to " & return & return & settingsBackup
	end if
	
	-- if we are running as the name "settings-import", restore CaptureOneSettings.zip from the desktop
	if appName ends with "Import" then
		-- ask user to choose the backup file to restore
		set settingsBackup to quoted form of POSIX path of (choose file with prompt "Select the settings backup file to restore" default location POSIX path of (path to desktop))
		
		-- command to import settings from desktop
		set importCmd to "eval $(/usr/libexec/path_helper -s); unzip -o -d " & settingsRoot & " " & settingsBackup
		try
			do shell script importCmd
		on error errStr number errorNumber
			display dialog "ERROR: " & appBase & ": " & errStr & ": " & (errorNumber as text) & " " & settingsBackup with icon coIcon
		end try
		display dialog "Imported settings from " & settingsBackup & ". Please restart Capture One." with icon coIcon
		set alertMessage to "Settings imported from" & return & return & settingsBackup
	end if
	
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
