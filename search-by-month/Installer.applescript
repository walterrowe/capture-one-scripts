use AppleScript version "2.7"
use scripting additions

property appNames : {"Search By Month"}
property appType : ".scpt"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

on run
	
	set appBase to my name as string
	
	if appNames does not contain appBase then
		repeat with appName in appNames
			set scriptSource to quoted form of POSIX path of (path to me)
			set scriptTarget to quoted form of (installFolder & appName & appType)
			set installCommand to "osacompile -x -o " & scriptTarget & " " & scriptSource
			-- execute the shell command to install export-settings.scpt
			try
				do shell script installCommand
			on error errStr number errorNumber
				display dialog "Install ERROR: " & errStr & ": " & (errorNumber as text) & "on file " & scriptSource
			end try
		end repeat
		display dialog "Installation complete." buttons {"OK"}
		return
	end if
	
	
	tell application "Capture One"
		
		set monthNames to {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
		set monthName to first item of (choose from list monthNames)
		repeat with idx from 1 to (count of monthNames)
			if item idx of monthNames is monthName then set searchMonth to idx
		end repeat
		
		set sYear to text returned of (display dialog "Enter Start Year:" default answer "" with icon note buttons {"Continue", "Cancel"} default button "Continue")
		set eYear to text returned of (display dialog "Enter Start Year:" default answer "" with icon note buttons {"Continue", "Cancel"} default button "Continue")
		
		set mySmartName to ((monthName) & " of " & (sYear as string) & " to " & (eYear as string))
		
		set sYear to sYear as integer
		set eYear to eYear as integer
		
		set mySmartRule to my createSmartRule(sYear, eYear, searchMonth)
		tell front document
			make new collection with properties {name:mySmartName, kind:smart album, rules:mySmartRule}
		end tell
		
	end tell
	
end run

on createSmartRule(sYear, eYear, searchMonth)
	
	if searchMonth > 0 and searchMonth < 10 then set searchMonth to "0" & (searchMonth as string)
	if searchMonth > 9 and searchMonth < 13 then set searchMonth to (searchMonth as string)
	
	set searchPrefix to "<?xml version=\"1.0\" encoding=\"UTF-8\"?><MatchOperator Kind=\"AND\"><MatchOperator Kind=\"OR\">"
	set searchCriteria to ""
	repeat with thisYear from sYear to eYear
		set searchCriteria to searchCriteria & "<Condition Enabled=\"YES\"><Key>_date_yearMonth</Key><Operator>0</Operator><Criterion>" & (thisYear as string) & "-" & searchMonth & "</Criterion></Condition>"
	end repeat
	set searchPostfix to "</MatchOperator></MatchOperator>"
	set smartRule to searchPrefix & searchCriteria & searchPostfix
	
	return smartRule
	
end createSmartRule