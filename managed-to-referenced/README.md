# Managed to Referenced

**Donations**: if you like these scripts and want to support them [buy me a coffee](https://buymeacoffee.com/walterrowe).

This AppleScript utility moves image files from inside a managed Capture One catalog to a referenced location outside the catalog. The files are moved into folders based on the image EXIF date. The utility does not use the date folders from the managed folders inside the catalog because the managed folder dates are based on import date.

- Select the images to move from your Capture One catalog.
- Choose the top level folder where the files will be moved.
- The utility creates YYYY/MM/DD subfolders based on the EXIF date of the files moved.

The utility has been tested on:

- macOS Sonoma (Intel and M3 MacBook Pro)
- Capture One 16.4
- Moving to internal and external storage

If you are viewing this in GitLab click the script name to see the source of the script. The press the download button at the top right of the script view panel. Double-click the downloaded script to open it in Script Editor, then run it. 

The script self-installs in the Capture One Scripts folder. Placing it there lets you run it from the Scripts menu inside Capture One.

## Author

| Author | Updated | Description |
| --- | --- | --- |
| Walter Rowe | 2024-08-03 | Initial version written |
