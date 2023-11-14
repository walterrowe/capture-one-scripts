-- set the color label to blue for every variant with an empty iptc title
-- Author: Eric Nepean (@ericnepean in Capture One Forums)

tell application "Capture One" to tell (every variant whose content headline is "") to set color tag to 5
