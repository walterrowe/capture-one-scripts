# Purge Denoise Proxies

**Donations**: if you like to keep these scripts free please consider [buying me a coffee](https://buymeacoffee.com/walterrowe).

## Summary

This utility finds and moves Capture One denoise proxies to the System Trash to reclaim their space.

## Description

Enhanced Denoise was introduced in Capture One 16.8. When enabled Capture One creates a "noise reduced" proxy of the original raw file. The proxy is stored in the same folder as the image preview and has a ".conoisereduced" extension. The format of the proxy filename is the full raw file name on disk plus this extension (e.g. "WPR-20260503-9437.NEF.conoisereduced"). Each proxy is approximately the same size as the original raw file. If you enable this feature on large numbers of files it will dramatically increase the amount of space consumed by your catalog or session. If you enable it and then disable it, the proxy remains. The benefit of it remaining is that you won't have to wait to regenerate it. The downside is the space is consumed even if decide you don't want enhanced denoise on an image after trying it.

Capture One will regenerate each denoise proxy as needed much like normal image previews. After you complete your job and deliver your final output it is perfectly safe to remove these proxies until you need them again. Since Capture One does not provide this feature natively I wrote this macOS utility to help you purge the denoise proxies by moving them to the System Trash. You can restore any of the proxies you choose by opening the Trash and using the "Put Back" feature.

**NOTE**: _The space consumed by these proxies will not be reclaimed until you permanently delete the proxies from the System Trash_.

**SUGGESTION**: Enable Enhanced Denoise only on your best images that truly benefit from it. Apply your adjustments and export your finished work. Once you have delivered your work you can safely remove the denoise proxies until you need them again. Capture One will regenerate them as needed.

- If any variants are selected then only the denoise proxies for those variants are included and moved to Trash
- If no variants are selected then ALL denoise proxies that are found are included and moved to Trash

The script searches for all the denoise proxies in the open session or catalog. You are shown the number of proxies found and total space consumed, and then asked for confirmation to proceed.

![](assets/Purge-Denoise-Confirm.png)

If you proceed, then the proxies are moved to the System Trash and a confirmation is given when complete.

![](assets/Purge-Denoise-Complete.png)

## Prerequisites

None

# Installation

The script self-installs in your Capture One Scripts folder.

1. Open the AppleScript file in macOS Script Editor.
1. Click the "Run this script" (&#9654;) button.
1. Open Capture One and choose Scripts > Update Script Menu.
1. You now can run the script from the Capture One Scripts menu.

## Compatibility

The utility has been tested on:

- macOS Tahoe (Apple M3 and M4 systems)
- Capture One 16.8

## ChangeLog

- 28 May 2026 - initial version
