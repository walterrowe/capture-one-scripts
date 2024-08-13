(*
  Script: apply-monochrome-keywords
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

use AppleScript version "2.8"
use scripting additions

property appNames : {"Apply Monochrome Keywords", "Remove Monochrome Keywords"}
property appType : ".scpt"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property bwKeywords : {"Black & White", "Monochrome"}

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
	
	set requiresDoc to false
	if class of requiresCOdocument is string then set requiresDoc to true
	if class of requiresCOdocument is boolean and requiresCOdocument then set requiresDoc to true
	
	if requiresCOrunning then
		
		tell application "Capture One" to set isRunning to running
		if not isRunning then
			display alert "Alert" message "Capture One must be running." buttons {"Quit"}
			set requirementsMet to false
		end if
		
		if requiresDoc and requirementsMet then
			tell application "Capture One" to set documentOpen to exists current document
			if not documentOpen then
				display alert appBase message "A Capture One Session or Catalog must be open." buttons {"Quit"}
				set requirementsMet to false
			end if
			
			if class of requiresCOdocument is string then
				tell application "Capture One"
					tell current document
						if kind is catalog then set docKind to "catalog"
						if kind is session then set docKind to "session"
					end tell
				end tell
				if docKind is not requiresCOdocument then
					display alert appBase message "You must be working in a Capture One " & requiresCOdocument & "." buttons {"Quit"}
					set requirementsMet to false
				end if
			end if
		end if
	end if
	
	return requirementsMet
	
end meetsRequirements
