(*
	Original: Kim Aldis	 2016
	Modified:	 Walter Rowe 2019
	Source: https://github.com/walterrowe/add_border
*)

(* TO FILTER FOR IMAGE FILES, LOOK FOR QUICKTIME SUPPORTED IMAGE FORMATS *)
property type_list : {"JPEG", "TIFF", "PNGf", "8BPS", "BMPf", "GIFf", "PDF ", "PICT"}
property extension_list : {"jpg", "jpeg", "tif", "tiff", "png", "psd", "bmp", "gif", "jp2", "pdf", "pict", "pct", "sgi", "tga"}
property typeIDs_list : {"public.jpeg", "public.tiff", "public.png", "com.adobe.photoshop-image", "com.microsoft.bmp", "com.compuserve.gif", "public.jpeg-2000", "com.adobe.pdf", "com.apple.pict", "com.sgi.sgi-image", "com.truevision.tga-image"}
property padding : 4 --set interior border width to 2 pixel on each side - total of 4 pixels 

on open these_items
	repeat with this_item in these_items
		set item_info to info for this_item
		
		(* get the properties of the current file we are processing as an array theoretically faster *)
		try
			set {this_filename, this_extension, this_filetype, this_typeID} to {name, name extension, file type, type identifier} of item_info
		on error
			set {this_filename, this_extension, this_filetype, this_typeID} to {"", "", "", ""}
		end try
		
		(* get the POSIX path of the current file we are processing *)
		set this_path to quoted form of POSIX path of this_item
		
		
		
		(* only process if we support the image type *)
		if ((this_filetype is in type_list) or (this_extension is in extension_list) or (this_typeID is in typeIDs_list)) then
			try
				(* extract the x/y dimensions in pixels *)
				set theRes to (do shell script ("sips -g pixelHeight -g pixelWidth " & this_path as string))
				set {y, x} to {last word of second paragraph, last word of last paragraph} of theRes
				
				(* set absolute image width and height to include ÒinteriorÓ white border edge *)
				set pixelHeight to y + padding
				set pixelWidth to x + padding
				
				(* increase image dimensions by padding pixels to add white border *)
				
				try
					do shell script "sips " & this_path & " -p " & pixelHeight & " " & pixelWidth & " --padColor ffffff -i"
				on error errStr number errorNumber
					display dialog "Droplet ERROR: " & errStr & ": " & (errorNumber as text) & "on file " & this_filename
				end try
				
				(* this uses shortest edge to calculate 4% border width, swap the two formulas to use longest edge *)
				if x is greater than y then -- set outer border width to 2% of shortest edge in pixels
					set padding to padding + (padding / 100 * y)
				else
					set padding to padding + (padding / 100 * x)
				end if
				
				(* now set absolute image width and height to include black border *)
				set pixelHeight to y + padding
				set pixelWidth to x + padding
				
				(* increase image dimensions by ÒpaddingÓ pixels to add black border *)
				set theSIP to do shell script "sips " & this_path & " -p " & pixelHeight & " " & pixelWidth & " --padColor 000000 -i"
				
			on error errStr number errorNumber
				display dialog "Droplet ERROR: " & errStr & ": " & (errorNumber as text) & "on file " & this_filename
			end try
			
		end if
	end repeat
end open
