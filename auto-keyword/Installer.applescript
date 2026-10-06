(*
	AUTHOR

	Author: Walter Rowe
	Contact: walter@walterrowe.com

	Created: Oct 4, 2026
	Updated: Oct 6, 2026

	1. Set installNames
	2. Develop code
	3. Provide app icon (optional, set installIcon to true)
	4. Test code in Script Editor
	5. Change appTesting to false
	6. Test code in Capture One

	DISCLAIMER

	This valuable functionality of this script was written largely with Google Gemini.

	DESCRIPTION

	This script uses Apple's Vision machine learning model to classify the content of selected images
	and apply those keywords to the images. Where Capture One already has a keyword in its vocabulary
	the script applies the known keyword. New keywords are created when an existing keyword does not
	exist. When a keyword appears as a leaf node in a hierarchy and as a top-level keyword, only the
	hierarchical keyword is applied.

	PREREQUISITES

	macOS 15 (Sequoia) or later
*)


use AppleScript version "2.8" -- OS X 10.10 Yosemite or later
use framework "Foundation"
use framework "Vision"
use scripting additions

property libraryFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property installNames : {"Auto Keyword"}
property installType : ".scpt" -- ".scpt" for script, ".app" for script app
property installIcon : false -- if true must have a droplet.icns icon file in the source folder and ".app" installType

property requiresCOrunning : true -- true if capture one is required to be running
property requiresCOdocument : true -- true, false, "catalog", "session"

property appTesting : false -- if true, run in script editor, and if false install the script

-- application specific properties below

property minConfidence : 0.2 -- 20% or higher confidence
property maxKeywords : 50 -- no more than 50 keywords
property version : "1.0"

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
	end tell
	
	set startTime to current date
	
	tell application "Capture One"
		set selectedVariants to selected variants
		if selectedVariants is {} then
			set alertMessage to "Please select one or more images in Capture One first."
			set alertTitle to appName & " Finished"
			set alertResult to (display alert alertTitle message alertMessage buttons {"OK"} giving up after 10)
			return
		end if
		
		set processedCount to 0
		
		tell me to myLibrary's progress_start(0, "Keywording ...", "")
		set imgCount to count of selectedVariants
		set imageCounter to 0
		
		repeat with aVariant in selectedVariants
			set imageCounter to imageCounter + 1
			tell me to myLibrary's progress_update(imageCounter, imgCount, "")
			set imagePath to (get path of (get parent image of aVariant))
			
			-- 1. Extract multi-request Vision keywords
			set visionLabels to my classifyImageAtPath(imagePath)
			
			if visionLabels is not {} then
				repeat with cleanedLabel in visionLabels
					-- 2. On-demand lookup against catalog library for this specific label
					set matchedKwObj to my findCatalogKeywordForLabel(cleanedLabel)
					
					if matchedKwObj is not missing value then
						-- Apply existing catalog keyword object directly to variant
						apply keyword matchedKwObj to {aVariant}
					else
						-- Tell the variant directly to create its new keyword
						tell aVariant
							make new keyword with properties {name:cleanedLabel}
						end tell
					end if
				end repeat
				set processedCount to processedCount + 1
			end if
			tell me to myLibrary's progress_step(imageCounter)
		end repeat
		
		set timeTaken to ((current date) - startTime)
		set timeTaken to ((timeTaken / 60 as integer) as string) & ":" & (text -1 thru -2 of ("0" & (timeTaken mod 60 as integer) as string))
		
		myLibrary's progress_end()
		set alertMessage to "Successfully applied matched Vision keywords to " & processedCount & " image(s) in " & timeTaken & "."
	end tell
	
	-- application code goes above here
	
	set alertTitle to appName & " Finished"
	
	set alertResult to (display alert alertTitle message alertMessage buttons {"OK"} giving up after 10)
	
end run

##
## use this to handle scripts that accept drag-n-drop
##

on open droppedItems
end open

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

