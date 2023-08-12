--
-- Apply Capture One color tags as color labels of corresponding files in macOS Finder
--
-- Author: Walter Rowe
-- Create: 12-August-2023
--

use AppleScript version "2.8"
use scripting additions

on run
	tell application "Capture One 23"
		set startTime to current date
		set imageSel to get variants where selected is true
		set noLabels to {}
		tell me to progress_start(0, "Processing ...", "scanning")
		set imgCount to count of imageSel
		set imgsUpdated to 0
		repeat with i from 1 to imgCount
			tell me to progress_update(i, imgCount, "")
			set thisVariant to item i of imageSel
			set thisFile to file of parent image of thisVariant as alias
			set thisLabel to color tag of thisVariant
			-- map capture one color tags to macOS finder label indexes
			-- color CO-index Finder-index
			-- 
			-- None		0		0
			-- Red		1		2
			-- Orange	2		1
			-- Yellow		3		3
			-- Green		4		6
			-- Blue		5		4
			-- Pink		6		7 (CO pink maps to Finder gray)
			-- Purple		7		5
			--
			if thisLabel is 1 then
				set thisLabel to 2
			else if thisLabel is 2 then
				set thisLabel to 1
			else if thisLabel is 4 then
				set thisLabel to 6
			else if thisLabel is 5 then
				set thisLabel to 4
			else if thisLabel is 6 then
				set thisLabel to 7
			else if thisLabel is 7 then
				set thisLabel to 5
			end if
			
			tell application "Finder" to set label index of thisFile to thisLabel
			tell me to progress_step(i)
		end repeat
		
		tell me to progress_end()
		
		tell me to set noLabelsCount to ((count of noLabels) as string)
		tell me to set timeTaken to ((current date) - startTime)
		set timeTaken to ((timeTaken / 60 as integer) as string) & ":" & (text -1 thru -2 of ("0" & (timeTaken mod 60 as integer) as string))
		
		display dialog "Updated " & imgCount & " images in " & timeTaken & " (mm:ss)." with title "Copy Labels to Finder" buttons {"Okay"}
		
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

