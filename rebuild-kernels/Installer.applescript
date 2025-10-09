(*
	AUTHOR

	Author: Walter Rowe
	Contact: walter@walterrowe.com

	Created: Oct 8, 2025
	Updated: 

	1. Set installNames
	2. Develop code
	3. Provide app icon (optional, set installIcon to true)
	4. Test code in Script Editor
	5. Change appTesting to false
	6. Test code in Capture One

	DESCRIPTION

	Delete Capture One hardware acceleration kernel files and restart the application.


	PREREQUISITES

	None
*)

property version : "1.0"

use AppleScript version "2.8"
use scripting additions

property libraryFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property installNames : {"Rebuild Kernels"}
property installType : ".scpt" -- ".scpt" for script, ".app" for script app
property installIcon : false -- if true must have a droplet.icns icon file in the source folder and ".app" installType

property requiresCOrunning : false -- true if capture one is required to be running
property requiresCOdocument : false -- true, false, "catalog", "session"

property appTesting : false -- if true, run in script editor, and if false install the script

-- application specific properties below

property imageCoreParent : (POSIX path of (path to home folder)) & "Library/Application Support/Capture One/ImageCore/"
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
			set appName to choose from list installNames with prompt "Choose Application to Mimic"
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
	set coIcon to path to resource "AppIcon.icns" in bundle (path to application "Capture One Beta")
	
	-- ensure we have permission to interact with other apps
	myLibrary's activateUIScripting()
	
	-- application code goes below here	
	
	-- get a list of all existing capture one acceleration kernel folders
	set metalFolders to (do shell script "find /private/var/folders -type d -path '*captureone*' -name 'com.apple.metal*' 2>/dev/null || true")
	
	set imageCoreFolders to (do shell script "ls -1 \"" & imageCoreParent & "\" 2>/dev/null || true")
	
	-- split returned text into a list of paths
	set cDelims to text item delimiters
	set text item delimiters to return
	set metalFolders to every text item of metalFolders as list
	set imageCoreFolders to every text item of imageCoreFolders as list
	set imageCorePaths to imageCoreFolders as text
	set text item delimiters to cDelims
	
	
	-- delete all capture one acceleration kernel folders
	if (class of metalFolders is list) and (length of metalFolders) > 0 then
		tell application "System Events"
			repeat with metalFolder in metalFolders
				delete disk item metalFolder
			end repeat
		end tell
	end if
	
	-- delete all ImageCore folders
	if (class of imageCoreFolders is list) and (length of imageCoreFolders) > 0 then
		tell application "System Events"
			repeat with imageCoreFolder in imageCoreFolders
				delete disk item (imageCoreParent & imageCoreFolder)
			end repeat
		end tell
	end if
	
	-- display status message before restarting Capture One	
	set alertMessage to ""
	set kernelCount to (count of metalFolders) + (count of imageCoreFolders)
	if (count of metalFolders) > 0 then
		set alertMessage to "Deleted " & ((count of metalFolders) as text) & " kernels." & return & return
	end if
	if (count of imageCoreFolders) > 0 then
		set alertMessage to alertMessage & "Deleted these ImageCore folders:" & return & return & imageCorePaths & return & return
	end if
	
	if kernelCount > 0 then
		set alertMessage to alertMessage & "Capture One will now restart."
	else
		set alertMessage to alertMessage & "No kernels were found." & return & return & "No need to restart Capture One."
	end if
	
	set alertTitle to appName & " Finished"
	
	set alertResult to (display alert alertTitle message alertMessage buttons {"OK"} giving up after 10)
	
	-- restart capture one
	if kernelCount > 0 then
		set coWasRunning to false
		tell application "System Events"
			if application process "Capture One Beta" exists then
				set coWasRunning to true
				tell application "Capture One Beta"
					quit
					repeat while running
						delay 0.1 -- Wait for the app to fully close
					end repeat
				end tell
			end if
		end tell
		if coWasRunning then tell application "Capture One Beta" to activate
	end if
	
	-- application code goes above here
	
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