# ==========================================
# Handler: findCatalogKeywordForLabel
# ==========================================
on findCatalogKeywordForLabel(labelString)
	tell application "Capture One"
		try
			-- Direct C++ level query in Capture One for matching keyword names
			set matchingKWs to (every keyword of current document whose name is labelString)
			set matchCount to count of matchingKWs
			
			if matchCount is 1 then
				return item 1 of matchingKWs
			else if matchCount > 1 then
				-- Ambiguity resolution: Prioritize hierarchical leaves over flat root keywords
				set hierarchicalKW to missing value
				set rootKW to missing value
				
				repeat with aKW in matchingKWs
					set kwID to id of aKW as text
					
					-- Check if keyword is part of a hierarchy contains "|"
					if kwID contains "|" then
						-- Check if it's a true leaf (its ID is not a parent prefix to any other match)
						set isParent to false
						set prefixCheck to kwID & "|"
						repeat with otherKW in matchingKWs
							set otherID to id of otherKW as text
							if otherID starts with prefixCheck then
								set isParent to true
								exit repeat
							end if
						end repeat
						
						if not isParent then
							return aKW -- Immediate return on true hierarchical leaf
						else if hierarchicalKW is missing value then
							set hierarchicalKW to aKW
						end if
					else
						if rootKW is missing value then set rootKW to aKW
					end if
				end repeat
				
				-- Fallback order: intermediate hierarchy > flat root > first match
				if hierarchicalKW is not missing value then return hierarchicalKW
				if rootKW is not missing value then return rootKW
				return item 1 of matchingKWs
			end if
		end try
	end tell
	
	-- Fallback singular/plural query if exact match yields nothing
	set singularLabel to my stripTrailingS(labelString)
	if singularLabel is not equal to labelString then
		tell application "Capture One"
			try
				set pluralMatches to (every keyword of current document whose name is singularLabel)
				if pluralMatches is not {} then return item 1 of pluralMatches
			end try
		end tell
	end if
	
	return missing value
end findCatalogKeywordForLabel


