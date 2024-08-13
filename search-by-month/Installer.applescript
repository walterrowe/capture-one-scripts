use AppleScript version "2.8"
use scripting additions

property appNames : {"Smart Album By Month"}
property appType : ".scpt"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property appIcon : false
property appTesting : false
property requiresCOrunning : true
property requiresCOdocument : true

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

on installMe(appBase, pathToMe, installFolder, appType, appNames, appIcon)
	
	## Copyright 2024 Walter Rowe, Maryland, USA		No Warranty
	## General purpose AppleScript Self-Installer
	##
	## Compiles and installs an AppleScript via osacompile as a type and list of names in a target folder
	##
	## Displays an error when it cannot install the script
	## Displays an alert when installation is successful
	
	repeat with appName in appNames
		set scriptSource to POSIX path of pathToMe
		set scriptTarget to (installFolder & appName & appType)
		set installCommand to "osacompile -x -o " & (quoted form of scriptTarget) & " " & (quoted form of scriptSource)
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


on meetsRequirements(appBase, requiresCOrunning, requiresCOdocument)
	set requirementsMet to true
	
	if requiresCOrunning then
		
		tell application "Capture One" to set isRunning to running
		if not isRunning then
			display alert "Alert" message "Capture One must be running." buttons {"Quit"}
			set requirementsMet to false
		end if
		
		if requiresCOdocument and isRunning then
			tell application "Capture One" to set documentOpen to exists current document
			if not documentOpen then
				display alert appBase message "A Capture One Session or Catalog must be open." buttons {"Quit"}
				set requirementsMet to false
			end if
		end if
		
	end if
	
	return requirementsMet
	
end meetsRequirements