(*
	AUTHOR

	Author: Walter Rowe
	Contact: walter@walterrowe.com

	Created: 28-Dec-2023
	Updated: 20-Aug-2024

	DESCRIPTION

	Ask user to choose the months, and a year range, and create a smart album with that criteria

	PREREQUISITES

	None
*)

use AppleScript version "2.8"
use scripting additions

property libraryFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property installNames : {"Smart Album By Month"}
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
	
	set monthNames to {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
	set monthPicks to (choose from list monthNames with title "CHOOSE MONTH" with multiple selections allowed)
	if monthPicks is false then return
	
	set searchMonths to {}
	set searchNames to {}
	repeat with monthName in monthPicks
		repeat with idx from 1 to (count of monthNames)
			if item idx of monthNames is (monthName as string) then
				set end of searchMonths to idx
				set end of searchNames to (monthName as text)
			end if
		end repeat
	end repeat
	
	set textDelimiters to text item delimiters
	set text item delimiters to " "
	set searchNames to (searchNames as text)
	set text item delimiters to textDelimiters
	
	try
		set sYear to text returned of (display dialog "Enter Start Year:" default answer "" with icon coIcon buttons {"Continue", "Cancel"} default button "Continue")
		set eYear to text returned of (display dialog "Enter Start Year:" default answer "" with icon coIcon buttons {"Continue", "Cancel"} default button "Continue")
	on error
		return
	end try
	
	set mySmartName to ((sYear as string) & " to " & (eYear as string) & " | " & searchNames)
	
	set sYear to sYear as integer
	set eYear to eYear as integer
	
	set mySmartRule to my createSmartRule(sYear, eYear, searchMonths)
	
	tell application "Capture One"
		tell front document
			set current collection to (make new collection with properties {name:mySmartName, kind:smart album, rules:mySmartRule})
		end tell
	end tell
	
	set alertMessage to "Smart Album " & mySmartName & " created and selected."
	
	-- application code goes above here
	
	set alertTitle to appName & " Finished"
	
	set alertResult to (display alert alertTitle message alertMessage buttons {"OK"} giving up after 10)
	
end run

on createSmartRule(sYear, eYear, searchMonths)
	
	-- convert each month number into zero-filled two-digit string
	repeat with idx from 1 to count of searchMonths
		set searchMonth to (item idx of searchMonths) as string
		if length of searchMonth < 2 then set searchMonth to "0" & searchMonth
		set item idx of searchMonths to searchMonth
	end repeat
	
	set searchPrefix to "<?xml version=\"1.0\" encoding=\"UTF-8\"?><MatchOperator Kind=\"AND\"><MatchOperator Kind=\"OR\">"
	set searchCriteria to ""
	repeat with idx from 1 to count of searchMonths
		repeat with thisYear from sYear to eYear
			set searchCriteria to searchCriteria & "<Condition Enabled=\"YES\"><Key>_date_yearMonth</Key><Operator>0</Operator><Criterion>" & (thisYear as string) & "-" & item idx of searchMonths & "</Criterion></Condition>"
		end repeat
	end repeat
	set searchPostfix to "</MatchOperator></MatchOperator>"
	set smartRule to searchPrefix & searchCriteria & searchPostfix
	
	return smartRule
	
end createSmartRule

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
