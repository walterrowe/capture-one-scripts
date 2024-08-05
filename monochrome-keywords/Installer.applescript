(*
  Script: remove-monochrome-keywords
  Author: Walter Rowe
  Create: July 2020
  Update: April 2023

  Apply or Remove a list of monochrome-oriented keywords from images that do not meet monochrome criteria.

  Monochrome criteria:

  * black and white is enabled
  --OR--
  * saturation is -100.0

  When the script is completed, it will show a count of images updated in the results window.

*)

property appNames : {"Apply Monochrome Keywords", "Remove Monochrome Keywords"}
property appType : ".scpt"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"
property bwKeywords : {"Black & White", "Monochrome"}

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
		set alertResult to (display alert "Installation Complete" buttons {"OK"} default button "OK")
		return
	end if
	
	set updateCount to 0
	
	tell application "Capture One"
		
		if appBase starts with "Apply" then
			-- get list of variants with black & white enabled or background saturation set to -100
			set monoVariants to (get variants where ((black and white of adjustments is true) or (saturation of adjustments is -100.0)))
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
				set updateCount to (count of monoVariants)
			end if
		end if
		
		if appBase starts with "Remove" then
			repeat with thisKeyword in bwKeywords
				set monoVariants to (variants where (thisKeyword is in name of keywords) and (saturation of adjustments is not -100.0) and (black and white of adjustments is false))
				repeat with thisVariant in monoVariants
					delete (every keyword of thisVariant whose name is thisKeyword)
				end repeat
				set updateCount to updateCount + (count of monoVariants)
			end repeat
		end if
		
	end tell
	
	display alert appBase message (updateCount as string) & " images updated."
	
end run