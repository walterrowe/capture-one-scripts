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

use AppleScript version "2.7"
use scripting additions

property exportBase : "settings-export"
property importBase : "settings-import"
property installFolder : "~/Library/Scripts/Capture\\ One\\ Scripts/"
property installType : ".scpt"
property appNames : {importBase, exportBase}
property exportimport : "export-import-settings"

on run
	set pathToMe to path to me
	set whereAmI to quoted form of POSIX path of pathToMe
	
	set settingsRoot to "~/Library/"
	set settingsFolders to "Application\\ Support/Capture\\ One/ Scripts/Capture\\ One\\ Scripts/"
	set settingsBackup to POSIX path of (path to desktop) & "CaptureOneSettings.zip"
	set settingsExclude to "-x '**Batch**' '**CaptureCore**' '**Diagnostics**' '**[Ee]rror**' '**IPCamera**' '**Plug-ins**' '**Sync**' '**/.DS_Store' '**Disabled**'"
	
	-- convert "path:to:me.scpt:" into "me" (script apps are folders so note the trailing colon thus the -2 below)
	set appPathList to splitText(pathToMe as string, ":")
	set appName to item -1 of appPathList
	if appName is "" then set appName to item -2 of appPathList
	set appBase to item 1 of splitText(appName, ".")
	
	-- if we are running as the name "export-import-settings", create scripts in Capture One scripts folder
	if appNames does not contain appBase then
		install_script(whereAmI, appNames, installFolder, installType)
		return
	end if
	
	-- if we are running as the name "settings-export", create CaptureOneSettings.zip on the desktop	
	if appBase is exportBase then
		-- ask user to choose where to create the backup file
		set backupFolder to POSIX path of (choose folder with prompt "Select the folder place your backup file:" default location POSIX path of (path to desktop))
		set settingsBackup to POSIX path of backupFolder & "CaptureOneSettings.zip"
		
		-- command to export settings to desktop
		set exportCmd to "eval $(/usr/libexec/path_helper -s); cd " & settingsRoot & ";zip -r " & settingsBackup & " " & settingsFolders & " " & settingsExclude
		
		try
			do shell script exportCmd
		on error errStr number errorNumber
			display dialog "ERROR: " & appBase & ": " & errStr & ": " & (errorNumber as text)
		end try
		display dialog "Exported settings to " & settingsBackup
	end if
	
	-- if we are running as the name "settings-import", restore CaptureOneSettings.zip from the desktop
	if appBase is importBase then
		-- ask user to choose the backup file to restore
		set settingsBackup to quoted form of POSIX path of (choose file with prompt "Select the settings backup file to restore" default location POSIX path of (path to desktop))
		
		-- command to import settings from desktop
		set importCmd to "eval $(/usr/libexec/path_helper -s); unzip -o -d " & settingsRoot & " " & settingsBackup
		try
			do shell script importCmd
		on error errStr number errorNumber
			display dialog "ERROR: " & appBase & ": " & errStr & ": " & (errorNumber as text) & " " & settingsBackup
		end try
		display dialog "Imported settings from " & settingsBackup & ". Please restart Capture One."
	end if
	
end run

-- comppile myself as a list of app names
on install_script(sourceScript, targetApps, appFolder, appType)
	
	repeat with scriptBase in targetApps
		set scriptPath to appFolder & (quoted form of scriptBase) & appType
		set installCommand to "osacompile -x -o " & scriptPath & " " & sourceScript
		
		-- execute the shell command to install export-settings.scpt
		try
			do shell script installCommand
		on error errStr number errorNumber
			display dialog "Install ERROR: " & errStr & ": " & (errorNumber as text) & "on file " & scriptBase
		end try
		-- display dialog "Installed " & scriptBase
	end repeat
	
end install_script

-- split a string based on a specific delimiter
on joinText(theText, theDelimiter)
	set AppleScript's text item delimiters to theDelimiter
	set theTextItems to every text item of theText as string
	set AppleScript's text item delimiters to ""
	return theTextItems
end joinText

-- split a string based on a specific delimiter
on splitText(theText, theDelimiter)
	set AppleScript's text item delimiters to theDelimiter
	set theTextItems to every text item of theText
	set AppleScript's text item delimiters to ""
	return theTextItems
end splitText
