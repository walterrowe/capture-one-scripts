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

## Installation

The script self-installs in your Capture One Scripts folder.

1. Open the AppleScript file in macOS Script Editor.
1. Click the "Run this script" (&#9654;) button.
1. Open Capture One and choose Scripts > Update Script Menu.
1. You now can run the script from the Capture One Scripts menu.
## How To Use

Select a batch of pictures in Capture One and run the script.

## ChangeLog

- 13 Aug 2024 - enhanced installer and requirements checks
