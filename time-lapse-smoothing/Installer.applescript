(*
	AUTHOR

	Author: Walter Rowe
	Contact: walter@walterrowe.com

	Created: 20 Jan 2025
	Updated: 20 Jan 2025

	1. Set installNames
	2. Develop code
	3. Provide app icon (optional, set installIcon to true)
	4. Test code in Script Editor
	5. Change appTesting to false
	6. Test code in Capture One

	DESCRIPTION

	Timelapse Smoothing smooths the exposure and white balance of a time lapse
	sequence of images taken over a period of time where the ambient light is
	increasing (sunrise) or decreasing (sunset) and the photographer has stepped
	the exposure in batches across the entire sequence.
	
	If the photographer took a 300-image time lapse sequence and increased or
	decreased the exposure time by 1/3rd of a stop every 10 frames, there would
	be 30 batches of 10 images. Each frame in a batch would have the same exposure.
	Successive batches change exposure. The last frame of one batch and the first
	frame of the next batch will exhibit a dramatic change in appearance (lighter or
	darker). This script adjusts exposure of each frame in each batch to compensate
	for this jump or drop.
	
	As the sun rises or sets the white balance also changes. This script also adjusts
	the temperature of the white balance over the entire time lapse sequence to smooth
	out the WB. The photographer must set the WB of the first and last frame in the
	whole time lapse sequence. We then calculate the difference between the first
	and last frame's Kelvin temperature and divide it the number of frames in the
	whole sequence to determine how much to step each frame in the sequence.
	
	The result of this script is smoothed out exposure and white balance for a time
	lapse sequence.

	PREREQUISITES

	None
*)

property version : "1.0"

use AppleScript version "2.8"
use scripting additions

property libraryFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property installNames : {"Time Lapse Smoothing"}
property installType : ".scpt" -- ".scpt" for script, ".app" for script app
property installIcon : false -- if true must have a droplet.icns icon file in the source folder and ".app" installType

property requiresCOrunning : true -- true if capture one is required to be running
property requiresCOdocument : true -- true, false, "catalog", "session"

property appTesting : true -- if true, run in script editor, and if false install the script

-- application specific properties below

property shutterSpeedIncrements : {-1.0, -0.67, -0.5, -0.3, 0.3, 0.5, 0.67, 1.0}

-- application specific properties above

