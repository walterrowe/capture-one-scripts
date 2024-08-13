--
-- Apply Capture One color tags as color labels of corresponding files in macOS Finder
--
-- Author: Walter Rowe
-- Create: 12-August-2023
-- Updated: 05-August-2024
--

use AppleScript version "2.8"
use scripting additions

property appNames : {"Copy Labels To Finder"}
property appType : ".scpt"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"
property docType : "catalog" as string

property appIcon: false
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
	
	tell application "Capture One"
		set startTime to current date
		set imageSel to get selected variants
		
		if (count of imageSel) < 1 then
			set alertResult to (display alert "No Selection" message "No images are selected." buttons {"Stop"} default button "Stop" as critical giving up after 10)
			return
		end if
		
		set noLabels to {}
		tell me to progress_start(0, "Processing ...", "scanning")
		set imgCount to count of imageSel
		set imgsUpdated to 0
		repeat with i from 1 to imgCount
			tell me to progress_update(i, imgCount, "")
			set thisVariant to item i of imageSel
			set thisFile to file of parent image of thisVariant as alias
			set thisLabel to color tag of thisVariant
			-- map capture one color tags to macOS finder label indexes
			-- color CO-index Finder-index
			-- 
			-- None		0		0
			-- Red		1		2
			-- Orange	2		1
			-- Yellow		3		3
			-- Green		4		6
			-- Blue		5		4
			-- Pink		6		7 (CO pink maps to Finder gray)
			-- Purple		7		5
			--
			if thisLabel is 1 then
				set thisLabel to 2
			else if thisLabel is 2 then
				set thisLabel to 1
			else if thisLabel is 4 then
				set thisLabel to 6
			else if thisLabel is 5 then
				set thisLabel to 4
			else if thisLabel is 6 then
				set thisLabel to 7
			else if thisLabel is 7 then
				set thisLabel to 5
			end if
			
			tell application "Finder" to set label index of thisFile to thisLabel
			tell me to progress_step(i)
		end repeat
		
		tell me to progress_end()
		
		tell me to set noLabelsCount to ((count of noLabels) as string)
		tell me to set timeTaken to ((current date) - startTime)
		set timeTaken to ((timeTaken / 60 as integer) as string) & ":" & (text -1 thru -2 of ("0" & (timeTaken mod 60 as integer) as string))
		
		set alertResults to (display alert "Copy Labels to Finder Completed" message "Updated " & imgCount & " images in " & timeTaken & " (mm:ss)." buttons {"Okay"} as informational giving up after 10)
		
	end tell
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
		set scriptSource to quoted form of POSIX path of pathToMe
		set scriptTarget to quoted form of (installFolder & appName & appType)
		set installCommand to "osacompile -x -o " & scriptTarget & " " & scriptSource
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
		
		if requiresCOdocument and isRunning then
			tell application "Capture One" to set documentOpen to exists current document
			if not documentOpen then
				display alert appBase message "A Capture One Session or Catalog must be open." buttons {"Quit"}
				set requirementsMet to false
			end if
		end if
		
	end if
	
	return requirementsMet
	
end meetsRequirements

-- --------------------
-- FUNCTIONS
-- --------------------
-- The example above shows the raw method for implementing progress bars.
-- The functions below are convenience wrappers for the same code to keep
-- your overall code much cleaner and less repetitive.

-- Create the initial progress bar.
-- @param {int} 	 steps  			The number of steps for the process 
-- @param {string} descript		The initial text for the progress bar
-- @param {string} descript_add 	Additional text for the progress bar
-- @returns void
on progress_start(steps, descript, descript_add)
	set progress total steps to steps
	set progress completed steps to 0
	set progress description to descript
	set progress additional description to descript_add
end progress_start

-- Update the progress bar. This goes inside your loop.
-- @param {int} 	 n  			The current step number in the iteration
-- @param {int} 	 steps  		The number of steps for the process 
-- @param {string} message   The progress update message
-- @returns void
on progress_update(n, steps, message)
	set progress additional description to message & n & " of " & steps
end progress_update

-- Increment the step number of the progress bar.
-- @param {int} 	 n            The current step number in the iteration
-- @returns void
on progress_step(n)
	set progress completed steps to n
end progress_step

-- Clear the progress bar values
-- @returns void
on progress_end()
	-- Reset the progress information
	set progress total steps to 0
	set progress completed steps to 0
	set progress description to ""
	set progress additional description to ""
end progress_end

