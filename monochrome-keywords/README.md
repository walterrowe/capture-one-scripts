# Monochrome Keywords

Auth: Walter Rowe<br>
Date: June 2020

## Description

There are two scripts in this directory.

* [apply-monochrome-keywords](apply-monochrome-keywords.applescript) - adds keywords to the images matching the criteria.
* [remove-monochrome-keywords](remove-monochrome-keywords.applescript) - removes keywords from images not matching the criteria.

## Monochrome Image Criteria

The criteria for identifying monochrome images are:

1. The black and white tool is enabled (checked), OR
2. The saturation of the background layer set to -100

You may ask why the script only looks at the background layer for the saturation adjustment value of -100. The background layer contains no mask. It applies the adjustment globally to the entire image. Other layers may have masks that do not affect the entire image. We cannot assume these other layers result in a monochrome image.

## apply-monochrome-keywords

For each variant matching the above criteria, it adds each of the keywords in the list ```bwKeywords```.

## remove-monochrome-keywords

For each variant NOT matching the above criteria, AND having one of the keywords in the list ```bwKeywords```, the requisite keyword is removed. 

## Change The Keywords

The default list includes ```Monochrome``` and ```Black & White```.

You can change the list of keywords by finding the line 

```
set bwKeywords to { "Black & White", "Monochrome" }
```

and changing the list of keywords to words of your choosing for your monochrome images. Remember that each keyword must be in double quotes, the list must be comma-separated, and there must be curly braces enclosing the list as shown here.

## Usage

Follow these steps to execute this script:

1. Download the file scripts to your macOS system.
2. Open the Capture One catalog you want to update and select the All Images collection.
3. Open the script you wish to run in Apple ScriptEditor.
4. Make any desired changes to the list of keywords applied.
5. Run the script by pressing the "Run" button (looks like a "Play" button).

When the script is completed, it will show a list of image names in the results window. If no images are changed, a message will appear indicating so.
