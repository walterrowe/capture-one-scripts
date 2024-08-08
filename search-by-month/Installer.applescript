use AppleScript version "2.8"
use scripting additions

property appNames : {"Smart Album By Month"}
property appType : ".scpt"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property appTesting : false

on run
	
	-- do install if not running under app name
	set appBase to my name as string
	set pathToMe to path to me
	if appNames does not contain appBase and not appTesting then
		installMe(appBase, pathToMe, installFolder, appType, appNames)
		return
	end if	
	
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
		set sYear to text returned of (display dialog "Enter Start Year:" default answer "" with icon note buttons {"Continue", "Cancel"} default button "Continue")
		set eYear to text returned of (display dialog "Enter Start Year:" default answer "" with icon note buttons {"Continue", "Cancel"} default button "Continue")
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