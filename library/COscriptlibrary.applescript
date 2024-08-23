(*
	AUTHOR

	Author: Walter Rowe
	Contact: walter@walterrowe.com

	Created: 16-Aug-2024
	Updated: 23-Aug-2024

	DESCRIPTION

	COscriptlibrary - a library of utility handlers for Capture One scripting
	Use templates/AppTemplate.applescript for new apps that use this library

	- some handlers are from the Apple AppleScript Language Guide
	- some handlers are credited to other AppleScript developers
	- some handlers are written by me based on examples and need

	PREREQUISITES

	None
*)

property name : "COscriptlibrary"
property version : "1.0"
property id : "COscriptlibrary"

use AppleScript version "2.8"
use scripting additions

## performs a self-install of the library into ~/Library/Scripts/COscriptlibrary.scpt
##
## *** useful if you are working offline ***

on run
	set appName to my name
	set pathToMe to path to me
	set libraryFolder to ((POSIX path of (path to home folder)) as string) & "Library/Scripts/"
	set appType to ".scpt"
	
	installMe(appName, pathToMe, libraryFolder, appType, appName as list, false)
end run

##
## applescript self-installer function
##

on installMe(appBase as string, pathToMe as string, installFolder as string, appType as string, appNames as list, appIcon as boolean)
	
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
			tell application "Finder"
				set myFolder to (folder of (pathToMe as alias)) as string
				set iconSource to myFolder & "droplet.icns"
				set iconTarget to POSIX file (scriptTarget & "/Contents/Resources/") as alias as string
				try
					duplicate file iconSource to folder iconTarget with replacing and exact copy
				on error errStr number errorNumber
					set alertResult to (display alert "Install Icon Error" message errStr & ": " & (errorNumber as text) & "on file " & scriptSource buttons {"Stop"} default button "Stop" as critical giving up after 10)
				end try
			end tell
		end if
	end repeat
	set alertResult to (display alert "Installation Complete" buttons {"OK"} default button "OK")
	
end installMe

##
## confirm if capture one is running and has an open document (if required)
##

on meetsRequirements(appBase as string, requiresCOrunning as boolean, requiresCOdocument)
	
	set requirementsMet to true
	
	set requiresDoc to false
	if class of requiresCOdocument is string then set requiresDoc to true
	if class of requiresCOdocument is boolean and requiresCOdocument then set requiresDoc to true
	
	if requiresCOrunning then
		
		tell application "Capture One" to set isRunning to running
		if not isRunning then
			display alert "Alert" message "Capture One must be running." buttons {"Quit"}
			set requirementsMet to false
		end if
		
		if requiresDoc and requirementsMet then
			tell application "Capture One" to set documentOpen to exists current document
			if not documentOpen then
				display alert appBase message "A Capture One Session or Catalog must be open." buttons {"Quit"}
				set requirementsMet to false
			end if
			
			if requirementsMet and class of requiresCOdocument is string then
				tell application "Capture One"
					tell current document
						if kind is catalog then set docKind to "catalog"
						if kind is session then set docKind to "session"
					end tell
				end tell
				if docKind is not requiresCOdocument then
					display alert appBase message "You must be working in a Capture One " & requiresCOdocument & "." buttons {"Quit"}
					set requirementsMet to false
				end if
			end if
		end if
	end if
	
	return requirementsMet as boolean
	
end meetsRequirements

##
## Ask the user to turn on UI scripting
##

-- notice to display when UI Scripting is not enabled
property UIScriptingNotice : "User Interface scripting is not enabled for Capture One. In order to continue it must be enabled." & return & return & "After clicking OK, the System Settings window will open. Enable Capture One in the list and enter your password when prompted, then try the app again."

on activateUIScripting()
	tell application "System Events"
		set UIscripting to UI elements enabled
	end tell
	if UIscripting is false then
		display alert UIScriptingNotice
		tell application "System Settings"
			activate
			reveal anchor "Privacy_Accessibility" of pane "Privacy & Security"
		end tell
	end if
end activateUIScripting

##
## get string representation of "kind" of object(s)
##

on getCOtype(theObject)
	
	## capture one native handler to return string value(s) of object(s) type
	## modelled after eric valk's convertKindList() but uses native references
	
	if class of theObject is list then
		set types_list to {}
		repeat with theItem in theObject
			set the end of types_list to my getCOtype(theItem)
		end repeat
		return types_list
	end if
	
	tell application "Capture One"
		tell current document
			if class of theObject is variant then return "variant"
			if class of theObject is image then return "image"
			if class of theObject is recipe then return "recipe"
			if class of theObject is collection then
				if kind of theObject is favorite then return "favorite"
				if kind of theObject is catalog folder then return "catalog folder"
				if kind of theObject is smart album then return "smart album"
				if kind of theObject is group then return "group"
				if kind of theObject is project then return "project"
				if kind of theObject is album then return "album"
			end if
			if class of theObject is layer then
				if kind of theObject is background then return "background"
				if kind of theObject is heal then return "clone"
				if kind of theObject is clone then return "heal"
				if kind of theObject is adjustment then return "adjustment"
			end if
			if class of theObject is watermark then
				if kind of theObject is Textual then return "text"
				if kind of theObject is Imagery then return "image"
				return "none"
			end if
			if class of theObject is document then
				if kind of theObject is catalog then return "catalog"
				if kind of theObject is session then return "session"
			end if
		end tell
	end tell
	return missing value