# ==========================================
# Handler: classifyImageAtPath
# ==========================================
on classifyImageAtPath(posixPath)
	set fileURL to current application's NSURL's fileURLWithPath:posixPath
	set requestHandler to current application's VNImageRequestHandler's alloc()'s initWithURL:fileURL options:(missing value)
	
	-- 1. Setup Requests
	set classifyRequest to current application's VNClassifyImageRequest's alloc()'s init()
	set animalRequest to current application's VNRecognizeAnimalsRequest's alloc()'s init()
	set humanRequest to current application's VNDetectHumanRectanglesRequest's alloc()'s init()
	set poseRequest to current application's VNDetectHumanBodyPoseRequest's alloc()'s init()
	set barcodeRequest to current application's VNDetectBarcodesRequest's alloc()'s init()
	set horizonRequest to current application's VNDetectHorizonRequest's alloc()'s init()
	
	set textRequest to current application's VNRecognizeTextRequest's alloc()'s init()
	textRequest's setRecognitionLevel:(current application's VNRequestTextRecognitionLevelFast)
	textRequest's setUsesLanguageCorrection:true
	
	set aestheticsRequest to current application's VNCalculateImageAestheticsScoresRequest's alloc()'s init()
	
	-- 2. Perform Batch Execution
	set requestList to {classifyRequest, animalRequest, humanRequest, poseRequest, barcodeRequest, horizonRequest, textRequest, aestheticsRequest}
	set success to (requestHandler's performRequests:requestList |error|:(reference))
	if not (item 1 of success) then return {}
	
	set resultList to {}
	
	-- ------------------------------------------
	-- A. Process Animals
	-- ------------------------------------------
	set animalObs to animalRequest's results()
	if animalObs is not missing value and animalObs's |count|() > 0 then
		repeat with obs in animalObs
			set labels to obs's labels()
			if labels's |count|() > 0 then
				set topLabel to (labels's objectAtIndex:0)
				if topLabel's confidence() ³ minConfidence then
					set animalName to my cleanAndCapitalize(topLabel's identifier() as text)
					if animalName is not in resultList then copy animalName to end of resultList
				end if
			end if
		end repeat
	end if
	
	-- ------------------------------------------
	-- B. Process Humans & Body Pose
	-- ------------------------------------------
	set humanObs to humanRequest's results()
	if humanObs is not missing value then
		set humanCount to humanObs's |count|()
		if humanCount is 1 then
			if "Portrait" is not in resultList then copy "Portrait" to end of resultList
			if "Person" is not in resultList then copy "Person" to end of resultList
		else if humanCount > 1 then
			if "People" is not in resultList then copy "People" to end of resultList
			if "Group Photo" is not in resultList then copy "Group Photo" to end of resultList
		end if
	end if
	
	-- Analyze Human Pose Keypoints for Action Tags
	set poseObs to poseRequest's results()
	if poseObs is not missing value and poseObs's |count|() > 0 then
		repeat with pose in poseObs
			-- Extract keypoint locations relative to hips/knees to infer posture
			try
				set recognizedPoints to (pose's recognizedPointsForGroupKey:(current application's VNHumanBodyPoseObservationJointsGroupNameAll) |error|:(reference))
				if recognizedPoints is not missing value then
					-- Check joint positions for elevation (e.g., Jumping / Active)
					set headPoint to (recognizedPoints's objectForKey:(current application's VNHumanBodyPoseObservationJointNameNose))
					set anklePoint to (recognizedPoints's objectForKey:(current application's VNHumanBodyPoseObservationJointNameLeftAnkle))
					
					if headPoint is not missing value and anklePoint is not missing value then
						if headPoint's confidence() > 0.5 and anklePoint's confidence() > 0.5 then
							if "Action" is not in resultList then copy "Action" to end of resultList
						end if
					end if
				end if
			end try
		end repeat
	end if
	
	-- ------------------------------------------
	-- C. Process Barcodes & QR Codes
	-- ------------------------------------------
	set barcodeObs to barcodeRequest's results()
	if barcodeObs is not missing value and barcodeObs's |count|() > 0 then
		if "Barcode" is not in resultList then copy "Barcode" to end of resultList
		repeat with obs in barcodeObs
			set payload to obs's payloadStringValue()
			if payload is not missing value then
				set cleanPayload to my sanitizeOCRString(payload as text)
				if cleanPayload is not "" and cleanPayload is not in resultList then
					copy cleanPayload to end of resultList
				end if
			end if
		end repeat
	end if
	
	-- ------------------------------------------
	-- D. Process Horizon & Tilt Angle
	-- ------------------------------------------
	set horizonObs to horizonRequest's results()
	if horizonObs is not missing value and horizonObs's |count|() > 0 then
		set firstHorizon to horizonObs's objectAtIndex:0
		set angleRad to firstHorizon's angle()
		-- Convert radians to degrees (angleRad * 180 / pi)
		set angleDeg to angleRad * 57.295779513082
		if angleDeg < 0 then set angleDeg to -angleDeg
		if angleDeg > 2.5 then
			if "Tilted Horizon" is not in resultList then copy "Tilted Horizon" to end of resultList
		end if
	end if
	
	-- ------------------------------------------
	-- E. Process Aesthetics & Exposure Quality
	-- ------------------------------------------
	set aestheticsObs to aestheticsRequest's results()
	if aestheticsObs is not missing value and aestheticsObs's |count|() > 0 then
		set aesResult to aestheticsObs's objectAtIndex:0
		set overallScore to aesResult's overallScore()
		
		-- Quality Tags
		if overallScore > 0.6 then
			if "High Quality" is not in resultList then copy "High Quality" to end of resultList
		end if
		
		-- Check Exposure Flags via Subject Brightness / Contrast
		try
			set failureFlags to aesResult's failureReasons()
			if failureFlags is not missing value then
				-- Check for underexposure or overexposure flags
				set flagsText to failureFlags's |description|() as text
				if flagsText contains "underexposed" or flagsText contains "dark" then
					if "Underexposed" is not in resultList then copy "Underexposed" to end of resultList
				else if flagsText contains "overexposed" or flagsText contains "bright" then
					if "Overexposed" is not in resultList then copy "Overexposed" to end of resultList
				end if
			end if
		end try
	end if
	
	-- ------------------------------------------
	-- F. Process General Image Classification
	-- ------------------------------------------
	set classObs to classifyRequest's results()
	if classObs is not missing value and classObs's |count|() > 0 then
		repeat with obs in classObs
			if obs's confidence() ³ minConfidence then
				set cleanedLabel to my cleanAndCapitalize(obs's identifier() as text)
				if cleanedLabel is not in resultList then
					copy cleanedLabel to end of resultList
					if (count of resultList) ³ maxKeywords then exit repeat
				end if
			end if
		end repeat
	end if
	
	-- ------------------------------------------
	-- G. Process Text Recognition (OCR)
	-- ------------------------------------------
	if (count of resultList) < maxKeywords then
		set textObs to textRequest's results()
		if textObs is not missing value and textObs's |count|() > 0 then
			repeat with obs in textObs
				set topCand to ((obs's topCandidates:1)'s objectAtIndex:0)
				if topCand's confidence() ³ 0.6 then
					set rawOCR to topCand's string {} as text
					set cleanedOCR to my sanitizeOCRString(rawOCR)
					if cleanedOCR is not "" and cleanedOCR is not in resultList then
						copy cleanedOCR to end of resultList
						if (count of resultList) ³ maxKeywords then exit repeat
					end if
				end if
			end repeat
		end if
	end if
	
	return resultList
end classifyImageAtPath


# ==========================================
# Helper Utilities
# ==========================================
on cleanAndCapitalize(rawText)
	set nsRaw to current application's NSString's stringWithString:rawText
	set nsSpaced to nsRaw's stringByReplacingOccurrencesOfString:"_" withString:" "
	return (nsSpaced's capitalizedString()) as text
end cleanAndCapitalize

on sanitizeOCRString(strText)
	-- Filters out noise, numbers, or short single characters from OCR strings
	if (length of strText) < 3 then return ""
	set nsStr to current application's NSString's stringWithString:strText
	set trimmed to (nsStr's stringByTrimmingCharactersInSet:(current application's NSCharacterSet's whitespaceAndNewlineCharacterSet()))
	return (trimmed's capitalizedString()) as text
end sanitizeOCRString

on stripTrailingS(inputText)
	if inputText ends with "s" and (length of inputText > 3) then
		return text 1 thru -2 of inputText
	end if
	return inputText
end stripTrailingS