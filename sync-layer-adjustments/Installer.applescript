(*
	AUTHOR

	Author: Walter Rowe
	Contact: walter@walterrowe.com

	Created: 25-Oct-2024
	Updated:

	1. Set installNames
	2. Develop code
	3. Provide app icon (optional, set installIcon to true)
	4. Test code in Script Editor
	5. Change appTesting to false
	6. Test code in Capture One

	DESCRIPTION

	Lets a user sync adjustments between two layers across selected variants, or sync a layer across
	images. Helpful in syncing adjustments to newer dynamic people masking layers. User can
	choose to set source layer as not enabled after adjustments are copied.

	PREREQUISITES

	None
*)

property version : "1.0"

use AppleScript version "2.8"
use scripting additions

property libraryFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property installNames : {"Sync Between Layers", "Sync Layer Across Images"}
property installType : ".scpt" -- ".scpt" for script, ".app" for script app
property installIcon : false -- if true must have a droplet.icns icon file in the source folder and ".app" installType

property requiresCOrunning : true -- true if capture one is required to be running
property requiresCOdocument : true -- true, false, "catalog", "session"

property appTesting : false -- if true, run in script editor, and if false install the script

-- application specific properties below -- properties are constants at compile time

-- application specific properties above -- properties are constants at compile time

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
	
	-- verify Capture One is running and has a document open
	set readyToRun to myLibrary's meetsRequirements(appName, requiresCOrunning, requiresCOdocument)
	if not readyToRun then return
	
	-- get path to Capture One's app icon
	set coIcon to path to resource "AppIcon.icns" in bundle (path to application "Capture One")
	
	-- ensure we have permission to interact with other apps
	myLibrary's activateUIScripting()
	
	tell application "Capture One"
		set docKind to myLibrary's getCOtype(current document)
		tell current document to set docName to name
		tell current document to set docPath to POSIX path of (path as alias) as string
	end tell
	
	-- application code goes below here
	
	-- Sync Adjustments Between Layers
	if appName is item 1 of installNames then
		set alertMessage to syncBetweenLayers(myLibrary, appName)
	end if
	
	-- Sync Layer Across Images
	if appName is item 2 of installNames then
		set alertMessage to syncLayerAcrossImages(myLibrary, appName)
	end if
	
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

on syncBetweenLayers(myLibrary, appName as text)
	
	tell application "Capture One"
		set layerNames to {}
		set theVariants to selected variants
		
		-- collect names of layers from all selected variants
		repeat with theVariant in theVariants
			repeat with theLayer in every layer of theVariant
				if layerNames does not contain name of theLayer then
					set end of layerNames to name of theLayer
				end if
			end repeat
		end repeat
		
		-- sort layer names
		set layerNames to myLibrary's sortList(layerNames)
		
		-- choose names of layers to sync
		set sourceLayerName to choose from list layerNames with prompt "Choose Source Layer To Sync"
		if sourceLayerName is false then return
		
		set targetLayerName to choose from list layerNames with prompt "Choose Target Layer To Sync"
		if targetLayerName is false then return
		
		set disableSourceLayer to (display alert "Disable Source Layer" message "Do you want to disable the source layer?" buttons {"Cancel", "No", "Yes"})
		if button returned of disableSourceLayer is "Cancel" then return
		if button returned of disableSourceLayer is "Yes" then
			set disableSourceLayer to true
		else
			set disableSourceLayer to false
		end if
		
		-- make sure source and target differ
		if sourceLayerName is targetLayerName then
			set alertTitle to appName & " Alert"
			set alertMessage to "Source and Target layers must be different."
			set alertResult to (display alert alertTitle message alertMessage buttons {"OK"} giving up after 10)
			return
		end if
		
		-- sync chosen layers across all selected variants
		set syncedVariants to 0
		set skippedVariants to 0
		repeat with theVariant in theVariants
			set sourceLayer to (every layer of theVariant where name is sourceLayerName)
			set targetLayer to (every layer of theVariant where name is targetLayerName)
			
			set sourceLayers to count of sourceLayer
			set targetLayers to count of targetLayer
			
			-- variant must have exactly one source and one target layer
			if (sourceLayers ­ 1) or (targetLayers ­ 1) then
				set skippedVariants to skippedVariants + 1
			else
				set syncedVariants to syncedVariants + 1
				
				set sourceLayer to first item of sourceLayer
				set targetLayer to first item of targetLayer
				
				my synchronizeLayers(sourceLayer, targetLayer)
				
				-- disable source layer
				if disableSourceLayer then set enabled of sourceLayer to false
			end if
		end repeat
	end tell
	
	if syncedVariants > 0 then
		set alertMessage to (syncedVariants as text) & " variants(s) synced." & return & (skippedVariants as text) & " variants(s) skipped."
	else
		set alertMessage to "No variants synchronized."
	end if
	
	return alertMessage
	
