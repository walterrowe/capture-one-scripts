use AppleScript version "2.8"
use scripting additions

-- candidate source file name extensions
property sourceExts : {"DNG"}
-- candidate target file name extensions
property targetExts : {"CR2", "CRW", "ARW", "ARF", "RAF", "NEF"}

on run
	tell application "Capture One 23"
		-- initialize source and target lists
		set sourceVariants to {}
		set sourceDates to {}
		set targetVariants to {}
		set targetDates to {}
		set matchedVariants to {}
		
		-- get all selected variants		
		set selectedVariants to variants where selected is true
		
		tell me to progress_start(0, "Processing ...", "scanning")
		
		-- divide selected variants into potential sources and targets
		repeat with thisVariant in selectedVariants
			set thisParent to thisVariant's parent image
			set thisFile to quoted form of POSIX path of (thisParent's file as alias)
			set thisName to thisParent's name as string
			set thisDate to do shell script "eval $(/usr/libexec/path_helper -s); exiftool -DateTimeOriginal " & thisFile & "|  cut -c35-"
			if thisVariant's parent image's extension is in sourceExts then
				set sourceVariants to sourceVariants & {thisVariant}
				set sourceDates to sourceDates & {thisDate}
			end if
			if thisVariant's parent image's extension is in targetExts then
				set targetVariants to targetVariants & {thisVariant}
				set targetDates to targetDates & {thisDate}
			end if
		end repeat
		
		-- synchronize adjustments and metadata for matching sources and targets
		set targetCount to length of targetVariants
		repeat with targetItem from 1 to targetCount
			tell me to progress_update(targetItem, targetCount, "")
			
			set targetDate to item targetItem of targetDates
			set targetVariant to item targetItem of targetVariants
			
			-- look for target date in source dates
			set sourceItem to my binarySearch(targetDate, sourceDates, 1, length of sourceDates)
			-- display dialog (sourceItem as string) buttons {"Cancel", "Continue"}
			if sourceItem > 0 then
				set sourceVariant to item sourceItem of sourceVariants
				set matchedVariants to matchedVariants & {sourceVariant, targetVariant}
				-- display dialog sourceName & " => " & targetName buttons "Dismiss"
				set targetVariant's crop to sourceVariant's crop
				copy adjustments sourceVariant
				reset adjustments targetVariant
				apply adjustments targetVariant
				repeat with sourceKeyword in sourceVariant's keywords
					apply keyword sourceKeyword to {targetVariant}
				end repeat
				set targetVariant's color tag to sourceVariant's color tag
				set targetVariant's rating to sourceVariant's rating
				set targetVariant's contact creator to sourceVariant's contact creator
				set targetVariant's contact creator job title to sourceVariant's contact creator job title
				set targetVariant's contact address to sourceVariant's contact address
				set targetVariant's contact city to sourceVariant's contact city
				set targetVariant's contact state to sourceVariant's contact state
				set targetVariant's contact postal code to sourceVariant's contact postal code
				set targetVariant's contact country to sourceVariant's contact country
				set targetVariant's contact phone to sourceVariant's contact phone
				set targetVariant's contact email to sourceVariant's contact email
				set targetVariant's contact website to sourceVariant's contact website
				set targetVariant's content headline to sourceVariant's content headline
				set targetVariant's content description to sourceVariant's content description
				set targetVariant's content category to sourceVariant's content category
				set targetVariant's content supplemental categories to sourceVariant's content supplemental categories
				set targetVariant's content subject codes to sourceVariant's content subject codes
				set targetVariant's content description writer to sourceVariant's content description writer
				set targetVariant's image intellectual genre to sourceVariant's image intellectual genre
				set targetVariant's image scenes to sourceVariant's image scenes
				set targetVariant's image location to sourceVariant's image location
				set targetVariant's image city to sourceVariant's image city
				set targetVariant's image state to sourceVariant's image state
				set targetVariant's image country to sourceVariant's image country
				set targetVariant's image country code to sourceVariant's image country code
				set targetVariant's status title to sourceVariant's status title
				set targetVariant's status job identifier to sourceVariant's status job identifier
				set targetVariant's status instructions to sourceVariant's status instructions
				set targetVariant's status provider to sourceVariant's status provider
				set targetVariant's status source to sourceVariant's status source
				set targetVariant's status copyright notice to sourceVariant's status copyright notice
				set targetVariant's status rights usage terms to sourceVariant's status rights usage terms
				set targetVariant's Getty personalities to sourceVariant's Getty personalities
				set targetVariant's Getty original filename to sourceVariant's Getty original filename
				set targetVariant's Getty parent MEID to sourceVariant's Getty parent MEID
			end if
			tell me to progress_step(targetItem)
		end repeat
		
		if (count of matchedVariants) > 0 then
			tell current document
				if exists collection "Matched Variants" then
					set matchedCollection to collection "Matched Variants"
				else
					set matchedCollection to make new collection with properties {kind:album, name:"Matched Variants"}
				end if
				add inside matchedCollection variants matchedVariants
			end tell
		end if
	end tell
	tell me to progress_end()
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


-- A binary search that always use the complete values list and call itself
-- recursively with different lower and upper indexes. It returns the index
-- of the found item or 0 if not found.
-- credit: https://gist.github.com/mk2/9949533

-- @param	aValue		The value to find
-- @param	values		The full values list to search
-- @param	iLower		The lower index (intially 1)
-- @param	iUpper		The upper index (initially count of values)
-- @returns	0 or index	Return 0 for not found, index when found

on binarySearch(aValue, values, iLower, iUpper)
	
	set valueIndex to 0
	
	-- if search list is narrowed down to only 1 item
	if (iUpper - iLower) <= 4 then
		repeat with midIndex from iLower to iUpper
		if aValue = (item midIndex of values) then
			set valueIndex to midIndex
		end if
		end repeat
		return valueIndex
	end if
	
	set midIndex to (iLower + ((iUpper - iLower) div 2))
	set midValue to item midIndex of values
	
	if midValue = aValue then
		return midIndex
	else if midValue > aValue then
		return my binarySearch(aValue, values, iLower, midIndex)
	else if midValue < aValue then
		return my binarySearch(aValue, values, (midIndex + 1), iUpper)
	end if
	
end binarySearch