end getCOtype


## display an alert with heading, message, button(s), time out (give up), cancel button
##
## @param {string}			alertHeading		short bold alert text title
## @param {string}			alertMessage		long alert text displayed below alert title
## @param {int} 				alertGiveUp		number of seconds to wait for response (0 = forever)
## @param {list of strings}		alertButtons		one to three buttons to offer user
## @param {string}			alertCancel		value returned for button representing cancel
##
## @returns false if gave up or cancel button pressed
## @returns button returned value

on myAlert(alertHeading as string, alertMessage as string, alertGiveUp as integer, alertButtons as list, alertCancel as string)
	set alertResult to (display alert alertHeading message alertMessage as critical buttons alertButtons giving up after alertGiveUp)
	if (gave up of alertResult) or (button returned of alertResult is alertCancel) then
		return false
	else
		return button returned of alertResult
	end if
end myAlert

##
## join a list into a string based on a specific delimiter
##

on joinText(theText as string, theDelimiter as string)
	set AppleScript's text item delimiters to theDelimiter
	set theTextItems to every text item of theText as string
	set AppleScript's text item delimiters to ""
	return theTextItems
end joinText

##
## split a string into a list based on a specific delimiter
##

on splitText(theText as string, theDelimiter as string)
	set AppleScript's text item delimiters to theDelimiter
	set theTextItems to every text item of theText
	set AppleScript's text item delimiters to ""
	return theTextItems
end splitText

##
## use text item delimiters to find and replace text in a string
##

on findReplace(t as string, toFind as string, toReplace as string)
	set {tid, text item delimiters} to {text item delimiters, toFind}
	set t to text items of t
	set text item delimiters to toReplace
	set t to t as text
	set text item delimiters to tid
	return t
end findReplace

##
## sort a list
##

on sortList(theList as list)
	set theIndexList to {}
	set theSortedList to {}
	repeat (length of theList) times
		set theLowItem to ""
		repeat with a from 1 to (length of theList)
			if a is not in theIndexList then
				set theCurrentItem to item a of theList as text
				if theLowItem is "" then
					set theLowItem to theCurrentItem
					set theLowItemIndex to a
				else if theCurrentItem comes before theLowItem then
					set theLowItem to theCurrentItem
					set theLowItemIndex to a
				end if
			end if
		end repeat
		set end of theSortedList to theLowItem
		set end of theIndexList to theLowItemIndex
	end repeat
	return theSortedList
end sortList

##
## progress status functions
## original: https://github.com/iconifyit/applescript-examples
##

-- Create the initial progress bar.
-- @param {int} 	 steps  			The number of steps for the process
-- @param {string} descript		The initial text for the progress bar
-- @param {string} descript_add 	Additional text for the progress bar
-- @returns void
on progress_start(steps as integer, descript as string, descript_add as string)
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
on progress_update(n as integer, steps as integer, message as string)
	set progress additional description to message & n & " of " & steps
end progress_update

-- Increment the step number of the progress bar.
-- @param {int} 	 n            The current step number in the iteration
-- @returns void
on progress_step(n as integer)
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

##
## nigel garvey (2011)
##
## https://www.macscripter.net/t/recursively-extract-items-from-list-of-lists/61412/3
##

