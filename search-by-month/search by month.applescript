use AppleScript version "2.7"
use scripting additions

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