(*
  Script: remove-monochrome-keywords
  Author: Walter Rowe
  Create: July 2020
  Update: April 2023

  Remove a list of monochrome-oriented keywords from images that do not meet monochrome criteria.

  Monochrome criteria:

  * black and white is enabled
  --OR--
  * saturation is -100.0

  When the script is completed, it will show a count of images updated in the results window.

*)

set bwKeywords to {"Black & White", "Monochrome"}
set affectedList to {}

tell application "Capture One 23"
	set updateCount to 0
	repeat with thisKeyword in bwKeywords
		set monoVariants to (variants where (thisKeyword is in name of keywords) and (saturation of adjustments is not -100.0) and (black and white of adjustments is false))
		repeat with thisVariant in monoVariants
			delete (every keyword of thisVariant whose name is thisKeyword)
		end repeat
		set updateCount to updateCount + (count of monoVariants)
	end repeat
	display dialog (updateCount as string) & " images updated." with title "Monochrome Keywords Removed"
end tell
