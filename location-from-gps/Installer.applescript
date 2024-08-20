(*
	AUTHOR

	Author: Walter Rowe
	Contact: walter@walterrowe.com

	Created: 06-APR-2023
	Updated: 20-AUG-2024

	DESCRIPTION

	This script looks for EXIF GPS latitude and longitude coordinates
	If present it uses Google Maps API to get real place location info

	* Populates the IPTC fields for City, State, Country, Country Code
	* Adds Hierarhical Keyword for Country > State/Province > County > City

	PREREQUISITES

	* JSON Helper installed
	* Google Maps API Key
*)

use AppleScript version "2.8"
use scripting additions

property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"
property libraryFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/"

property installNames : {"Location From GPS"}
property installType : ".scpt"
property installIcon : false -- if true must have a droplet.icns icon file in the source folder and ".app" installType

property requiresCOrunning : true -- true if capture one is required to be running
property requiresCOdocument : true -- true, false, "catalog", "session"

property appTesting : false -- if true, run in script editor, and if false install the script

-- application specific properties below

property mapsKey : "YOUR GOOGLE MAPS PROJECT API KEY"
property mapsURL : "https://maps.googleapis.com/maps/api/geocode/json?key=" & mapsKey & "&latlng="

-- application specific properties above

on run
	
	-- set required base variables
	set appName to my name
	set appPath to path to me
	
	-- make sure the CO script library is loaded
	set myLibrary to loadLibrary(appName)
	if myLibrary is missing value then return
	
	-- do install if not running under app name
	if installNames does not contain appName and not appTesting then
		myLibrary's installMe(appName, appPath, installFolder, installType, installNames, installIcon)
		return
	end if
	
	-- verify Capture One is running and has a document open
	set readyToRun to myLibrary's meetsRequirements(appName, requiresCOrunning, requiresCOdocument)
	if not readyToRun then return
	
	-- get path to Capture One's app icon
	set coIcon to path to resource "AppIcon.icns" in bundle (path to application "Capture One")
	
	-- ensure we have permission to interact with other apps
	myLibrary's activateUIScripting()
	
	-- make sure there is a maps API key
	if mapsKey starts with "YOUR" then
		display alert appBase message "You need to provide a Google Maps API Key before installing the script. Look for this text in the Installer.applescript and replace it with your key." & return & return & mapsKey & return
		return
	end if
	
	tell application "Capture One"
		set startTime to current date
		set imageSel to get selected variants
		set noGPS to {}
		
		tell me to myLibrary's progress_start(0, "Processing ...", "scanning")
		set imgCount to count of imageSel
		
		repeat with i from 1 to imgCount
			tell me to myLibrary's progress_update(i, imgCount, "")
			set thisVariant to item i of imageSel
			
			if (latitude of thisVariant is missing value) or (longitude of thisVariant is missing value) then
				set end of noGPS to name of parent image of thisVariant
			else
				
				set lat to my myLibrary's replace(((latitude of thisVariant as real) as string), "/,/", ".")
				set lon to my myLibrary's replace(((longitude of thisVariant as real) as string), "/,/", ".")
				set gpsFetch to (mapsURL & lat & "," & lon) as string
				
				-- if testing display the URL with longitude and latitude to debug
				-- if appTesting then display dialog gpsFetch buttons {"OK"}
				
				tell application "JSON Helper"
					try
						set gpsResult to (fetch JSON from gpsFetch)
					on error
						tell me to set alertResult to (display alert appBase message "Unable to get Google Maps information." buttons {"Exit"})
						return
					end try
					
					if gpsResult is "" or results of gpsResult is {} then
						tell me to set alertResult to (display alert appBase message "Unable to get Google Maps information." buttons {"Exit"})
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
			tell me to myLibrary's progress_step(i)
			
		end repeat
		
		tell me to myLibrary's progress_end()
		
		tell me to set noGPScount to ((count of noGPS) as string)
		tell me to set timeTaken to ((current date) - startTime)
		set timeTaken to ((timeTaken / 60 as integer) as string) & ":" & (text -1 thru -2 of ("0" & (timeTaken mod 60 as integer) as string))
		tell me to set imgsUpdated to imgCount - noGPScount
		
		set alertResult to (display alert appName message "Updated " & imgsUpdated & " images in " & timeTaken & " (mm:ss)." & return & return & "There were " & noGPScount & " images with no GPS data." buttons {"Exit"} giving up after 10)
		
	end tell
end run


##
## download and install the latest CO script library
##

on loadLibrary(appName as string)
	
	set myLibrary to libraryFolder & "COscriptlibrary.scpt"
	
	tell application "Finder"
		set libraryDownload to "curl -s -f https://raw.githubusercontent.com/walterrowe/capture-one-scripts/master/library/COscriptlibrary.applescript -o COscriptlibrary.applescript --output-dir " & libraryFolder
		set libraryCompile to "osacompile -x -o " & (quoted form of myLibrary) & " " & libraryFolder & "COscriptlibrary.applescript"
		try
			do shell script libraryDownload
			do shell script libraryCompile
		on error errorText
			-- failed to download and compile the latest library
			-- if we have a copy of the library installed then use it
			try
				exists (POSIX file myLibrary as alias)
			on error
				set myLibrary to POSIX path of myLibrary
				set alertResult to (display alert appName message "Unable to download and compile script library " & myLibrary & return & return & libraryDownload & return & return & libraryCompile & return & return & errorText buttons {"Quit"} giving up after 30)
				return missing value
			end try
		end try
	end tell
	
	try
		set myLibrary to load script myLibrary
		return myLibrary
	on error
		set myLibrary to POSIX path of myLibrary
		set alertResult to (display alert appName message "Unable to load script library " & myLibrary buttons {"Quit"} giving up after 30)
		return missing value
	end try
	
end loadLibrary