##
## use this to handle typical running from Capture One Scripts menu
##

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
	
	-- if app testing and we have multiple install names choose what action to perform
	if appTesting is true then
		if (count of installNames) > 1 then
			set appName to choose from list installNames with prompt "Choose Target Layer To Sync"
			if appName is false then return
			set appName to first item of appName
		else
			set appName to item 1 of installNames
		end if
	end if
	
	-- verify Capture One is running and has a document open
	set readyToRun to myLibrary's meetsRequirements(appName, requiresCOrunning, requiresCOdocument)
	if not readyToRun then return
	
	-- get path to Capture One's app icon
	set coIcon to path to resource "AppIcon.icns" in bundle (path to application "Capture One")
	
	-- ensure we have permission to interact with other apps
	myLibrary's activateUIScripting()
	
	-- application code goes below here
	
	tell application "Capture One"
		set docKind to myLibrary's getCOtype(current document)
		tell current document to set docName to name
		tell current document to set docPath to POSIX path of (path as alias) as string
		
		# set start time
		set startTime to current date
		
		# get time lapse sequence
		set timeLapseList to (get selected variants)
		set sequenceLength to (count of timeLapseList)
		if sequenceLength is 2 then
			set alertTitle to appName & " ERROR"
			set alertMessage to "You have selected " & sequenceLength & " variants." & return & "This is not enough variants for time lapse smoothing."
			set alertResult to (display alert alertTitle message alertMessage buttons {"OK"} giving up after 20)
			return
		end if
		
		
		# get first/last item, sequence length
		set firstVariant to first item of timeLapseList
		set lastVariant to last item of timeLapseList
		
		# get WB temperature range from first and last variant
		set tempStart to temperature of adjustments of firstVariant
		set tempEnd to temperature of adjustments of lastVariant
		
		# get difference in temperature of first and last frame
		set tempRange to tempEnd - tempStart
		
		# calculate WB temperature increment (divide temperature difference by total # of frames)
		# increment across one fewer than sequence length so last frame retains current WB temp
		set tempStep to tempRange / (sequenceLength - 1)
		
		# estimate the exposure set size by looking for shutter speed change
		set firstShutterSpeed to EXIF shutter speed of (parent image of firstVariant)
		repeat with frameSet from 1 to sequenceLength
			if EXIF shutter speed of parent image of (item frameSet of timeLapseList) is not firstShutterSpeed then exit repeat
		end repeat
		set frameSet to frameSet - 1
		
		# get confirmation of exposure set size (N frames per exposure)
		set frameSet to (text returned of (display dialog "Confirm the # of frames per incremental exposure set in your time lapse sequence:" default answer frameSet with icon coIcon buttons {"Continue", "Cancel"} default button "Continue")) as integer
		
		# if the user pressed cancel then exit
		if frameSet is false then return
		
		# ensure exposure set size evenly divides into number of frames of time lapse sequence
		if (sequenceLength mod frameSet) is not 0 then
			set alertTitle to appName & " ERROR"
			set alertMessage to "Your time lapse sequence of " & sequenceLength & " frames is not a multiple of your batch set (" & frameSet & ")."
			set alertResult to (display alert alertTitle message alertMessage buttons {"OK"} giving up after 20)
			return
		end if
		
		# get exposure increment per batch set
		set exposureStep to (choose from list shutterSpeedIncrements)
		
		# if the user pressed cancel then exit
		if exposureStep is false then return
		
		# calculate list exposure smoothing adjustments per sequence batch
		# if batch size is 10 and exposure step is 0.3, then increment is 0.3 Ö 10 (.03)
		# list would be { 0.27, 0.24, 0.21, 0.18, 0.15, 0.12, 0.09, 0.06, 0.03, 0.0 }
		# it is the same repeating pattern for each exposure set so calculate it one time
		set smoothingExpIncrement to (exposureStep / (frameSet as number)) as number
		
		# build list of exposure values per exposure set
		set smoothingExpIncrements to {}
		repeat with batchStep from (frameSet - 1) to 0 by -1
			set end of smoothingExpIncrements to batchStep * smoothingExpIncrement
		end repeat
		
		# loop through time lapse sequence smoothing white balance temp and exposure
		repeat with timeLapseCount from 1 to sequenceLength by frameSet
			repeat with batchFrame from 1 to frameSet
				
				# calculate which frame # in the time lapse sequence
				set timeLapseFrame to timeLapseCount + (batchFrame - 1)
				
				# get the Capture One variant from the time lapse sequence
				set thisFrame to item timeLapseFrame of timeLapseList
				
				# calculate the smoothing white balance temperature for this frame
				set thisTemp to tempStart + (tempStep * (timeLapseFrame - 1))
				
				# apply the smoothing white balance temperature to this variant
				set temperature of adjustments of thisFrame to thisTemp
				
				# set smoothing exposure starting with second frame set
				if timeLapseFrame > frameSet then
					set exposure of adjustments of thisFrame to item batchFrame of smoothingExpIncrements
				end if
				
			end repeat -- batch loop
		end repeat -- time lapse loop
		
	end tell
	
	# calculate the time it took to smooth the sequence
	set timeTaken to ((current date) - startTime)
	set timeTaken to ((timeTaken / 60 as integer) as string) & ":" & (text -1 thru -2 of ("0" & (timeTaken mod 60 as integer) as string))
	
	# craft the final alert message that we are done
	set alertMessage to "Elapsed Time: " & timeTaken & " (mm:ss)" & return & return & "Time Lapse: " & sequenceLength & " frames."
	
	-- application code goes above here
	
	set alertTitle to appName & " Finished"
	
	set alertResult to (display alert alertTitle message alertMessage buttons {"OK"} giving up after 10)
	
end run

##
## use this to handle scripts that accept drag-n-drop
##

# on open droppedItems
# end open

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
