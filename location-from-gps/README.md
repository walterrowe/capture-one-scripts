# Location from GPS

**Donations**: if you like these scripts and want to support them [buy me a coffee](https://buymeacoffee.com/walterrowe).

For the selected variants scan for GPS coordinates. If GPS coordinates are present then use Google Maps to get location attributes for city, county, state, country, country code.

* Apply a hierarchical keyword for country > state > county > city
* Set variant IPTC fields for city, state, country, country code

# Requirements

This script uses JSON Helper and your own [Google Maps API Key (via Google Developer portal)](https://developers.google.com/maps/documentation/geocoding/get-api-key) to  send GPS latitude and longitude to fetch address information and parse it in JSON format.

# How To Use

Select a batch of pictures in Capture One and run the script. 

# Installation

Installation is simple:

1. Open the AppleScript file in macOS Script Editor and run it.
2. The script self-installs in the Capture One Scripts folder.
3. Open Capture One and choose Script > Update Script Menu.
4. You now can run the script from the Capture One Scripts menu.
