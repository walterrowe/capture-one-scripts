(*
  Script: apply-monochrome-keywords
  Author: Walter Rowe
  Create: June 2020

  Apply a list of monochrome-oriented keywords from images that meet monochrome criteria.

  Monochrome criteria:

  * black and white is enabled
  --OR--
  * saturation is -100.0

*)

set bwKeywords to {"Black & White", "Monochrome"}
set affectedList to {""}

tell application "Capture One 20"
	set affectedList to name of (variants where ((black and white of adjustments is true) or (saturation of adjustments is -100.0)))
	repeat with eachVariant in (variants where ((black and white of adjustments is true) or (saturation of adjustments is -100.0)))
		repeat with bwKeyword in bwKeywords
			tell eachVariant to make keyword with properties {name:bwKeyword}
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
