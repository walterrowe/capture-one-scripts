# Time Lapse Smoothing

**Donations**: if you like to keep these scripts free please consider [buying me a coffee](https://buymeacoffee.com/walterrowe).

## Description

Time Lapse Smoothing enables you to quickly and efficiently adjust the exposure and white balance temperature across an entire time lapse sequence of exposure sets to achieve that smooth gradation of exposure and white balance.

### Exposure Smoothing

In a time lapse sequence the ambient light and the light color temperature change near linearly as the sun rises or sets. The photographer cannot match this linear progression because cameras can only change exposure in fixed increments of 1/3rd stop or more. The photographer is forced to capture multiple exposure sets at fixed stop increments of increasing or decreasing shutter speeds to compensate for a setting or rising sun. Where the camera's exposure changes for the next frame set the images reflect a non-linear "jump" or "drop" in the exposure.

If you take a 300-frame time lapse sequence and increase or decrease the exposure time (shutter speed) by 1/3rd of a stop every 10 frames, you end up with 30 sets of 10 frames each. Each frame in a frame set will have the same exposure. The exposure time in each successive frame set will change by the increment programmed into the camera until the entire time lapse sequence has been captured. Where the camera's exposure setting changes at each new frame set you see a dramatic jump or drop in light when you view the images on your computer.

The script steps through every frame in the time lapse sequence, setting the Capture One exposure of each frame to linearly smooth out this jump or drop to match how the natural light changes.

### White Balance Smoothing

As the sun rises or sets, the camera's white balance must change to match the changing light. We can't program the camera to do that so we must do it in post processing. Prior to running this script you will set the correct white balance for the first and last frame of the time lapse sequence. The script gets the difference in temperature between the first and last frame and divides it by the total number of frames in the sequence. This gives you a temperature delta to apply frame to frame starting with the first frame's temperature all the way to the last frame's temperature.

Imagine you set the white balance temperature of the first frame to 5200 Kelvin and the last frame to 3100 Kelvin. The difference is 2100 Kelvin. If you have a 300-frame sequence, and divide 2100 Kelvin by 300 frames, you get 70 Kelvin per frame you need to apply linearly from first to last frame. The first frame will have no WB change (5200K). The second frame will have the WB of the first frame adjusted by -70 (5030K). The third frame will have the WB of the second frame adjusted by -70 (4960K). This progresses across the entire sequence down to the last frame's 3100K.

This smooths out the white balance temperature of the time lapse sequence to match how the natural light changes.

## Prerequisites

None.

## Installation

The script self-installs in your Capture One Scripts folder.

1. Open the AppleScript file in macOS Script Editor.
1. Click the "Run this script" (&#9654;) button.
1. Open Capture One and choose Scripts > Update Script Menu.
1. You now can run the script from the Capture One Scripts menu.

## How To Use

Set the white balance temperature of the first and last frame for the entire time lapse sequence, select ALL frames of the entire time lapse sequence, then run the script.

Time Lapse Smoothing assumes that every exposure set across a time lapse sequence has the same number of images (eg. 10 frames at 2 secs, 10 frames at 4 secs, 10 frames at 6 secs, etc).

The script attempts to determine how many frames are in each exposure set by searching for  the first change in exposure time (shutter speed). It then asks for confirmation for this number and allows you change it if it is incorrect.

The script then asks for the exposure increment in stops (between -1 and +1 in 1/3 increments).

Using the number of frames in each exposure set and exposure increment, and the white balance temperature of the first and last frame of the entire sequence, the script then adjusts the color temperature and exposure of each frame to linearly smooth them out across the entire time lapse sequence.

A pop-up dialog will appear when it is done showing how long it took and how many frames were adjusted.

## Compatibility

The utility has been tested on:

- macOS Sequoia
- Capture One 16.5

## ChangeLog

- 24 Jan 2025 - initial version
