-- set the color label to blue for every variant with an empty iptc title
-- Author: Eric Nepean (@ericnepean in Capture One Forums)

property appNames : {"Label Untitled Variants"}
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


tell application "Capture One Beta" to tell (every variant whose content headline is "") to set color tag to 5

end run