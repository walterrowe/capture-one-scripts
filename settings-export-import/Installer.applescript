(*

	export-import-settings

	author: walter rowe walter.rowe@gmail.com
	create: 13 december 2023
	update: 15 january 2024
	
	This script creates or restores a ZIP of the transportable parts of these folders under ~/Library related to Capture One

		- Application Support/Capture One
		- Scripts/Capture One Scripts

	When restoring you must restart Capture One afterward for the app to see the restored settings.

*)

use AppleScript version "2.8"
use scripting additions

property appNames : {"Settings Export", "Settings Import"}
property appType : ".scpt"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property appIcon : false
property appTesting : false
property requiresCOrunning : true
property requiresCOdocument : false

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
	
	set whereAmI to quoted form of POSIX path of pathToMe
	
	set settingsRoot to "~/Library/"
	set settingsFolders to "Application\\ Support/Capture\\ One/ Scripts/Capture\\ One\\ Scripts/"
	set settingsBackup to POSIX path of (path to desktop) & "CaptureOneSettings.zip"
	set settingsExclude to "-x '**Batch**' '**CaptureCore**' '**Diagnostics**' '**[Ee]rror**' '**IPCamera**' '**Plug-ins**' '**Sync**' '**/.DS_Store' '**Disabled**'"
	
	-- if we are running as the name "settings-export", create CaptureOneSettings.zip on the desktop	
	if appBase ends with "Export" then
		-- ask user to choose where to create the backup file
		set backupFolder to POSIX path of (choose folder with prompt "Select the folder place your backup file:" default location POSIX path of (path to desktop))
		set settingsBackup to POSIX path of backupFolder & "CaptureOneSettings.zip"
		
		-- command to export settings to desktop
		set exportCmd to "eval $(/usr/libexec/path_helper -s); cd " & settingsRoot & ";zip -r " & settingsBackup & " " & settingsFolders & " " & settingsExclude
		
		try
			do shell script exportCmd
		on error errStr number errorNumber
			display dialog "ERROR: " & appBase & ": " & errStr & ": " & (errorNumber as text) with icon coIcon
		end try
		display dialog "Exported settings to " & settingsBackup with icon coIcon
	end if
	
	-- if we are running as the name "settings-import", restore CaptureOneSettings.zip from the desktop
	if appBase ends with "Import" then
		-- ask user to choose the backup file to restore
		set settingsBackup to quoted form of POSIX path of (choose file with prompt "Select the settings backup file to restore" default location POSIX path of (path to desktop))
		
		-- command to import settings from desktop
		set importCmd to "eval $(/usr/libexec/path_helper -s); unzip -o -d " & settingsRoot & " " & settingsBackup
		try
			do shell script importCmd
		on error errStr number errorNumber
			display dialog "ERROR: " & appBase & ": " & errStr & ": " & (errorNumber as text) & " " & settingsBackup with icon coIcon
		end try
		display dialog "Imported settings from " & settingsBackup & ". Please restart Capture One." with icon coIcon
	end if
	
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