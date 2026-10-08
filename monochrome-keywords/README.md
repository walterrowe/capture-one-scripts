# Monochrome Keywords

**Donations**: if you like to keep these scripts free please consider [buying me a coffee](https://buymeacoffee.com/walterrowe).

## Description

There are two scripts in this directory.

* [apply-monochrome-keywords](apply-monochrome-keywords.applescript) - adds keywords to the images matching the criteria.
* [remove-monochrome-keywords](remove-monochrome-keywords.applescript) - removes keywords from images not matching the criteria.

These script will run on the currently selected document and collection. It should honor any filters on the view.

## Prerequisites

None

## Installation

The script self-installs into your local Capture One Scripts folder on first run.

1. Open `Installer.applescript` (or `.scpt`) in macOS **Script Editor**.
2. Make sure that ScriptEditor shows "AppleScript" (**NOT JavaScript**).
    
    <img width=300px border=1 src="../assets/script-editor-applescript.png">

3. Click the **Run** button (&#9654;). The script will automatically download and compile the required `COscriptlibrary` library into `~/Library/Scripts/Capture One Scripts/`.
4. Open Capture One and navigate to **Scripts > Update Script Menu**.
5. You can now execute **Apply Monochrome Keywords** and **Remove Monochrome Keywords** directly from Capture One's **Scripts** menu.

## How To Use

### Monochrome Image Criteria

The criteria for identifying monochrome images are:

1. The black and white tool is enabled (checked), OR
2. The saturation of the background layer set to -100

You may ask why the script only looks at the background layer for the saturation adjustment value of -100. The background layer contains no mask. It applies the adjustment globally to the entire image. Other layers may have masks that do not affect the entire image. We cannot assume these other layers result in a monochrome image.

### Apply Monochrome Keywords

For each variant matching the above criteria, it adds each of the keywords in the list ```bwKeywords```.

**NOTICE**: RGB grayscale color profile images will not be identified as monochrome. No keywords will be applied. You will have to visually identify and tag these images manually.

### Remove Monochrome Keywords

For each variant NOT matching the above criteria, AND having one of the keywords in the list ```bwKeywords```, the requisite keyword is removed.

**NOTICE**: RGB grayscale color profile images will not be identified as monochrome. Monochrome keywords WILL be removed because they will not match the criteria above. Filter your collection view to exclude these image to avoid this.

### Change The Keywords

The default list includes ```Monochrome``` and ```Black & White```.

You can change the list of keywords by finding the line

```
set bwKeywords to { "Black & White", "Monochrome" }
```

and changing the list of keywords to words of your choosing for your monochrome images. Remember that each keyword must be in double quotes, the list must be comma-separated, and there must be curly braces enclosing the list as shown here.

## Compatibility

The utility has been tested on:

- macOS Sonoma (Intel and M3 MacBook Pro)
- Capture One 16.4
- Moving to internal and external storage

## ChangeLog

- 13 Aug 2024 - enhanced installer and requirements checks
