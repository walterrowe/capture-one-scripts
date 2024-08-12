-- select image (backgreound) layer of selected variants
use AppleScript version "2.8"
use scripting additions


property appNames : {"Select Image Layer"}
property appType : ".scpt"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property appTesting : false
property requiresCOrunning : true
property requiresCOdocument : true

on run
	
	-- do install if not running under app name
	set appBase to my name as string
	set pathToMe to path to me
	if appNames does not contain appBase and not appTesting then
		installMe(appBase, pathToMe, installFolder, appType, appNames)
		return
	end if

	-- verify Capture One is running and has a document open
	if not meetsRequirements(appBase, requiresCOrunning, requiresCOdocument) then return
	
	-- get path to Capture One's app icon
	set coIcon to path to resource "AppIcon.icns" in bundle (path to application "Capture One")
	
	tell application "Capture One"
		set selVarList to get selected variants
		if (count of selVarList) is 0 then set selVarList to all variants
		repeat with thisVariant in selVarList
			tell thisVariant to set current layer to first layer
		end repeat
	end tell
	
end run

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

on meetsRequirements(appBase, requiresCOrunning, requiresCOdocument)
	set requirementsMet to true
	
	if requiresCOrunning then
		
		tell application "Capture One" to set isRunning to running
		if not isRunning then
			display alert "Alert" message "Capture One must be running." buttons {"Quit"}
			set requirementsMet to false
		end if
		
		if requiresCOdocument then
			tell application "Capture One" to set documentOpen to exists current document
			if not documentOpen then
				display alert appBase message "A Capture One Session or Catalog must be open." buttons {"Quit"}
				set requirementsMet to false
			end if
		end if
		
	end if
	
	return requirementsMet
	
end meetsRequirements