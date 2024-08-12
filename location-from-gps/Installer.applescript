--
-- this script looks for EXIF GPS latitude and longitude coordinates
-- if present it uses Google Maps API to get real place location info
--
--   * it populate the IPTC state, city, country, country code
--   * it adds hierarhial keywords country > state > county > city
--
-- requirements: json helper, google maps api key
--
-- author: walter rowe
-- create: 06-april-2023
--

use AppleScript version "2.8"
use scripting additions

property appNames : {"Location From GPS"}
property appType : ".scpt"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property appTesting : false
property requiresCOrunning : true
property requiresCOdocument : true

property mapApiKey : "YOUR GOOGLE MAPS PROJECT API KEY"

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
	
	tell application "Capture One"
		set startTime to current date
		set imageSel to get selected variants
		set noGPS to {}
		
		tell me to progress_start(0, "Processing ...", "scanning")
		set imgCount to count of imageSel
		
		repeat with i from 1 to imgCount
			tell me to progress_update(i, imgCount, "")
			set thisVariant to item i of imageSel
			
			if (latitude of thisVariant is missing value) or (longitude of thisVariant is missing value) then
				set noGPS to noGPS & {name of parent image of thisVariant}
			else
				set lat to latitude of thisVariant as real
				set lon to longitude of thisVariant as real
				tell application "JSON Helper"
					set gpsResult to (fetch JSON from ("https://maps.googleapis.com/maps/api/geocode/json?latlng=" & lat & "," & lon & "&key=" & mapApiKey))
					if results of gpsResult is {} then
						tell me to set alertResult to (display alert appBase message gpsResult buttons {"Exit"})
						return
					else
						
						set address_components to get address_components of item 1 of results of gpsResult
						
						-- making a list (Array) of address component names
						set imgCity to ""
						set imgCounty to ""
						set imgState to ""
						set imgCountry to ""
						set gotGPS to false
						repeat with j from 1 to count of address_components
							-- get location components
							set addressInfo to get item j of address_components
							if item 1 of |types| of addressInfo is in {"locality", "administrative_area_level_2", "administrative_area_level_1", "country"} then
								set gotGPS to true
								if item 1 of |types| of addressInfo is "locality" then
									tell application "Capture One" to set image city of thisVariant to long_name of addressInfo
									set imgCity to long_name of addressInfo
								end if
								if item 1 of |types| of addressInfo is "administrative_area_level_2" then
									set imgCounty to long_name of addressInfo
								end if
								if item 1 of |types| of addressInfo is "administrative_area_level_1" then
									tell application "Capture One" to set image state of thisVariant to long_name of addressInfo
									set imgState to long_name of addressInfo
								end if
								if item 1 of |types| of addressInfo is "country" then
									tell application "Capture One" to set image country of thisVariant to long_name of addressInfo
									tell application "Capture One" to set image country code of thisVariant to short_name of addressInfo
									set imgCountry to long_name of addressInfo
								end if
							end if
						end repeat
					end if
				end tell
				
				if gotGPS is true then
					tell thisVariant to make keyword with properties {name:imgCity, parent:imgCountry & "|" & imgState & "|" & imgCounty}
				end if
				
			end if
			tell me to progress_step(i)
			
		end repeat
		
		tell me to progress_end()
		
		tell me to set noGPScount to ((count of noGPS) as string)
		tell me to set timeTaken to ((current date) - startTime)
		set timeTaken to ((timeTaken / 60 as integer) as string) & ":" & (text -1 thru -2 of ("0" & (timeTaken mod 60 as integer) as string))
		tell me to set imgsUpdated to imgCount - noGPScount
		
		set alertResult to (display alert appBase message "Updated " & imgsUpdated & " images in " & timeTaken & " (mm:ss)." & return & return & "There were " & noGPScount & " images with no GPS data." buttons {"Exit"} giving up after 10)
		
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