end syncBetweenLayers

on syncLayerAcrossImages(myLibrary, appName as text)
	tell application "Capture One"
		-- get primary and selected variants
		set primaryVariant to primary variant
		set selectedVariants to selected variants
		
		-- have to select more than one variant for this operation
		if (count of selectedVariants) is 1 then
			display alert appName message "You must select more than one variant."
			return
		end if
		
		-- collect names of layers from the primary variant
		set layerNames to (get name of every layer of primaryVariant)
		set invertedLayers to {}
		repeat with layerNumber from (count of layerNames) to 1 by -1
			if invertedLayers does not contain item layerNumber of layerNames then
				set end of invertedLayers to item layerNumber of layerNames
			end if
		end repeat
		if (count of layerNames) ­ (count of invertedLayers) then
			display alert appName message "Multiple layers have the same name. Please rename one."
			return
		end if
		
		-- choose name of the layer to sync across images
		set sourceLayerName to choose from list layerNames with prompt "Choose Layer To Sync Across Images"
		if sourceLayerName is false then return
		set sourceLayer to (every layer of primaryVariant where name is sourceLayerName)
		set sourceLayer to first item of sourceLayer
		
		-- sync chosen layer across all selected variants
		set targetVariants to {}
		repeat with theVariant in selectedVariants
			if id of theVariant is not id of primaryVariant then set end of targetVariants to theVariant
		end repeat
		
		set syncedVariants to 0
		set skippedVariants to 0
		repeat with theVariant in targetVariants
			set targetLayer to (every layer of theVariant where name is sourceLayerName)
			set targetLayers to count of targetLayer
			
			-- variant must have exactly one source and one target layer
			if targetLayers ­ 1 then
				set skippedVariants to skippedVariants + 1
			else
				set syncedVariants to syncedVariants + 1
				set targetLayer to first item of targetLayer
				
				my synchronizeLayers(sourceLayer, targetLayer)
			end if
		end repeat
	end tell
	
	if syncedVariants > 0 then
		set alertMessage to (syncedVariants as text) & " variants(s) synced." & return & (skippedVariants as text) & " variants(s) skipped."
	else
		set alertMessage to "No variants synchronized."
	end if
	
	return alertMessage
	
end syncLayerAcrossImages

