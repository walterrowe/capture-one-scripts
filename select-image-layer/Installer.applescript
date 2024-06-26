-- select image (backgreound) layer of selected variants
use AppleScript version "2.4" -- Yosemite (10.10) or later 
use scripting additions


property appNames : {"Select Image Layer"}
property appType : ".scpt"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"


tell application "Capture One Beta"
	set appBase to my name as string
	
	if appNames does not contain appBase then
		repeat with appName in appNames
			set scriptSource to quoted form of POSIX path of (path to me)
			set scriptTarget to quoted form of (installFolder & appName & appType)
			display dialog scriptTarget
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
	
	set selVarList to get selected variants
	if (count of selVarList) is 0 then set selVarList to all variants
	repeat with thisVariant in selVarList
		tell thisVariant to set current layer to first layer
	end repeat
end tell
