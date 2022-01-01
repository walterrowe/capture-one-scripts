# add-border

macOS AppleScript to add borders to image files. This works as a droplet with macOS Finder or with Capture One Pro when added to the Open With field in Output Recipes.

| Role | Name | Year |
| ---: | :--- | ---: |
| Original | Kim Aldis | 2016 |
| Modified | Walter Rowe | 2022 |

## How To Use This

### Create an app from this script

1. Open add_border.scpt in ScriptEditor
2. File > Export and save in a place where you can reference it
   * File Format: Application

### Use with macOS Finder

1. Select image files in Finder
2. Drag-n-drop selected files onto add_border droplet

### Use with Capture One

1. Go to `Open With` field in a Capture One Process Recipe
2. Choose `Other` from the `Open With` drop-down menu
3. Navigate to and select your add_border droplet
4. Select Process Recipe
5. Select images to process
6. Process images (`CMD-d`)

### Change Border Size

Look at comments inside the AppleScript code to see where you can change the border styles. You can create multiple apps from this same script. Simply modify the border code to your liking inside the script and export it as a new app with an appropriate name. Each app you create will add the border you coded into the script when you saved it. If you don't like what you created, just delete the exported app and create a new one.

Example ideas might be:

* add\_border\_10 – add a 10-pixel border
* add\_border\_20 – add a 20-pixel border
* add\_border\_black – add a black border with inner white border
* add\_border\_white – add a white border with inner black border

You can create different Process Recipes in Capture One that reference the different apps you created, or you can use macOS Finder to drag-n-drop selected images onto the app version that adds the border you desire.

## macOS Catalina Changes

macOS Catalina introduces new levels of security to protect your system from unwanted access to your files. This change requires that you to grant explicit access to your files and folders. The add_border droplet uses the Image Event core service to modify the border of the selected image files. We therefore need to grant Full Disk access to the Image Event service so it can read and write your image files.

This information was documented in [this article](https://darjeelingsteve.com/articles/Fixing-%22Image-Events%22-AppleScripts-Broken-in-macOS-10.15-Catalina.html) written by Steve Anthony.

1. Open System Preferences
2. Go to Security & Privacy
3. Click the Lock icon to unlock the panel
4. Click the Privacy tab at the top
5. Scroll down to and select Full Disk Access
6. In the right side click the "+" button
7. In the navigator popup, select the following:
   * Macintosh HD > System > Library > CoreServices > Image Events
8. Press the Open button in the bottom right corner

This should add the Image Events service to the list of apps with Full Disk Access permissions.

## Origins

This script originates from Apple’s Recursive Image File Processing Droplet template. You can read more about it in the [Mac Automation Scripting Guide to Process Dropped Files and Folders](https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/ProcessDroppedFilesandFolders.html). It formats and executes terminal `sips` command to edit the selected image files.

1. Open Apple ScriptEditor
2. Navigate to menu option File > New from Template > Droplets > Recursive Image File Processing Droplet