on flatten(listOfLists as list)
	script o
		property fl : {}
		
		on flttn(l)
			script p
				property lol : l
			end script
			
			repeat with i from 1 to (count l)
				set v to item i of p's lol
				if (v's class is list) then
					flttn(v)
				else
					set end of my fl to v
				end if
			end repeat
		end flttn
	end script
	
	tell o
		flttn(listOfLists)
		return its fl
	end tell
end flatten

## get a collection's parent path
## inspired by eric valk

on getCollectionPath(theColl)
	tell application "Capture One"
		if class of theColl is not collection then return {}
		set collPath to {current document}
		tell current document
			try
				-- force an error and capture the error text
				get || of theColl
			on error errText
				-- extract list of the collection IDs from the error text
				-- example return: { "18", "17", "13, "12" }
				-- first ID is the collection we were passed
				set collIDs to my match(errText, "/(\\d+)/g")
			end try
		end tell
		-- if count is 1, collection we were passed is a root level collection
		if (count of collIDs) > 1 then
			repeat with collIndex from (count of collIDs) to 2 by -1
				set collID to item collIndex of collIDs
				tell first item of collPath to set beginning of collPath to collection id collID
			end repeat
		end if
	end tell
	return collPath
end getCollectionPath

## get contents of a collection and its children
## inspired by eric valk
## returns a list of records
## - name : collection name
## - path : collection path relative to start collection
## - type : collection type (album, smart album)
## - vars : list of variants in collection

on getCollections(theCollection, parentPath)
	
	set groupTypes to {"group", "project"}
	set albumTypes to {"album", "smart album"}
	
	-- construct colon-separated path string
	if parentPath is not "" then set parentPath to parentPath & ":"
	
	set myType to myLibrary's getCOtype(theCollection)
	
	-- display dialog myType
	set myName to ""
	if class of theCollection is not list then
		tell application "Capture One" to tell current document to set myName to ((name of theCollection) as string)
	end if
	if class of theCollection is list then
		set theSubColls to {}
		repeat with subColl in theCollection
			set end of theSubColls to getCollections(subColl, parentPath)
		end repeat
		return theSubColls
	end if
	
	-- display dialog myName & return & parentPath & return & myType
	
	-- if we find a group type, search for and traverse the children
	if myType is in groupTypes then
		tell application "Capture One" to tell current document to set subCollections to every collection of theCollection
		if (count of subCollections) > 0 then
			set theSubColls to {}
			repeat with subColl in subCollections
				set thisColl to my getCollections(subColl, parentPath & myName)
				if class of thisColl is record then set end of theSubColls to (thisColl as record)
				if class of thisColl is list then set theSubColls to theSubColls & thisColl
			end repeat
			return theSubColls
		end if
	end if
	
	-- if we find an album type, return a record with name, parent path, type, list of variants
	if myType is in albumTypes then
		tell application "Capture One"
			tell current document
				set collContents to every variant of theCollection
				return {collectionName:myName, collectionPath:parentPath, collectionType:myType, CollectionVars:collContents} as record
			end tell
		end tell
	end if
end getCollections

# collection of string handlers that leverage JavaScript
# https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String

on match(_subject as string, _regex as string)
	set handlerName to "match"
	set _js to "(new String(`" & _subject & "`)).match(" & _regex & ")"
	set _result to run script _js in "JavaScript"
	if _result is null or _result is missing value then return {}
	return _result
end match

on replace(_subject as string, _regex as string, _replace as string)
	set handlerName to "replace"
	set _js to "(new String(`" & _subject & "`)).replace(" & _regex & ",\"" & _replace & "\")"
	set _result to run script _js in "JavaScript"
	if _result is null or _result is missing value then return {}
	return _result
end replace

on split(_subject as string, _split as string)
	set handlerName to "split"
	set _js to "(new String(`" & _subject & "`)).split(" & _split & ")"
	set _result to run script _js in "JavaScript"
	if _result is null or _result is missing value then return {}
	return _result
end split

on trim(_subject as string)
	set handlerName to "trim"
	set _js to "(new String(`" & _subject & "`)).trim()"
	set _result to run script _js in "JavaScript"
	if _result is null or _result is missing value then return {}
	return _result
end trim

on slice(_subject as string, _start as integer, _chars as integer)
	set handlerName to "slice"
	if (_start < 1) and (_chars < 1) then error handlerName & " parameters must be source string [,start pos[,num of chars]]"
	if (_start + _chars) > length of _subject then error handlerName & " parameters must be source string [,start pos[,num of chars]]"
	set _slice to _start & "," & (_start + _chars)
	
	set _js to "(new String(`" & _subject & "`)).slice(" & _slice & ")"
	set _result to run script _js in "JavaScript"
	if _result is null or _result is missing value then return {}
	return _result
end slice

on indexOf(_subject as string, _string as string, _start as integer)
	set handlerName to "indexOf"
	set _indexOf to "\"" & _string & "\""
	if _start is not 0 then set _indexOf to _indexOf & "," & _start
	
	set _js to "(new String(`" & _subject & "`)).indexOf(" & _indexOf & ")"
	set _result to run script _js in "JavaScript"
	if _result is null or _result is missing value then return {}
	return _result
end indexOf

on lastIndexOf(_subject as string, _string as string, _start as integer)
	set handlerName to "indexOf"
	set _lastindexOf to "\"" & _string & "\""
	if _start is not 0 then set _lastindexOf to _lastindexOf & "," & _start
	
	set _js to "(new String(`" & _subject & "`)).lastIndexOf(" & _lastindexOf & ")"
	set _result to run script _js in "JavaScript"
	if _result is null or _result is missing value then return {}
	return _result
end lastIndexOf
