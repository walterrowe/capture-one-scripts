(*
  Script: remove-keywords-non-monochrome
  Author: Walter Rowe
  Create: July 2020

  Remove a list of monochrome-oriented keywords from images that do not meet monochrome criteria.

  Monochrome criteria:

  * black and white is enabled
  --OR--
  * saturation is -100.0

  When the script is completed, it will show a list of image names in the results window.

*)

set bwKeywords to {"Black & White", "Monochrome"}
set affectedList to {}

tell application "Capture One 20"
	repeat with thisKeyword in bwKeywords
		repeat with thisVariant in (variants where (thisKeyword is in name of keywords) and (saturation of adjustments is not -100.0) and (black and white of adjustments is false))
			if (name of thisVariant) is not in affectedList then
				copy name of thisVariant to end of affectedList
			end if
			delete (every keyword of thisVariant whose name is thisKeyword)
		end repeat
	end repeat
	if (length of affectedList) > 0 then
		set saveTID to AppleScript's text item delimiters
		set AppleScript's text item delimiters to ", "
		set Final to affectedList as text
		set AppleScript's text item delimiters to saveTID
		display dialog Final with title "Affected Variants"
	else
		display dialog "No images affected" as string with title "Affected Variants"
	end if
end tell
