(*
	AUTHOR

	Author: Walter Rowe
	Contact: walter@walterrowe.com

	Created: 12-August-2023
	Updated: 20-August-2024

	DESCRIPTION

	Apply Capture One color tags as color labels of corresponding files in macOS Finder

	PREREQUISITES

	None
*)

use AppleScript version "2.8"
use scripting additions

property libraryFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property installNames : {"Copy Labels To Finder"}
property installType : ".scpt"
property installIcon : false

property requiresCOrunning : true
property requiresCOdocument : true

property appTesting : false

-- application specific properties below

property docType : "catalog" as string
property labelMapping : {2, 1, 3, 6, 4, 7, 5}

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
	
	tell application "Capture One"
		set startTime to current date
		set imageSel to get selected variants
		
		if (count of imageSel) < 1 then
			set alertResult to (display alert appName message "No images are selected." buttons {"Stop"} default button "Stop" as critical giving up after 10)
			return
		end if
		
		set noLabels to {}
		tell me to myLibrary's progress_start(0, "Processing ...", "scanning")
		set imgCount to count of imageSel
		set imgsUpdated to 0
		repeat with i from 1 to imgCount
			tell me to myLibrary's progress_update(i, imgCount, "")
			set thisVariant to item i of imageSel
			set thisFile to file of parent image of thisVariant as alias
			set thisLabel to color tag of thisVariant
			
			-- map capture one color tags to macOS finder label indexes
			-- color CO-index Finder-index
			--
			-- None		0		0
			-- Red		1		2
			-- Orange	2		1
			-- Yellow		3		3
			-- Green		4		6
			-- Blue		5		4
			-- Pink		6		7 (CO pink maps to Finder gray)
			-- Purple		7		5
			--
			-- use CO's label number as index into list for macOS label numbers
			-- omit 0 since it maps 1-to-1 and there is not item 0 in applescript lists
			-- { 1, 2, 3, 4, 5, 6, 7 }
			-- { 2, 1, 3, 6, 4, 7, 5 }
			
			-- 0 and 3 map to the same number
			if thisLabel is not in {0, 3} then
				set thisLabel to item thisLabel of labelMapping
			end if
			
			tell application "Finder" to set label index of thisFile to thisLabel
			tell me to myLibrary's progress_step(i)
		end repeat
		
		tell me to myLibrary's progress_end()
		
		tell me to set noLabelsCount to ((count of noLabels) as string)
		tell me to set timeTaken to ((current date) - startTime)
		set timeTaken to ((timeTaken / 60 as integer) as string) & ":" & (text -1 thru -2 of ("0" & (timeTaken mod 60 as integer) as string))
		
		
	end tell
	
	set alertMessage to "Updated " & imgCount & " images in " & timeTaken & " (mm:ss)."
	
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
