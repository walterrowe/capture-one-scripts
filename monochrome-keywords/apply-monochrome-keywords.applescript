(*
    Author: Walter Rowe
    Create: June 2020
    Update: April 2023

    1) Look for string "Black & White" and change it to what ever keyword you use for your black and white images.
    2) open the Capture One catalog you want to update and select the All Images collection.
    3) open run this script from Apple ScriptEditor.

    Monochrome criteria:

    * black and white is enabled
    --OR--
    * saturation is -100.0

    When the script is completed, it will show a count of images updated in the results window.

    If you open the Filters tool before running and scroll down to the Keywords filter and your black and white keyword,
    you can watch the counter go up as this script finds and applies your keyword to each image that has the Black and White
    tool enabled (checkbox).
*)

set bwKeywords to {"Black & White", "Monochrome"}

tell application "Capture One 23"
	-- get list of variants with black & white enabled or background saturation set to -100
	set monoVariants to (get variants where ((black and white of adjustments is true) or (saturation of adjustments is -100.0)))
	if (count of monoVariants) > 0 then
		repeat with bwKeyword in bwKeywords
			tell current document
				-- get or create this keyword
				if exists keyword bwKeyword then
					set monoKW to keyword bwKeyword
				else
					tell item 1 in monoVariants to set monoKW to make new keyword with properties {name:bwKeyword}
				end if
				-- apply the keyword to list of variants
				apply keyword monoKW to monoVariants
			end tell
		end repeat
	end if
	display dialog ((count of monoVariants) as string) & " images updated." with title "Monochrome Variants Updated"
end tell
