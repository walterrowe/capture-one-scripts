-- select image layer of selected variants
-- Zdeněk Macháček
-- https://support.captureone.com/hc/en-us/community/posts/7116665276701-Select-Background-Layer-all-variants-

use AppleScript version "2.4" -- Yosemite (10.10) or later 
use scripting additions

tell application "Capture One"
	set selVarList to selected variants
	repeat with thisVariant in selVarList
 		tell thisVariant to set current layer to first layer
	end repeat
end tell