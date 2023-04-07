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


property mapApiKey : "YOUR GOOGLE MAPS API KEY"

on run
	tell application "Capture One 23"
		set startTime to current date
		set imageSel to get variants where selected is true
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
					set reverse_geocode_request to fetch JSON from ("https://maps.googleapis.com/maps/api/geocode/json?latlng=" & lat & "," & lon & "&key=" & mapApiKey)
					set address_components to get address_components of item 1 of results of reverse_geocode_request
					
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
								tell application "Capture One 23" to set image city of thisVariant to long_name of addressInfo
								set imgCity to long_name of addressInfo
							end if
							if item 1 of |types| of addressInfo is "administrative_area_level_2" then
								set imgCounty to long_name of addressInfo
							end if
							if item 1 of |types| of addressInfo is "administrative_area_level_1" then
								tell application "Capture One 23" to set image state of thisVariant to long_name of addressInfo
								set imgState to long_name of addressInfo
							end if
							if item 1 of |types| of addressInfo is "country" then
								tell application "Capture One 23" to set image country of thisVariant to long_name of addressInfo
								tell application "Capture One 23" to set image country code of thisVariant to short_name of addressInfo
								set imgCountry to long_name of addressInfo
							end if
						end if
					end repeat
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
		
		display dialog "Updated " & imgsUpdated & " images in " & timeTaken & " (mm:ss).
There were " & noGPScount & " images with no GPS data." with title "Populate Location from GPS" buttons {"Okay"}
		
	end tell
end run

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

