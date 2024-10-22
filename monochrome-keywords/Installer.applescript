(*
	AUTHOR

	Author: Walter Rowe
	Contact: walter@walterrowe.com

	Created: 03-Jul-2020
	Updated: 20-Aug-2024

	DESCRIPTION

	Apply or Remove a list of monochrome-oriented keywords from monochrome images.

	Monochrome criteria:

	* black and white is enabled
	--OR--
	* saturation is -100.0

	When the script is completed, it will show a count of images updated in the results window.

	PREREQUISITES

	None
*)

use AppleScript version "2.8"
use scripting additions

property libraryFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property installNames : {"Apply Monochrome Keywords", "Remove Monochrome Keywords"}
property installType : ".scpt" -- ".scpt" for script, ".app" for script app
property installIcon : false -- if true must have a droplet.icns icon file in the source folder and ".app" installType

property requiresCOrunning : true -- true if capture one is required to be running
property requiresCOdocument : true -- true, false, "catalog", "session"

property appTesting : false -- if true, run in script editor, and if false install the script

-- application specific properties below

property bwKeywords : {"Black & White", "Monochrome"}

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
	
	if appTesting then set appName to item 1 of (choose from list installNames)
	
	set updateCount to 0
	
	tell application "Capture One"
		
		if appName starts with "Apply" then
			-- get list of variants with black & white enabled or background saturation set to -100
			if (count of selected variants) > 0 then
				set monoVariants to (get variants where ((selected is true) and (black and white of adjustments is true) or (saturation of adjustments is -100.0)))
			else
				set monoVariants to (get variants where ((black and white of adjustments is true) or (saturation of adjustments is -100.0)))
			end if
			if (count of monoVariants) > 0 then
				repeat with bwKeyword in bwKeywords
					tell current document
						-- get or create this keyword
						if exists keyword bwKeyword then
							set monoKW to keyword bwKeyword
						else
							tell item 1 in monoVariants to set monoKW to make new keyword with properties {name:bwKeyword}
						end if
						-- apply the keyword to list of variants
						apply keyword monoKW to monoVariants
					end tell
				end repeat
				repeat with monoVariant in monoVariants
					tell monoVariant to set status job identifier to "-BW"
				end repeat
				set updateCount to (count of monoVariants)
			end if
		end if
		
		if appName starts with "Remove" then
			set updatedVariants to {}
			repeat with thisKeyword in bwKeywords
				if (count of selected variants) > 0 then
					set monoVariants to (get variants where ((selected is true) and (thisKeyword is in name of keywords)))
				else
					set monoVariants to (get variants where (thisKeyword is in name of keywords))
				end if
				repeat with thisVariant in monoVariants
					if updatedVariants does not contain (id of thisVariant) then set end of updatedVariants to (id of thisVariant)
					tell thisVariant to set status job identifier to ""
					delete (every keyword of thisVariant whose name is thisKeyword)
				end repeat
			end repeat
			set updateCount to (count of updatedVariants)
		end if
		
	end tell
	
	set alertMessage to (updateCount as string) & " images updated."
	
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
