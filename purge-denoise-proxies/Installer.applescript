(*
	AUTHOR

	Author: Walter Rowe
	Contact: walter@walterrowe.com

	Created: 26-May-2026
	Updated: 

	DESCRIPTION

	Purge the Enhanced Denoise proxy files of selected images or current document.

	PREREQUISITES

*)

use AppleScript version "2.8"
use scripting additions
use framework "Foundation"

property libraryFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/"
property installFolder : ((POSIX path of (path to home folder)) as string) & "Library/Scripts/Capture One Scripts/"

property installNames : {"Purge Denoise Proxies"}
property installType : ".scpt"
property installIcon : false -- if true there must be a droplet.icns icon file in the source folder

property requiresCOrunning : true -- true if capture one is required to be running
property requiresCOdocument : true -- true if capture one is required to have an open document

property appTesting : false -- if true, run in script editor, and if false install the script

-- application specific properties below

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
	
	-- get current document attributes
	tell application "Capture One"
		tell current document to set docName to (name as text)
		tell current document to set docPath to (path as text) & name
		tell current document to set docKind to kind
		
		-- get correct path to send to "find"
		if docKind is catalog then
			set docPath to docPath & ".cocatalog"
		end if
		if docKind is session then
			set docPath to text 1 thru ((count docPath) - (count ".cosessiondb")) of docPath
		end if
	end tell
	tell application "Finder" to set docPath to POSIX path of (docPath as text)
	
	-- build and execute the "find" command	
	set findCommand to "find " & docPath & " -name '*.conoisereduced' -print"
	set nrProxies to do shell script findCommand
	
	-- split the results of the find command into a list	
	set tid to text item delimiters
	set text item delimiters to return
	set nrProxies to text items of nrProxies as list
	set text item delimiters to tid
	
	set proxyCount to count of nrProxies
	
	
	if proxyCount = 0 then
		set alertTitle to item 1 of installNames
		set alertMessage to "No denoise proxies found."
		set alertResult to (display alert alertTitle message alertMessage buttons {"OK"} giving up after 10)
		return
	end if
	
	
	-- determine which noise reduced proxies to delete
	set proxiesToDelete to {}
	set sizeReclaimed to 0
	
	if proxyCount > 0 then
		tell application "Capture One" to set selectedVariants to (name of every variant where selected is true)
		if (count of selectedVariants) > 0 then
			-- if the user has selected variants, only purge proxies for selected variants
			repeat with thisVariant in selectedVariants
				repeat with thisProxy in nrProxies
					if thisProxy contains thisVariant then
						tell application "Finder"
							set proxyFile to (POSIX file (thisProxy as text) as alias)
							set end of proxiesToDelete to proxyFile
							set sizeReclaimed to sizeReclaimed + (size of proxyFile)
						end tell
					end if
				end repeat
			end repeat
		else
			-- if the user has no selected variants, purge all found proxies
			repeat with thisProxy in nrProxies
				tell application "Finder"
					set proxyFile to (POSIX file (thisProxy as text) as alias)
					set end of proxiesToDelete to proxyFile
					set sizeReclaimed to sizeReclaimed + (size of proxyFile)
				end tell
			end repeat
		end if
	end if
	
	-- format the sizeReclaimed into a user friendly format (ie. KB, MB, GB)
	set formatter to current application's NSByteCountFormatter's alloc()'s init()
	-- Enables KB, MB, GB labels rather than raw byte counts
	formatter's setAllowedUnits:(current application's NSByteCountFormatterUseAll)
	-- Formats for natural display
	formatter's setCountStyle:(current application's NSByteCountFormatterCountStyleFile)
	-- convert the value to friendly string format
	set sizeReclaimedString to (formatter's stringFromByteCount:(sizeReclaimed)) as text
	
	-- give the user an opportunity to stop before deleting
	set alertTitle to item 1 of installNames
	if proxyCount ­ 1 then
		set alertMessage to "Move " & (proxyCount) & " Denoise proxies (" & sizeReclaimedString & ") to the Trash?"
	else
		set alertMessage to "Move " & (proxyCount) & " Denoise proxy (" & sizeReclaimedString & ") to the Trash?"
	end if
	set alertResult to (display alert alertTitle message alertMessage buttons {"Cancel", "Continue"})
	if button returned of alertResult is "Cancel" then return false
	
	-- user chose to continue
	set proxyCount to count of proxiesToDelete
	if proxyCount > 0 then tell application "Finder" to delete proxiesToDelete
	
	
	set alertTitle to item 1 of installNames
	if proxyCount ­ 1 then
		set alertMessage to "Deleted " & (proxyCount) & " Denoise proxies" & return & "Reclaimed " & sizeReclaimedString & " of space."
	else
		set alertMessage to "Deleted " & (proxyCount) & " Denoise proxy" & return & "Reclaimed " & sizeReclaimedString & " of space."
	end if
	
	-- application code goes above here
	
	set alertResult to (display alert alertTitle message alertMessage buttons {"OK"} giving up after 10)
	
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
