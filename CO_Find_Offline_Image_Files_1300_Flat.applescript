## Applescript to search a Capture One 12 or 20 Catalog for Images with offline files
## Version 13.00 !! Best effort support !!  
## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
## This is the reference Application for my version 13 framework
## Last functional update on 2020-04-14 23:59

-- ***To Setup
-- Start Script Editor, open a new (blank) file, copy and paste both parts into one Script Editor Document, compile (hammer symbol) and save.
-- Best if you make "Scripts" folder somewhere in your Documents or Desktop
-- This file is suitable to use as an application in Capture One Pro's Script Menu

-- *** Operation in Script Editor
-- Open  the compiled and saved document
-- Open the Script Editor log window, and select the messages tab
-- The user may elect to set defaults for enabling or disabling results in Notifications, TextEdit and Script Editor by setting the "enable" variables at beginning of the script
-- The user may change the default amount of reporting by setting the "debugLogLevel" and "ResultsFileMaxDebug" variables at beginning of the script
-- There is a GUI which allows the user to modify settings
-- If you are having some issues, then set debugLogLevel to 3 and send me the results from Script Editors log window, or Text Edit.

use AppleScript version "2.5"
use scripting additions

## uses  "Utilities_1300"
## uses  "Loqqing_1300"
## uses  "CaptureOne_1300"
## uses  "GUI_1300"

property LoqqingVersion : "L13.00"


global debugLogEnable, parent_name
local enableReadPrefs, enableWritePrefs, Script_Title

on getDefaultPrefs()
	### Positioned at the top of the script to give quick access to the default Application Settings
	
	global debugLogEnable
	local GC
	local dfGUI, dfinitLogLevel, dfPrefFile, dfLogFiles, dfMaxErrorExits, dfForceDefaults, dSfSettingCheck
	local dfExcludedSubCollectionL, dfSearchlevel, dfResultsCollection, dfResultsProject, dfC1ProgressBar, dfFastWorkFlow
	local dfCompleteAlert, dfResultsFile, dfResultsByLoq, dfResultsByClipboard, dfResultsByNotifications
	local dfResultsByDialog, dfDialogTimeout, dfDialogPercent, dfScriptProgressBar, dfDebugLogLevel, ResultsFileMaxDebug
	local dfClipboardMaxDebug, dfDebugNotifications, dfnotificationsMaxDebug
	
	############  Start of User settable area ###
	## ***** Values in this section are safe to change, within limits indicated. Support is likely but no commitment
	
	## Default Settings for the Application, these can be changed with the GUI on each run of the script
	set dfExcludedSubCollectionL to {} -- 	Collections in this list will not be searched
	set dfSearchlevel to 32 --				(1..100) Reduce if you only want to search top level collections - not verified to 100
	set dfResultsCollection to true --     		(true/false) found images are stored in an album in dfResultsProject
	set dfC1ProgressBar to true --     		(true/false)
	set dfFastWorkFlow to false --			True sets a faster workflow with less user interaction
	
	## Choice Lists for the GUI
	set GC to {ExcludedSubCollectionChoice:{}} -- 
	
	## Default Settings for reporting results, can be changed with the GUI on each run of the script
	set dfCompleteAlert to false --			(true/false) - Create an Alert when the script completes
	set dfResultsFile to true --				(true/false) - Log Results to a .txtx file opened in Text Editor
	set dfResultsByLoq to true --			(true/false) - Log Results to Script Editor or Scripot Debugger
	set dfResultsByClipboard to false --		(true/false) - Clipboard is populated only when the script exits 
	set dfResultsByDialog to false --			(true/false) - Results reported by Dialog
	set dfDialogTimeout to 20 --				1...119 seconds
	set dfDialogPercent to 20 -- 				1...100 Percent of screen height used by the Scripts Dialog	
	set dfResultsByNotifications to false --	(true/false) - only enable this if needed as it is slow
	set dfScriptProgressBar to true --		(true/false)  - enable a progress bar in the Script window
	
	set dfDebugLogLevel to 0 --				0...6 Values >0 result in increasing amounts of debug data and longer run times
	set dfResultsFileMaxDebug to 2 --		0...6  suggest not more than 2 if run from Script Editor
	set dfClipboardMaxDebug to 0 --			0...6  suggest not more than 4
	set dfDebugNotifications to false --		(true/false)  - enable notifications of errors and exceptions
	set dfnotificationsMaxDebug to 0 --		0...2  suggest not more than 1
	
	### Script Settings - these cannot be adjusted by the GUI
	set dfinitLogLevel to 3 -- 				logging level while script is initialising -- normally 0, set to 2 if problems
	set dfPrefFile to true -- 					if false prevents creation of a .plist file for reading and writing of settings
	set dfLogFiles to true -- 				if false prevents creation of .txt file for logging results
	set dfMaxErrorExits to 6 -- 				after this number of script error exits, the Loqqing and Application settings are set to default
	set dfForceDefaults to false --			Force the script to use the scripts default settings (above) instead of the settings in the .plist file
	set dSfSettingCheck to false --			Force the script to always validate the settings, Enable this if you are having errors
	set dfResultsProject to "ScriptSearchResults" -- 	this is the project where found images found by scripts are stored. Not possible to exclude this from searching
	
	############ End of User Settable area ###
	## Definitions for debugLogLevel which is used  to define the level of reporting and logging
	##	-1 		Results 
	##	0		Critical errors
	##	1		Verbose results
	##	2		Managed Exceptions (a problem occurred, but the script handled it)
	##	3		Actions and Results
	##	4		Simple diagnostics
	##	5		Detailed diagnostics
	##	6		Very long diagnostics
	##
	##	Only levels ≤ debugLogLevel are reported
	##  Levels -1 and 0 are always reported
	##
	local AD, LD
	
	set AD to {ExcludedSubCollectionL:dfExcludedSubCollectionL, maxSearchlevel:dfSearchlevel, enableResultsCollection:dfResultsCollection, nameResultsProject:dfResultsProject, enableC1ProgressBar:dfC1ProgressBar}
	
	set LD to {enableResultsFile:dfResultsFile, enableResultsByLoq:dfResultsByLoq, enableResultsByClipboard:dfResultsByClipboard, enableResultsByNotifications:dfResultsByNotifications}
	set LD to LD & {enableResultsByDialog:dfResultsByDialog, dialogTimeout:dfDialogTimeout, maxDialogPercent:dfDialogPercent}
	set LD to LD & {enableScriptProgressBar:dfScriptProgressBar, enableCompleteAlert:dfCompleteAlert, debugLogLevel:dfDebugLogLevel, ResultsFileMaxDebug:dfResultsFileMaxDebug}
	set LD to LD & {clipboardMaxDebug:dfClipboardMaxDebug, enableDebugNotifications:dfDebugNotifications, notificationsMaxDebug:dfnotificationsMaxDebug, enableFastGui:dfFastWorkFlow}
	
	return {appDefs:AD, logDefs:LD, guiChoices:GC, initLogLevel:dfinitLogLevel, enablePrefFile:dfPrefFile, enableLogFiles:dfLogFiles, maxErrorExits:dfMaxErrorExits, forceScriptDefaults:dfForceDefaults, forceSettingsCheck:dSfSettingCheck}
end getDefaultPrefs

############ Start of execution flow

local appDefaults, logDefaults, initLogLevel, enablePrefFile, enableLogFiles, maxErrorExits, forceAppDefaults, forceSettingsCheck

tell getDefaultPrefs() --- this is called several times in different places to get other defaults as needed
	set {initLogLevel, enablePrefFile, enableLogFiles, maxErrorExits, forceAppDefaults, forceSettingsCheck} to ¬
		{its initLogLevel, its enablePrefFile, its enableLogFiles, its maxErrorExits, its forceScriptDefaults, its forceSettingsCheck}
end tell

if enablePrefFile then
	set {enableReadPrefs, enableWritePrefs} to {(not forceAppDefaults), true}
else
	set {enableReadPrefs, enableWritePrefs} to {false, false}
end if

## Trigger MacOS's security questions - for OMacOS 10.14.6 and later
if enableLogFiles or enablePrefFile then tell application "Finder" to get count of windows
if enableLogFiles then tell application "TextEdit" to get count of windows
tell application "System Events" to set parent_name to name of current application

set Script_Title to my getScriptTitle((path to me), true, false)

set {CoScriptLogsPath, CoScriptPrefsPath} to my setup4CaptureOneScript(initLogLevel, enableLogFiles, enablePrefFile)'s {path2CoLogFolder, path2CoPrefFolder}
set guiData to my initGuiGlobals() -- anchor guiData here, as it refers to other variables also defined in this scope. Implicitly global, but actually is passed by reference.
set mainLoqqingVersion to my initLoqqingGlobals(initLogLevel, Script_Title, CoScriptPrefsPath, enableLogFiles, CoScriptLogsPath, enableReadPrefs, enableWritePrefs)
## Loqqing system now has basic functionality and all required files have been created and opened

## initPrefsFromFile() loads settings from the .plist file, unless there have been more errors than maxErrorExits or the file does not exist
my initPrefsFromFile(Script_Title, initLogLevel, maxErrorExits, enableReadPrefs, enableWritePrefs, CoScriptPrefsPath, enableLogFiles, CoScriptLogsPath, mainLoqqingVersion, forceSettingsCheck)

## Configure the Loqqing and Application Settings according to the application defaults and previous settings
## The Application and Logqing default settings will be ignored if settings have been read from the .plist file
setLoqPrefs(forceAppDefaults, enableReadPrefs, enableWritePrefs, enableLogFiles)
my loqThis(1, false, ("Started from: " & parent_name & "  Action: Find Offline Image files"))

local coParList, coAppName, COPDocRef, minCOPversion, maxCOPversion

set {minCOPversion, maxCOPversion, coParList} to {"12", "13", {}}

tell my validateCOP5(minCOPversion, maxCOPversion)
	if its hasErrors then error (get its errorText)
	set {coAppName, COPDocRef} to {its theAppName, its COPDocRef}
	set coParList to coParList & {coAppName:its theAppName, copVersion:its copVersion, COPDocRef:its COPDocRef}
end tell

tell my validateCOPdoc5(COPDocRef, {"Catalog"})
	if its hasErrors then error (get its errorText)
	set coParList to coParList & {COPDocName:its COPDocName, COPDocKind_s:its COPDocKind_s}
end tell

tell my validateCOcollection6(COPDocRef)
	if its hasErrors then error (get its errorText)
	set coParList to coParList & {selectedCollectionRef:its selectedCollectionRef, kindSelectedCollection_s:its selectedCollectionKind_s, selectedCollectionName:its selectedCollectionName, selectedCollAllImages:its selectedCollectionIsAllImages}
end tell

setAppPrefs(forceAppDefaults, coParList)

local userCancelledGUI, perfMetrics

set userCancelledGUI to false

makeGuiRecords(guiData)
my loqGUIsettings2(guiData)
my guisGUiSettings(guiData)

tell application "System Events" to set frontmost of process parent_name to true

set userCancelledGUI to my guiRunSettingsEditor(guiData)

if userCancelledGUI then
	guiCancelResetDefs() -- if the user cancelled the script, ask if the script preferences should be reset to default
	set perfMetrics to "User Cancelled"
else
	my saveLoqqingPrefs()
	saveAppPrefs()
	set perfMetrics to searchHandler() -- does the search
end if

return my loqqedNormalHalt7(perfMetrics)

tell application "System Events" to set frontmost of process coAppName to true
if Loqqing's enableResultsFile then
	tell application "System Events" to set frontmost of process "TextEdit" to true
else
	tell application "System Events" to set frontmost of process parent_name to true
end if
false

################  The End ###############
## Script Specific Handlers #######

