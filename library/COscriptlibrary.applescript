##
## COscriptlibrary - a library of utility handlers for Capture One scripting
##
## - some handlers came from the Apple AppleScript Language Guide
## - some handlers are credited to other AppleScript developers
##
## how to use this library
##
## 1) open COscriptlibrary.applescript in Script Editor
## 2) run the script to self-install the library
## 3) add code similar to this to your Apple Script
##
## on run
##		set appBase to my name
## 		try
## 			set myLibrary to ((path to home folder as alias) as string) & "Library:Scripts:COscriptlibrary.scpt" as alias
## 			set myLibrary to load script (myLibrary)
## 		on error
## 			set myLibrary to POSIX path of (((path to home folder as alias) as string) & "Library:Scripts:COscriptlibrary.scpt")
## 			set alertResult to (display alert appBase message "Unable to load script library " & myLibrary buttons {"Quit"} giving up after 30)
## 			return
## 		end try
##
## 		set readyToRun to myLibrary's meetsRequirements("fake script", true, "catalog")
## end run
##

##
## this performs a self-install of the library into ~/Library/Scripts/COscriptlibrary.scpt
##
on run
	set appName to my name
	set pathToMe to path to me
	set installFolder to ((POSIX path of (path to home folder)) as string) & "Library/Scripts/"
	set appType to ".scpt"
	
	installMe(appName, pathToMe, installFolder, appType, appName as list, false)
end run

##
## applescript self-installer function
##

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

##
## confirm if capture one is running and has an open document (if required)
##

on meetsRequirements(appBase, requiresCOrunning, requiresCOdocument)
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
	
	return requirementsMet
	
end meetsRequirements

##
## Ask the user to turn on UI scripting
##

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
## convert capture one kind codes into real words
##

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
		if "Ç" ­ (get text 1 of theKind) then return theKind
		set kindItem_s to theKind
	else
		tell application "Capture One" to set kindItem_s to (get theKind as text)
		if "Ç" ­ (get text 1 of kindItem_s) then return kindItem_s
	end if
	
	set code_start to -5
	if ("È" ­ (get text -1 of kindItem_s)) or (16 > (count of kindItem_s)) then Â
		error "convertKindList received an unexpected Kind string: " & kindItem_s
	
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
	
	error "convertKindList received an unexpected Kind string: " & kindItem_s
	
end convertKindList


##
## capture one native handler to return string value of object type
##

on getCOtype(theObject)
	
	##
	## capture one native handler to return string value of object type
	##
	## modelled after eric valk's convertKindList but uses native references
	##
	
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

on myAlert(alertHeading, alertMessage, alertGiveUp, alertButtons, alertCancel)
	set alertResult to (display alert alertHeading message alertMessage as critical buttons alertButtons giving up after alertGiveUp)
	if (gave up of alertResult) or (button returned of alertResult is alertCancel) then
		return false
	else
		return button returned of alertResult
	end if
end myAlert

##
## trim specified leading/trailing characters from a string
##

on trimString(theSource, theTrimmer)
	local theResult
	
	set strBegin to 1
	set strEnd to length of theSource
	
	-- find first char after theTrimmer
	if theSource starts with theTrimmer then
		repeat while ((strBegin < strEnd) and (item strBegin of theSource is theTrimmer))
			set strBegin to strBegin + 1
		end repeat
	end if
	
	-- find last char before theTrimmer
	if theSource ends with theTrimmer then
		repeat while ((strEnd > strBegin) and (item strEnd of theSource is theTrimmer))
			set strEnd to strEnd - 1
		end repeat
	end if
	
	set theResult to characters strBegin thru strEnd of theSource as string
	if theResult = theTrimmer then
		return ""
	else
		return theResult
	end if
end trimString

##
## join a list into a string based on a specific delimiter
##

on joinText(theText, theDelimiter)
	set AppleScript's text item delimiters to theDelimiter
	set theTextItems to every text item of theText as string
	set AppleScript's text item delimiters to ""
	return theTextItems
end joinText

##
## split a string into a list based on a specific delimiter
##

on splitText(theText, theDelimiter)
	set AppleScript's text item delimiters to theDelimiter
	set theTextItems to every text item of theText
	set AppleScript's text item delimiters to ""
	return theTextItems
end splitText

##
## use text item delimiters to find and replace text in a string
##

on findReplace(t, toFind, toReplace)
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

on sortList(theList)
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

##
## nigel garvey (2011)
##
## https://www.macscripter.net/t/recursively-extract-items-from-list-of-lists/61412/3
##

on flatten(listOfLists)
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
