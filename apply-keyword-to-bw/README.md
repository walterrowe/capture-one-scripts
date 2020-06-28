# apply-keyword-to-bw

Auth: Walter Rowe<br>
Date: June 2020

# Description

This script will search all variants in your catalog looking for those with either

1. The black and white tool enabled (checked), or
2. The saturation adjustment of the background layer set to -100

For each variant matching the above criteria, it adds each of the keywords in the list bwKeywords. The default list includes ```Black & White``` and ```Monochrome```.

You can change the list of keywords applied to your images by finding the line that starts with ```set bwKeywords to``` and changing the list of keywords to words of your choosing for your monochrome images. Remember that each keyword must be in double quotes, the list must be comma-separated, and there must be curly braces enclosing the list as shown here.

```
set bwKeywords to { "Black & White", "Monochrome" }
```

You may ask why the script only looks at the background layer for the saturation adjustment value of -100. The background layer contains no mask. It always applies the adjustment globally to the entire image. Other layers may have masks that do not cover the entire image. We therefore cannot assume these other layers result in a monochrome image.

# Usage

Follow these steps to execute this script:

1. Download the file [apply-keyword-to-bw.applescript](apply-keyword-to-bw.applescript) to your macOS system.
2. Open the Capture One catalog you want to update and select the All Images collection.
3. Open script in Apple ScriptEditor.
4. Make any desired changes to the list of keywords applied.
5. Run the script by pressing the "Run" button (looks like a "Play" button).

When the script is completed, it will show a list of image names in the results window.

# Watch It Run

Before you run the script, open the Filters tool in Capture One and scroll down to the Keywords filter. Scroll down the list of keywords to your black and white keyword. Now press the "Run this script" button in Script Editor. You will see the counter for your chosen keywords go up as this script finds and applies your keywords to each image that has the Black and White tool enabled (checkbox) or saturation set to -100.