on searchHandler()
	global debugLogEnable, theApp, Loqqing, C1
	
	local Mark1, Mark2, Mark3, Mark4, Mark5
	set Mark1 to my GetTick_Now()
	
	setSearchWindows()
	
	## Setup the search
	
	local thisCollectionRef, countProcessedImages, thisColl_name, thisCollKindS, countImages, estDuration, estProgressDuration_S, nextSearchLevel
	
	tell application "Capture One 20"
		set thisCollectionRef to C1's selectedCollectionRef
		tell thisCollectionRef
			set thisColl_name to its name
			set thisCollKindS to my convertKindList((get its kind))
			set countImages to count of images
		end tell
	end tell
	
	set nextSearchLevel to 1
	if ({"project", "album", "smart album"} does not contain thisCollKindS) then ¬
		set countImages to countAllImages(thisCollectionRef, thisColl_name, thisCollKindS, nextSearchLevel)
	my loqThis(1, false, ("Starting in " & thisCollKindS & " \"" & thisColl_name & "\" with " & countImages & " Images"))
	
	set {estDuration, estProgressDuration_S} to {0, ""}
	if 0 < (0 + (theApp's ratePerSecond)) then
		set estDuration to (countImages / (theApp's ratePerSecond))
		set estProgressDuration_S to " (" & (my roundDecimals(estDuration, 0)) & "s)"
		my loqThis(1, false, ("Estimated Execution Time is " & (my roundDecimals(estDuration, 0)) & " seconds"))
	end if
	
	set Mark2 to my GetTick_Now()
	
	if 300 < estDuration then
		tell application "System Events" to set frontmost of process parent_name to true
		set dialog_result to display dialog "Estimated Execution time is " & estProgressDuration_S with title Loqqing's Script_Title ¬
			buttons {"Exit Script", "Continue"} default button "Continue"
		if (get button returned of dialog_result) contains "Exit" then
			my loqThis(-1, false, ("User Cancelled Script on predicted execution time of " & estProgressDuration_S))
			guiCancelResetDefs()
			return
		end if
		setSearchWindows()
	else if (0 = estDuration) and (countImages > 5000) then
		tell application "System Events" to set frontmost of process parent_name to true
		set dialog_result to display dialog C1's kindSelectedCollection_s & " contains " & countImages & " images" & estProgressDuration_S with title Loqqing's Script_Title ¬
			buttons {"Exit Script", "Continue"} default button "Continue"
		if (get button returned of dialog_result) contains "Exit" then
			my loqThis(-1, false, ("User Cancelled Script on too many images: " & countImages))
			guiCancelResetDefs()
			return
		end if
		setSearchWindows()
	end if
	
	set Mark5 to my GetTick_Now()
	local Result_AlbumRoot, Result_ProjectName, Coll_Init_Text, ref2ResultAlbum
	if theApp's enableResultsCollection then
		set Result_AlbumRoot to "OfflineFiles"
		set Result_ProjectName to (get theApp's nameResultsProject)
		set Coll_Init_Text to "Images with offline files will be added to album "
		set ref2ResultAlbum to my InitializeResultsCollection(Result_ProjectName, Result_AlbumRoot, Coll_Init_Text)
		set C1 to {ref2ResultAlbum:ref2ResultAlbum} & C1
	end if
	
	set Mark3 to my GetTick_Now()
	local nextSearchLevel, countImageNotFound, Coll_path
	set nextSearchLevel to 1
	set countImageNotFound to 0
	set countProcessedImages to 0
	set Coll_path to ">" & thisColl_name
	
	tell my search_collection(thisCollectionRef, thisColl_name, thisCollKindS, nextSearchLevel, Coll_path, true, estProgressDuration_S)
		set countImageNotFound to its countImageNotFound
		set countProcessedImages to its countProcessedImages
	end tell
	set Mark4 to my GetTick_Now()
	
	local elapsedTime1, elapsedTime1s, elapsedTime2s, searchTimePerVariant, searchTimeMsPerVariant, countTimeMsPerVariant
	
	my loqThis(-1, false, (return & "Found " & countImageNotFound & " of " & countProcessedImages & " images with offline files in " & thisCollKindS & " \"" & thisColl_name & "\" (" & countImages & " images)"))
	
	set {countTimeMsPerVariant, searchTimeMsPerVariant} to {"--", "--"}
	
	set elapsedTime2s to my roundDecimals(Mark4 - Mark3, 3)
	if (countProcessedImages > 10) and (0.1 < (Mark4 - Mark3)) then -- reasonable accuracy
		set theApp's ratePerSecond to countProcessedImages / (Mark4 - Mark3) -- ratePerSecond is used only after setup is completed
		saveAppPrefs()
		set searchTimeMsPerVariant to my roundDecimals(((Mark4 - Mark3) / countProcessedImages * 1000), 1)
	end if
	
	set elapsedTime1 to (Mark2 - Mark1) + (Mark3 - Mark5)
	set elapsedTime1s to my roundDecimals(elapsedTime1, 3)
	if (countImages > 10) and (0.1 < elapsedTime1) then ¬
		set countTimeMsPerVariant to my roundDecimals((elapsedTime1 / countImages * 1000), 1) -- reasonable accuracy
	
	return (return & "Searching: " & elapsedTime2s & "s;  " & searchTimeMsPerVariant & "ms per image   Setup: " & elapsedTime1s & "s;  " & countTimeMsPerVariant & "ms per image")
	
end searchHandler

on setSearchWindows()
	global debugLogEnable, theApp, Loqqing, C1, parent_name
	
	tell application "System Events" -- Arrange the windows to show results and progress bars on top
		set theAppName to (get C1's coAppName as text)
		set frontmost of process theAppName to true
		if (not theApp's enableC1ProgressBar) and Loqqing's enableScriptProgressBar and (parent_name = "Script Editor") then ¬
			set frontmost of process "Script Editor" to true
		if Loqqing's enableResultsFile then set frontmost of process "TextEdit" to true
	end tell
end setSearchWindows

on countAllImages(thisCollection, thisColl_name, thisCollKindS, searchLevel)
	-- recursive handler to count images in a collection and it's subcollections
	
	global debugLogEnable, theApp, Loqqing, C1
	
	if theApp's ExcludedSubCollectionL contains thisColl_name then return 0
	
	local countImages
	tell application "Capture One 20" to tell thisCollection to set countImages to count of every image
	if debugLogEnable then
		set actionString to "counting images in " & thisCollKindS & " \"" & thisColl_name & "\""
		my loqThis(3, false, actionString)
	end if
	
	local nameSubCollsL, refSubCollsL, kindSubCollsSL, nextSearchLevel, countSubColls
	local nextCollName, nextCollRef, nextCollKindS, ptrSubColl
	if ({"project", "album", "smart album"} contains thisCollKindS) or (searchLevel ≥ theApp's maxSearchlevel) then return countImages
	tell application "Capture One 20" to tell thisCollection to tell every collection to ¬
		set {refSubCollsL, nameSubCollsL, kindSubCollsSL} to {(get it), (get its name), (my convertKindList(get its kind))}
	set {nextSearchLevel, countSubColls} to {(searchLevel + 1), (count of nameSubCollsL)}
	if (countSubColls > 0) then
		repeat with ptrSubColl from 1 to countSubColls
			set {nextCollName, nextCollRef, nextCollKindS} to {(nameSubCollsL's item ptrSubColl), (refSubCollsL's item ptrSubColl), (kindSubCollsSL's item ptrSubColl)}
			set countImages to countImages + (my countAllImages(nextCollRef, nextCollName, nextCollKindS, nextSearchLevel))
		end repeat
	end if
	return countImages
end countAllImages

on search_collection(thisCollection, thisColl_name, thisCollKindS, searchLevel, thisCollPath, printColl, estProgressDuration_S)
	-- recursive handler to search a collection and it's subcollections
	
	global debugLogEnable, theApp, Loqqing, C1
	local imagePathL, nextSearchLevel, countImages, actionString, enableProgressBar, useC1ProgressBar, secondsThresh
	
	if theApp's ExcludedSubCollectionL contains thisColl_name then return {countImageNotFound:0, countProcessedImages:0, _debug:(get my loqThis(1, false, ("Skipped " & thisColl_name)))}
	
	tell application "Capture One 20" to tell thisCollection to set countImages to count of every image
	set actionString to "Searching " & thisCollKindS & " \"" & thisColl_name & "\" with " & countImages & " images" & estProgressDuration_S
	if debugLogEnable then my loqThis(3, false, actionString)
	
	set {secondsThresh, enableProgressBar} to {3, false}
	if (Loqqing's enableScriptProgressBar or theApp's enableC1ProgressBar) and ¬
		(C1's selectedCollAllImages or ¬
			((0 ≠ theApp's ratePerSecond) and (countImages > (secondsThresh * (theApp's ratePerSecond)))) or ¬
			((0 = theApp's ratePerSecond) and (countImages > 500)) ¬
				) then
		
		set {enableProgressBar, progressInterval, useC1ProgressBar} to {true, 25, (true and theApp's enableC1ProgressBar)} -- updating the CO progress counter takes as long as checking the path of one image
		if useC1ProgressBar then
			tell application "Capture One 20" to set {progress text, progress completed units, progress total units, progress additional text} to {actionString, 0, countImages, ("" & countImages & " images")}
		else
			set {progress description, progress total steps, progress completed steps} to {actionString, countImages, 0}
		end if
	end if
	
	tell application "Capture One 20" to tell thisCollection to set imagePathL to get path of every image
	
	local loc_Text, first_Hit, countImageNotFound, countProcessedImages, ImageCounter, imagepath, imageName, progressInterval
	
	set loc_Text to "In " & thisCollKindS & " " & thisCollPath & ":"
	set first_Hit to true and not printColl -- if this is the starting collection then don't print out the collection name
	set countImageNotFound to 0
	set countProcessedImages to count of imagePathL
	
	if 0 < countImages then
		
		repeat with ImageCounter from 1 to countImages
			if enableProgressBar and (0 = ImageCounter mod progressInterval) then
				if useC1ProgressBar then
					tell application "Capture One 20" to set progress completed units to ImageCounter
				else
					set progress completed steps to ImageCounter
				end if
			end if
			set imagepath to item ImageCounter of imagePathL
			
			tell application "System Events"
				set hasImageFile to (get exists file imagepath)
				if not hasImageFile then
					set countImageNotFound to countImageNotFound + 1
					if first_Hit then my loqThis(-1, false, (return & loc_Text))
					set first_Hit to false
					tell application "Capture One 20" to tell C1's COPDocRef to tell thisCollection to tell image ImageCounter
						set imageName to name
						if theApp's enableResultsCollection then add inside (C1's ref2ResultAlbum) variants (get variants)
					end tell
					my loqThis(-1, false, ("File for " & imageName & " not found at " & imagepath))
				end if
			end tell
		end repeat
		if enableProgressBar then tell application "Capture One 20" to set progress completed units to countImages
		if Loqqing's enableScriptProgressBar then set progress completed steps to countImages
	end if
	if debugLogEnable then my loqThis(3, false, ("Done " & thisCollKindS & "  " & thisCollPath & " with " & countImageNotFound & " offline files"))
	
	local nameSubCollsL, refSubCollsL, kindSubCollsSL, nextSearchLevel, countSubColls
	local nextCollName, nextCollRef, nextCollKindS, ptrSubColl
	if thisCollKindS ≠ "project" then -- do not search collections contained inside a project to avoid repeated "hits" of the same image
		tell application "Capture One 20" to tell C1's COPDocRef to tell thisCollection to tell every collection to ¬
			set {refSubCollsL, nameSubCollsL, kindSubCollsSL} to {(get it), (get name of it), (my convertKindList(kind))}
		set {nextSearchLevel, countSubColls} to {(searchLevel + 1), (count of nameSubCollsL)}
		if (countSubColls > 0) and (nextSearchLevel ≤ theApp's maxSearchlevel) then
			repeat with ptrSubColl from 1 to countSubColls
				set {nextCollName, nextCollRef, nextCollKindS} to {(get nameSubCollsL's item ptrSubColl), (get refSubCollsL's item ptrSubColl), (get kindSubCollsSL's item ptrSubColl)}
				set nextCollPath to thisCollPath & ">" & nextCollName
				tell my search_collection(nextCollRef, nextCollName, nextCollKindS, nextSearchLevel, nextCollPath, false, estProgressDuration_S)
					set countProcessedImages to countProcessedImages + (its countProcessedImages)
					set countImageNotFound to countImageNotFound + (its countImageNotFound)
				end tell
			end repeat
		end if
	end if
	return {countImageNotFound:countImageNotFound, countProcessedImages:countProcessedImages}
end search_collection

on setLoqPrefs(forceDefaults, enableReadPrefs, enableWritePrefs, enableLogFiles)
	global debugLogEnable, Loqqing
	
	local logDefs, saveLoqPrefs
	
	tell getDefaultPrefs() to set logDefs to its logDefs
	set logDefs to {fullSetup:true, isChecked:false} & logDefs
	
	set saveLoqPrefs to false
	if (not Loqqing's fullSetup) or forceDefaults then -- setup Loqqing from scripts defaults
		set {Loqqing, saveLoqPrefs} to {logDefs & Loqqing, true} -- save the revised values, isChecked is false
		my loqThis(1, false, "Loqqing settings were set to Script Defaults")
	end if
	
	tell Loqqing -- control what's useable for this script
		set its gateResultsByClipboard to true
		set its gateResultsFile to true
		set its gateResultsDialog to true
		set its gateResultsNotification to true
		set its gateParentLoqqing to true
		set its enableReadPrefs to enableReadPrefs
		set its enableWritePrefs to enableWritePrefs
	end tell
	
	if not enableLogFiles then set Loqqing's gateResultsFile to false
	
	if saveLoqPrefs then
		set loqResultMethod to my setupLoqqing6()
		if enableWritePrefs then my saveLoqqingPrefs()
	end if
	
end setLoqPrefs

on setAppPrefs(forceDefaults, coParList)
	
	global debugLogEnable, Loqqing
	global theApp, guiChoices, C1
	local appSettingsName, selectedCollectionRef, kindSelectedCollection_s, nameSelectedCollection, selectedCollAllImages
	
	set theAppSettingsName to "appSettings"
	copy ({appSettingsName:theAppSettingsName} & coParList) to C1
	
	local appDefs, saveAppPrefs, gotAppPrefs, AppPrefs, theErrMess, nameSubColl_L
	
	tell getDefaultPrefs() to set {appDefs, guiChoices} to {its appDefs, its guiChoices}
	
	set {saveAppPrefs, gotAppPrefs} to {(true and Loqqing's enableWritePrefs), false}
	if Loqqing's enableReadPrefs and not forceDefaults then
		try
			tell application "System Events" to tell property list file (Loqqing's posix2PrefFile)
				if (get name of every property list item) contains theAppSettingsName then
					set AppPrefs to (get value of property list item theAppSettingsName) & {}
					set gotAppPrefs to true
				end if
			end tell
			if gotAppPrefs then
				if debugLogEnable then my loqThis(2, false, "Application Settings loaded from the Preference File")
				copy (AppPrefs & appDefs) to theApp -- AppPrefs takes priority
				if AppPrefs = theApp then set saveAppPrefs to false -- don't save needlessly
			else
				my loqThis(0, true, "Did not find Application Settings in the Preference File")
				set gotAppPrefs to false
			end if
		on error errmess
			set theErrMess to "Error Message: " & errmess
			if debugLogEnable then my loqThis(0, true, "Failed Reading Application Settings from Preference File \"" & theAppSettingsName & "\" with Error Message " & (get errmess))
			set gotAppPrefs to false
		end try
	end if
	local forceAppDefaults, enableReadPrefs, enableWritePrefs, enableLogFiles
	
	if not gotAppPrefs then
		copy (appDefs & {ratePerSecond:0}) to theApp
		tell Loqqing to set {forceAppDefaults, enableReadPrefs, enableWritePrefs, enableLogFiles} to ¬
			{true, (true and its enableReadPrefs), (true and its enableWritePrefs), (true and its gateResultsFile)}
		setLoqPrefs(forceAppDefaults, enableReadPrefs, enableWritePrefs, enableLogFiles)
		my loqThis(1, false, "Application settings were set to Script Defaults")
	end if
	if saveAppPrefs then saveAppPrefs()
	
	local nameSubColl_L, nameSubSubColl_L, aList
	
	if C1's selectedCollAllImages or ("project" = C1's kindSelectedCollection_s) then
		set guiChoices's ExcludedSubCollectionChoice to {}
	else
		tell application "Capture One 20" to tell C1's selectedCollectionRef
			set nameSubColl_L to (get name of its collections)
			set nameSubSubColl_L to get name of collections of (collections whose kind is not project)
		end tell
		repeat with aList in nameSubSubColl_L
			set nameSubColl_L to nameSubColl_L & aList
		end repeat
		
		set guiChoices's ExcludedSubCollectionChoice to nameSubColl_L & guiChoices's ExcludedSubCollectionChoice
	end if
	
end setAppPrefs

on saveAppPrefs()
	## Save the Application settings into the preferences (.plist) file
	
	global debugLogEnable, theApp, Loqqing, C1
	local theAppSettingsName
	set theAppSettingsName to (get "" & C1's appSettingsName)
	if Loqqing's enableWritePrefs or (false ≠ Loqqing's posix2PrefFile) then
		tell application "System Events" to tell property list file (Loqqing's posix2PrefFile)
			if (get name of every property list item) contains theAppSettingsName then
				set value of property list item theAppSettingsName to theApp
			else
				make new property list item at end with properties {kind:record, name:theAppSettingsName, value:theApp}
			end if
		end tell
		if debugLogEnable then my loqThis(2, false, "Saved Application Settings into .plist File")
	else
		my loqThis(1, false, "Unable to Save Application Set Up into Preference File -  no path")
	end if
end saveAppPrefs

on guiCancelResetDefs()
	global debugLogEnable, Loqqing, parent_name, C1
	local forceAppDefaults, enableReadPrefs, enableWritePrefs, enableLogFiles, newC1
	
	set prefSaved to ""
	copy (get {} & C1) to newC1
	
	if Loqqing's enableFastGui then
		set prefSaved to "; changed settings were not saved"
	else
		tell application "System Events" to set frontmost of process parent_name to true
		set dialog_result to display dialog "Reset the Application Settings to Default?" with title "Settings for " & Loqqing's Script_Title ¬
			buttons {"Exit Script", "Reset and Exit"} default button "Exit Script"
		if (get button returned of dialog_result) contains "Reset" then
			set prefSaved to "; script settings were reset"
			if Loqqing's enableWritePrefs then set prefSaved to " and saved"
			setAppPrefs(true, newC1)
			tell Loqqing to set {forceAppDefaults, enableReadPrefs, enableWritePrefs, enableLogFiles} to ¬
				{true, (true and its enableReadPrefs), (true and its enableWritePrefs), (true and its gateResultsFile)}
			setLoqPrefs(forceAppDefaults, enableReadPrefs, enableWritePrefs, enableLogFiles)
		else
			if Loqqing's enableWritePrefs then set prefSaved to "; changed settings were saved"
			saveAppPrefs()
			my saveLoqqingPrefs()
		end if
	end if
	my loqThis(-1, false, "User has cancelled the search" & prefSaved)
	return
end guiCancelResetDefs

on makeGuiRecords(theGuiData)
	## Set up the GUI records for the Application Settings
	
	global debugLogEnable, theApp, guiChoices, C1
	local settingList, scriptList, loqSettings_L, loqScript_L
	local helpMaxSearchLevel
	
	set helpMaxSearchLevel to "The maximum number of levels under the selected colllection which will be searched"
	set settingList to {}
	set end of settingList to {s_ID:0, s_Name:"Max Search Level", s_Help:helpMaxSearchLevel, s_Value:(a reference to theApp's maxSearchlevel), s_UserSet:true, s_Active:C1's selectedCollAllImages, s_Invert:true, s_Class:"Integer", s_LType:"InMin&InMax", s_Limit_L:{1, 100}}
	set end of settingList to {s_ID:0, s_Name:"Excluded Collections", s_Value:(a reference to theApp's ExcludedSubCollectionL), s_UserSet:true, s_Active:C1's selectedCollAllImages, s_Invert:true, s_Class:"List_Text", s_LType:"Free&List", s_Limit_L:(guiChoices's ExcludedSubCollectionChoice)}
	set end of settingList to {s_ID:0, s_Name:"Enable Results Collection", s_Value:(a reference to theApp's enableResultsCollection), s_UserSet:true, s_Active:true, s_Class:"Boolean"}
	set end of settingList to {s_ID:0, s_Name:"Enable C1 Progress Bar", s_Value:(a reference to theApp's enableC1ProgressBar), s_UserSet:true, s_Active:true, s_Class:"Boolean"}
	set end of settingList to {s_ID:0, s_Name:"++++", s_Value:missing value, s_UserSet:missing value, s_Active:true}
	
	set theGuiData's guiRecordList to settingList & theGuiData's guiRecordList
	
	return
end makeGuiRecords

on finalCleanup()
	## Remove data from large lists to prevent a stack overflow from blocking Script Editor from saving
	global debugLogEnable, imagePathL, C1, theApp, loqDialogTextList, loqClipboardTextS, Loqqing, parent_name
	if debugLogEnable then my loqThis(3, false, "Final Cleanup ")
	if parent_name does not contain "Script" then return
	if theApp's enableC1ProgressBar then tell application "Capture One 20" to set {progress text, progress completed units, progress total units, progress additional text} to {"", 1, 0, ""}
	set {imagePathL, C1, theApp, loqDialogTextList, loqClipboardTextS} to {null, null, null, null, null}
end finalCleanup

##  CaptureOne_1300.scpt  #########################################################
## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
## Capture One General Handlers  Version 1300  2020/04/14

## Dependencies
## my  joinListToString   splitStringToList  compareVersion  findTargetFolder  removeLeadingTrailingSpaces  replaceText
## my loqThis  loqqed_Error_Halt5   


on setup4CaptureOneScript(debugLogLevel, gateReportFiles, gatePrefFiles)
	## Purpose - provide paths to the folders for script logs and script preferences; create if necessary
	local alias2PrefsParent_as, alias2PrefsParent_a, alias2ReportsParent_a, alias2CoScriptPrefs, alias2CoScriptReports
	set {alias2CoScriptReports, alias2CoScriptPrefs} to {false, false}
	set alias2PrefsParent_as to (((get path to scripts folder) as text) & "Capture One Scripts:")
	if 1 ≤ debugLogLevel then tell me to log "Finding Reports and Prefs parent folder \"" & (get POSIX path of alias2PrefsParent_as) & "\""
	try
		set alias2PrefsParent_a to alias alias2PrefsParent_as
		set alias2ReportsParent_a to alias2PrefsParent_a
	on error errorString number errorNumber
		error "setup4CaptureOneScript() had error " & errorNumber & " \"" & errorString & "\"."
	end try
	if gatePrefFiles then set alias2CoScriptPrefs to my findTargetFolder(alias2PrefsParent_a, "Script Preferences", debugLogLevel, true)
	if gateReportFiles then set alias2CoScriptReports to my findTargetFolder(alias2ReportsParent_a, "Script Reports", debugLogLevel, true)
	return {path2CoLogFolder:(alias2CoScriptReports as text), path2CoPrefFolder:(alias2CoScriptPrefs as text)}
end setup4CaptureOneScript

on validateCOP5(minCOPversionstr, maxCOPversionstr)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General purpose initialisation handler for scripts using Capture One Pro
	## Extract and check basic information about the Capture One application
	
	global debugLogEnable
	local theAppName, copVersion, copVersionStr, copDetailedVersion
	local minVersionPass, maxVersionPass
	
	tell application "Capture One 20" to set {theAppName, copVersionStr, copDetailedVersion, COPDocRef} to {name, app version, version, current document}
	set copVersion to (word -1 of copVersionStr)
	set theAppName to (get ("" & theAppName) as text)
	
	if debugLogEnable then my loqThis(1, false, ("Using " & theAppName & " version " & copDetailedVersion))
	tell my compareVersion(copVersion, minCOPversionstr, maxCOPversionstr) to set {minVersionPass, maxVersionPass} to {its minVersionPass, its maxVersionPass}
	if not minVersionPass then return {hasErrors:true, errorText:(get my loqqed_Error_Halt5(("This Script does not support version " & copDetailedVersion & " of Capture One - versions " & minCOPversionstr & " and later are supported")))}
	if not maxVersionPass then my loqThis(0, true, ("Caution: This Script has not been verified for Capture One " & copDetailedVersion))
	return {hasErrors:false, theAppName:theAppName, copVersion:copVersion, COPDocRef:COPDocRef}
end validateCOP5

on validateCOPdoc5(theDocRef, validDocKindList)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General purpose initialisation handler for scripts using Capture One Pro
	## Extract and check basic information about a document
	
	global debugLogEnable
	--local COPDocKind_s, COPDocKind_p, COPDocName
	
	if "text" = (get class of theDocRef as text) and (0 = (get count of theDocRef)) then tell application "Capture One 20" to set theDocRef to get current document
	
	try
		tell application "Capture One 20" to set {COPDocName, COPDocKind_p} to get {name, kind} of theDocRef
	on error errorText number errorNumber
		return {hasErrors:true, errorText:(get my loqqed_Error_Halt5("The Script could not retrieve Capture One document info. Error " & errorNumber & ": \"" & errorText & "\""))}
	end try
	set COPDocKind_s to convertKindList(COPDocKind_p)
	
	if validDocKindList does not contain COPDocKind_s then return {hasErrors:true, errorText:(get my loqqed_Error_Halt5((COPDocName & " is a " & COPDocKind_s & " -- not supported by this script")))}
	return {hasErrors:false, COPDocName:COPDocName, COPDocKind_s:COPDocKind_s}
end validateCOPdoc5

on validateCOPcollections5(theDocRef)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General purpose initialisation handler for scripts using Capture One Pro
	## Extract basic information regarding the current collection, and the top level collections
	global debugLogEnable
	local selectedCollectionRef, selectedCollectionIndex, countTopCollections
	local nameSelectedCollection, kindSelectedCollection_s, userSelectedCollection, idSelectedCollection
	local namesTopCollections, kindsTopCollections_s, usersTopCollections, idsTopCollections
	
	tell application "Capture One 20" to set {COPDocName, COPDocKind_p} to get {name, kind} of theDocRef
	set COPDocKind_s to convertKindList(COPDocKind_p)
	
	tell application "Capture One 20" to tell theDocRef
		set selectedCollectionRef to get current collection
		if (missing value = selectedCollectionRef) then
			try
				set current collection to collection "All Images"
			on error
				set current collection to first collection
			end try
			set selectedCollectionRef to get current collection
		end if
		tell selectedCollectionRef to set {nameSelectedCollection, kindSelectedCollection_s, userSelectedCollection, idSelectedCollection} to {name, my convertKindList(kind), user, id}
		tell every collection to set {namesTopCollections, kindsTopCollections_s, usersTopCollections, idsTopCollections} to {name, my convertKindList(kind), user, id}
	end tell
	set countTopCollections to count of namesTopCollections
	
	set selectedCollectionIndex to 0
	repeat with collectionCounter from countTopCollections to 1 by -1
		if (idSelectedCollection = item collectionCounter of idsTopCollections) then
			set selectedCollectionIndex to collectionCounter
			exit repeat
		end if
	end repeat
	
	local selectedCollectionMirroredAtTopLast, bottomUserCollectionIndex, topUserCollectionIndex, selectedCollectionIsUser
	set {bottomUserCollectionIndex, topUserCollectionIndex} to {0, 0}
	local foldersTopCollection, folderSelectedCollection, countFavoriteCollections, namesFavoriteCollections
	
	if COPDocKind_s = "catalog" then
		set selectedCollectionIsUser to userSelectedCollection
		set selectedCollectionMirroredAtTopLast to ¬
			(selectedCollectionIndex = countTopCollections) and userSelectedCollection and ¬
			({"catalog folder", "favorite"} does not contain last item of kindsTopCollections_s)
		
		repeat with collectionCounter from 1 to topUserCollectionIndex
			if (get item collectionCounter of usersTopCollections) then
				set bottomUserCollectionIndex to collectionCounter + 0
				exit repeat
			end if
		end repeat
		
		if bottomUserCollectionIndex > 0 then
			repeat with collectionCounter from bottomUserCollectionIndex to countTopCollections
				if not (get item collectionCounter of usersTopCollections) then
					set topUserCollectionIndex to collectionCounter - 1
					exit repeat
				end if
			end repeat
		end if
		
		
		set {countFavoriteCollections, namesFavoriteCollections} to {missing value, missing value}
		
	else if COPDocKind_s = "session" then
		tell application "Capture One 20" to tell theDocRef
			set foldersTopCollection to folder of every collection
			set folderSelectedCollection to folder of selectedCollectionRef
		end tell
		
		set selectedCollectionIsUser to userSelectedCollection and (missing value = folderSelectedCollection)
		
		repeat with collectionCounter from 1 to countTopCollections
			if (get item collectionCounter of userTopCollections) and (missing value = item collectionCounter of foldersTopCollection) then
				set bottomUserCollectionIndex to collectionCounter + 0
				exit repeat
			end if
		end repeat
		
		if bottomUserCollectionIndex > 0 then
			repeat with collectionCounter from bottomUserCollectionIndex to countTopCollections
				if not ((get item collectionCounter of userTopCollections) and (missing value = item collectionCounter of foldersTopCollection)) then
					set topUserCollectionIndex to collectionCounter - 1
					exit repeat
				end if
			end repeat
		end if
		
		set countFavoriteCollections to countTopCollections - topUserCollectionIndex
		if 1 > countFavoriteCollections then
			set namesFavoriteCollections to {}
		else
			set namesFavoriteCollections to (get items (topUserCollectionIndex + 1) thru countTopCollections of namesTopCollections)
		end if
		
		set selectedCollectionMirroredAtTopLast to false
	end if
	
	local selectedCollectionIsUser, namesTopUserCollections, kindsTopUserCollections_s, countTopUserCollections
	
	if (topUserCollectionIndex < bottomUserCollectionIndex) or (0 = topUserCollectionIndex) then
		set {topUserCollectionIndex, bottomUserCollectionIndex} to {missing value, missing value}
		set {namesTopUserCollections, kindsTopUserCollections_s, countTopUserCollections} to {{}, {}, 0}
	else
		set {namesTopUserCollections, kindsTopUserCollections_s} to {(get items bottomUserCollectionIndex thru topUserCollectionIndex of namesTopCollections), (get items bottomUserCollectionIndex thru topUserCollectionIndex of kindsTopCollections_s)}
		set countTopUserCollections to count of namesTopUserCollections
	end if
	
	return {hasErrors:false, namesTopUserCollections:namesTopUserCollections, kindsTopUserCollections_s:kindsTopUserCollections_s, countTopUserCollections:countTopUserCollections, selectedCollectionRef:selectedCollectionRef, selectedCollectionIndex:selectedCollectionIndex, kindSelectedCollection_s:kindSelectedCollection_s, nameSelectedCollection:nameSelectedCollection, selectedCollectionMirroredAtTopLast:selectedCollectionMirroredAtTopLast, selectedCollectionIsUser:selectedCollectionIsUser, bottomUserCollectionIndex:bottomUserCollectionIndex, topUserCollectionIndex:topUserCollectionIndex, countFavoriteCollections:countFavoriteCollections, namesFavoriteCollections:namesFavoriteCollections}
	
end validateCOPcollections5

on validateCOcollection6(theDocRef)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General purpose initialisation handler for scripts using Capture One Pro
	## Extract basic information regarding the current collection
	global debugLogEnable
	local collectionRef, collectionName, collectionKind_s, collectionId, collectionUser, collectionIsMirrored, docKind_p, docKind_s, selectedCollectionIsUser, collectionIsAllImages
	
	tell application "Capture One 20" to tell theDocRef
		set docKind_p to kind
		set collectionRef to get current collection
		if (missing value = collectionRef) then
			set current collection to first collection
			set collectionRef to get current collection
			if debugLogEnable then my loqThis(0, true, "No collection was selected - selected the first collection")
		end if
		tell collectionRef to set {collectionName, collectionKind_s, collectionId, collectionUser} to {name, my convertKindList(kind), id, user}
		if debugLogEnable then my loqThis(2, false, ("Collection:  Name-" & collectionName & ";  Kind-" & collectionKind_s & "; ID-" & collectionId & "; User-" & collectionUser))
		if (docKind_p = session) then
			tell application "Capture One 20" to tell theDocRef to set selectedCollectionIsUser to ¬
				collectionUser and (missing value = (get folder of collectionRef))
			if debugLogEnable then my loqThis(2, false, ("Session Collection Is User: " & selectedCollectionIsUser))
			set collectionIsMirrored to false
		else if (docKind_p = catalog) then
			set selectedCollectionIsUser to collectionUser
			set collectionIsMirrored to collectionUser and (collectionId = (get id of last collection))
			if debugLogEnable then my loqThis(2, false, ("Catalog Collection Is Mirrored at Top Last: " & collectionIsMirrored))
			set collectionIsAllImages to (not collectionUser) and (collectionId = (get id of first collection))
		else
			tell application "Capture One 20" to set docKind_s to (docKind_p as text)
			return {hasErrors:true, errorText:(get my loqqed_Error_Halt5("validateCOcollection6 received an unexpected Document Kind: " & docKind_s))}
		end if
	end tell
	
	return {hasErrors:false, selectedCollectionRef:collectionRef, selectedCollectionKind_s:collectionKind_s, selectedCollectionName:collectionName, selectedCollectionMirroredAtTopLast:collectionIsMirrored, selectedCollectionIsUser:selectedCollectionIsUser, selectedCollectionID:collectionId, selectedCollectionIsAllImages:collectionIsAllImages}
end validateCOcollection6

on convertKindList(theKind)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General Purpose Handler for scripts using Capture One Pro
	## Capture One returns the chevron form of the "kind" property when AppleScript is run as an Application
	## Unless care is taken to avoid text conversion of this property, this bug breaks script decisions based on "kind"
	## This script converts text strings with the chevron form to strings with the expected text form
	## The input may be a single string, a single enum, a list of strings or a list of enums
	## The code is not compact but runs very fast, between 60us and 210us per item 
	
	local kind_sl, theItem, kindItem_s, code_start, kindItem_s, kind_code, kind_type
	
	if list = (class of theKind) then
		set kind_sl to {}
		repeat with theItem in theKind
			set the end of kind_sl to convertKindList(theItem)
		end repeat
		return kind_sl
	else if text = (class of theKind) then
		if "«" ≠ (get text 1 of theKind) then return theKind
		set kindItem_s to theKind
	else
		tell application "Capture One 20" to set kindItem_s to (get theKind as text)
		if "«" ≠ (get text 1 of kindItem_s) then return kindItem_s
	end if
	
	set code_start to -5
	if ("»" ≠ (get text -1 of kindItem_s)) or (16 > (count of kindItem_s)) then ¬
		error (get my loqqed_Error_Halt5("convertKindList received an unexpected Kind string: " & kindItem_s))
	
	set kind_code to get (text code_start thru (code_start + 3) of kindItem_s)
	set kind_type to get (text code_start thru (code_start + 1) of kindItem_s)
	
	if kind_type = "CC" then ## Collection Kinds
		if kind_code = "CCpj" then
			return "project"
		else if kind_code = "CCgp" then
			return "group"
		else if kind_code = "CCal" then
			return "album"
		else if kind_code = "CCsm" then
			return "smart album"
		else if kind_code = "CCfv" then
			return "favorite"
		else if kind_code = "CCff" then
			return "catalog folder"
		end if
		
	else if kind_type = "CL" then ## Layer Kinds
		if kind_code = "CLbg" then
			return "background"
		else if kind_code = "CLnm" then
			return "adjustment"
		else if kind_code = "CLcl" then
			return "clone"
		else if kind_code = "CLhl" then
			return "heal"
		end if
		
	else if kind_type = "CR" then ## Watermark Kinds
		if kind_code = "CRWn" then
			return "none"
		else if kind_code = "CRWt" then
			return "textual"
		else if kind_code = "CRWi" then
			return "imagery"
		end if
		
	else if kind_type = "CO" then ## Document Kinds
		if kind_code = "COct" then
			return "catalog"
		else if kind_code = "COsd" then
			return "session"
		end if
	end if
	
	error (get my loqqed_Error_Halt5("convertKindList received an unexpected Kind string: " & kindItem_s))
	
end convertKindList

on InitializeResultsCollection(nameResultProject, nameResultAlbumRoot, Coll_Init_Text)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General Purpose Handler for scripts using Capture One Pro
	## Sets up a project and albums for collecting images
	
	global debugLogEnable, C1, Loqqing
	local coll_ctr, nameResultAlbum, resultProjectList, Coll_Init_Text, ref2ResultAlbum
	
	tell application "Capture One 20" to tell C1's COPDocRef
		if 0 = (get count of (collections whose name is nameResultProject and user is true)) then
			set ref2ResultProject to make new collection with properties {kind:project, name:nameResultProject}
			if debugLogEnable then my loqThis(1, false, ("Created " & nameResultProject))
		else
			set resultProjectList to collections whose name is nameResultProject and kind is project
			if 1 = (count of resultProjectList) then
				set ref2ResultProject to first item of resultProjectList
				if debugLogEnable then my loqThis(1, false, ("Found " & nameResultProject))
			else
				error (get my loqqed_Error_Halt5("A user collection named \"" & nameResultProject & "\" already exists, and it is not a project."))
			end if
		end if
	end tell
	
	set coll_ctr to 1
	set nameResultAlbum to nameResultAlbumRoot & "_" & (get short date string of (get current date)) & "_"
	repeat
		tell application "Capture One 20" to tell ref2ResultProject
			if not (exists collection named (get nameResultAlbum & coll_ctr)) then
				set nameResultAlbum to (get nameResultAlbum & coll_ctr)
				set ref2ResultAlbum to make new collection with properties {kind:album, name:nameResultAlbum}
				exit repeat
			else
				set coll_ctr to coll_ctr + 1
			end if
		end tell
	end repeat
	
	if 0 < length of Coll_Init_Text then set Coll_Init_Text to Coll_Init_Text & ": "
	my loqThis(0, false, (Coll_Init_Text & nameResultProject & ">" & nameResultAlbum))
	
	return ref2ResultAlbum
end InitializeResultsCollection

on findParentColl(thisCollRef)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General purpose handler to find the parent of a collection
	## July 14 2020
	global debugLogEnable
	local errorText, errorText1, parentStringList, refPtr, docPtr, docName, parentPtr, parentRefList, startPtr, stopPtr
	tell application "Capture One 20"
		if (document = (class of thisCollRef)) then
			if debugLogEnable then my loqThis(2, false, "Returned the document reference, no other parents")
			return {thisCollRef}
		end if
		if (collection ≠ (class of thisCollRef)) then error my loqqed_Error_Halt5("findParentColl's parameter is not a collection or a document")
	end tell
	
	if debugLogEnable then my loqThis(2, false, "Starting Parent Search")
	try
		get || of {thisCollRef} -- intentionally create an error
	on error errorText
		if debugLogEnable then my loqThis(5, false, "Full error text \"" & errorText & "\"")
	end try
	## Extract the string between "{" and "}"
	repeat with startPtr from 1 to count of errorText
		if "{" = text startPtr of errorText then exit repeat
	end repeat
	repeat with stopPtr from -1 to -(count of errorText) by -1
		if "}" = text stopPtr of errorText then exit repeat
	end repeat
	set errorText to my removeLeadingTrailingSpaces((text (startPtr + 1) thru (stopPtr - 1) of errorText))
	## if script runs as an application "collection" is replaced by "«class COcl»", fix that
	if "«class COcl»" = text 1 thru 12 of errorText then set errorText to my replaceText(errorText, "«class COcl»", "collection")
	set parentStringList to my splitStringToList(errorText, "of") -- make a list of references
	if debugLogEnable then my loqThis(4, false, "Processed error text \"" & errorText & "\"")
	
	repeat with docPtr from (count of parentStringList) to 0 by -1
		try
			if "document" = first word of item docPtr of parentStringList then exit repeat
		end try
	end repeat
	set {docPtr, parentRefList} to {(docPtr + 0), {}}
	if 0 = docPtr then error my loqqed_Error_Halt5("findParentColl couldn't find \"document\" in the string \"" & errorText & "\"")
	set docName to my removeLeadingTrailingSpaces((get item 2 of my splitStringToList((my removeLeadingTrailingSpaces((get item docPtr of parentStringList))), "\"")))
	tell application "Capture One 20" to copy (document docName) to beginning of parentRefList
	if debugLogEnable then my loqThis(5, false, ("Found Document Reference \"" & (get parentStringList's item docPtr) & "\""))
	repeat with parentPtr from 1 to docPtr
		if "collection" = (first word of item parentPtr of parentStringList) then exit repeat
	end repeat
	set parentPtr to parentPtr + 1
	if (parentPtr > docPtr) then error my loqqed_Error_Halt5("findParentColl is unable to find the starting collection in the string \"" & errorText & "\"")
	repeat with refPtr from docPtr - 1 to parentPtr by -1
		if debugLogEnable then my loqThis(5, false, ("Collection Reference \"" & (get parentStringList's item refPtr) & "\""))
		tell application "Capture One 20" to tell (first item of parentRefList) to copy (collection id (get last word of parentStringList's item refPtr)) to beginning of parentRefList
	end repeat
	return parentRefList
end findParentColl

##  Loqqing_1300.scpt  #########################################################################
## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
## Logging Handlers  Version 1300 2020/04/14

## Dependencies  my joinListToString    my GetTick_Now()

## Definitions for debugLogLevel which is used  to define the level of reporting and logging
##	-1 		Results 
##	0		Critical errors
##	1		Verbose results
##	2		Managed Exceptions
##	3		Action and Results
##	4		Simple diagnostics
##	5		Detailed diagnostics
##	6		Very long diagnostics
##
##	Only levels ≤ debugLogLevel are reported
##  Levels -1 and 0 are always reported
##

on initLoqqingGlobals(debugLogLevel, Script_Title, posix2PrefFile, gateResultsFile, path2ResultsFiles, enableReadPrefs, enableWritePrefs)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## Handler to setup the Global Variables used by the loqqing system at the start of the script
	## loqResultDocRef is kept separate from Loqqing to allow easy listing of Loqqing
	-- , enableReadPrefs, enableWritePrefs
	global debugLogEnable, Loqqing, parent_name
	global loqResultDocRef, loqResultMethod, loqDialogTextList, loqClipboardTextS
	## Setup for logging during initialisation 
	## Setup for logging without GUI and prefs file 
	## controlled by the enable settings only
	## Logging by Clipboard, Notifications and Logging
	## LoqqingVersion is not copied into Loqqing, not need without GUI
	
	set {loqResultDocRef, loqResultMethod, loqDialogTextList, loqClipboardTextS} to {false, "Preliminary - Clipboard", (get Script_Title & " Startup"), (get Script_Title & " Startup")}
	## the last word of the first line of loqDialogTextList and loqClipboardTextS must be "Startup"
	
	set debugLogEnable to (get debugLogLevel > 0)
	
	set Loqqing to {stateResultDoc:false, gateResultsFile:gateResultsFile, enableResultsFile:false, initResultDoc:false, nameResultDoc:(Script_Title & ".txt"), ResultsFileMaxDebug:0} & ¬
		{stateResultsByClipboard:false, gateResultsByClipboard:false, enableResultsByClipboard:true, initResultsByClipboard:false, clipboardMaxDebug:6} & ¬
		{stateResultsByDialog:false, gateResultsDialog:false, enableResultsByDialog:false, maxDialogPercent:50, maxDialogLines:25, maxDialogChar:1000, dialogTimeout:20} & ¬
		{stateResultsByNotification:false, gateResultsNotification:false, enableResultsByNotifications:false, enableDebugNotifications:false, notificationsMaxDebug:0} & ¬
		{stateResultsByLoq:false, gateParentLoqqing:true, enableResultsByLoq:true, initLoqqing:false, enableDebugByLoq:false} & ¬
		{enableCompleteAlert:false, gateScriptProgressBar:false, enableScriptProgressBar:false} & ¬
		{debugLogLevel:(0 + debugLogLevel), path2ResultsFiles:path2ResultsFiles, enableReadPrefs:enableReadPrefs, enableWritePrefs:enableWritePrefs} & ¬
		{posix2PrefFile:posix2PrefFile, LoqVersion:LoqqingVersion, fullSetup:false, isChecked:false, enableFastGui:false, Script_Title:Script_Title} & ¬
		{cleanExit:false, errorExit:false, errorExitCtr:0, startTick:my GetTick_Now(), stopTick:0}
	
	if {"Script Editor", "Script Debugger"} contains parent_name then
		set Loqqing's enableDebugByLoq to true
		set loqResultMethod to loqResultMethod & ", Logs"
	else
		set Loqqing's enableDebugNotifications to true
		set loqResultMethod to loqResultMethod & ", Notifications"
	end if
	
	return LoqqingVersion
end initLoqqingGlobals

on saveLoqqingPrefs()
	global Loqqing, debugLogEnable
	set posix2PrefFile to Loqqing's posix2PrefFile
	if ((get Loqqing's posix2PrefFile) = false) or (not Loqqing's fullSetup) then
		loqThis(3, false, "Logging Settings save was bypassed")
		loqThis(4, false, "Unable to save Logging Setup into Preference File: Path-" & (Loqqing's posix2PrefFile) & "; Full Setup-" & (Loqqing's fullSetup))
	else
		tell application "System Events" to tell property list file (get Loqqing's posix2PrefFile)
			if (get name of every property list item) contains "Loqqing" then
				set value of property list item "Loqqing" to Loqqing
			else
				make new property list item at end with properties {kind:record, name:"Loqqing", value:Loqqing}
			end if
		end tell
		if debugLogEnable then loqThis(3, false, "Logging Settings saved into Settings File")
	end if
	if debugLogEnable then loqThis(4, false, "Settings File: Path-" & (Loqqing's posix2PrefFile) & "; Full Setup-" & (Loqqing's fullSetup))
end saveLoqqingPrefs

on loqqed_Error_Halt5(exitReason)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General purpose handler for logging during script termination
	global debugLogEnable, Loqqing
	local plistNames, errorText, errorNumber, lastLine, countErrorExits
	
	if false = (get Loqqing's posix2PrefFile) then
		loqThis(3, false, ("loqqed_Error_Halt5() did not update settings file (expected, not configured)"))
	else
		try
			tell application "System Events" to tell property list file (get Loqqing's posix2PrefFile)
				if (get name of every property list item) contains "Loqqing" then
					tell property list item "Loqqing"
						set value of property list item "stopTick" to my GetTick_Now()
						set countErrorExits to 1 + (value of property list item "errorExit")
						set value of property list item "cleanExit" to false
						set value of property list item "errorExit" to true
						set value of property list item "errorExitCtr" to countErrorExits
					end tell
					my loqThis(3, false, ("loqqed_Error_Halt5 updated settings file for an error exit"))
				else
					my loqThis(2, false, ("loqqedNormalHalt6() error " & "property list item \"Loqqing\" was not found in .plist file"))
				end if
			end tell
		on error errorText number errorNumber
			my loqThis(0, false, ("loqqed_Error_Halt5() error \"" & errorText & "\""))
		end try
	end if
	
	local clipText, exitText
	
	set {clipText, exitText} to {"", ""}
	if Loqqing's enableResultsByClipboard then set clipText to return & "Results are on the clipboard"
	try
		if 0 < (length of (get exitReason as text)) then set exitText to (" Exit Reason: " & exitReason & return)
	end try
	
	tell current application to set lastLine to "Script \"" & Loqqing's Script_Title & "\" exits with error at " & (get (current date) as text)
	loqThis(-1, true, lastLine & exitText & clipText)
	
	loqAnnounceResults(lastLine)
	
	finalCleanup()
	
	return lastLine & exitText
end loqqed_Error_Halt5

on loqqedNormalHalt6()
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General purpose handler for logging during script termination
	global debugLogEnable, Loqqing
	local plistNames, errorText, errorNumber, lastLine
	
	if false = (get Loqqing's posix2PrefFile) then
		loqThis(3, false, ("loqqed_Error_Halt6() did not update settings file (expected, not configured)"))
	else
		try
			tell application "System Events" to tell property list file (get Loqqing's posix2PrefFile)
				if (get name of every property list item) contains "Loqqing" then
					tell property list item "Loqqing"
						set value of property list item "stopTick" to my GetTick_Now()
						set value of property list item "cleanExit" to true
						set value of property list item "errorExit" to false
						set value of property list item "errorExitCtr" to 0
					end tell
					my loqThis(3, false, ("loqqedNormalHalt6() updated settings file for a clean exit"))
				else
					my loqThis(2, false, ("loqqedNormalHalt6() error " & "property list item \"Loqqing\" was not found in .plist file"))
				end if
			end tell
		on error errorText number errorNumber
			my loqThis(0, true, ("loqqedNormalHalt6() error \"" & errorText & "\""))
		end try
	end if
	
	tell current application to set lastLine to "Script \"" & Loqqing's Script_Title & "\" exits normally at " & (get (current date) as text)
	local clipText
	set clipText to ""
	if Loqqing's enableResultsByClipboard then set clipText to return & "Results are on the clipboard"
	loqThis(-1, true, lastLine & clipText)
	loqAnnounceResults(lastLine)
	
	finalCleanup()
	
	return lastLine
end loqqedNormalHalt6

on loqqedNormalHalt7(exitMessage)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General purpose handler for logging during script termination
	global debugLogEnable, Loqqing
	local plistNames, errorText, errorNumber, lastLine
	
	if false = (get Loqqing's posix2PrefFile) then
		loqThis(3, false, ("loqqed_Error_Halt7() did not update settings file (expected, not configured)"))
	else
		try
			tell application "System Events" to tell property list file (get Loqqing's posix2PrefFile)
				if (get name of every property list item) contains "Loqqing" then
					tell property list item "Loqqing"
						set value of property list item "stopTick" to my GetTick_Now()
						set value of property list item "cleanExit" to true
						set value of property list item "errorExit" to false
						set value of property list item "errorExitCtr" to 0
					end tell
					my loqThis(3, false, ("loqqedNormalHalt7() updated settings file for a clean exit"))
				else
					my loqThis(2, false, ("loqqedNormalHalt7() error " & "property list item \"Loqqing\" was not found in .plist file"))
				end if
			end tell
		on error errorText number errorNumber
			my loqThis(0, false, ("loqqedNormalHalt7() error \"" & errorText & "\""))
		end try
	end if
	
	tell current application to set lastLine to "\"" & Loqqing's Script_Title & "\" normal exit at " & (get (current date) as text) & exitMessage
	
	local clipText
	set clipText to ""
	if Loqqing's enableResultsByClipboard then set clipText to return & "Results are on the clipboard"
	loqThis(-1, true, lastLine & clipText)
	loqAnnounceResults(lastLine)
	
	finalCleanup()
	
	return lastLine
end loqqedNormalHalt7

on loqAnnounceResults(lastLine)
	global debugLogEnable, loqClipboardTextS, parent_name, Loqqing
	local announceText
	tell application "System Events" to set frontmost of process parent_name to true
	set announceText to "\"" & Loqqing's Script_Title & "\" has completed"
	if Loqqing's enableResultsByClipboard then
		set the clipboard to loqClipboardTextS
		set announceText to announceText & return & "Results are on the clipboard"
	end if
	
	## Avoiding Duplicate notifications and alerts
	if not Loqqing's enableResultsByNotifications then display notification announceText
	if Loqqing's enableCompleteAlert and not Loqqing's enableResultsByDialog then display alert announceText
end loqAnnounceResults

on loqGUIsettings2(theGuiData)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General Purpose handler that creates the settings list for the Settings GUI for all the settings
	
	script ResultsMgr_S
		on resolve()
			## Gets called after any change to ResultsByClipboard, ResultsByDialog, ResultsFile, enableResultsByLoq, ResultsByNotifications
			global debugLogEnable, loqResultMethod, Loqqing
			set loqResultMethod to setupLoqqing6()
		end resolve
		
		on preConfig()
			global Result_DocName, loqResultMethod
			set loqResultMethod to setupLoqqing6()
			return return & "Result Reporting: " & loqResultMethod & return
		end preConfig
		
		on postConfig()
			## Gets called before and after the GUI runs
			global Result_DocName, loqResultMethod, Loqqing
			if not (Loqqing's enableResultsByClipboard or Loqqing's enableResultsByDialog or Loqqing's enableResultsFile or Loqqing's enableResultsByLoq or Loqqing's enableResultsByNotifications) then
				## search for some kind of enabled result reporting and turn it on
				## in order of preference
				if Loqqing's gateParentLoqqing then
					set Loqqing's enableResultsByLoq to true
				else if Loqqing's gateResultsFile then
					set Loqqing's enableResultsFile to true
				else
					if Loqqing's gateResultsNotification then set Loqqing's enableDebugNotifications to true
					if Loqqing's gateResultsDialog then
						set Loqqing's enableResultsByDialog to true
					else if Loqqing's gateResultsClipboard then
						set Loqqing's enableResultsByClipboard to true
					else if Loqqing's gateResultsNotification then
						set Loqqing's enableResultsByNotifications to true
					end if
				end if
				
				set loqResultMethod to setupLoqqing6()
				display alert "All methods of reporting results have been disabled!! " message ("Enabling result reporting by " & loqResultMethod) as critical giving up after 30
			else
				set loqResultMethod to setupLoqqing6()
			end if
			return return & "Result Reporting: " & loqResultMethod & return
		end postConfig
	end script
	
	script DebugMgr_S
		on resolve()
			global debugLogEnable, loqResultMethod, Loqqing
			set loqResultMethod to setupLoqqing6()
		end resolve
	end script
	
	local helpdebugLogLevel, helpMaxDebug, helpMaxDialog, helpFastGUI
	set helpdebugLogLevel to "Maximum level of debug info reported"
	set helpMaxDebug to "Maximum level of debug data in TextEdit file"
	set helpMaxNotifications to "Maximum level of debug data in Notifications"
	set helpMaxDialog to "Percentage of screen fill that triggers a Dialog report"
	set helpFastGUI to "Disables Free Input for a faster workflow"
	
	global debugLogEnable, Loqqing
	local settingList, scriptList, theSetting_r
	
	set settingList to {}
	set end of settingList to {s_ID:0, s_Name:"Alert when Script ends", s_Value:(a reference to Loqqing's enableCompleteAlert), s_UserSet:true, s_Active:true, s_Class:"Boolean"}
	set end of settingList to {s_ID:0, s_Name:"Report Results by Text File", s_Value:(a reference to Loqqing's enableResultsFile), s_UserSet:true, s_Active:Loqqing's gateResultsFile, s_Class:"Boolean", s_Script:ResultsMgr_S}
	set end of settingList to {s_ID:0, s_Name:"Report Results by Logging", s_Value:(a reference to Loqqing's enableResultsByLoq), s_UserSet:true, s_Active:(a reference to Loqqing's gateParentLoqqing), s_Class:"Boolean", s_Script:ResultsMgr_S}
	set end of settingList to {s_ID:0, s_Name:"Report Results by Clipboard", s_Value:(a reference to Loqqing's enableResultsByClipboard), s_UserSet:true, s_Active:Loqqing's gateResultsByClipboard, s_Class:"Boolean", s_Script:ResultsMgr_S}
	set end of settingList to {s_ID:0, s_Name:"Report Results by Dialogs", s_Value:(a reference to Loqqing's enableResultsByDialog), s_UserSet:true, s_Active:Loqqing's gateResultsDialog, s_Class:"Boolean", s_Script:ResultsMgr_S}
	set end of settingList to {s_ID:0, s_Name:"Dialog Timeout (s)", s_Help:helpMaxDialog, s_Value:(a reference to Loqqing's dialogTimeout), s_UserSet:true, s_Active:(a reference to Loqqing's enableResultsByDialog), s_Class:"Integer", s_LType:"ExMin&ExMax", s_Limit_L:{0, 120}}
	set end of settingList to {s_ID:0, s_Name:"Length of Dialog Report (%)", s_Help:helpMaxDialog, s_Value:(a reference to Loqqing's maxDialogPercent), s_UserSet:true, s_Active:(a reference to Loqqing's enableResultsByDialog), s_Class:"Integer", s_LType:"ExMin&InMax", s_Limit_L:{0, 100}, s_Script:ResultsMgr_S}
	set end of settingList to {s_ID:0, s_Name:"Report Results by Notifications", s_Value:(a reference to Loqqing's enableResultsByClipboard), s_UserSet:true, s_Active:Loqqing's gateResultsNotification, s_Class:"Boolean", s_Script:ResultsMgr_S}
	set end of settingList to {s_ID:0, s_Name:"Enable Script Window's Progress Bar", s_Value:(a reference to Loqqing's enableScriptProgressBar), s_UserSet:true, s_Active:(a reference to Loqqing's gateScriptProgressBar), s_Class:"Boolean"}
	set end of settingList to {s_ID:0, s_Name:"++++", s_Value:missing value, s_UserSet:missing value, s_Active:true}
	set end of settingList to {s_ID:0, s_Name:"Debug Level", s_Help:helpdebugLogLevel, s_Value:(a reference to Loqqing's debugLogLevel), s_UserSet:true, s_Active:true, s_Class:"Integer", s_LType:"InMin&InMax", s_Limit_L:{0, 6}, s_Script:DebugMgr_S}
	set end of settingList to {s_ID:0, s_Name:"Max Debug Level in Text File", s_Help:helpMaxDebug, s_Value:(a reference to Loqqing's ResultsFileMaxDebug), s_UserSet:true, s_Active:(a reference to Loqqing's enableResultsFile), s_Class:"Integer", s_LType:"InMin&InMax", s_Limit_L:{0, 6}}
	set end of settingList to {s_ID:0, s_Name:"Max Debug Level in Clipboard", s_Help:helpMaxNotifications, s_Value:(a reference to Loqqing's clipboardMaxDebug), s_UserSet:true, s_Active:(a reference to Loqqing's enableResultsByClipboard), s_Class:"Integer", s_LType:"InMin&InMax", s_Limit_L:{0, 6}}
	set end of settingList to {s_ID:0, s_Name:"Report Debug by Notifications", s_Value:(a reference to Loqqing's enableDebugNotifications), s_UserSet:Loqqing's gateResultsNotification, s_Active:true, s_Class:"Boolean", s_Script:ResultsMgr_S}
	set end of settingList to {s_ID:0, s_Name:"Max Debug Level in Notifications", s_Help:helpMaxNotifications, s_Value:(a reference to Loqqing's notificationsMaxDebug), s_UserSet:true, s_Active:(a reference to Loqqing's enableDebugNotifications), s_Class:"Integer", s_LType:"InMin&InMax", s_Limit_L:{0, 2}}
	
	set theGuiData's guiRecordList to theGuiData's guiRecordList & settingList
	set theGuiData's guiScriptList to theGuiData's guiScriptList & {ResultsMgr_S}
	set theGuiData's guiParams's guiChecked to a reference to Loqqing's isChecked
	
	return null
end loqGUIsettings2

on setupLoqqing6()
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## Handler to initialize logging of results
	## Do  use loq_Results() until the end of the handler and initialising is completed
	## Doesn't set loqResultMethod, this is set by caller of this handler
	
	global debugLogEnable
	global parent_name, Loqqing, loqDialogTextList, loqResultDocRef, loqClipboardTextS
	
	set debugLogEnable to (0 < (get Loqqing's debugLogLevel))
	
	local LogMethods, LogHeader, date_string, originLine, initLoqCache, errorText, errorNumber
	tell current application to set date_string to (current date) as text
	set LogMethods to {}
	set LogHeader to ("Script \"" & Loqqing's Script_Title & "\" results on " & date_string)
	set originLine to (" by \"" & Loqqing's Script_Title & "\" on " & date_string)
	if debugLogEnable then loqThis(3, false, "setupLoqqing6: Script Title \"" & Loqqing's Script_Title & "\"")
	
	set initLoqCache to ""
	if (0 < (count paragraphs of loqClipboardTextS)) and ¬
		(0 < (count words of loqClipboardTextS's first paragraph)) and ¬
		("Startup" = (get loqClipboardTextS's first paragraph's last word)) then -- capture startup logs
		if (1 < (count paragraphs of loqClipboardTextS)) then ¬
			set initLoqCache to "Cached Events:" & return & "---" & loqClipboardTextS & return & "---"
		set loqClipboardTextS to ""
	end if
	
	local TextEditlist, DocName_Ext
	if not Loqqing's gateResultsFile then
		set {Loqqing's stateResultDoc, Loqqing's enableResultsFile, Loqqing's initResultDoc} to {false, false, false}
	else
		if debugLogEnable then loqThis(4, false, "Name Result Doc \"" & (Loqqing's nameResultDoc) & "\";  Enable Results File: " & (Loqqing's enableResultsFile) & ";  Init Results File: " & (Loqqing's initResultDoc))
		if Loqqing's enableResultsFile then
			set DocName_Ext to Loqqing's nameResultDoc
			set end of LogMethods to "TextEdit: " & DocName_Ext
			if not Loqqing's initResultDoc then
				## initResultDoc means that we have a valid loqResultDocRef and a header has been written 
				set Loqqing's stateResultDoc to false -- insurance
				
				## If TextEdit is already open and has the document open then add the header
				tell application "System Events" to set TextEditlist to get background only of every application process whose name is "TextEdit"
				if (0 < (count of TextEditlist)) and not item 1 of TextEditlist then
					if (DocName_Ext is in (get name of documents of application "TextEdit")) then
						tell application "TextEdit" to tell document DocName_Ext
							set loqResultDocRef to it
							tell its text to set paragraph (1 + (count paragraphs)) to return & "-----" & return & LogHeader & return
						end tell
						set Loqqing's initResultDoc to true
						if debugLogEnable then loqThis(3, false, "Path to \"" & DocName_Ext & "\" obtained" & originLine)
					end if
				end if
				
				local targetFileWasCreated, targetFolderParent_a, targetFolderParent_p, targetFolderName, targetFolder_a, targetFolder_p, ResultDocPath_a, ResultDocPath_p, newFolderRef, newFileRef
				if (not Loqqing's initResultDoc) then
					## Do the full intialization since the document was not open
					set targetFileWasCreated to false
					set targetFolder_a to alias (get Loqqing's path2ResultsFiles)
					set targetFolder_p to get POSIX path of targetFolder_a
					set ResultDocPath_p to targetFolder_p & "/" & DocName_Ext
					if debugLogEnable then loqThis(3, false, " Initializing \"" & DocName_Ext & "\" in \"" & targetFolder_p & "\"")
					
					try
						set ResultDocPath_a to (get alias POSIX file ResultDocPath_p)
						if debugLogEnable then loqThis(4, false, "File " & ResultDocPath_p & "  Exists")
					on error errorText number errorNumber -- create the document
						tell application "Finder" to set newFileRef to make new file at targetFolder_a with properties {name:DocName_Ext}
						set ResultDocPath_a to newFileRef as alias
						set targetFileWasCreated to true
					end try
					
					tell application "TextEdit" -- open the document and add the first line if empty
						activate
						set loqResultDocRef to open ResultDocPath_a
						tell text of loqResultDocRef
							if targetFileWasCreated then
								set paragraph 1 to "Created" & originLine & return
								my loqThis(3, false, ResultDocPath_p & "  Created" & originLine)
							else
								if (0 = (count of paragraphs)) then
									set paragraph 1 to "Initialised" & originLine & return
									my loqThis(3, false, ResultDocPath_p & " Initialised" & originLine)
								end if
							end if
						end tell
					end tell
					set Loqqing's initResultDoc to true -- prevents initialisation from repeating
					tell application "TextEdit" to tell text of loqResultDocRef to ¬
						set paragraph (1 + (count paragraphs)) to return & LogHeader & return
				end if
				## before the results document is initalized, logged events are stored in loqClipboardTextS, copy those to the results document
				if ("" ≠ initLoqCache) then tell application "TextEdit" to tell text of loqResultDocRef to ¬
					set paragraph (1 + (count paragraphs)) to initLoqCache
				
			else
				if debugLogEnable then loqThis(3, false, "\"" & DocName_Ext & "\" already initialized")
			end if
			if Loqqing's initResultDoc then
				set Loqqing's stateResultDoc to true
			else
				loqThis(-1, true, "Unable to intialize results document")
				set {Loqqing's stateResultDoc, Loqqing's enableResultsFile} to {false, false}
			end if
		end if
		if Loqqing's stateResultDoc and not Loqqing's enableResultsFile then
			set Loqqing's stateResultDoc to false
			tell application "TextEdit" to tell text of loqResultDocRef to ¬
				set paragraph (1 + (count paragraphs)) to return & parent_name & "Results reporting disabled for: " & Loqqing's Script_Title & return
		end if
	end if
	
	local screenWidthO, screenHeightO, screenWidth, screenHeight, fontSize_pts, charactersPerLine, dotsPer_Point, linesPerScreen, borderWidth
	if not Loqqing's gateResultsDialog then
		set {Loqqing's stateResultsByDialog, Loqqing's enableResultsByDialog} to {false, false}
	else
		if Loqqing's enableResultsByDialog then
			set end of LogMethods to "Dialogs"
			if not Loqqing's stateResultsByDialog then
				set loqDialogTextList to (get LogHeader & return)
				set Loqqing's stateResultsByDialog to true
			end if
			## Debugged with the largest and smallest Mac screens - 11"MBA and 27" iMac
			tell application "Finder" to set {screenWidthO, screenHeightO, screenWidth, screenHeight} to bounds of window of desktop
			set fontSize_pts to 12 -- estimated font size for display dialog, including line spacing
			set charactersPerLine to 58 -- estimated characters per line for display dialog, if there are no "return" characters
			set dotsPer_Point to 1.5 -- similar for 5K 27" iMac and 11" MBA - similar for others -  retina independent
			set linesPerScreen to (screenHeight - screenHeightO) / (fontSize_pts * dotsPer_Point)
			set borderWidth to 5 -- lines
			set Loqqing's maxDialogLines to (get ((Loqqing's maxDialogPercent) / 100 * (linesPerScreen - borderWidth)) as integer)
			set Loqqing's maxDialogChar to (get (charactersPerLine * (Loqqing's maxDialogLines)) as integer)
			if debugLogEnable then loqThis(4, false, ("maxDialogPercent-" & (Loqqing's maxDialogPercent) & "; screenHeight-" & (screenHeight) & "; linesPerScreen-" & (linesPerScreen) & "; maxDialogLines-" & (Loqqing's maxDialogLines) & "; maxDialogChar-" & (Loqqing's maxDialogChar)))
		else if Loqqing's stateResultsByDialog then
			set Loqqing's stateResultsByDialog to false
			--set loqDialogTextList to ""
		end if
	end if
	
	if not Loqqing's gateResultsByClipboard then
		set {Loqqing's stateResultsByClipboard, Loqqing's enableResultsByClipboard} to {false, false}
	else
		if Loqqing's enableResultsByClipboard then
			if not Loqqing's initResultsByClipboard then
				set loqClipboardTextS to (LogHeader & return) -- extra line
				set Loqqing's initResultsByClipboard to true
				if ("" ≠ initLoqCache) then set loqClipboardTextS to return & loqClipboardTextS & initLoqCache & return -- extra line
			end if
			if not Loqqing's stateResultsByClipboard then
				set Loqqing's stateResultsByClipboard to true
				set loqClipboardTextS to loqClipboardTextS & return & "Clipboard Results enabled"
			end if
		else if Loqqing's stateResultsByClipboard then
			set Loqqing's stateResultsByClipboard to false
			set loqClipboardTextS to loqClipboardTextS & return & "Clipboard Results disabled"
		end if
	end if
	
	set Loqqing's gateScriptProgressBar to (get ("Script Editor" = parent_name)) -- gateScriptProgressBar  controls user's ability to set progress bar in the Script Editor window
	if not Loqqing's gateScriptProgressBar then set Loqqing's enableScriptProgressBar to false
	
	if {"Script Editor", "Script Debugger"} contains parent_name then set Loqqing's enableDebugByLoq to true
	## enableDebugByLoq  sets the logging of debug information
	## Don't capture initLoqCache - if enableDebugByLoq would be true then it is already captured.
	
	## Logging of results -- gateParentLoqqing  controls user's ability to set logging of results
	if Loqqing's gateResultsNotification and Loqqing's enableResultsByLoq and not Loqqing's initLoqqing then
		set Loqqing's stateResultsByLoq to false
		if ("Script Editor" = parent_name) then
			try -- Open the Log History window
				tell application "System Events" to tell application process "Script Editor"
					if (get name of windows) does not contain "log History" then ¬
						click menu item "Log History" of menu "Window" of menu bar 1
				end tell
			end try
			set Loqqing's initLoqqing to true
		else if ("Script Debugger" = parent_name) then
			try
				## Script avoids compiler errors when Script Debugger is not installed
				run script "tell application \"Script Debugger\" to tell first document to set event log visible to true"
				run script "tell application \"Script Debugger\" to tell first document to set event log scope bar visible to true"
			end try
			set Loqqing's initLoqqing to true
		else
			tell Loqqing to set {its gateParentLoqqing, enableResultsByLoq} to {false, false}
		end if
	end if
	
	if not Loqqing's gateParentLoqqing then
		tell Loqqing to set {its stateResultsByLoq, its enableResultsByLoq} to {false, false}
	else if Loqqing's enableResultsByLoq then
		set end of LogMethods to " " & parent_name & " Log"
		if not Loqqing's stateResultsByLoq then
			set Loqqing's stateResultsByLoq to true
			if debugLogEnable then loqThis(3, false, "Results Logging enabled for: " & Loqqing's Script_Title)
		end if
	else if Loqqing's stateResultsByLoq then
		set Loqqing's stateResultsByLoq to false
		if debugLogEnable then loqThis(3, false, "Results Logging disabled for: " & Loqqing's Script_Title)
	end if
	
	if not Loqqing's gateResultsNotification then
		set {Loqqing's stateResultsByNotification, Loqqing's enableResultsByNotifications} to {false, false}
	else
		if Loqqing's enableResultsByNotifications then
			set end of LogMethods to "Notifications"
			set Loqqing's stateResultsByNotification to true
		else if Loqqing's stateResultsByNotification then
			display notification "Notifications disabled for: " & Loqqing's Script_Title
			set Loqqing's stateResultsByNotification to false
		end if
	end if
	
	set LogMethods_S to my joinListToString(LogMethods, ", ")
	if debugLogEnable then loqThis(3, false, ("Result Reported by " & LogMethods_S))
	return LogMethods_S
end setupLoqqing6

on loqThis(thisLogDebugLevel, MakeFront, log_Text)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General purpose handler for logging results
	## log results if the debug level of the message is below the the threshold set by debugLogLevel
	## log the results by whatever mechanism is enabled - {Script Editor Log, Text Editor Log, Display Dialog}
	
	global debugLogEnable
	global parent_name, Loqqing, loqDialogTextList, loqResultDocRef, loqClipboardTextS
	local log_Text_S, dialogTriggeredMakeFront
	
	if thisLogDebugLevel > Loqqing's debugLogLevel then return "" -- immediate return if thisLogDebugLevel exceeds threshold
	
	set log_Text_S to my joinListToString(log_Text, "; ")
	set dialogTriggeredMakeFront to false
	
	## Dialog
	if Loqqing's stateResultsByDialog and (thisLogDebugLevel ≤ 0) then
		set loqDialogTextList to (get loqDialogTextList & return & log_Text_S)
		
		if MakeFront or (0 ≥ Loqqing's maxDialogLines) or ¬
			(Loqqing's maxDialogLines < (get count of paragraphs of loqDialogTextList)) or ¬
			(Loqqing's maxDialogChar < (get length of loqDialogTextList)) then
			tell application "System Events" to set frontmost of process parent_name to true
			set dialogTriggeredMakeFront to true
			set dialogResult to display dialog loqDialogTextList with title "Report for " & Loqqing's Script_Title & " (timeout " & (Loqqing's dialogTimeout) & ¬
				"s)" buttons {"Continue", "Hold"} default button "Continue" giving up after Loqqing's dialogTimeout -- assignment prevents Apple Event timeout
			if gave up of dialogResult then set dialogResult to ¬
				display dialog loqDialogTextList with title "Hold this Dialog?" buttons {"Continue", "Hold"} default button "Continue" giving up after 10
			if button returned of dialogResult is "Hold" then set dialogResult to ¬
				display dialog loqDialogTextList with title "Report for " & Loqqing's Script_Title & " (holding) " buttons {"Continue"} default button "Continue"
			set loqDialogTextS to ""
		end if
	end if
	
	## Result Document
	if Loqqing's stateResultDoc and (thisLogDebugLevel ≤ Loqqing's ResultsFileMaxDebug) then ¬
		tell application "TextEdit" to tell text of loqResultDocRef to ¬
			set paragraph (1 + (count paragraphs)) to ((log_Text_S as text) & return)
	
	## Log
	if Loqqing's enableDebugByLoq and (thisLogDebugLevel ≥ 0) then log (log_Text)
	if Loqqing's enableResultsByLoq and (thisLogDebugLevel < 0) then log (log_Text)
	
	## Clipboard
	if Loqqing's enableResultsByClipboard and (thisLogDebugLevel ≤ Loqqing's clipboardMaxDebug) then ¬
		set loqClipboardTextS to (loqClipboardTextS & return & log_Text_S)
	
	## Notifications
	## If a notification has too many characters then the notification system hangs 
	## Constrain it to 3 lines of 39 characters max.
	local paraCtr, notString, lineCnt, paramax, remChar, thePara, thisCount
	if (Loqqing's enableDebugNotifications and (thisLogDebugLevel ≤ Loqqing's notificationsMaxDebug)) or ¬
		(Loqqing's stateResultsByNotification and (thisLogDebugLevel ≤ 0)) then
		set paraCtr to 0
		set notString to ""
		set lineCnt to 39
		set paramax to 3
		copy (get paramax * lineCnt) to remChar
		repeat with thePara in (get paragraphs of (get my joinListToString(log_Text, return)))
			set thisCount to (get count of (get contents of thePara))
			if thisCount > 0 then
				set paraCtr to paraCtr + 1
				if thisCount > remChar then copy remChar to thisCount
				set notString to notString & (get text 1 thru thisCount of thePara)
				set remChar to remChar - lineCnt * (thisCount div lineCnt)
				if (0 < (thisCount mod lineCnt)) then set remChar to remChar - lineCnt
				if (paramax ≤ paraCtr) or (0 ≥ remChar) then exit repeat
				set notString to notString & return
			end if
		end repeat
		display notification notString
	end if
	
	if (not dialogTriggeredMakeFront) and (MakeFront or (0 = thisLogDebugLevel)) then -- 
		if Loqqing's enableDebugByLoq then tell application "System Events" to set frontmost of process parent_name to true
		if Loqqing's stateResultDoc then tell application "System Events" to set frontmost of process "TextEdit" to true
	end if
	return log_Text_S
end loqThis

##  GUI_1300.scpt  ###################################################################
## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
## General GUI Handlers  Version 1300 2020/04/14

## Dependencies
## my  joinListToString   splitStringToList  removeTextFromList  removeLeadingTrailingSpaces  deReference  replaceText  GetTick_Now  isARef
## my   loqThis   loqqed_Error_Halt5  LoqqingVersion  initLoqqingGlobals  setupLoqqing6  saveLoqqingPref

on initGuiGlobals()
	global enableFastGui, checkedGuiData
	set checkedGuiData to false
	set enableFastGui to false
	return {guiRecordList:{}, guiScriptList:{}, guiParams:{guiChecked:false}}
end initGuiGlobals

on initPrefsFromFile(Script_Title, debugLogLevel, errorExitMax, gateReadPrefFiles, gateWritePrefFiles, path2Prefs, gateResultsLogFiles, path2ResultsLogFiles, mainsLoqqingVersion, forceSettingsCheck)
	global debugLogEnable, Loqqing, loqResultDocRef, checkedGuiData
	local path2Prefs, alias2Prefs, posix2Prefs, path2PrefFile, posix2PrefFile, hasPrefFile, verifiedLoqPlist, gotPrefSetUp, this_plistfile, LoqqingVersion, errorText, errorNumber
	local prefsLoqVersion, prefsExitCtr, prefsErrorExit, prefsCleanExit, prefsFullSetup, hasLoqPlist
	set {posix2PrefFile, hasPrefFile, hasLoqPlist, verifiedLoqPlist, gotPrefSetUp} to {false, false, false, false, false}
	
	## very simple logging setup, text edit logging not ready yet, preferences file not read yet
	
	set checkedGuiData to false
	set LoqqingVersion to my LoqqingVersion
	if mainsLoqqingVersion ≠ LoqqingVersion then error my loqqed_Error_Halt5("SW Error: Loqqing Version Mismatch in GUI Library")
	if (gateReadPrefFiles or gateWritePrefFiles) then
		
		set path2PrefFile to path2Prefs & Script_Title & ".plist"
		set posix2PrefFile to (POSIX path of path2PrefFile)
		
		-- Do not use finder to test for the file existence because it has a bug that ignores leading 0's
		-- https://www.macscripter.net/viewtopic.php?id=45178 
		--hasPrefFile, hasLoqPlist, verifiedLoqPlist, gotPrefSetUp
		try
			get path2PrefFile as alias -- check for existance of preferences .plist file
			set hasPrefFile to true
			## now check if its readable and the Preferences are any good
			tell application "System Events"
				set prefsLoqVersion to value of (property list file posix2PrefFile)'s property list item "Loqqing"'s property list item "LoqVersion"
				set hasLoqPlist to true -- minimum condition for readable plist is met
				set prefsExitCtr to value of (property list file posix2PrefFile)'s property list item "Loqqing"'s property list item "errorExitCtr"
				set prefsErrorExit to value of (property list file posix2PrefFile)'s property list item "Loqqing"'s property list item "errorExit"
				set prefsCleanExit to value of (property list file posix2PrefFile)'s property list item "Loqqing"'s property list item "cleanExit"
				set prefsFullSetup to value of (property list file posix2PrefFile)'s property list item "Loqqing"'s property list item "fullSetup"
			end tell
			if (not prefsErrorExit) and (not prefsCleanExit) then set prefsExitCtr to prefsExitCtr + 1
			
			set rejectList to {}
			if not (LoqqingVersion = prefsLoqVersion) then set rejectList to rejectList & "Incorrect Version: Is " & prefsLoqVersion & "  Expected " & LoqqingVersion
			if (prefsExitCtr ≥ errorExitMax) then set rejectList to rejectList & "Error Exit Count too high: Is " & prefsExitCtr & "  Limit " & errorExitMax
			if not prefsFullSetup then set rejectList to rejectList & "Contains a preliminary setup"
			
			if (0 = (get count of rejectList)) then
				set verifiedLoqPlist to true
				my loqThis(3, false, "Preferences file has passed verification")
			else
				set rejectList to (my joinListToString(rejectList, ", ")) & " (File \"" & posix2PrefFile & "\")"
				my loqThis(2, false, "Rejected Preferences file: " & rejectList)
			end if
		on error errorText number errorNumber
			my loqThis(-1, false, ("Got an error reading the preferences file: " & return & errorText & " (" & errorNumber & ")"))
		end try
		
		if gateReadPrefFiles and verifiedLoqPlist then
			## now get the entire Loqqing record
			--hasPrefFile, hasLoqPlist, verifiedLoqPlist, gotPrefSetUp
			try
				tell application "System Events" to tell property list file posix2PrefFile to copy (get value of property list item "Loqqing") to Loqqing
				set gotPrefSetUp to true
				set checkedGuiData to true
			on error errorText number errorNumber
				## something wrong with the file's  plist. State of Loqqing is unknown
				set verifiedLoqPlist to false
				my loqThis(-1, true, ("Could not read the .plist file due to error: " & return & errorText & " (" & errorNumber & ")"))
			end try
			
			if gotPrefSetUp then
				tell Loqqing
					set {its startTick, its stopTick} to {my GetTick_Now(), 0}
					set its posix2PrefFile to posix2PrefFile
					set {its initResultDoc, its stateResultDoc, its initResultsByClipboard, its stateResultsByClipboard, its stateResultsByDialog, its initLoqqing, its stateResultsByLoq, its stateResultsByNotification} to ¬
						{false, false, false, false, false, false, false, false}
					if forceSettingsCheck then set its isChecked to false -- can be true or false when read
					set {its enableReadPrefs, its enableWritePrefs, its Script_Title} to {gateReadPrefFiles, gateWritePrefFiles, Script_Title}
					copy (0 + (its debugLogLevel)) to debugLogLevel
				end tell
				set loqResultMethod to my setupLoqqing6()
				my loqThis(3, false, "Starting with " & loqResultMethod & ";  Loqqing Preferences have been loaded from the .plist file")
			else
				my initLoqqingGlobals(debugLogLevel, Script_Title, posix2PrefFile, gateResultsLogFiles, path2ResultsLogFiles, gateReadPrefFiles, gateWritePrefFiles)
				if debugLogEnable then my loqThis(3, false, ("Loqqing Full Setup, preferences file ignored"))
				set {gotPrefSetUp, verifiedLoqPlist} to {false, false}
			end if
		end if
		
		if gateWritePrefFiles then
			if gotPrefSetUp then
				my saveLoqqingPrefs() -- update preference file with modified settings
			else
				## The preferences file wasn't used
				local parent_dictionary, theFile
				if (not hasPrefFile) or (not hasLoqPlist) or (not verifiedLoqPlist) then -- there is no prefs file, or the prefs file plist cannnot be read, or the prefs file plist cannnot be verified 
					tell application "System Events" -- make a new prefs file
						set the parent_dictionary to make new property list item with properties {kind:record} -- create an empty property list dictionary item
						set theFile to make new property list file with properties {contents:parent_dictionary, name:posix2PrefFile} -- create new property list file using the empty dictionary list item as contents
						tell theFile to make new property list item at end with properties {kind:record, name:"Loqqing", value:{LoqVersion:"0"}}
					end tell
					set Loqqing's posix2PrefFile to posix2PrefFile
					set {hasPrefFile, hasLoqPlist, checkedGuiData} to {true, true, false}
				else
					set Loqqing's posix2PrefFile to posix2PrefFile
					## The preferences file will be updated after full setup is completed
				end if
			end if
		end if
	end if
	return
end initPrefsFromFile

on guisGUiSettings(theGuiData)
	global debugLogEnable, Loqqing
	
	script PrefMgr_S
		on preConfig()
			global debugLogEnable, Loqqing
			local prefMethod, prefFileName
			if (false = (get Loqqing's posix2PrefFile)) then
				set prefMethod to "Settings File not used"
			else
				set prefFileName to last item of my splitStringToList(get Loqqing's posix2PrefFile, "/")
				set prefMethod to "Settings File: " & prefFileName & return
				set prefMethod to prefMethod & "Read Settings: " & (Loqqing's enableReadPrefs) & "  Write Settings: " & (Loqqing's enableWritePrefs) & return
				set prefMethod to return & prefMethod
			end if
			return prefMethod
		end preConfig
		
		on postConfig()
			global debugLogEnable
			preConfig()
		end postConfig
	end script
	
	
	local helpFastGUI, settingList
	set helpFastGUI to "Disables Free Input for a faster workflow"
	set settingList to {}
	set end of settingList to {s_ID:0, s_Name:"Fast WorkFlow", s_Help:helpFastGUI, s_Value:(a reference to Loqqing's enableFastGui), s_UserSet:true, s_Active:true, s_Class:"Boolean"}
	
	set theGuiData's guiParams to {enableFastGui:(a reference to Loqqing's enableFastGui), Script_Title:(get "" & Loqqing's Script_Title)} & theGuiData's guiParams
	set theGuiData's guiRecordList to settingList & theGuiData's guiRecordList
	set theGuiData's guiScriptList to theGuiData's guiScriptList & {PrefMgr_S}
	
	return null
	
end guisGUiSettings

on guiRunSettingsEditor(theGuiData)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General Purpose handler that provides a user interface to control settings for Script
	## This is the main handler that runs the GUI
	
	global debugLogEnable, parent_name
	local nextID, idCtr, scriptList
	local scriptDisplay_S, configDisplay_S, scriptCount, scriptCtr, theScript, legendString
	local usercancelled, errorText, errorNumber, dialog_result
	
	set usercancelled to false
	set scriptList to theGuiData's guiScriptList
	
	set idCtr to 1
	repeat with nextID from 1 to (count of theGuiData's guiRecordList)
		if not (missing value = theGuiData's guiRecordList's record nextID's s_UserSet) then
			set theGuiData's guiRecordList's record nextID's s_ID to idCtr
			if debugLogEnable then my loqThis(4, false, ("Name: \"" & (theGuiData's guiRecordList's record nextID's s_Name) & "\"   ID:" & (theGuiData's guiRecordList's record nextID's s_ID)))
			set idCtr to 1 + idCtr
		end if
	end repeat
	
	guiValidateSettingsRecords(theGuiData)
	
	set {configDisplay_S, scriptCount} to {"", (count of scriptList)}
	if scriptCount > 0 then
		repeat with scriptCtr from 1 to scriptCount
			set theScript to scriptList's script scriptCtr
			try
				set scriptDisplay_S to theScript's preConfig()
				if text = class of scriptDisplay_S then set configDisplay_S to configDisplay_S & scriptDisplay_S
			on error errorText number errorNumber
				if -1708 = errorNumber then
					my loqThis(4, false, "Did not find script " & (get theScript's name) & "'s preConfig() handler")
				else
					my loqThis(2, false, "Got an error from script " & (get theScript's name) & ": " & errorText & " (" & errorNumber & ")")
				end if
			end try
		end repeat
	end if
	
	repeat while not usercancelled
		tell application "System Events" to set frontmost of process parent_name to true
		set settingsDisplay_S to guiMakeSettingsDisplay(theGuiData, true) & configDisplay_S
		set legendString to return & "  • \"Edit\" to edit settings" & return & "  • \"OK\" to continue with these settings" & return & "  • \"Cancel\" to stop now"
		if theGuiData's guiParams's enableFastGui then set legendString to (return & "Disable \"Fast WorkFlow\" to enable more control" & return) & legendString
		set dialog_result to display dialog settingsDisplay_S & legendString with title "Settings for " & theGuiData's guiParams's Script_Title ¬
			buttons {"Cancel Script", "OK", "Edit"} default button "OK"
		if (get dialog_result's button returned) contains "Cancel" then
			my loqThis(3, true, "guiRunSettingsEditor: User Cancelled the Script")
			set usercancelled to true
			exit repeat
		end if
		
		if "OK" = (get button returned of dialog_result) then exit repeat
		
		if "Edit" = (get button returned of dialog_result) then
			set usercancelled to guiSelectSetting(theGuiData)
			
			if theGuiData's guiParams's enableFastGui then exit repeat
		end if
	end repeat
	
	set configDisplay_S to ""
	if scriptCount > 0 then
		repeat with scriptCtr from 1 to scriptCount
			set theScript to scriptList's script scriptCtr
			try
				set scriptDisplay_S to theScript's postConfig()
				if text = class of scriptDisplay_S then set configDisplay_S to configDisplay_S & scriptDisplay_S
			on error errorText number errorNumber
				if -1708 = errorNumber then
					my loqThis(4, false, "Did not find script " & (get theScript's name) & "'s postConfig() handler")
				else
					my loqThis(2, false, "Got an error from script " & (get theScript's name) & ": " & errorText & " (" & errorNumber & ")")
				end if
			end try
		end repeat
	end if
	
	if debugLogEnable then
		set settingsDisplay_S to guiMakeSettingsDisplay(theGuiData, false) & configDisplay_S
		my loqThis(1, false, (return & "Post GUI Settings:" & return & settingsDisplay_S))
	end if
	
	return usercancelled
	
	#############
	## Definition of the Setting record
	## s_ID             ID of the setting (integer)
	## s_Name        Name of the Setting (text)
	## s_Help          Help Text for the Setting (text)
	## s_Value         Value or Reference to the Global Variable which holds the option value (text or reference to {text, integer, real, list})
	## s_UserSet       True if the user can edit this setting (boolean)
	##                          false if the user cannot edit this setting (boolean)
	##                          missing value if this is a static setting - never edited
	## s_Active          True if this setting is used; if false never shown (boolean)
	## S_Invert          Inverts the behaviour of s_Active if True, Ignored otherwise
	## s_Class         Class of the data representing the option  {Boolean, Text, List_Text, Integer, Real} (text)
	## s_LType         How the option values are constrained {false, "Free", "List", "InMin", "InMax",  "ExMin", "ExMax","NoSpace","OkSpace"}
	##                          multiple values in one string are permitted, seperated by "&"
	## s_Limit_L       The list of permissible values of the option (List of Text, List of Integer, List of Real, List of [Min],[Max])
	## s_Block_L      A list of blocked characters
	## s_Script         A script containing a resolve() handler which performs actions after a setting has changed.
	#############
end guiRunSettingsEditor

on guiMakeSettingsDisplay(theGuiData, showSettable)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General Purpose handler that creates a string for displaying the script settings in the settings GUI.
	global debugLogEnable
	local settingsDisplay_S, theSettingRecord, theSettingValueS, xor, settingsList
	set settingsList to theGuiData's guiRecordList
	set settingsDisplay_S to ""
	repeat with recordCtr from 1 to (count of settingsList)
		copy (get settingsList's record recordCtr) to theSettingRecord
		set xor to true
		try
			if (true = (contents of theSettingRecord's s_Invert)) then set xor to false
		end try
		if (xor = (contents of theSettingRecord's s_Active)) then
			if showSettable then
				if true = (get theSettingRecord's s_UserSet) then
					set settingsDisplay_S to settingsDisplay_S & "+ "
				else
					set settingsDisplay_S to settingsDisplay_S & "   "
				end if
			end if
			set settingsDisplay_S to settingsDisplay_S & (get theSettingRecord's s_Name)
			if (missing value ≠ (get theSettingRecord's s_Value)) then
				if (missing value = (get theSettingRecord's s_UserSet)) then
					set theSettingValueS to "" & (get contents of theSettingRecord's s_Value)
				else
					set theSettingClassS to "" & (get contents of theSettingRecord's s_Class)
					if (theSettingClassS contains "list") then
						if (theSettingClassS contains "text") then
							if 0 < (count of (get contents of theSettingRecord's s_Value)) then
								## set theSettingValueS to "{\"" & (my joinListToString((contents of theSettingRecord's s_Value), "\",\"")) & "\"}"
								copy ("{\"" & (my joinListToString((get contents of theSettingRecord's s_Value), "\",\"")) & "\"}") to theSettingValueS
							else
								set theSettingValueS to "{}"
							end if
						else
							## set theSettingValueS to "{" & (my joinListToString((contents of theSettingRecord's s_Value), ",")) & "}"
							copy ("{" & (my joinListToString((get contents of theSettingRecord's s_Value), ",")) & "}") to theSettingValueS
						end if
					else if (theSettingClassS = "text") then
						## set theSettingValueS to "\"" & (contents of theSettingRecord's s_Value) & "\""
						copy ("\"" & (get contents of theSettingRecord's s_Value) & "\"") to theSettingValueS
					else
						## set theSettingValueS to "" & (contents of theSettingRecord's s_Value)
						copy ("" & (get contents of theSettingRecord's s_Value)) to theSettingValueS
					end if
				end if
				set settingsDisplay_S to settingsDisplay_S & ": " & theSettingValueS
			end if
			set settingsDisplay_S to settingsDisplay_S & return
		end if
	end repeat
	return settingsDisplay_S
end guiMakeSettingsDisplay

on guiValidateSettingsRecords(theGuiData)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General purpose handler that checks a setting record for inconsistancies
	
	global debugLogEnable
	
	local errText, errNum
	
	if (true and (get contents of (theGuiData's guiParams's guiChecked))) then
		if debugLogEnable then my loqThis(3, false, "Validation of GUI data bypassed")
	else
		if debugLogEnable then my loqThis(3, false, "Validation of GUI data has started")
		local theRecord, theSettingName, validationFail, theSettingRecord, complaintList, recordCtr, xor
		set validationFail to false
		repeat with recordCtr from 1 to (count of theGuiData's guiRecordList)
			set theSettingRecord to theGuiData's guiRecordList's record recordCtr
			set complaintList to {}
			set {isReferenced, xor} to {(my isARef(theSettingRecord's s_Active)), true}
			try
				set isReferenced to isReferenced or (my isARef(theSettingRecord's s_Invert))
				if (true = (contents of theSettingRecord's s_Invert)) then set xor to false
			end try
			if (isReferenced or (xor = (contents of theSettingRecord's s_Active))) and (missing value ≠ (get theSettingRecord's s_UserSet)) then
				set theRecord to guiParseSettingRecord(theSettingRecord)
				if theRecord's ParseFail then
					set the end of complaintList to (get theRecord's ParseErrorString)
				else
					local ParseError, ParseErrorList, theSettingName, theSettingValue, theValueCLassName, theSettingLimitList, hasSettingLimitList, hasFreeInput, theSettingBlockList
					local hasSettingBlockList, blockLTSpaces, theSettingMin, hasInclusiveMin, theSettingMax, hasInclusiveMax, hasExclusiveMin, hasExclusiveMax, hasQuotation, hasNoSpace, hasOkSpace
					tell theRecord
						set {ParseError, ParseErrorList, theSettingName, theSettingValue, theValueCLassName, valueIsList, theSettingLimitList, hasSettingLimitList, hasFreeInput, theSettingBlockList, hasSettingBlockList, blockLTSpaces, theSettingMin, hasInclusiveMin, theSettingMax, hasInclusiveMax, hasExclusiveMin, hasExclusiveMax, hasQuotation, hasNoSpace, hasOkSpace} to ¬
							{(its ParseError), (its ParseErrorList), (its settingName), (its settingValue), (its valueCLassName), (its valueIsList), (its settingLimitList), (its hasSettingLimitList), (its hasFreeInput), (its SettingBlockList), (its hasSettingBlockList), (its blockLTSpaces), (its settingMin), (its hasInclusiveMin), (its settingMax), (its hasInclusiveMax), (its hasExclusiveMin), (its hasExclusiveMax), (its hasQuotation), (its hasNoSpace), (its hasOkSpace)}
					end tell
					if ParseError then set complaintList to complaintList & ParseErrorList
					
					if hasSettingLimitList and (not hasFreeInput) and (0 = (count of theSettingLimitList)) then set the end of complaintList to ("Setting \"" & theSettingName & "\" has an empty Choose List and not Free Input")
					
					if {"real", "integer"} contains theValueCLassName then
						if (hasInclusiveMin and (theSettingValue < theSettingMin)) or (hasExclusiveMin and (theSettingValue ≤ theSettingMin)) then set the end of complaintList to ("The value of \"" & theSettingName & "\" is less than it's minimum")
						if (hasInclusiveMax and (theSettingValue > theSettingMax)) or (hasExclusiveMax and (theSettingValue ≥ theSettingMax)) then set the end of complaintList to ("The value of \"" & theSettingName & "\" is greater than it's maximum")
					else -- limits valid only for real and integer should not be used elsewhere
						if hasInclusiveMin or hasExclusiveMin or hasInclusiveMax or hasExclusiveMax then set the end of complaintList to ("Setting \" " & settingName & "\" has a \"Min\" or \"Max\" limit which is invalid for type \"" & valueCLassName & "\"")
					end if
					
					local initialValue, theSettingLimitList
					if ("text" = theValueCLassName) then
						if hasNoSpace and hasOkSpace then set the end of complaintList to ("Setting \"" & settingName & "\" has an \"OkSpace\" limit and a \"NoSpace\" limit - invalid combination")
						if hasOkSpace and (hasSettingBlockList and ((theSettingBlockList contains " ") or (theSettingBlockList contains "\""))) then ¬
							set the end of complaintList to ("Setting \"" & settingName & "\" has an \"OkSpace\" limit and a Setting Block List which contains Space or the Quotation symbol - invalid combination")
						if hasSettingLimitList then
							copy theSettingLimitList to initialValue
							if hasSettingBlockList then set theSettingLimitList to my removeTextFromList(theSettingLimitList, theSettingBlockList)
							if blockLTSpaces then set theSettingLimitList to my removeLeadingTrailingSpaces(theSettingLimitList)
							if not (initialValue = theSettingLimitList) then set the end of complaintList to ("Setting \"" & theSettingName & "\" has blocked or prohibited characters in it's Choose List")
						end if
						if 0 < (length of theSettingValue) then
							copy (theSettingValue as list) to initialValue
							if hasSettingBlockList then set theSettingValue to my removeTextFromList(theSettingValue, theSettingBlockList) -- result is a list
							if blockLTSpaces then set theSettingValue to my removeLeadingTrailingSpaces(theSettingValue)
							if not (initialValue = (get theSettingValue as list)) then set the end of complaintList to ("Setting \"" & theSettingName & "\" has blocked or prohibited characters in it's setting")
						end if
					else -- limits valid only for text should not be used elsewhere
						if hasSettingBlockList then set the end of complaintList to ("Setting \" " & settingName & "\" has a \"Blocked Characters\" limit which is invalid for type \"" & valueCLassName & "\"")
						if hasNoSpace or hasOkSpace then set the end of complaintList to ("Setting \" " & settingName & "\" has a limit type which is invalid for type \"" & valueCLassName & "\"")
					end if
					local badList
					if (not hasFreeInput) and hasSettingLimitList then
						if valueIsList then
							set badList to {}
							repeat with theValue in theSettingValue
								if (theSettingLimitList does not contain (get contents of theValue)) then set end of badList to (get contents of theValue)
							end repeat
							if 0 < (count of badList) then set the end of complaintList to {0, false, ("Values \"" & my joinListToString(badList, ("\", \"")) & "\" of setting \"" & theSettingName & "\" are not in it's Choose List and Free Input is not enabled")}
						else
							if (theSettingLimitList does not contain theSettingValue) then set the end of complaintList to ("The value of setting \"" & theSettingName & "\" is not in it's Choose List and Free Input is not enabled")
						end if
						
					end if
					
				end if
				local theComplaint
				if (0 < (count of complaintList)) then
					set validationFail to true
					repeat with theComplaint in the complaintList
						my loqThis(-1, false, theComplaint)
					end repeat
				end if
			end if
		end repeat
		if validationFail then error my loqqed_Error_Halt5("Validation of GUI data has failed ")
		try
			set contents of (theGuiData's guiParams's guiChecked) to true
		on error errText number errNum
			my loqThis(-1, true, ("error " & errNum & " :" & errText))
		end try
		my loqThis(3, false, "Validation of GUI data successfully completed")
	end if
end guiValidateSettingsRecords

on guiParseSettingRecord(theSettingRecord)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General Purpose handler that parses one setting record
	global debugLogEnable
	ignoring case -- for this entire handler
		local settingName, settingCLassName, valueIsList, valueCLassName, settingValue, ParseError, ParseErrorList, xor
		
		set ParseError to false -- minor errors
		set ParseErrorList to {} -- minor errors
		
		set settingName to (get contents of theSettingRecord's s_Name)
		
		if (missing value = (get contents of theSettingRecord's s_UserSet)) then
			return {ParseFail:true, ParseErrorString:("SW Error: Setting \" " & settingName & "'s\"  s_UserSet is missing value")} -- may cause unexpected behaviour
		end if
		-- set settingCLassName to (get theSettingRecord's s_Class)  -- works
		set settingCLassName to (get contents of theSettingRecord's s_Class)
		if (get settingCLassName contains "list") then
			set valueIsList to true
			if (get settingCLassName contains "text") then
				set valueCLassName to "text"
			else -- error that will cause a failure to edit
				return {ParseFail:true, ParseErrorString:("Setting \" " & settingName & "\" has an unexpected value in Setting Class: \"" & settingCLassName & "\"")}
			end if
		else
			set valueCLassName to (get settingCLassName as text)
			set valueIsList to false
		end if
		
		if {"text", "integer", "real", "boolean"} does not contain valueCLassName then -- error that will cause a failure to edit
			return {ParseFail:true, ParseErrorString:("SW Error: Setting \" " & settingName & "\" has an unexpected value in Setting Class: \"" & valueCLassName & "\"")}
		end if
		(get contents of theSettingRecord's s_Value)
		set settingValue to my deReference((get contents of theSettingRecord's s_Value), valueCLassName)
		
		local SettingBlockList, hasSettingBlockList
		set SettingBlockList to missing value
		if "text" = valueCLassName then
			if valueIsList then
				set settingValue to settingValue as list
			else
				set settingValue to settingValue as text
			end if
		end if
		try
			set SettingBlockList to (get contents of theSettingRecord's s_Block_L)
			set hasSettingBlockList to true
		on error
			set hasSettingBlockList to false
		end try
		
		local hasFreeInput, hasSettingLimitType, hasInclusiveMin, hasInclusiveMax, hasSettingLimitList, hasSettingLimitList, SettingLimitType, settingMin, settingMax, settingLimitList
		local hasQuotation, hasNoSpace, hasOkSpace
		set {hasFreeInput, hasSettingLimitType, hasInclusiveMin, hasInclusiveMax, hasExclusiveMin, hasExclusiveMax, hasSettingLimitList, hasQuotation, hasNoSpace, hasOkSpace} to ¬
			{false, false, false, false, false, false, false, false, false, false}
		set {settingMin, settingMax, settingLimitList, SettingLimitType} to {missing value, missing value, missing value, missing value}
		
		local SettingLimitType
		if (valueCLassName = "Boolean") then
			set SettingLimitType to "boolean"
			set hasSettingLimitType to true
		else
			try
				set SettingLimitType to (get contents of theSettingRecord's s_LType) as text -- this works even if the class is boolean
				set hasSettingLimitType to true
				if "false" = SettingLimitType then set hasSettingLimitType to false
			on error
				set hasSettingLimitType to false
			end try
		end if
		
		local theLimitType, SettingLimitType_L, sltCtr
		if hasSettingLimitType then
			set SettingLimitType_L to my splitStringToList(SettingLimitType, "&")
			repeat with sltCtr from 1 to (count of SettingLimitType_L)
				set theLimitType to SettingLimitType_L's item sltCtr
				if "boolean" = theLimitType then
					set settingLimitList to {true, false}
					set hasSettingLimitList to true
					
				else if "InMin" = theLimitType then
					set hasInclusiveMin to true
					set hasFreeInput to true
					set settingMin to my deReference((get item 1 of theSettingRecord's s_Limit_L), valueCLassName)
					
				else if "InMax" = theLimitType then
					set hasInclusiveMax to true
					set hasFreeInput to true
					set settingMax to my deReference((get item -1 of theSettingRecord's s_Limit_L), valueCLassName)
					
				else if "ExMin" = theLimitType then
					set hasExclusiveMin to true
					set hasFreeInput to true
					set settingMin to my deReference((get item 1 of theSettingRecord's s_Limit_L), valueCLassName)
					
				else if "ExMax" = theLimitType then
					set hasExclusiveMax to true
					set hasFreeInput to true
					set settingMax to my deReference((get item -1 of theSettingRecord's s_Limit_L), valueCLassName)
					
				else if "Free" = theLimitType then
					set hasFreeInput to true
					
				else if "List" = theLimitType then
					set settingLimitList to my deReference((get theSettingRecord's s_Limit_L), valueCLassName)
					set hasSettingLimitList to true
					if ("text" = valueCLassName) and (SettingLimitType_L contains "OkSpace") then ¬
						set settingLimitList to my splitStringToList(("\"" & my joinListToString(settingLimitList, "\",\"") & "\""), ",")
					
				else if "OkSpace" = theLimitType then
					set hasOkSpace to true -- add quotation marks to the text string or list of strings
					if ("text" = valueCLassName) then
						set hasQuotation to true
						if valueIsList then
							set settingValue to my splitStringToList(("\"" & my joinListToString(settingValue, "\",\"") & "\""), ",")
						else
							set settingValue to "\"" & settingValue & "\""
						end if
					end if
					
				else if "NoSpace" = theLimitType then
					set hasNoSpace to true -- add a space to the SettingBlockList
					if ("text" = valueCLassName) then
						if hasSettingBlockList then
							if SettingBlockList does not contain " " then set end of SettingBlockList to " "
						else
							set hasSettingBlockList to true
							set SettingBlockList to {" "}
						end if
					end if
					
				else
					set ParseError to true -- minor errors
					set end of ParseErrorList to ("Setting \" " & settingName & "\" has an unexpected Setting Limit type: \"" & theLimitType & "\"")
				end if
			end repeat
		end if
		
		local blockLTSpaces
		set blockLTSpaces to ("text" = valueCLassName) and (not hasNoSpace) and (not hasOkSpace) and (not (hasSettingBlockList and (SettingBlockList contains " "))) -- blockLT is the default if no other space control
		
		if (not hasFreeInput) then -- errors that will cause a failure to edit
			if (not hasSettingLimitList) then return {ParseFail:true, ParseErrorString:("Setting \"" & settingName & "\" is configured with free input disabled and with list input disabled")}
			if (0 = (count of settingLimitList)) then return {ParseFail:true, ParseErrorString:("Setting \"" & settingName & "\" is configured with free input disabled and has an empty Choose List")}
		end if
		
	end ignoring
	return {ParseFail:false, ParseError:ParseError, ParseErrorList:ParseErrorList, settingName:settingName, settingValue:settingValue, valueCLassName:valueCLassName, valueIsList:valueIsList, blockLTSpaces:blockLTSpaces, hasSettingBlockList:hasSettingBlockList, SettingBlockList:SettingBlockList, hasFreeInput:hasFreeInput, hasInclusiveMin:hasInclusiveMin, hasInclusiveMax:hasInclusiveMax, hasExclusiveMin:hasExclusiveMin, hasExclusiveMax:hasExclusiveMax, hasSettingLimitList:hasSettingLimitList, settingMin:settingMin, settingMax:settingMax, settingLimitList:settingLimitList, hasQuotation:hasQuotation, hasNoSpace:hasNoSpace, hasOkSpace:hasOkSpace}
end guiParseSettingRecord

on guiSelectSetting(theGuiData)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General Purpose handler that enables the user to select the setting to be edited
	
	global debugLogEnable
	local usercancelled, userDone, settings_choose_List, settings_choose_List, ChooseResult, selectedSetting, settingID, numSelectedSetting, theSelected_Setting, theSettingValueS
	local separatorLine, xor
	--local settingsList
	--set settingsList to theGuiData's guiRecordList
	
	set {usercancelled, userDone, separatorLine} to {false, false, "-----"}
	
	repeat while userDone is false
		
		copy {} to settings_choose_List
		repeat with recordCtr from 1 to (count of theGuiData's guiRecordList)
			## set theSetting_r to theGuiData's guiRecordList's record recordCtr
			## copy (get theGuiData's guiRecordList's record recordCtr) to theSetting_r
			
			set xor to true
			try
				if (true = (contents of theGuiData's guiRecordList's record recordCtr's s_Invert)) then set xor to false
			end try
			if (xor = (contents of theGuiData's guiRecordList's record recordCtr's s_Active)) and (true = contents of theGuiData's guiRecordList's record recordCtr's s_UserSet) then
				if ((contents of theGuiData's guiRecordList's record recordCtr's s_Class) contains "list") then
					if ((contents of theGuiData's guiRecordList's record recordCtr's s_Class) contains "text") then
						if 0 < (count of (get contents of theGuiData's guiRecordList's record recordCtr's s_Value)) then
							copy ("{\"" & (my joinListToString((get contents of theGuiData's guiRecordList's record recordCtr's s_Value), "\",\"")) & "\"}") to theSettingValueS
						else
							set theSettingValueS to "{}"
						end if
					else
						copy ("{" & (my joinListToString((get contents of theGuiData's guiRecordList's record recordCtr's s_Value), ",")) & "}") to theSettingValueS
					end if
				else if ("text" = (contents of theGuiData's guiRecordList's record recordCtr's s_Class)) then
					copy ("\"" & (get contents of theGuiData's guiRecordList's record recordCtr's s_Value) & "\"") to theSettingValueS
				else
					copy ("" & (get contents of theGuiData's guiRecordList's record recordCtr's s_Value)) to theSettingValueS
				end if
				
				copy (((get contents of theGuiData's guiRecordList's record recordCtr's s_ID) as text) & ": " & (get contents of theGuiData's guiRecordList's record recordCtr's s_Name) & ": " & theSettingValueS) to the end of settings_choose_List
				
			else if (true = (contents of theGuiData's guiRecordList's record recordCtr's s_Active)) and (missing value = contents of theGuiData's guiRecordList's record recordCtr's s_UserSet) then
				copy separatorLine to the end of settings_choose_List
			end if
		end repeat
		
		set ChooseResult to {separatorLine}
		repeat while separatorLine = ChooseResult's first item
			if theGuiData's guiParams's enableFastGui then
				set ChooseResult to (get choose from list settings_choose_List with title "Settings for " & theGuiData's guiParams's Script_Title with prompt "Select an Item to Edit or no Item if Done" cancel button name "Cancel" OK button name "Change/Done" with empty selection allowed)
				if ChooseResult = false then -- user has cancelled
					set usercancelled to true
					exit repeat -- exit from this repeat loop
				else if 0 = (count of ChooseResult) then -- user is done editting
					set userDone to true
					exit repeat -- exit from this repeat loop
				end if
			else
				set ChooseResult to (get choose from list settings_choose_List with title "Settings for " & theGuiData's guiParams's Script_Title with prompt "Select an Item to Edit" cancel button name "Done" OK button name "Edit" without empty selection allowed)
				if ChooseResult = false then -- user is done editting
					set userDone to true
					exit repeat -- exit from this repeat loop 
				end if
			end if
		end repeat
		if userDone or usercancelled then exit repeat --exit from the main repeat loop
		
		##  without empty selection allowed
		set selectedSetting to item 1 of ChooseResult
		set settingID to get ((item 1 of (my splitStringToList(selectedSetting, ":"))) as integer)
		
		set numSelectedSetting to false
		repeat with recordCtr from 1 to (count of theGuiData's guiRecordList)
			if settingID = (theGuiData's guiRecordList's record recordCtr's s_ID) then
				set numSelectedSetting to 0 + recordCtr
				set settingFound to true
				exit repeat
			end if
		end repeat
		
		if false = numSelectedSetting then error my loqqed_Error_Halt5("SW Error 1: Unable to find setting #" & settingID)
		guiEditSetting(theGuiData, numSelectedSetting)
		
	end repeat
	return usercancelled
end guiSelectSetting

on guiEditSetting(theGuiData, numSelectedSetting)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General Purpose handler that provides a user interface to edit one setting
	
	global debugLogEnable
	
	ignoring case -- for this entire handler
		
		local theRecord
		set theRecord to guiParseSettingRecord(get theGuiData's guiRecordList's record numSelectedSetting)
		if theRecord's ParseFail then error my loqqed_Error_Halt5((get theRecord's ParseErrorString))
		if debugLogEnable and theRecord's ParseError then my loqThis(2, false, (get theRecord's ParseErrorList))
		
		local theSettingName, theValueCLassName, valueIsList, theSettingLimitList, hasSettingLimitList, hasFreeInput, theSettingBlockList, hasSettingBlockList, blockLTSpaces, theSettingMin, hasInclusiveMin, theSettingMax, hasInclusiveMax, hasExclusiveMin, hasExclusiveMax, hasQuotation
		tell theRecord
			set {theSettingName, theSettingValue, theValueCLassName, valueIsList, theSettingLimitList, hasSettingLimitList, hasFreeInput, theSettingBlockList, hasSettingBlockList, blockLTSpaces, theSettingMin, hasInclusiveMin, hasExclusiveMin, theSettingMax, hasInclusiveMax, hasExclusiveMax, hasQuotation} to ¬
				{(get its settingName), (get its settingValue), (get its valueCLassName), (get its valueIsList), (get its settingLimitList), (get its hasSettingLimitList), (get its hasFreeInput), (get its SettingBlockList), (its hasSettingBlockList), (its blockLTSpaces), (its settingMin), (its hasInclusiveMin), (its hasExclusiveMin), (its settingMax), (its hasInclusiveMax), (its hasExclusiveMax), (its hasQuotation)}
		end tell
		
		local settingHelpPrompt, SettingBlockString
		
		try
			set settingHelpPrompt to (get (theGuiData's guiRecordList's record numSelectedSetting's s_Help) as text)
			if 0 = (get length of settingHelpPrompt) then
				set settingHelpPrompt to ""
			else
				set settingHelpPrompt to return & " (" & settingHelpPrompt & ")"
			end if
		on error
			set settingHelpPrompt to ""
		end try
		
		if hasSettingBlockList then
			set SettingBlockString to return & "Blocked characters: \"" & my joinListToString(theSettingBlockList, ("\",  \"")) & "\""
		else
			set SettingBlockString to ""
		end if
		
		if debugLogEnable then
			my loqThis(4, false, ¬
				{"settingName: " & theSettingName, "valueCLassName: " & theValueCLassName, "valueIsList: " & valueIsList, "hasFreeInput: " & hasFreeInput})
			my loqThis(4, false, ¬
				{"hasSettingLimitList: " & hasSettingLimitList, "hasSettingBlockList: " & hasSettingBlockList, "blockLTSpaces: " & blockLTSpaces, "hasQuotation: " & hasQuotation})
			my loqThis(4, false, ¬
				{"hasInclusiveMin: " & hasInclusiveMin, "hasInclusiveMax: " & hasInclusiveMax, "hasExclusiveMin: " & hasExclusiveMin, "hasExclusiveMax: " & hasExclusiveMax})
		end if
		
		
		
		local usercancelled, hasNewSettingValue, chooseSettingValueList, buttonList
		local settingAddTitle, settingChooseTitle, settingChoosePrompt, settingEditPrompt
		local newSettingEntry, ChooseResult, dialog_result, dialogResultList, theValueString, skipListInput
		local errorText, errorNumber
		
		## Setup local variables
		set usercancelled to false
		set hasNewSettingValue to false
		set chooseSettingValueList to missing value
		set skipListInput to false
		
		#### Setup is complete
		
		if (not valueIsList) then
			if theGuiData's guiParams's enableFastGui and (theValueCLassName = "Boolean") then
				set contents of theGuiData's guiRecordList's record numSelectedSetting's s_Value to (get not theSettingValue)
				set hasNewSettingValue to true
			else
				set settingAddTitle to "Enter a New Value"
				set settingChooseTitle to "Select a New Value"
				copy ("Setting: " & (get theSettingName as text) & (get settingHelpPrompt as text) & SettingBlockString) to settingEditPrompt
				
				if hasFreeInput and (not (theGuiData's guiParams's enableFastGui and hasSettingLimitList)) then
					if (hasInclusiveMin or hasInclusiveMax or hasExclusiveMin or hasExclusiveMax) then set settingEditPrompt to settingEditPrompt & return
					if hasInclusiveMin then set settingEditPrompt to settingEditPrompt & "Minimum: ≥" & my deReference(theSettingMin, theValueCLassName)
					if hasExclusiveMin then set settingEditPrompt to settingEditPrompt & "Minimum: >" & my deReference(theSettingMin, theValueCLassName)
					if hasInclusiveMin or hasExclusiveMin then set settingEditPrompt to settingEditPrompt & ";  "
					if hasInclusiveMax then set settingEditPrompt to settingEditPrompt & "Maximum: ≤" & my deReference(theSettingMax, theValueCLassName)
					if hasExclusiveMax then set settingEditPrompt to settingEditPrompt & "Maximum: <" & my deReference(theSettingMax, theValueCLassName)
					if hasSettingLimitList then
						set buttonList to {"Select", "Cancel Editing", "Skip List Input"}
					else
						set buttonList to {"Select", "Cancel Editing"}
					end if
					
					repeat while not hasNewSettingValue
						set skipListInput to false
						set dialog_result to display dialog settingEditPrompt with title settingAddTitle default answer theSettingValue buttons buttonList
						if "Cancel Editing" = (get dialog_result's button returned) then
							set usercancelled to true
							set hasNewSettingValue to false
							exit repeat
						end if
						
						try
							if 0 < (length of text returned of dialog_result) then
								set newSettingEntry to my deReference((text returned of dialog_result), theValueCLassName)
								if hasSettingBlockList then set newSettingEntry to my replaceText(newSettingEntry, theSettingBlockList, "")
								if blockLTSpaces then set newSettingEntry to my removeLeadingTrailingSpaces(newSettingEntry)
								if hasQuotation then set newSettingEntry to "\"" & (my replaceText(newSettingEntry, "\"", "")) & "\""
								set hasNewSettingValue to true
							else if 0 = (length of text returned of dialog_result) and ("text" = theValueCLassName) then
								if hasQuotation then
									set newSettingEntry to "\"" & "\""
								else
									set newSettingEntry to ""
								end if
								set hasNewSettingValue to true
							else
								error
							end if
						on error
							display dialog (settingEditPrompt & return & "Unable to convert \"" & (get text returned of dialog_result) & "\"  to an " & theValueCLassName) with title "Press OK to try again" buttons {"OK"} default button "OK"
							set hasNewSettingValue to false
						end try
						
						if hasNewSettingValue and ¬
							((hasInclusiveMin and (newSettingEntry < theSettingMin)) or (hasInclusiveMax and (newSettingEntry > theSettingMax)) or ¬
								(hasExclusiveMin and (newSettingEntry ≤ theSettingMin)) or (hasExclusiveMax and (newSettingEntry ≥ theSettingMax))) then
							set hasNewSettingValue to false
							display dialog (settingEditPrompt & return & "The value " & newSettingEntry & " is below the Min or above the Max") with title "Press OK to try again" buttons {"OK"} default button "OK"
						end if
						if hasNewSettingValue and ("Skip List Input" = (get button returned of dialog_result)) then set skipListInput to true
					end repeat
				end if
				
				if hasSettingLimitList and (not usercancelled) and (not skipListInput) then
					set chooseSettingValueList to (get contents of theSettingLimitList)
					if chooseSettingValueList does not contain theSettingValue then set end of chooseSettingValueList to theSettingValue
					if hasNewSettingValue and (chooseSettingValueList does not contain newSettingEntry) then set end of chooseSettingValueList to newSettingEntry
					if not hasNewSettingValue then
						set chooseDefaults to theSettingValue
					else
						set chooseDefaults to newSettingEntry
					end if
					
					set ChooseResult to (get choose from list chooseSettingValueList with prompt settingEditPrompt ¬
						with title settingChooseTitle OK button name "Select" cancel button name "Cancel Editing" default items chooseDefaults)
					if ChooseResult = false then
						set usercancelled to true
						set hasNewSettingValue to false
					else
						if (0 ≤ (count of ChooseResult)) then set newSettingEntry to my deReference((get item 1 of ChooseResult), theValueCLassName)
						set hasNewSettingValue to true
					end if
				end if
				if hasNewSettingValue then
					if hasQuotation then set newSettingEntry to my replaceText(newSettingEntry, "\"", "")
					set contents of theGuiData's guiRecordList's record numSelectedSetting's s_Value to newSettingEntry
				end if
			end if
			
			if hasNewSettingValue then
				try
					theGuiData's guiRecordList's record numSelectedSetting's s_Script's resolve()
				on error errorText number errorNumber
					if -1728 = errorNumber then
						my loqThis(4, false, "Did not find " & theSettingName & "'s Script: " & errorText)
					else
						my loqThis(2, false, "Got an error regarding " & theSettingName & "'s resolve handler: " & errorText & " (" & errorNumber & ")")
					end if
				end try
			end if
			
		else --- handle a list
			## Initiialise local variables
			set settingAddTitle to "Enter a New Value"
			set settingChooseTitle to "Select Values"
			set settingChoosePrompt to "Setting: " & theSettingName & settingHelpPrompt & return & "Empty selection allowed" & return & "(cmd-click deselects)"
			set settingEditPrompt to "Setting: " & theSettingName & settingHelpPrompt & return & "(use ';' to make a list)" & SettingBlockString
			
			set chooseSettingValueList to (get contents of theSettingValue)
			set newSettingEntry to {}
			set hasNewSettingValue to false
			set skipListInput to false
			
			if hasSettingLimitList then
				repeat with theValueString in theSettingLimitList
					if chooseSettingValueList does not contain (contents of theValueString) then copy (contents of theValueString) to the end of chooseSettingValueList
				end repeat
			end if
			
			if hasFreeInput and (not (theGuiData's guiParams's enableFastGui and (0 < (count of chooseSettingValueList)))) then
				if 0 < (count of chooseSettingValueList) then
					set buttonList to {"OK", "Cancel Editing", "Skip List Input"}
				else
					set buttonList to {"OK", "Cancel Editing"}
				end if
				
				set dialog_result to display dialog settingEditPrompt with title settingAddTitle default answer "" buttons buttonList
				if "Cancel Editing" = (get dialog_result's button returned) then set usercancelled to true
				
				if (not usercancelled) then
					set dialogResultList to my splitStringToList((get text returned of dialog_result), ";")
					if hasSettingBlockList then copy my removeTextFromList(dialogResultList, theSettingBlockList) to dialogResultList
					if blockLTSpaces then copy my removeLeadingTrailingSpaces(dialogResultList) to dialogResultList
					if hasQuotation then copy (my removeTextFromList(dialogResultList, "\"")) to dialogResultList
					if 0 = (length of text returned of dialog_result) then
						set newSettingEntry to {}
						set hasNewSettingValue to true
					else
						if hasQuotation then copy my splitStringToList(("\"" & my joinListToString(dialogResultList, "\",\"") & "\""), ",") to dialogResultList
						repeat with theValueString in dialogResultList
							if (0 < (get length of theValueString)) and (newSettingEntry does not contain (contents of theValueString)) then
								copy (contents of theValueString) to the end of newSettingEntry
								if chooseSettingValueList does not contain (contents of theValueString) then copy (contents of theValueString) to the end of chooseSettingValueList
								set hasNewSettingValue to true
							end if
						end repeat
					end if
					if ("Skip List Input" = (get button returned of dialog_result)) then set skipListInput to true
				end if
			end if
			
			if (not usercancelled) and (not skipListInput) and (0 < (get count of chooseSettingValueList)) then
				set ChooseResult to (get choose from list chooseSettingValueList with prompt settingChoosePrompt ¬
					with title settingChooseTitle OK button name "Select" cancel button name "Cancel Editing" default items (theSettingValue & newSettingEntry) with empty selection allowed and multiple selections allowed)
				if ChooseResult = false then
					set usercancelled to true
					set hasNewSettingValue to false -- might have been set to true in free input section
				else
					copy (get ChooseResult as list) to newSettingEntry
					set hasNewSettingValue to true
				end if
			end if
			
			if hasNewSettingValue and not usercancelled then
				if hasQuotation then set newSettingEntry to my removeTextFromList(newSettingEntry, "\"")
				set the contents of theGuiData's guiRecordList's record numSelectedSetting's s_Value to {}
				copy (contents of newSettingEntry) to contents of theGuiData's guiRecordList's record numSelectedSetting's s_Value
				try
					theGuiData's guiRecordList's record numSelectedSetting's s_Script's resolve()
				on error errorText number errorNumber
					if -1728 = errorNumber then
						my loqThis(4, false, "Did not find " & theSettingName & "'s Script: " & errorText)
					else
						my loqThis(2, false, "Got an error regarding " & theSettingName & "'s resolve handler: " & errorText & " (" & errorNumber & ")")
					end if
				end try
			end if
		end if
	end ignoring
	return -- the only exit
end guiEditSetting

##  Utilities_1300.scpt  ################################################
## General Utility Handlers  Version 1300  2020/04/14
## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
## No Dependencies on other Libraries

on getScriptTitle(script_path, removeExtension, replacePeriod)
	## extracts the script tile from an alias as a string, removing the file path
	## if removeExtension the file extension and period are removed
	## Remaining "." are replaced by the replacePeriod characters
	
	set script_path to script_path as string
	set astid to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to ":"
		if (script_path ends with ":") then
			set Script_Title to text item -2 of script_path
		else
			set Script_Title to text item -1 of script_path
		end if
		set lastTextItem to -1
		if removeExtension and (Script_Title contains ".") then set lastTextItem to -2
		set AppleScript's text item delimiters to "."
		set Script_Title to text items 1 thru lastTextItem of Script_Title
		if false ≠ replacePeriod then set AppleScript's text item delimiters to replacePeriod
		set Script_Title to Script_Title as text
	end try
	set AppleScript's text item delimiters to astid
	if 0 = (get length of Script_Title) then error "getScriptTitle: Script Title is empty"
	return Script_Title
end getScriptTitle

on findTargetFolder(targetFolderParent_a, targetFolderName, debugLogLevel, enableCreate)
	## Return a refernce to a folder. If the folder doesn't exist, create it.
	## targetFolderParent_a can be an alias or a string 
	local targetFolder_p, targetFolder_a
	local errorString1, errorNumber1, errorString2, errorNumber2
	
	try
		set targetFolder_p to (POSIX path of targetFolderParent_a) & targetFolderName
		if 1 ≤ debugLogLevel then tell me to log " Initializing Folder \"" & targetFolder_p & "\""
		set targetFolder_a to (get alias POSIX file targetFolder_p)
		if 2 ≤ debugLogLevel then tell me to log "Folder \"" & targetFolderName & "\"  exists"
	on error errorString1 number errorNumber1
		try
			if (errorNumber1 = -1728) then
				if enableCreate then
					tell application "Finder" to set targetFolder_a to (make new folder at targetFolderParent_a with properties {name:targetFolderName}) as alias
					if 2 ≤ debugLogLevel then tell me to log "Folder \"" & targetFolderName & "\"  was created"
				else
					if 1 ≤ debugLogLevel then tell me to log "Could not find folder \"" & targetFolder_p & "\"."
					set targetFolder_a to false
				end if
			else
				error errorString1 number errorNumber1
			end if
		on error errorString2 number errorNumber2
			error ("findTargetFolder() had error " & errorNumber2 & " \"" & errorString2 & "\".") number errorNumber2
		end try
	end try
	return targetFolder_a
end findTargetFolder

on stdDecimalVersionNumber(theVersion_S, numDigits)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General purpose handler for creating a version number with a fixed number of digits per group
	## if numDigits is 0 then the number of digits per group is chosen automatically
	## if numDigits is < 0 then the number of digits per group is chosen automatically, but has a minimum value of (-numDigits)
	local theVersionNumber, theVersion_LS, theDotVersion_LS, groupMult, maxDigits
	local thisGroupMult, thisGroup_S
	
	set {theVersion_LS, numDigits} to {(splitStringToList(replaceText(removeLeadingTrailingSpaces((theVersion_S as text)), " ", "."), ".")), (numDigits as integer)}
	
	set theVersionNumber to (item 1 of theVersion_LS) as integer
	if 1 < (get count of theVersion_LS) then
		set {hasDotVersions, theDotVersion_LS} to {true, (items 2 thru -1 of theVersion_LS)}
		if numDigits < 1 then
			set maxDigits to -numDigits
			repeat with thisGroup_S in theDotVersion_LS
				if (length of thisGroup_S) > maxDigits then set maxDigits to (length of thisGroup_S)
			end repeat
		else
			set maxDigits to numDigits
			repeat with thisGroup_S in theDotVersion_LS
				if numDigits < (length of thisGroup_S) then error "The digit group \"" & thisGroup_S & "\" has more than " & numDigits & " digits"
			end repeat
		end if
		
		set {thisGroupMult, groupMult} to {1, (10 ^ maxDigits)}
		repeat with thisGroup_S in theDotVersion_LS
			set thisGroupMult to thisGroupMult / groupMult
			set theVersionNumber to theVersionNumber + (thisGroup_S as integer) * thisGroupMult
		end repeat
	else
		set hasDotVersions to false
		if numDigits > 0 then set {maxDigits, groupMult} to {numDigits, (10 ^ numDigits)}
		if numDigits = 0 then set {maxDigits, groupMult} to {1, 10}
		if numDigits < 0 then set {maxDigits, groupMult} to {(-numDigits), (10 ^ (-numDigits))}
	end if
	
	return {stdVersionNumber:theVersionNumber, lengthVersionGroup:maxDigits, multVersionGroup:groupMult, hasDotVersions:hasDotVersions}
end stdDecimalVersionNumber

on compareVersion(testVersion_S, minVersion_S, maxVersion_S)
	## Copyright 2020 Eric Valk, Ottawa, Canada   Creative Commons License CC BY-SA    No Warranty.
	## General purpose handler for comparing versions
	--local digitMult, testVersionNumber, minVersionNumber, maxVersionNumber, testVersion_LS, minVersion_LS, maxVersion_LS, groupsCount, group_ctr
	--local testGroupsCount, minGroupsCount, maxGroupsCount, hasTestGroup, hasMinGroup, hasMaxGroup, testGroupVersion, minGroupVersion, maxGroupVersion
	--local allBoundsPass, lowerBoundPass, upperBoundPass, lowerBoundFail, upperBoundFail, boundsCheckPass
	
	if (text ≠ (get class of testVersion_S)) or (text ≠ (get class of minVersion_S)) or (text ≠ (get class of maxVersion_S)) then error "compareVersion() failed: Text inputs only"
	
	set testVersion_LS to (splitStringToList(replaceText(removeLeadingTrailingSpaces(testVersion_S), " ", "."), "."))
	set minVersion_LS to (splitStringToList(replaceText(removeLeadingTrailingSpaces(minVersion_S), " ", "."), "."))
	set maxVersion_LS to (splitStringToList(replaceText(removeLeadingTrailingSpaces(maxVersion_S), " ", "."), "."))
	
	set testGroupsCount to get count of testVersion_LS
	set minGroupsCount to get count of minVersion_LS
	set maxGroupsCount to get count of maxVersion_LS
	
	set groupsCount to testGroupsCount
	if groupsCount < minGroupsCount then set groupsCount to minGroupsCount
	if groupsCount < maxGroupsCount then set groupsCount to maxGroupsCount
	
	set {lowerBoundPass, lowerBoundFail, upperBoundPass, upperBoundFail, boundsCheckPass} to {false, false, false, false, false}
	
	repeat with group_ctr from 1 to groupsCount
		
		set hasTestGroup to (get group_ctr ≤ testGroupsCount)
		set hasMinGroup to (get group_ctr ≤ minGroupsCount)
		set hasMaxGroup to (get group_ctr ≤ maxGroupsCount)
		
		if hasTestGroup then set testGroupVersion to 0 + (item group_ctr of testVersion_LS)
		if hasMinGroup then set minGroupVersion to 0 + (item group_ctr of minVersion_LS)
		if hasMaxGroup then set maxGroupVersion to 0 + (item group_ctr of maxVersion_LS)
		
		if not boundsCheckPass then
			if hasMaxGroup and hasMinGroup then
				if maxGroupVersion > minGroupVersion then set boundsCheckPass to true
				if maxGroupVersion < minGroupVersion then error "compareVersion() failed: Maximum version is less than minimum version"
			else
				set boundsCheckPass to true
			end if
		end if
		
		if not (lowerBoundPass or lowerBoundFail) then
			if hasMinGroup and hasTestGroup then
				if testGroupVersion > minGroupVersion then set lowerBoundPass to true
				if testGroupVersion < minGroupVersion then set lowerBoundFail to true
			else if hasMinGroup then -- (and no testGroup) e.g. test 11 , min 11.1 
				set lowerBoundFail to true --  not symetric with upper bound behaviour
			else if hasTestGroup then -- (and no minGroup) e.g. test 11.1, min 11 --> OK
				set lowerBoundPass to true
			end if
		end if
		
		if not (upperBoundPass or upperBoundFail) then
			if hasMaxGroup and hasTestGroup then
				if testGroupVersion < maxGroupVersion then set upperBoundPass to true
				if testGroupVersion > maxGroupVersion then set upperBoundFail to true
			else if hasMaxGroup then -- (and no testGroup) e.g. test 11.1 , max 11.1.2 or test 11 , max 11.1 
				set upperBoundPass to true --  not symetric with lower bound behaviour
			else if hasTestGroup then --(and no maxGroup) e.g. test 11.1, max 11 --> pass
				set upperBoundPass to true
			end if
		end if
		
	end repeat
	
	return {maxVersionPass:(not upperBoundFail), minVersionPass:(not lowerBoundFail)}
end compareVersion

on deReference(theItem, theclassName)
	## General purpose handler for removing references from a variable
	## reusult is a value, or list of values, of the specified class 
	## Enables data handling of multiple classes of items in the same code
	
	if class = (get class of theclassName) then set theclassName to (get theclassName as text)
	
	if list = (get class of (get theItem)) then
		set theResult to {}
		set cntItems to length of theItem
		if (text = (get class of theclassName)) then
			set hasClassList to false
		else if (list = (get class of theclassName)) then
			if (1 = (get length of theclassName)) then
				set hasClassList to false
			else if (cntItems = (get length of theclassName)) then
				set hasClassList to true
			else
				error "deReference() can't handle a mismatch between number of items and number of classes"
			end if
		end if
		if not hasClassList then copy (get theclassName as text) to thisclassName
		repeat with item_ctr from 1 to cntItems
			if hasClassList then copy (get (theclassName's item item_ctr) as text) to thisclassName
			copy (get theItem's item item_ctr) to thisItem
			if "boolean" = thisclassName then
				set the end of theResult to false or (get thisItem as boolean)
			else if "integer" = thisclassName then
				set the end of theResult to 0 + (get thisItem as integer)
			else if "text" = thisclassName then
				set the end of theResult to "" & (get thisItem as text)
			else if "real" = thisclassName then
				set the end of theResult to 0.0 + (get thisItem as real)
			else if "date" = thisclassName then
				set the end of theResult to (get thisItem as date) + 0
			else
				error "deReference() can't handle class \"" & thisclassName & "\""
			end if
		end repeat
		
	else
		if "boolean" = theclassName then
			set theResult to false or (get theItem as boolean)
		else if "integer" = theclassName then
			set theResult to 0 + (get theItem as integer)
		else if "text" = theclassName then
			set theResult to "" & (get theItem as text)
		else if "real" = theclassName then
			set theResult to 0.0 + (get theItem as real)
		else if "date" = theclassName then
			set theResult to (get theItem as date) + 0
		else
			error "deReference() can't handle class \"" & theclassName & "\" as " & (get class of theclassName)
		end if
	end if
	return theResult
end deReference

on makeList(listLength, theElement)
	-- Note that the theElement can even be a List
	if listLength = 0 then return {}
	if listLength = 1 then return {theElement}
	
	set theList to {theElement}
	repeat while (count of theList) < listLength / 2
		copy contents of theList to ListB
		copy theList & ListB to theList
	end repeat
	copy contents of theList to ListB
	return (theList & items 1 thru (listLength - (count of ListB)) of ListB)
end makeList

on splitStringToList(theString, theDelim)
	## Public Domain
	set theList to {}
	set astid to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to theDelim
		set theList to text items of theString
	on error
		set AppleScript's text item delimiters to astid
	end try
	set AppleScript's text item delimiters to astid
	return theList
end splitStringToList

on joinListToString(theList, theDelim)
	## Public Domain
	set theString to ""
	set astid to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to theDelim
		set theString to theList as string
	end try
	set AppleScript's text item delimiters to astid
	return theString
end joinListToString

on ConcatenatedRemovedLeadingTrailingSpaces(theString, separatorCharList)
	## theString can be either string or list 
	## Attempts to handle any class of theString without crashing
	## If the input is a list, the output is a string which is all trimmed strings concatenated
	## If separatorCharList is a string, the first character is the main separator, the second and third characters are the start and end separators for a sub list 
	## If separatorCharList is a list, the first string is the main separator, the second and third strings are the start and end separators for a sub list 
	
	local newString, theSubString, resString, isFirstItem, mainSepChar, startSepChar, endSepChar, startSubSepChar, endSubSepChar
	local thestringLen, hasTriggered, indexLow, indexHigh, errMess1
	
	if (list = (get (class of theString))) then
		set {resString, isFirstItem} to {"", true}
		set {mainSepChar, startSubSepChar, endSubSepChar, countSepChars} to {"", "", "", (get length of separatorCharList)}
		if 0 < countSepChars then
			if text = (get class of separatorCharList) then
				set mainSepChar to separatorCharList's text 1
				if 2 ≤ countSepChars then set startSubSepChar to (get separatorCharList's text 2)
				if 3 ≤ countSepChars then set endSubSepChar to separatorCharList's text 3
			else if list = (get class of separatorCharList) then
				set mainSepChar to separatorCharList's item 1
				if 2 ≤ countSepChars then set startSubSepChar to (get separatorCharList's item 2)
				if 3 ≤ countSepChars then set endSubSepChar to separatorCharList's item 3
			end if
		end if
		
		repeat with theSubString in theString
			set newString to ConcatenatedRemovedLeadingTrailingSpaces(theSubString, separatorCharList)
			if 0 < (get length of newString) then
				set {startSepChar, endSepChar} to {"", ""}
				if (list = (get class of theSubString)) then set {startSepChar, endSepChar} to {startSubSepChar, endSubSepChar}
				if not isFirstItem then set startSepChar to mainSepChar & startSepChar
				set resString to resString & startSepChar & newString & endSepChar
				if isFirstItem then set isFirstItem to false
			end if
		end repeat
		return resString
		
	else if (text = (get (class of theString))) then
		set {thestringLen, hasTriggered} to {(get count of theString), false}
		repeat with indexLow from 1 to thestringLen
			set hasTriggered to (" " ≠ (get text indexLow of theString as text))
			if hasTriggered then exit repeat
		end repeat
		if not hasTriggered then return ""
		
		repeat with indexHigh from -1 to (-thestringLen) by -1
			if " " ≠ (get text indexHigh of theString as text) then exit repeat
		end repeat
		return (text indexLow thru indexHigh of theString)
		
	else
		try
			return (get theString as text)
		on error errMess1
			try
				return (get name of theString)
			on error
				return errMess1
			end try
		end try
	end if
	
end ConcatenatedRemovedLeadingTrailingSpaces


on removeLeadingTrailingSpaces(theString)
	## 40% faster than a version which trims the string 1 space at a time
	## handles both string and list input correctly
	## handles just about any input without crashing
	
	local newString, theSubString, thestringLen, hasTriggered, indexLow, indexHigh, errMess1
	
	if (list = (get (class of theString))) then
		set newString to {}
		repeat with theSubString in theString
			set the end of newString to removeLeadingTrailingSpaces(theSubString)
		end repeat
		return newString
		
	else if (text = (get (class of theString))) then
		set {thestringLen, hasTriggered} to {(get count of theString), false}
		repeat with indexLow from 1 to thestringLen
			set hasTriggered to (" " ≠ (get text indexLow of theString as text))
			if hasTriggered then exit repeat
		end repeat
		if not hasTriggered then return ""
		
		repeat with indexHigh from -1 to (-thestringLen) by -1
			if " " ≠ (get text indexHigh of theString as text) then exit repeat
		end repeat
		return (text indexLow thru indexHigh of theString)
		
	else
		try
			return (get theString as text)
		on error errMess1
			try
				return (get name of theString)
			on error
				return errMess1
			end try
		end try
	end if
	
end removeLeadingTrailingSpaces

on removeLeadingTrailingChars(theString, trimLeading, trimTrailing)
	## 40% faster than a version which trims the string 1 character at a time
	## handles both string and list input correctly 
	## if trimLeading or trimTrailing are boolean and true, then spaces are removed from the leading and trailing sides
	## if trimLeading or trimTrailing are characters or strings, then these characters are removed from the leading and trailing sides
	
	local enableTrimLeading, enableTrimTrailing, charTrimLeading, charTrimTrailing, charTrimLeadingIsString, charTrimTrailingIsString
	local newString, theSubString, thestringLen, hasTriggered, indexLow, indexHigh, errMess1
	
	if (list = (get (class of theString))) then
		set newString to {}
		repeat with theSubString in theString
			set the end of newString to removeLeadingTrailingChars(theSubString, trimLeading, trimTrailing)
		end repeat
		return newString
		
	else if (text = (get (class of theString))) then
		set {enableTrimLeading, enableTrimTrailing} to {false, false}
		if (trimLeading = true) then set {enableTrimLeading, charTrimLeading, charTrimLeadingIsString} to {true, " ", false}
		if (text = (class of trimLeading)) then ¬
			set {enableTrimLeading, charTrimLeading, charTrimLeadingIsString} to {true, trimLeading, (1 < (length of trimLeading))}
		
		if (trimTrailing = true) then set {enableTrimTrailing, charTrimTrailing, charTrimTrailingIsString} to {true, " ", false}
		if (text = (class of trimTrailing)) then ¬
			set {enableTrimTrailing, charTrimTrailing, charTrimTrailingIsString} to {true, trimTrailing, (1 < (length of trimTrailing))}
		
		set {thestringLen, indexLow, indexHigh, hasTriggered} to {(count of theString), 1, -1, false}
		repeat with indexLow from 1 to thestringLen
			if charTrimLeadingIsString then
				set hasTriggered to (charTrimLeading does not contain (theString's text indexLow))
			else
				set hasTriggered to (charTrimLeading ≠ (theString's text indexLow))
			end if
			if hasTriggered then exit repeat
		end repeat
		if not hasTriggered then return ""
		
		repeat with indexHigh from -1 to (-thestringLen) by -1
			if charTrimTrailingIsString then
				if (charTrimTrailing does not contain (theString's text indexHigh)) then exit repeat
			else
				if (charTrimTrailing ≠ (theString's text indexHigh)) then exit repeat
			end if
			
		end repeat
		if ((thestringLen + 1 + indexHigh) < indexLow) then return ""
		return (text indexLow thru indexHigh of theString)
		
	else
		try
			return removeLeadingTrailingChars((get theString as text), trimLeading, trimTrailing)
		on error errMess1
			try
				return removeLeadingTrailingChars((get name of theString), trimLeading, trimTrailing)
			on error
				return errMess1
			end try
		end try
	end if
	
end removeLeadingTrailingChars

on removeTextFromList(theList, theBadChar)
	## theBadChar may be a string or character, whereupon that string will be removed
	## theBadChar may be a list of strings or characters, whereupon those strings will be removed
	
	set theDelim to character id 60000 -- obscure character chosen for the low likelihood of its appearance
	set astid to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to theDelim
		set theString to theList as string
		set AppleScript's text item delimiters to theBadChar
		set text_list to every text item of theString
		set AppleScript's text item delimiters to ""
		set cleanText_S to the text_list as string
		set AppleScript's text item delimiters to theDelim
		set theList to text items of cleanText_S
	end try
	set AppleScript's text item delimiters to astid
	
	return theList
end removeTextFromList

on removeItemFromList(theList, theBadItem)
	## theBadChar may be a string or character, whereupon that string will be removed
	## theBadChar may be a list of strings or characters, whereupon those strings will be removed
	local theDelim, theString, text_list, cleanText_S, errorText, astid
	set theDelim1 to character id 60000 -- obscure characters chosen for the low likelihood of its appearance
	set theDelim2 to character id 60001
	set astid to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to {theDelim2 & theDelim1}
		set theString to theDelim1 & (theList as string) & theDelim2
		set AppleScript's text item delimiters to theDelim1 & theBadItem & theDelim2
		set text_list to every text item of theString
		set AppleScript's text item delimiters to ""
		set cleanText_S to text_list as string
		if 2 < (count of cleanText_S) then
			set cleanText_S to text 2 thru -2 of (text_list as string)
		else
			set cleanText_S to ""
		end if
		set AppleScript's text item delimiters to {theDelim2 & theDelim1}
		set theList to text items of cleanText_S
	end try
	set AppleScript's text item delimiters to astid
	
	return theList
end removeItemFromList

on replaceText(this_text, search_string, replacement_string)
	set astid to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to the search_string
		set the item_list to every text item of this_text
		set AppleScript's text item delimiters to the replacement_string
		set this_text to the item_list as string
	end try
	set AppleScript's text item delimiters to astid
	return this_text
end replaceText

on getIndexOfStrict(theItem, theList)
	## based on the idea by Emmanuel Levy, modified to handle embedded non-alphabetic characters correctly
	set theDelim to character id 60000 -- obscure character chosen for the low likelihood of its appearance
	set theReturnToken to character id 60001
	set theSearchItem to return & replaceText(theItem, return, theReturnToken) & return
	set tempString to joinListToString(theList, theDelim)
	set tempString to replaceText(tempString, return, theReturnToken)
	set theSearchList to return & replaceText(tempString, theDelim, return) & return
	try
		-1 + (count (paragraphs of (text 1 thru (offset of theSearchItem in theSearchList) of theSearchList)))
	on error
		0
	end try
end getIndexOfStrict

on roundToQuantum(thisValue, quantum)
	## Public domain author unknown
	return (round (thisValue / quantum) rounding to nearest) * quantum
end roundToQuantum

on roundDecimals(n, numDecimals)
	## Nigel Garvey, Macscripter
	set x to 10 ^ numDecimals
	tell n * x to return (it div 0.5 - it div 1) / x
end roundDecimals

on MSduration(firstTicks, lastTicks)
	## Public domain
	## returns duration in ms
	## inputs are durations, in seconds, from GetTick's Now()
	return (round (10000 * (lastTicks - firstTicks)) rounding to nearest) / 10
end MSduration

on GetTick_Now()
	## From MacScripter Author "Jean.O.matiC"
	## returns duration in seconds since since 00:00 January 2nd, 2000 GMT, calculated using computer ticks
	script GetTick
		property parent : a reference to current application
		use framework "Foundation" --> for more precise timing calculations
		on Now()
			return (current application's NSDate's timeIntervalSinceReferenceDate) as real
		end Now
	end script
	
	return GetTick's Now()
end GetTick_Now

on noValue()
	## Matt Nueberg
end noValue

on isARef(objectToBeTested)
	## Matt Nueberg
	try
		objectToBeTested as reference
		return true
	on error
		return false
	end try
end isARef
