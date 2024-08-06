# Monochrome Keywords

Auth: Walter Rowe<br>
Date: June 2020

**Donations**: if you like these scripts and want to support them [buy me a coffee](https://buymeacoffee.com/walterrowe).

## Description

There are two scripts in this directory.

* [apply-monochrome-keywords](apply-monochrome-keywords.applescript) - adds keywords to the images matching the criteria.
* [remove-monochrome-keywords](remove-monochrome-keywords.applescript) - removes keywords from images not matching the criteria.

These script will run on the currently selected document and collection. It should honor any filters on the view.

# Installation

The script self-installs in your Capture One Scripts folder.

1. Open the AppleScript file in macOS Script Editor.
1. Click the "Run this script" (&#9654;) button.
1. Open Capture One and choose Script > Update Script Menu.
1. You now can run the script from the Capture One Scripts menu.

## Monochrome Image Criteria

The criteria for identifying monochrome images are:

1. The black and white tool is enabled (checked), OR
2. The saturation of the background layer set to -100

You may ask why the script only looks at the background layer for the saturation adjustment value of -100. The background layer contains no mask. It applies the adjustment globally to the entire image. Other layers may have masks that do not affect the entire image. We cannot assume these other layers result in a monochrome image.

## Apply Monochrome Keywords

For each variant matching the above criteria, it adds each of the keywords in the list ```bwKeywords```.

**NOTICE**: RGB grayscale color profile images will not be identified as monochrome. No keywords will be applied. You will have to visually identify and tag these images manually.

## Remove Monochrome Keywords

For each variant NOT matching the above criteria, AND having one of the keywords in the list ```bwKeywords```, the requisite keyword is removed.

**NOTICE**: RGB grayscale color profile images will not be identified as monochrome. Monochrome keywords WILL be removed because they will not match the criteria above. Filter your collection view to exclude these image to avoid this.

## Change The Keywords

The default list includes ```Monochrome``` and ```Black & White```.

You can change the list of keywords by finding the line

```
set bwKeywords to { "Black & White", "Monochrome" }
```

and changing the list of keywords to words of your choosing for your monochrome images. Remember that each keyword must be in double quotes, the list must be comma-separated, and there must be curly braces enclosing the list as shown here.

## Usage

Follow these steps to execute this script:

1. Download the scripts or repository to your macOS system.
2. Open the Capture One catalog you want to update and select the All Images collection.
3. Open the script you wish to run in Apple ScriptEditor.
4. Make any desired changes to the list of keywords.
5. Run the script by pressing the "Run" button (looks like a "Play" button).

When the script is completed, it will show a list of image names in the results window. If no images are changed, a message will appear indicating so.