on synchronizeLayers(sourceLayer, targetLayer)
	
	tell application "Capture One"
		
		-- copy layer adjustments
		if exists adjustments of sourceLayer then
			if white balance preset of adjustments of sourceLayer is not missing value then
				set white balance preset of adjustments of targetLayer to white balance preset of adjustments of sourceLayer
			end if
			if temperature of adjustments of sourceLayer is not missing value then
				set temperature of adjustments of targetLayer to temperature of adjustments of sourceLayer
			end if
			if tint of adjustments of sourceLayer is not missing value then
				set tint of adjustments of targetLayer to tint of adjustments of sourceLayer
			end if
			
			if exposure of adjustments of sourceLayer is not missing value then
				set exposure of adjustments of targetLayer to exposure of adjustments of sourceLayer
			end if
			if brightness of adjustments of sourceLayer is not missing value then
				set brightness of adjustments of targetLayer to brightness of adjustments of sourceLayer
			end if
			if contrast of adjustments of sourceLayer is not missing value then
				set contrast of adjustments of targetLayer to contrast of adjustments of sourceLayer
			end if
			if saturation of adjustments of sourceLayer is not missing value then
				set saturation of adjustments of targetLayer to saturation of adjustments of sourceLayer
			end if
			
			if color balance master hue of adjustments of sourceLayer is not missing value then
				set color balance master hue of adjustments of targetLayer to color balance master hue of adjustments of sourceLayer
			end if
			if color balance master saturation of adjustments of sourceLayer is not missing value then
				set color balance master saturation of adjustments of targetLayer to color balance master saturation of adjustments of sourceLayer
			end if
			if color balance shadow hue of adjustments of sourceLayer is not missing value then
				set color balance shadow hue of adjustments of targetLayer to color balance shadow hue of adjustments of sourceLayer
			end if
			if color balance shadow saturation of adjustments of sourceLayer is not missing value then
				set color balance shadow saturation of adjustments of targetLayer to color balance shadow saturation of adjustments of sourceLayer
			end if
			if color balance shadow lightness of adjustments of sourceLayer is not missing value then
				set color balance shadow lightness of adjustments of targetLayer to color balance shadow lightness of adjustments of sourceLayer
			end if
			if color balance midtone hue of adjustments of sourceLayer is not missing value then
				set color balance midtone hue of adjustments of targetLayer to color balance midtone hue of adjustments of sourceLayer
			end if
			if color balance midtone saturation of adjustments of sourceLayer is not missing value then
				set color balance midtone saturation of adjustments of targetLayer to color balance midtone saturation of adjustments of sourceLayer
			end if
			if color balance midtone lightness of adjustments of sourceLayer is not missing value then
				set color balance midtone lightness of adjustments of targetLayer to color balance midtone lightness of adjustments of sourceLayer
			end if
			if color balance highlight hue of adjustments of sourceLayer is not missing value then
				set color balance highlight hue of adjustments of targetLayer to color balance highlight hue of adjustments of sourceLayer
			end if
			if color balance highlight saturation of adjustments of sourceLayer is not missing value then
				set color balance highlight saturation of adjustments of targetLayer to color balance highlight saturation of adjustments of sourceLayer
			end if
			if color balance highlight lightness of adjustments of sourceLayer is not missing value then
				set color balance highlight lightness of adjustments of targetLayer to color balance highlight lightness of adjustments of sourceLayer
			end if
			
			if level highlight rgb of adjustments of sourceLayer is not missing value then
				set level highlight rgb of adjustments of targetLayer to level highlight rgb of adjustments of sourceLayer
			end if
			if level shadow rgb of adjustments of sourceLayer is not missing value then
				set level shadow rgb of adjustments of targetLayer to level shadow rgb of adjustments of sourceLayer
			end if
			if level highlight red of adjustments of sourceLayer is not missing value then
				set level highlight red of adjustments of targetLayer to level highlight red of adjustments of sourceLayer
			end if
			if level shadow red of adjustments of sourceLayer is not missing value then
				set level shadow red of adjustments of targetLayer to level shadow red of adjustments of sourceLayer
			end if
			if level highlight green of adjustments of sourceLayer is not missing value then
				set level highlight green of adjustments of targetLayer to level highlight green of adjustments of sourceLayer
			end if
			if level shadow green of adjustments of sourceLayer is not missing value then
				set level shadow green of adjustments of targetLayer to level shadow green of adjustments of sourceLayer
			end if
			if level highlight blue of adjustments of sourceLayer is not missing value then
				set level highlight blue of adjustments of targetLayer to level highlight blue of adjustments of sourceLayer
			end if
			if level shadow blue of adjustments of sourceLayer is not missing value then
				set level shadow blue of adjustments of targetLayer to level shadow blue of adjustments of sourceLayer
			end if
			if level target highlight rgb of adjustments of sourceLayer is not missing value then
				set level target highlight rgb of adjustments of targetLayer to level target highlight rgb of adjustments of sourceLayer
			end if
			if level target shadow rgb of adjustments of sourceLayer is not missing value then
				set level target shadow rgb of adjustments of targetLayer to level target shadow rgb of adjustments of sourceLayer
			end if
			if level target highlight red of adjustments of sourceLayer is not missing value then
				set level target highlight red of adjustments of targetLayer to level target highlight red of adjustments of sourceLayer
			end if
			if level target shadow red of adjustments of sourceLayer is not missing value then
				set level target shadow red of adjustments of targetLayer to level target shadow red of adjustments of sourceLayer
			end if
			if level target highlight green of adjustments of sourceLayer is not missing value then
				set level target highlight green of adjustments of targetLayer to level target highlight green of adjustments of sourceLayer
			end if
			if level target shadow green of adjustments of sourceLayer is not missing value then
				set level target shadow green of adjustments of targetLayer to level target shadow green of adjustments of sourceLayer
			end if
			if level target highlight blue of adjustments of sourceLayer is not missing value then
				set level target highlight blue of adjustments of targetLayer to level target highlight blue of adjustments of sourceLayer
			end if
			if level target shadow blue of adjustments of sourceLayer is not missing value then
				set level target shadow blue of adjustments of targetLayer to level target shadow blue of adjustments of sourceLayer
			end if
			if level midtone rgb of adjustments of sourceLayer is not missing value then
				set level midtone rgb of adjustments of targetLayer to level midtone rgb of adjustments of sourceLayer
			end if
			if level midtone red of adjustments of sourceLayer is not missing value then
				set level midtone red of adjustments of targetLayer to level midtone red of adjustments of sourceLayer
			end if
			if level midtone green of adjustments of sourceLayer is not missing value then
				set level midtone green of adjustments of targetLayer to level midtone green of adjustments of sourceLayer
			end if
			if level midtone blue of adjustments of sourceLayer is not missing value then
				set level midtone blue of adjustments of targetLayer to level midtone blue of adjustments of sourceLayer
			end if
			
			if rgb curve of adjustments of sourceLayer is not missing value then
				set rgb curve of adjustments of targetLayer to rgb curve of adjustments of sourceLayer
			end if
			if luma curve of adjustments of sourceLayer is not missing value then
				set luma curve of adjustments of targetLayer to luma curve of adjustments of sourceLayer
			end if
			if red curve of adjustments of sourceLayer is not missing value then
				set red curve of adjustments of targetLayer to red curve of adjustments of sourceLayer
			end if
			if green curve of adjustments of sourceLayer is not missing value then
				set green curve of adjustments of targetLayer to green curve of adjustments of sourceLayer
			end if
			if blue curve of adjustments of sourceLayer is not missing value then
				set blue curve of adjustments of targetLayer to blue curve of adjustments of sourceLayer
			end if
			
			if highlight adjustment of adjustments of sourceLayer is not missing value then
				set highlight adjustment of adjustments of targetLayer to highlight adjustment of adjustments of sourceLayer
			end if
			if shadow recovery of adjustments of sourceLayer is not missing value then
				set shadow recovery of adjustments of targetLayer to shadow recovery of adjustments of sourceLayer
			end if
			if white recovery of adjustments of sourceLayer is not missing value then
				set white recovery of adjustments of targetLayer to white recovery of adjustments of sourceLayer
			end if
			if black recovery of adjustments of sourceLayer is not missing value then
				set black recovery of adjustments of targetLayer to black recovery of adjustments of sourceLayer
			end if
			
			if clarity method of adjustments of sourceLayer is not missing value then
				set clarity method of adjustments of targetLayer to clarity method of adjustments of sourceLayer
			end if
			if clarity amount of adjustments of sourceLayer is not missing value then
				set clarity amount of adjustments of targetLayer to clarity amount of adjustments of sourceLayer
			end if
			if clarity structure of adjustments of sourceLayer is not missing value then
				set clarity structure of adjustments of targetLayer to clarity structure of adjustments of sourceLayer
			end if
			
			if dehaze amount of adjustments of sourceLayer is not missing value then
				set dehaze amount of adjustments of targetLayer to dehaze amount of adjustments of sourceLayer
			end if
			if dehaze color of adjustments of sourceLayer is not missing value then
				set dehaze color of adjustments of targetLayer to dehaze color of adjustments of sourceLayer
			end if
			
			if sharpening amount of adjustments of sourceLayer is not missing value then
				set sharpening amount of adjustments of targetLayer to sharpening amount of adjustments of sourceLayer
			end if
			if sharpening radius of adjustments of sourceLayer is not missing value then
				set sharpening radius of adjustments of targetLayer to sharpening radius of adjustments of sourceLayer
			end if
			if sharpening threshold of adjustments of sourceLayer is not missing value then
				set sharpening threshold of adjustments of targetLayer to sharpening threshold of adjustments of sourceLayer
			end if
			if sharpening halo suppression of adjustments of sourceLayer is not missing value then
				set sharpening halo suppression of adjustments of targetLayer to sharpening halo suppression of adjustments of sourceLayer
			end if
			
			if noise reduction luminance of adjustments of sourceLayer is not missing value then
				set noise reduction luminance of adjustments of targetLayer to noise reduction luminance of adjustments of sourceLayer
			end if
			if noise reduction details of adjustments of sourceLayer is not missing value then
				set noise reduction details of adjustments of targetLayer to noise reduction details of adjustments of sourceLayer
			end if
			
			if moire amount of adjustments of sourceLayer is not missing value then
				set moire amount of adjustments of targetLayer to moire amount of adjustments of sourceLayer
			end if
			if moire pattern of adjustments of sourceLayer is not missing value then
				set moire pattern of adjustments of targetLayer to moire pattern of adjustments of sourceLayer
			end if
		end if
		
		-- copy layer luma range
		if exists luma range of sourceLayer then
			if range low of luma range of sourceLayer > 0.0 then
				set range low of luma range of targetLayer to range low of luma range of sourceLayer
			end if
			if range high of luma range of sourceLayer < 255.0 then
				set range high of luma range of targetLayer to range high of luma range of sourceLayer
			end if
			if falloff low of luma range of sourceLayer > 0.0 then
				set falloff low of luma range of targetLayer to falloff low of luma range of sourceLayer
			end if
			if falloff high of luma range of sourceLayer < 255.0 then
				set falloff high of luma range of targetLayer to falloff high of luma range of sourceLayer
			end if
			if invert of luma range of sourceLayer is not false then
				set invert of luma range of targetLayer to invert of luma range of sourceLayer
			end if
			if radius of luma range of sourceLayer > 0.0 then
				set radius of luma range of targetLayer to radius of luma range of sourceLayer
			end if
			if sensitivity of luma range of sourceLayer > 0.0 then
				set sensitivity of luma range of targetLayer to sensitivity of luma range of sourceLayer
			end if
		end if
		
		-- copy layer opacity
		if exists opacity of sourceLayer then
			if opacity of sourceLayer < 100.0 then
				set opacity of targetLayer to opacity of sourceLayer
			end if
		end if
	end tell
end synchronizeLayers