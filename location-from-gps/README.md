# Location from GPS

**Donations**: if you like to keep these scripts free please consider [buying me a coffee](https://buymeacoffee.com/walterrowe).

## Description

For the selected variants scan for GPS coordinates. If GPS coordinates are present then use Google Maps to get location attributes for city, county, state, country, country code.

* Apply a hierarchical keyword for country > state > county > city
* Set variant IPTC fields for city, state, country, country code

## Prerequisites

- JSON Helper
- Google Maps API Key

This utility uses JSON Helper to parse the JSON returned from the Google Maps API. It requires your [Google Maps API Key (via Google Developer portal)](https://developers.google.com/maps/documentation/geocoding/get-api-key) to authenticate with the Google Maps API service to fetch address information using latitude and longitude values associated with each selected image.

You will be prompted to enter your API key the first time you use this utility. It will store the key in a property list file in your home directory and read it from there with each subsequent use. This is decribed in more detail below.

## Installation

The script self-installs in your Capture One Scripts folder.

1. Open the AppleScript file in macOS Script Editor.
1. Click the "Run this script" (&#9654;) button.
1. Open Capture One and choose Scripts > Update Script Menu.
1. You now can run the script from the Capture One Scripts menu.

## How To Use

Select a batch of pictures in Capture One and run the script.

## Maps API Key

The first time you run the script it will ask for your Google Maps API Key. The key will be stored in a property list file. Each subsequent time the script is run it will read the key from the property list file. The property list file is called ` location_from_gps.plist ` and is stored in your home folder under the ` ~/Library/Preferences ` folder.

When you copy-paste your API key into the dialog you may only see the last few characters of the key. This is because the dialog box has wrapped the text line. If you press the up arrow you will see the rest of your key. Pressing the down arrow will show the end of the key again. Do not fear. The entire key will be stored in the property list file and used to query the Google Maps location service.

## ChangeLog

- 13 Aug 2024 - enhanced installer and requirements checks
- 06 Sep 2024 - store maps api key in property list file
